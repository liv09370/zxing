module ZXing; end
module ZXing::FFI; end

class ZXing::FFI::Binarizer
  include ZXing::Binarizer
  def initialize ptr, source
    super ZXing::FFI::Library::BinarizerPointer.new ptr
    @source = source
  end
  attr_reader :source
  def black_matrix
    ZXing::FFI::Common::BitMatrix.new ZXing::FFI::Library.Binarizer_black_matrix(native)
  end
  def image
    require 'mini_magick'
    require 'tempfile'
    
    width = source.width
    height = source.height
    
    # Create PBM (Portable Bitmap) format data for black and white
    pbm_data = "P1\n#{width} #{height}\n"
    (0...height).each do |row|
      (0...width).each do |column|
        bit = black_matrix.get(column, row) ? '1' : '0'
        pbm_data += "#{bit} "
      end
      pbm_data += "\n"
    end
    
    # Write PBM data to temp file and read as image
    temp_file = Tempfile.new(['binarizer', '.pbm'])
    temp_file.write(pbm_data)
    temp_file.close
    
    image = ::MiniMagick::Image.open(temp_file.path)
    
    temp_file.unlink
    
    return image
  end
end
