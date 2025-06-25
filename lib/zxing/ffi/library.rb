require 'ffi'

module ZXing; end
module ZXing::FFI; end

module ZXing::FFI::Library
  extend ::FFI::Library
  
  begin
    lib = File.join File.dirname(__FILE__), "..", "..", "..", "ext"
    lib = File.expand_path lib
    ffi_lib ::FFI::Library::LIBC, Dir[lib.to_s+"/zxing/zxing.{bundle,dylib,so,dll,sl}"][0]
  rescue LoadError
    raise LoadError, "Could not load zxing.so. Please run 'rake compile' first."
  end

  # 基本内存管理
  attach_function 'free', [:pointer], :void

  # ImageFormat 枚举
  enum :image_format, [
    :lum, 0x01000000,
    :rgba, 0x04000102,
    :bgra, 0x04020100,
    :rgb, 0x03000102,
    :bgr, 0x03020100
  ]

  # BarcodeFormat 枚举
  enum :barcode_format, [
    :none, 0,
    :aztec, 1,
    :codabar, 2,
    :code39, 4,
    :code93, 8,
    :code128, 16,
    :datamatrix, 32,
    :ean8, 64,
    :ean13, 128,
    :itf, 256,
    :maxicode, 512,
    :pdf417, 1024,
    :qrcode, 2048,
    :databar, 4096,
    :databar_expanded, 8192,
    :upca, 16384,
    :upce, 32768,
    :micro_qrcode, 65536,
    :rmqr_code, 131072,
    :dx_film_edge, 262144
  ]

  # 核心解码函数
  attach_function :decode_barcode, [
    :pointer,    # data
    :int,        # width
    :int,        # height
    :image_format, # format
    :bool,       # tryHarder
    :bool,       # tryRotate
    :bool        # tryInvert
  ], :pointer

  attach_function :decode_barcodes, [
    :pointer,    # data
    :int,        # width
    :int,        # height
    :image_format, # format
    :bool,       # tryHarder
    :bool,       # tryRotate
    :bool        # tryInvert
  ], :pointer

  # Barcode 结果处理
  attach_function :Barcode_delete, [:pointer], :void
  attach_function :Barcode_isValid, [:pointer], :bool
  attach_function :Barcode_format, [:pointer], :int
  attach_function :Barcode_text, [:pointer], :string
  attach_function :Barcode_formatName, [:pointer], :string
  attach_function :Barcode_error, [:pointer], :string

  # Barcodes 集合处理
  attach_function :Barcodes_delete, [:pointer], :void
  attach_function :Barcodes_size, [:pointer], :int
  attach_function :Barcodes_at, [:pointer, :int], :pointer

  # 内存管理
  attach_function :free_string, [:string], :void

  # ImageFormat 枚举值获取
  attach_function :ImageFormat_Lum, [], :int
  attach_function :ImageFormat_RGB, [], :int
  attach_function :ImageFormat_BGR, [], :int
  attach_function :ImageFormat_RGBA, [], :int
  attach_function :ImageFormat_BGRA, [], :int

  # BarcodeFormat 枚举值获取
  attach_function :BarcodeFormat_QRCode, [], :int
  attach_function :BarcodeFormat_DataMatrix, [], :int
  attach_function :BarcodeFormat_Aztec, [], :int
  attach_function :BarcodeFormat_PDF417, [], :int
  attach_function :BarcodeFormat_Code128, [], :int
  attach_function :BarcodeFormat_Code39, [], :int
  attach_function :BarcodeFormat_EAN13, [], :int
  attach_function :BarcodeFormat_EAN8, [], :int
  attach_function :BarcodeFormat_UPCA, [], :int
  attach_function :BarcodeFormat_UPCE, [], :int

  # 自动指针类用于内存管理
  class BarcodePointer < FFI::AutoPointer
    def self.release ptr
      ZXing::FFI::Library::Barcode_delete ptr unless ptr.null?
    end
  end

  class BarcodesPointer < FFI::AutoPointer
    def self.release ptr
      ZXing::FFI::Library::Barcodes_delete ptr unless ptr.null?
    end
  end
end


