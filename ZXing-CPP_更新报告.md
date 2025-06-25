# ZXing-C++ 更新报告

## 更新概述

成功将项目从旧版本的 zxing-cpp 更新到最新的官方版本。

### 主要变更

#### 1. 更新 zxing-cpp 依赖
- **旧版本**: 来自 `glassechidna/zxing-cpp` 的旧版本
- **新版本**: 最新的官方 `zxing-cpp/zxing-cpp` 版本
- **更新时间**: 2025-01-25

#### 2. API 架构变更
- **旧 API**: 基于 Reader/Binarizer/BinaryBitmap 的复杂架构
- **新 API**: 基于 ReadBarcode/ImageView 的简化架构
- **优势**: 更简洁、更高效、更现代的 C++20 实现

#### 3. 核心文件更新

##### C++ 扩展 (ext/zxing/zxing.cc)
- 完全重写以适配新的 API
- 使用 `ReadBarcode()` 和 `ImageView` 替代旧的接口
- 简化的错误处理和内存管理
- 支持新的 `ReaderOptions` 配置

##### FFI 绑定 (lib/zxing/ffi/)
- **library.rb**: 移除所有旧的函数绑定，添加新的 API 绑定
- **multi_format_reader.rb**: 重写以使用新的解码函数
- **common/greyscale_luminance_source.rb**: 适配新的 ImageView 架构

##### 构建配置 (ext/zxing/extconf.rb)
- 更新 CMake 配置以适配新版本的构建选项
- 使用 `ZXING_READERS=ON` 等新的配置选项
- 优化编译性能

### 新功能特性

#### 1. 更好的性能
- 使用 C++20 的现代特性
- 更高效的内存管理
- 优化的算法实现

#### 2. 增强的格式支持
新版本支持更多的条码格式：
- QR Code (包括 Micro QR Code, rMQR Code)
- DataMatrix
- Aztec
- PDF417
- Code 128/39/93
- EAN-8/13
- UPC-A/E
- DataBar 系列
- MaxiCode (部分支持)

#### 3. 改进的选项配置
```ruby
ZXing.decode('image.png', {
  try_harder: true,    # 更努力地尝试解码
  try_rotate: true,    # 尝试旋转图像
  try_invert: true     # 尝试反转图像
})
```

#### 4. 多条码解码
```ruby
# 解码图像中的所有条码
results = ZXing.decode_all('image.png')
```

### 兼容性

#### 保持的功能
- ✅ 基本的 QR 码解码
- ✅ 图像读取和处理
- ✅ MiniMagick 集成
- ✅ 向后兼容的 API

#### 移除的功能
- ❌ 旧的 Reader/Binarizer 架构
- ❌ 一些过时的配置选项
- ❌ 旧的错误处理机制

### 测试结果

```
🎉 ZXing-C++ 新版本测试
==================================================
✅ 图像读取: 1355x889
✅ 图像旋转: 889x1355
✅ QR解码: http://rubyflow.com
✅ QR解码(try_harder): http://rubyflow.com
✅ 连续解码: 5/5 成功
✅ 解码所有条码: 1 个结果
==================================================
```

### 技术细节

#### 新的 C++ 接口
```cpp
// 新 API
ImageView image(data, width, height, ImageFormat::Lum);
ReaderOptions options;
Barcode barcode = ReadBarcode(image, options);

// 旧 API (已移除)
GreyscaleLuminanceSource* source = new GreyscaleLuminanceSource(...);
HybridBinarizer* binarizer = new HybridBinarizer(source);
BinaryBitmap* bitmap = new BinaryBitmap(binarizer);
```

#### 内存管理改进
- 自动指针管理
- 减少内存泄漏风险
- 更好的异常安全性

### 构建要求

#### 系统要求
- CMake 3.16+
- C++20 兼容编译器 (gcc 11+ / clang 12+ / VS 2019 16.10+)
- Ruby 2.7+
- FFI gem

#### 构建命令
```bash
cd ext/zxing
ruby extconf.rb
make
```

### 总结

这次更新将项目迁移到了现代化的 zxing-cpp 版本，带来了：

1. **更好的性能**: 现代 C++20 实现
2. **更简洁的 API**: 减少了复杂性
3. **更好的维护性**: 跟随官方开发
4. **增强的功能**: 支持更多格式和选项
5. **向后兼容**: 保持现有 Ruby API 不变

项目现在使用最新的 zxing-cpp 版本，为未来的发展奠定了坚实的基础。 