module ZXing; end
module ZXing::FFI; end

class ZXing::FFI::Common::GreyscaleLuminanceSource
  attr_reader :width, :height, :data

  def initialize(grey_data, width, height)
    @width = width
    @height = height
    @data = grey_data
    
    # 确保数据是正确的格式
    if @data.is_a?(String)
      @data = @data.bytes
    end
    
    # 验证数据大小
    expected_size = @width * @height
    if @data.size != expected_size
      raise ArgumentError, "Data size (#{@data.size}) doesn't match width*height (#{expected_size})"
    end
  end

  def self.new_from_rgb_data(rgb_data, width, height)
    # 将 RGB 数据转换为灰度
    grey_data = []
    rgb_data.each_slice(3) do |r, g, b|
      # 使用标准的 RGB 到灰度转换公式
      grey = (0.299 * r + 0.587 * g + 0.114 * b).round
      grey_data << [grey, 255].min
    end
    
    new(grey_data, width, height)
  end

  def self.new_from_rgba_data(rgba_data, width, height)
    # 将 RGBA 数据转换为灰度
    grey_data = []
    rgba_data.each_slice(4) do |r, g, b, a|
      # 使用标准的 RGB 到灰度转换公式，忽略 alpha
      grey = (0.299 * r + 0.587 * g + 0.114 * b).round
      grey_data << [grey, 255].min
    end
    
    new(grey_data, width, height)
  end

  def to_memory_pointer
    # 创建 FFI 内存指针
    ptr = ::FFI::MemoryPointer.new(:uchar, @data.size)
    ptr.write_array_of_uchar(@data)
    ptr
  end

  def image_format
    :lum
  end

  def pixel_stride
    1
  end

  def row_stride
    @width
  end

  def image
    require 'mini_magick'
    require 'tempfile'
    
    # Get the intensity data
    intensity_data = matrix.get_array_of_char(0, width*height).map{|v| v << 8}
    
    # Create PGM (Portable GrayMap) format data
    pgm_data = "P2\n#{width} #{height}\n65535\n"
    intensity_data.each_slice(width) do |row|
      pgm_data += row.join(' ') + "\n"
    end
    
    # Write to temporary file and read as MiniMagick image
    temp_file = Tempfile.new(['luminance', '.pgm'])
    temp_file.write(pgm_data)
    temp_file.close
    
    image = ::MiniMagick::Image.open(temp_file.path)
    
    temp_file.unlink
    
    return image
  end
end
