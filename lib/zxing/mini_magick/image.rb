require 'mini_magick'

module ZXing; end
module ZXing::MiniMagick; end

class ZXing::MiniMagick::Image
  include ZXing::Image

  # 内部 LuminanceSource 类
  class LuminanceSource < ZXing::FFI::Common::GreyscaleLuminanceSource
    def initialize(image)
      # 从 MiniMagick 图像提取灰度数据
      gray_data = image.gray
      width = image.width
      height = image.height
      
      # 调用父类构造函数
      super(gray_data, width, height)
    end
  end

  def self.read argument
    img = nil

    if argument.is_a? String
      if argument.encoding.name == Encoding.aliases['BINARY']
        begin
          img = ::MiniMagick::Image.read(argument)
        rescue Exception => e
          # Because 'BINARY' is just an alias for ASCII-8BIT, if treating the
          # argument as image blob failed, we should continue on and try treat
          # the argument like a regular string.
        end
      end
    end

    if img.nil?
      require 'uri'
      require 'pathname'

      uri = URI.parse(argument.respond_to?(:path) ? argument.path : argument.to_s)

      if uri.scheme.nil?
        uri.scheme = "file"
        uri.path = Pathname.new(uri.path).realpath.to_s
      end

      begin
        img = case uri.scheme
                when "file"; ::MiniMagick::Image.open(uri.path)
                else; ::MiniMagick::Image.read(fetch(uri).body)
              end
      rescue Exception => e
        raise ZXing::BadImageException.new e.message
      end
    end

    # Convert to RGB colorspace (equivalent to RMagick's colorspace = RGBColorspace)
    img.colorspace('RGB') if img.colorspace != 'RGB'

    self.new img
  end

  def rotate angle
    rotated_img = @native.clone
    rotated_img.rotate(angle)
    self.class.new rotated_img
  end

  def resize geometry
    resized_img = @native.clone
    resized_img.resize(geometry)
    self.class.new resized_img
  end

  def width
    @native.width
  end

  def height
    @native.height
  end

  def gray
    require 'tempfile'
    
    # Get dimensions first
    img_width = @native.width
    img_height = @native.height
    
    # Convert to grayscale
    gray_img = @native.clone
    gray_img.colorspace('Gray')
    gray_img.depth(8)
    
    # Use PGM format to get raw pixel data - this is more reliable
    temp_file = nil
    
    begin
      temp_file = Tempfile.new(['gray_pixels', '.pgm'])
      temp_file.close
      
      # Export as PGM (Portable GrayMap) format
      gray_img.format('pgm')
      gray_img.write(temp_file.path)
      
      # Read the PGM file and extract pixel data
      pgm_content = File.read(temp_file.path, mode: 'rb')
      
      # Parse PGM header to find where pixel data starts
      lines = pgm_content.split("\n")
      header_lines = 0
      
      lines.each_with_index do |line, index|
        header_lines = index + 1
        # Skip comments (lines starting with #)
        next if line.start_with?('#')
        
        # Found the maxval line (after width/height), pixel data follows
        if index >= 2 && line.match(/^\d+$/)
          break
        end
      end
      
      # Extract just the pixel data part
      header_size = lines[0...header_lines].join("\n").length + 1
      pixel_data = pgm_content[header_size..-1]
      
      # Ensure we have the right amount of data
      expected_size = img_width * img_height
      if pixel_data && pixel_data.length >= expected_size
        return pixel_data[0, expected_size]
      else
        # Fallback: create zero-filled data
        return "\x00" * expected_size
      end
      
    rescue => e
      # Fallback: return zero-filled data if anything goes wrong
      return "\x00" * (img_width * img_height)
    ensure
      # 确保清理临时文件
      if temp_file
        temp_file.unlink rescue nil
        temp_file.close rescue nil
      end
    end
  end

  private

  def initialize native
    @native = native
  end

  def self.fetch(uri, limit = 10)
    # You should choose better exception.
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    require 'net/http'

    response = Net::HTTP.get_response(uri)
    case response
    when Net::HTTPSuccess; response
    when Net::HTTPRedirection
      fetch(URI.parse(response['location']), limit-1)
    else
      response.error!
    end
  end
end 