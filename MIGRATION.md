# 从 RMagick 迁移到 MiniMagick

## 背景

由于 RMagick 不支持 ImageMagick 7，我们将此 gem 从 RMagick 迁移到了 MiniMagick。

## 主要变更

### 1. 依赖项更改

**之前（gemspec）:**
```ruby
s.add_dependency 'rmagick', '~> 2.13'
```

**现在（gemspec）:**
```ruby
s.add_dependency 'mini_magick', '~> 4.0'
```

### 2. 模块名称更改

**之前:**
```ruby
ZXing::RMagick::Image
```

**现在:**
```ruby
ZXing::MiniMagick::Image
```

### 3. API 兼容性

所有公共 API 保持不变。内部实现已更新为使用 MiniMagick：

- `ZXing::Image.read()` - 保持相同的接口
- `image.width` - 保持相同的接口  
- `image.height` - 保持相同的接口
- `image.rotate(angle)` - 保持相同的接口
- `image.gray` - 保持相同的接口

### 4. 内部实现更改

- 使用 PGM/PBM 格式进行像素数据操作
- 使用临时文件进行图像处理
- 改进了灰度转换和二进制化过程

## 升级指南

1. 更新您的 Gemfile：
   ```ruby
   # 移除
   gem 'rmagick'
   
   # 添加（如果您直接依赖图像处理）
   gem 'mini_magick'
   ```

2. 确保安装了 ImageMagick：
   ```bash
   # Ubuntu/Debian
   sudo apt-get install imagemagick
   
   # macOS
   brew install imagemagick
   
   # CentOS/RHEL
   sudo yum install ImageMagick
   ```

3. 运行测试确保一切正常工作：
   ```bash
   bundle install
   rake test
   ```

## 兼容性

- **Ruby**: 支持所有之前支持的 Ruby 版本
- **ImageMagick**: 现在支持 ImageMagick 6 和 7
- **功能**: 所有现有功能保持不变

## 注意事项

- 如果您的代码直接使用了 `ZXing::RMagick` 模块，请更新为 `ZXing::MiniMagick`
- 内部图像处理现在使用临时文件，这可能会稍微影响性能，但提供了更好的 ImageMagick 7 兼容性
- 所有公共 API 保持向后兼容 