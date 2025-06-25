module ZXing
  autoload :Common, 'zxing/common'

  autoload :FFI, 'zxing/ffi'
  autoload :MiniMagick, 'zxing/mini_magick'

  autoload :Image, 'zxing/image'
  autoload :Decodable, 'zxing/decodable'

  autoload :Reader, 'zxing/reader'
  autoload :MultiFormatReader, 'zxing/multi_format_reader'
  autoload :Result, 'zxing/result'
  autoload :LuminanceSource, 'zxing/luminance_source'
  autoload :BinaryBitmap, 'zxing/binary_bitmap'
  autoload :Binarizer, 'zxing/binarizer'

  autoload :Exception, 'zxing/exception'
  autoload :BadImageException, 'zxing/bad_image_exception'
  autoload :NotFoundException, 'zxing/not_found_exception'
  autoload :ReedSolomonException, 'zxing/reed_solomon_exception'
  autoload :ReaderException, 'zxing/reader_exception'
  autoload :IllegalArgumentException, 'zxing/illegal_argument_exception'
  autoload :ChecksumException, 'zxing/checksum_exception'
  autoload :FormatException, 'zxing/format_exception'

  autoload :DataMatrix, 'zxing/datamatrix'
  autoload :OneD, 'zxing/oned'
  autoload :Common, 'zxing/common'
  autoload :PDF417, 'zxing/pdf417'
  autoload :QRCode, 'zxing/qrcode'
  autoload :Aztec, 'zxing/aztec'

  # Load version information
  require 'zxing/version'

  def decode *args
    begin
      # 检查参数有效性
      if args.length > 0 && args[0].is_a?(String)
        path = args[0]
        # 空字符串或不存在的文件返回 nil
        if path.empty? || !File.exist?(path)
          return nil
        end
      end
      
      decode!(*args)
    rescue Exception => e
      nil
    end
  end

  def decode! argument, options = {}
    # 读取图像
    image = Image.read argument
    
    # 创建 LuminanceSource
    source = LuminanceSource.new image
    
    # 使用新的 MultiFormatReader 直接解码
    reader_options = {
      try_harder: options.fetch(:try_harder, false),
      try_rotate: options.fetch(:try_rotate, false),
      try_invert: options.fetch(:try_invert, false)
    }
    
    reader = ZXing::FFI::MultiFormatReader.new(reader_options)
    result = reader.decode(source)
    
    result ? result.text : nil
  end

  def decode_all argument, options = {}
    # 读取图像
    image = Image.read argument
    
    # 创建 LuminanceSource
    source = LuminanceSource.new image
    
    # 使用新的 MultiFormatReader 解码所有条码
    reader_options = {
      try_harder: options.fetch(:try_harder, false),
      try_rotate: options.fetch(:try_rotate, false),
      try_invert: options.fetch(:try_invert, false)
    }
    
    reader = ZXing::FFI::MultiFormatReader.new(reader_options)
    results = reader.decode_all(source)
    
    results.map(&:text)
  end

  module_function :decode, :decode!, :decode_all

end
