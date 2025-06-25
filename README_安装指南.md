# ZXing-C++ Ruby Gem 安装指南

## 📦 从 GitHub 安装 ZXing-C++ v0.3.0

这是一个现代化的 Ruby 条码识别库，支持 QR 码、DataMatrix、PDF417 等多种条码格式。

### 🚀 快速安装

> **✨ v0.3.0 新特性**: 自动子模块初始化！现在使用任何安装方法都会自动检查和下载 zxing-cpp 源代码，无需手动处理子模块。

#### 方法1：从 GitHub 直接安装（推荐）

```bash
gem install specific_install
gem specific_install https://github.com/liv09370/zxing.git
```

#### 方法2：使用 Bundler（推荐用于项目）

在你的 `Gemfile` 中添加：

```ruby
gem 'zxing_cpp', git: 'https://github.com/liv09370/zxing.git'
```

然后运行：

```bash
bundle install
```

#### 方法3：手动构建安装

```bash
# 克隆仓库（包含子模块）
git clone --recursive https://github.com/liv09370/zxing.git
cd zxing

# 如果已经克隆，更新子模块
git submodule update --init --recursive

# 安装依赖
bundle install

# 构建并安装
rake build
gem install pkg/zxing_cpp-0.3.0.gem
```

### 📋 系统要求

#### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install build-essential cmake ruby-dev imagemagick libmagick++-dev
```

#### Linux (CentOS/RHEL/Fedora)
```bash
sudo dnf install gcc-c++ cmake ruby-devel ImageMagick ImageMagick-devel
# 或者对于较老的系统: sudo yum install ...
```

#### macOS
```bash
# 安装 Xcode 命令行工具
xcode-select --install

# 使用 Homebrew 安装依赖
brew install cmake imagemagick
```

#### Windows
```bash
# 使用 RubyInstaller DevKit
# 安装 ImageMagick for Windows
# 确保已安装 Visual Studio Build Tools
```

### 🔧 依赖项

- **Ruby**: >= 2.7
- **ImageMagick**: >= 6.0 (支持 ImageMagick 7)
- **CMake**: >= 3.15
- **C++ 编译器**: 支持 C++17/C++20

### ⚡ 快速验证

安装完成后，创建测试文件 `test_zxing.rb`：

```ruby
require 'zxing'

# 基本用法
result = ZXing.decode('path/to/qrcode.png')
puts "解码结果: #{result}"

# 增强选项
result = ZXing.decode('path/to/barcode.png', 
                     try_harder: true, 
                     try_rotate: true, 
                     try_invert: true)

# 多条码解码
results = ZXing.decode_all('path/to/image_with_multiple_barcodes.png')
puts "找到 #{results.size} 个条码: #{results}"
```

运行测试：
```bash
ruby test_zxing.rb
```

### 📚 使用示例

#### 基本 QR 码解码
```ruby
require 'zxing'

# 从文件解码
result = ZXing.decode('qrcode.png')
puts result  # => "http://example.com"

# 从 URL 解码
result = ZXing.decode('https://example.com/qrcode.png')

# 从二进制数据解码
image_data = File.read('qrcode.png', mode: 'rb')
result = ZXing.decode(image_data)
```

#### 高级选项
```ruby
# 增强解码（适用于低质量图像）
result = ZXing.decode('blurry_qr.png', try_harder: true)

# 尝试旋转图像
result = ZXing.decode('rotated_qr.png', try_rotate: true)

# 尝试反色
result = ZXing.decode('inverted_qr.png', try_invert: true)

# 组合多个选项
result = ZXing.decode('difficult_qr.png', 
                     try_harder: true,
                     try_rotate: true, 
                     try_invert: true)
```

#### 多条码解码
```ruby
# 解码图像中的所有条码
results = ZXing.decode_all('multiple_barcodes.png')
results.each_with_index do |result, index|
  puts "条码 #{index + 1}: #{result}"
end
```

#### 错误处理
```ruby
begin
  result = ZXing.decode('nonexistent.png')
  puts result || "未找到条码"
rescue ZXing::BadImageException => e
  puts "图像格式错误: #{e.message}"
rescue => e
  puts "解码失败: #{e.message}"
end
```

### 🎯 支持的条码格式

- QR Code / Micro QR Code
- DataMatrix
- PDF417 / MicroPDF417  
- Aztec
- Code 128
- Code 39
- Code 93
- Codabar
- EAN-13 / EAN-8
- UPC-A / UPC-E
- ITF (Interleaved 2 of 5)
- RSS/DataBar 系列
- MaxiCode

### 🔥 v0.3.0 新特性

- ✨ **ImageMagick 7 完全兼容** - 从 RMagick 迁移到 MiniMagick
- 🚀 **最新 zxing-cpp** - 使用官方最新版本，支持更多格式
- ⚡ **性能提升** - 重写 C++ 扩展，使用现代 API
- 🔧 **新功能** - `decode_all` 方法支持多条码解码
- 🛡️ **更稳定** - 改进的错误处理和内存管理

### 🆚 从旧版本升级

如果你之前使用的是依赖 RMagick 的旧版本：

```bash
# 卸载旧版本
gem uninstall zxing_cpp

# 安装新版本
gem specific_install https://github.com/liv09370/zxing.git
```

API 保持向后兼容，无需修改现有代码。

### 🐛 故障排除

#### ImageMagick 问题
```bash
# 检查 ImageMagick 安装
convert -version

# Ubuntu/Debian 安装问题
sudo apt-get install pkg-config libmagickwand-dev

# macOS 安装问题  
brew reinstall imagemagick
```

#### 编译错误
```bash
# 确保安装了开发工具
# Linux: build-essential, ruby-dev
# macOS: xcode-select --install

# 清理重新构建
bundle exec rake clean
bundle exec rake compile
```

#### 权限问题
```bash
# 使用用户级安装
gem install --user-install specific_install
gem specific_install --user-install https://github.com/liv09370/zxing.git
```

### 📞 支持与反馈

- **GitHub Issues**: https://github.com/liv09370/zxing/issues
- **Wiki**: https://github.com/liv09370/zxing/wiki
- **版本历史**: 查看 [CHANGELOG.rdoc](CHANGELOG.rdoc)

### 📄 许可证

本项目基于原始 zxing-cpp 项目的许可证发布。

---

**享受高效的条码识别体验！** 🎉 