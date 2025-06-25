// -*- c-basic-offset:2 -*-

#include "ReadBarcode.h"
#include "ImageView.h"
#include "Barcode.h"
#include "BarcodeFormat.h"
#include "ReaderOptions.h"
#include "Error.h"

#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <stdexcept>

using namespace ZXing;

extern "C" {
  
  // 错误处理
  void* new_exception_data(const char* className, const char* message) {
    void** exception = (void**)malloc(sizeof(void*)*2);
    exception[0] = (void*)className;
    size_t size = strlen(message)+1;
    exception[1] = malloc(size);
    memcpy(exception[1], message, size);
    return (void*)((uintptr_t)exception | 1);
  }

  // 解码函数 - 新版本使用 ReadBarcode 函数
  void* decode_barcode(
    const unsigned char* data,
    int width,
    int height,
    ImageFormat format,
    bool tryHarder,
    bool tryRotate,
    bool tryInvert) {
    
    void* result = 0;
    try {
      ImageView image(data, width, height, format);
      ReaderOptions options;
      options.setTryHarder(tryHarder);
      options.setTryRotate(tryRotate);
      options.setTryInvert(tryInvert);
      
      Barcode barcode = ReadBarcode(image, options);
      
      if (barcode.isValid()) {
        result = new Barcode(std::move(barcode));
      } else {
        result = new_exception_data("ZXing::Error", barcode.error().msg().c_str());
      }
    } catch(const std::exception& e) {
      result = new_exception_data("std::exception", e.what());
    } catch(...) {
      result = new_exception_data("unknown", "Unknown error occurred");
    }
    return result;
  }

  // 解码多个条码
  void* decode_barcodes(
    const unsigned char* data,
    int width,
    int height,
    ImageFormat format,
    bool tryHarder,
    bool tryRotate,
    bool tryInvert) {
    
    void* result = 0;
    try {
      ImageView image(data, width, height, format);
      ReaderOptions options;
      options.setTryHarder(tryHarder);
      options.setTryRotate(tryRotate);
      options.setTryInvert(tryInvert);
      
      Barcodes barcodes = ReadBarcodes(image, options);
      result = new Barcodes(std::move(barcodes));
    } catch(const std::exception& e) {
      result = new_exception_data("std::exception", e.what());
    } catch(...) {
      result = new_exception_data("unknown", "Unknown error occurred");
    }
    return result;
  }

  // Barcode 结果处理
  void Barcode_delete(void* barcode_ptr) {
    Barcode* barcode = (Barcode*)barcode_ptr;
    delete barcode;
  }

  bool Barcode_isValid(void* barcode_ptr) {
    Barcode* barcode = (Barcode*)barcode_ptr;
    return barcode->isValid();
  }

  int Barcode_format(void* barcode_ptr) {
    Barcode* barcode = (Barcode*)barcode_ptr;
    return static_cast<int>(barcode->format());
  }

  char* Barcode_text(void* barcode_ptr) {
    Barcode* barcode = (Barcode*)barcode_ptr;
    std::string text = barcode->text();
    char* result = (char*)malloc(text.length() + 1);
    strcpy(result, text.c_str());
    return result;
  }

  char* Barcode_formatName(void* barcode_ptr) {
    Barcode* barcode = (Barcode*)barcode_ptr;
    std::string name = ToString(barcode->format());
    char* result = (char*)malloc(name.length() + 1);
    strcpy(result, name.c_str());
    return result;
  }

  char* Barcode_error(void* barcode_ptr) {
    Barcode* barcode = (Barcode*)barcode_ptr;
    std::string error = barcode->error().msg();
    char* result = (char*)malloc(error.length() + 1);
    strcpy(result, error.c_str());
    return result;
  }

  // Barcodes 集合处理
  void Barcodes_delete(void* barcodes_ptr) {
    Barcodes* barcodes = (Barcodes*)barcodes_ptr;
    delete barcodes;
  }

  int Barcodes_size(void* barcodes_ptr) {
    Barcodes* barcodes = (Barcodes*)barcodes_ptr;
    return barcodes->size();
  }

  void* Barcodes_at(void* barcodes_ptr, int index) {
    Barcodes* barcodes = (Barcodes*)barcodes_ptr;
    if (index >= 0 && index < barcodes->size()) {
      return new Barcode((*barcodes)[index]);
    }
    return nullptr;
  }

  // 内存清理
  void free_string(char* str) {
    if (str) {
      free(str);
    }
  }

  // ImageFormat 枚举值
  int ImageFormat_Lum() {
    return static_cast<int>(ImageFormat::Lum);
  }

  int ImageFormat_RGB() {
    return static_cast<int>(ImageFormat::RGB);
  }

  int ImageFormat_BGR() {
    return static_cast<int>(ImageFormat::BGR);
  }

  int ImageFormat_RGBA() {
    return static_cast<int>(ImageFormat::RGBA);
  }

  int ImageFormat_BGRA() {
    return static_cast<int>(ImageFormat::BGRA);
  }

  // BarcodeFormat 枚举值
  int BarcodeFormat_QRCode() {
    return static_cast<int>(BarcodeFormat::QRCode);
  }

  int BarcodeFormat_DataMatrix() {
    return static_cast<int>(BarcodeFormat::DataMatrix);
  }

  int BarcodeFormat_Aztec() {
    return static_cast<int>(BarcodeFormat::Aztec);
  }

  int BarcodeFormat_PDF417() {
    return static_cast<int>(BarcodeFormat::PDF417);
  }

  int BarcodeFormat_Code128() {
    return static_cast<int>(BarcodeFormat::Code128);
  }

  int BarcodeFormat_Code39() {
    return static_cast<int>(BarcodeFormat::Code39);
  }

  int BarcodeFormat_EAN13() {
    return static_cast<int>(BarcodeFormat::EAN13);
  }

  int BarcodeFormat_EAN8() {
    return static_cast<int>(BarcodeFormat::EAN8);
  }

  int BarcodeFormat_UPCA() {
    return static_cast<int>(BarcodeFormat::UPCA);
  }

  int BarcodeFormat_UPCE() {
    return static_cast<int>(BarcodeFormat::UPCE);
  }
}

