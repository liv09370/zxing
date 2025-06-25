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
  
  # 确保动态库正确加载
  def self.ensure_extension_loaded
    # 检查是否存在动态库文件
    ext_paths = [
      File.join(File.dirname(__FILE__), 'zxing', 'zxing.so'),
      File.join(File.dirname(__FILE__), 'zxing', 'zxing.bundle'),
      File.join(File.dirname(__FILE__), 'zxing', 'zxing.dll')
    ]
    
    existing_ext = ext_paths.find { |path| File.exist?(path) }
    
    if existing_ext
      puts "✅ 找到动态库: #{existing_ext}" if $DEBUG
      return true
    else
      puts "❌ 未找到编译的动态库文件"
      puts "🔧 尝试自动编译..."
      
      # 尝试自动编译
      if try_compile_extension
        # 重新检查
        existing_ext = ext_paths.find { |path| File.exist?(path) }
        if existing_ext
          puts "✅ 自动编译成功: #{existing_ext}"
          return true
        end
      end
      
      puts "❌ 自动编译失败"
      puts "💡 请手动运行: bundle exec rake compile"
      raise LoadError, "ZXing 动态库未编译或未找到"
    end
  end
  
  def self.try_compile_extension
    # 查找扩展目录
    gem_root = File.expand_path('..', File.dirname(__FILE__))
    ext_dir = File.join(gem_root, 'ext', 'zxing')
    
    return false unless File.exist?(ext_dir)
    
    puts "📁 扩展目录: #{ext_dir}"
    
    Dir.chdir(ext_dir) do
      # 运行 extconf.rb
      puts "🔧 运行 extconf.rb..."
      return false unless system('ruby extconf.rb > /dev/null 2>&1')
      
      # 编译
      puts "🔨 编译扩展..."
      return false unless system('make > /dev/null 2>&1')
      
      # 复制到 lib 目录
      so_file = Dir.glob('zxing.{so,bundle}').first
      if so_file
        lib_dir = File.join(gem_root, 'lib', 'zxing')
        require 'fileutils'
        FileUtils.mkdir_p(lib_dir)
        FileUtils.cp(so_file, lib_dir)
        puts "✅ 扩展编译成功"
        return true
      end
    end
    
    false
  end
  
  # 在模块加载时确保扩展可用
  ensure_extension_loaded

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
