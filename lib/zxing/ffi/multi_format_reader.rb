module ZXing; end
module ZXing::FFI; end

class ZXing::FFI::MultiFormatReader
  # 简单的结果类
  class Result
    attr_reader :text, :format

    def initialize(text, format)
      @text = text
      @format = format
    end
  end

  def initialize(options = {})
    @try_harder = options.fetch(:try_harder, false)
    @try_rotate = options.fetch(:try_rotate, false) 
    @try_invert = options.fetch(:try_invert, false)
  end

  def decode(luminance_source)
    # 获取图像数据
    data_ptr = luminance_source.to_memory_pointer
    width = luminance_source.width
    height = luminance_source.height
    format = luminance_source.image_format

    # 调用新的解码函数
    result_ptr = ZXing::FFI::Library.decode_barcode(
      data_ptr,
      width,
      height,
      format,
      @try_harder,
      @try_rotate,
      @try_invert
    )

    if result_ptr.null?
      return nil
    end

    # 检查是否是异常
    if (result_ptr.address & 1) != 0
      # 这是一个异常
      exception_ptr = ::FFI::Pointer.new(result_ptr.address & ~1)
      exception_data = exception_ptr.read_array_of_pointer(2)
      class_name = exception_data[0].read_string
      message = exception_data[1].read_string
      
      # 清理异常内存
      exception_data[1].free
      exception_ptr.free
      
      case class_name
      when "ZXing::Error"
        raise ZXing::NotFoundError, message
      else
        raise ZXing::ReaderException, "#{class_name}: #{message}"
      end
    end

    # 检查条码是否有效
    unless ZXing::FFI::Library.Barcode_isValid(result_ptr)
      error_msg = ZXing::FFI::Library.Barcode_error(result_ptr)
      ZXing::FFI::Library.Barcode_delete(result_ptr)
      raise ZXing::NotFoundError, error_msg
    end

    # 提取结果数据
    text = ZXing::FFI::Library.Barcode_text(result_ptr)
    format_name = ZXing::FFI::Library.Barcode_formatName(result_ptr)
    
    # 创建结果对象
    result = Result.new(text, format_name)
    
    # 清理内存
    ZXing::FFI::Library.Barcode_delete(result_ptr)
    
    result
  rescue => e
    # 确保清理内存
    ZXing::FFI::Library.Barcode_delete(result_ptr) if result_ptr && !result_ptr.null?
    raise e
  ensure
    # 清理数据指针
    data_ptr.free if data_ptr
  end

  def decode_all(luminance_source)
    # 获取图像数据
    data_ptr = luminance_source.to_memory_pointer
    width = luminance_source.width
    height = luminance_source.height
    format = luminance_source.image_format

    # 调用新的解码多个条码函数
    results_ptr = ZXing::FFI::Library.decode_barcodes(
      data_ptr,
      width,
      height,
      format,
      @try_harder,
      @try_rotate,
      @try_invert
    )

    if results_ptr.null?
      return []
    end

    # 检查是否是异常
    if (results_ptr.address & 1) != 0
      # 这是一个异常
      exception_ptr = ::FFI::Pointer.new(results_ptr.address & ~1)
      exception_data = exception_ptr.read_array_of_pointer(2)
      class_name = exception_data[0].read_string
      message = exception_data[1].read_string
      
      # 清理异常内存
      exception_data[1].free
      exception_ptr.free
      
      raise ZXing::ReaderException, "#{class_name}: #{message}"
    end

    # 获取结果数量
    count = ZXing::FFI::Library.Barcodes_size(results_ptr)
    results = []

    # 提取每个结果
    count.times do |i|
      barcode_ptr = ZXing::FFI::Library.Barcodes_at(results_ptr, i)
      next if barcode_ptr.null?

      if ZXing::FFI::Library.Barcode_isValid(barcode_ptr)
        text = ZXing::FFI::Library.Barcode_text(barcode_ptr)
        format_name = ZXing::FFI::Library.Barcode_formatName(barcode_ptr)
        results << Result.new(text, format_name)
      end

      ZXing::FFI::Library.Barcode_delete(barcode_ptr)
    end

    # 清理内存
    ZXing::FFI::Library.Barcodes_delete(results_ptr)
    
    results
  rescue => e
    # 确保清理内存
    ZXing::FFI::Library.Barcodes_delete(results_ptr) if results_ptr && !results_ptr.null?
    raise e
  ensure
    # 清理数据指针
    data_ptr.free if data_ptr
  end
end
