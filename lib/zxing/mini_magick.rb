module ZXing; end

module ZXing::MiniMagick
  def self.const_missing(name)
    if name == :Image
      require_relative 'mini_magick/image'
      const_get(name)
    else
      super
    end
  end
end 