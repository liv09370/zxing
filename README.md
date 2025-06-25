# ZXing-C++ Ruby Gem

[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%202.7-red.svg)](https://www.ruby-lang.org/)
[![ImageMagick](https://img.shields.io/badge/ImageMagick-6%20%7C%207-blue.svg)](https://imagemagick.org/)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](LICENSE)

现代化的 Ruby 条码识别库，基于最新的 zxing-cpp 官方版本，支持 ImageMagick 7。

## ✨ 特性

- 🚀 **ImageMagick 7 完全兼容** - 从 RMagick 迁移到 MiniMagick
- ⚡ **最新 zxing-cpp** - 使用官方最新版本，支持 C++20
- 🎯 **多种条码格式** - QR Code、DataMatrix、PDF417、Code 128 等
- 🔧 **多条码解码** - 单次解码图像中的所有条码
- 🛡️ **稳定可靠** - 改进的错误处理和内存管理

## 🚀 快速安装

### 推荐方式：

```bash
gem install specific_install
gem specific_install https://github.com/liv09370/zxing.git
```

### 或在 Gemfile 中：

```ruby
gem 'zxing_cpp', git: 'https://github.com/liv09370/zxing.git'
```

## 📖 快速开始

```ruby
require 'zxing'

# 基本解码
result = ZXing.decode('qrcode.png')
puts result  # => "http://example.com"

# 增强解码（适用于低质量图像）
result = ZXing.decode('blurry_qr.png', try_harder: true, try_rotate: true)

# 多条码解码
results = ZXing.decode_all('multiple_barcodes.png')
puts "找到 #{results.size} 个条码"
```

## 🎯 支持的格式

- QR Code / Micro QR Code
- DataMatrix
- PDF417 / MicroPDF417
- Aztec Code
- Code 128 / Code 39 / Code 93
- EAN-13 / EAN-8 / UPC-A / UPC-E
- ITF / Codabar
- RSS/DataBar 系列
- MaxiCode

## 📋 系统要求

- Ruby >= 2.7
- ImageMagick >= 6.0 (完全支持 ImageMagick 7)
- CMake >= 3.15
- C++ 编译器 (支持 C++17/C++20)

### Linux 依赖安装：

```bash
# Ubuntu/Debian
sudo apt-get install build-essential cmake ruby-dev imagemagick libmagick++-dev

# CentOS/RHEL/Fedora  
sudo dnf install gcc-c++ cmake ruby-devel ImageMagick ImageMagick-devel
```

### macOS 依赖安装：

```bash
xcode-select --install
brew install cmake imagemagick
```

## 🔥 v0.3.0 更新亮点

- ✅ **解决 ImageMagick 7 兼容性问题**
- ✅ **更新到最新官方 zxing-cpp**
- ✅ **完全重写 C++ 扩展使用现代 API**
- ✅ **新增 `decode_all` 多条码解码功能**
- ✅ **性能和稳定性大幅提升**

## 📚 使用示例

### 基本用法
```ruby
# 从文件解码
ZXing.decode('barcode.png')

# 从 URL 解码  
ZXing.decode('https://example.com/qr.png')

# 从二进制数据解码
image_data = File.read('qr.png', mode: 'rb')
ZXing.decode(image_data)
```

### 高级选项
```ruby
# 困难图像解码
ZXing.decode('difficult.png', 
            try_harder: true,    # 增强解码
            try_rotate: true,    # 尝试旋转
            try_invert: true)    # 尝试反色
```

### 多条码解码
```ruby
# 解码图像中所有条码
results = ZXing.decode_all('multiple_codes.png')
results.each_with_index do |code, i|
  puts "条码 #{i+1}: #{code}"
end
```

### 错误处理
```ruby
begin
  result = ZXing.decode('image.png')
  puts result || "未找到条码"
rescue ZXing::BadImageException => e
  puts "图像错误: #{e.message}"
end
```

## 🛠️ 开发

```bash
git clone https://github.com/liv09370/zxing.git
cd zxing
bundle install
bundle exec rake compile
bundle exec ruby test/test_zxing.rb
```

## 🐛 故障排除

查看 [安装指南](README_安装指南.md) 了解详细的故障排除步骤。

常见问题：
- ImageMagick 版本问题
- 编译依赖缺失  
- 权限配置问题

## 📞 支持

- [Issues](https://github.com/liv09370/zxing/issues) - 报告问题和建议
- [Wiki](https://github.com/liv09370/zxing/wiki) - 详细文档
- [Changelog](CHANGELOG.rdoc) - 版本历史

## 📄 许可证

基于 Apache 2.0 许可证发布。查看 [LICENSE](LICENSE) 了解详情。

## 🙏 致谢

- 基于 [zxing-cpp](https://github.com/zxing-cpp/zxing-cpp) 官方项目
- 感谢所有贡献者和用户的支持

---

⭐ 如果这个项目对你有帮助，请给个 Star！ 