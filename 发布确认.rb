#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

puts "🚀 ZXing-C++ Ruby Gem v0.3.0 发布确认"
puts "=" * 60

# 检查当前目录
unless File.exist?('zxing_cpp.gemspec')
  puts "❌ 错误：请在项目根目录运行此脚本"
  exit 1
end

# 设置加载路径
$LOAD_PATH.unshift(File.expand_path('lib', __dir__))
$LOAD_PATH.unshift(File.expand_path('ext', __dir__))

require 'zxing'

puts "📦 版本信息:"
puts "  ZXing-C++ Ruby Gem: v#{ZXing::VERSION}"
puts "  技术栈: 最新官方 zxing-cpp + MiniMagick + Ruby FFI"
puts

puts "🔧 快速功能验证:"

test_image = 'test/qrcode.png'
expected_result = 'http://rubyflow.com'

# 基本解码
print "  基本 QR 解码: "
result = ZXing.decode(test_image)
if result == expected_result
  puts "✅ 成功"
else
  puts "❌ 失败 (#{result})"
  exit 1
end

# 增强解码
print "  增强解码选项: "
result = ZXing.decode(test_image, try_harder: true, try_rotate: true)
if result == expected_result
  puts "✅ 成功"
else
  puts "❌ 失败"
  exit 1
end

# 多条码解码
print "  多条码解码: "
results = ZXing.decode_all(test_image)
if results.size == 1 && results.first == expected_result
  puts "✅ 成功 (#{results.size} 个结果)"
else
  puts "❌ 失败"
  exit 1
end

# 稳定性测试
print "  稳定性测试: "
success_count = 0
3.times do
  result = ZXing.decode(test_image)
  success_count += 1 if result == expected_result
end
if success_count == 3
  puts "✅ 成功 (#{success_count}/3)"
else
  puts "❌ 失败 (#{success_count}/3)"
  exit 1
end

puts

puts "📋 主要更新内容:"
puts "  ✨ 从 RMagick 迁移到 MiniMagick (解决 ImageMagick 7 兼容性)"
puts "  🔄 更新到最新官方 zxing-cpp (zxing-cpp/zxing-cpp)"
puts "  🏗️  完全重写 C++ 扩展以使用现代 ReadBarcode API"
puts "  ⚡ 支持 C++20 和更多条码格式"
puts "  🔧 新增多条码解码功能"
puts "  🛠️  改进的错误处理和内存管理"
puts

puts "🎯 重大改进:"
puts "  • 解决了 ImageMagick 7 兼容性问题"
puts "  • 使用最新的 zxing-cpp 官方版本"
puts "  • 简化的 API 和更好的性能"
puts "  • 向后兼容的 API 设计"
puts

puts "✅ 所有功能验证通过！"
puts "🚀 ZXing-C++ v#{ZXing::VERSION} 准备发布"
puts "=" * 60 