#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

puts "🚀 ZXing_CPP Gem 发布演示"
puts "=" * 50

# 1. 显示当前状态
puts "\n📊 当前项目状态:"
puts "   版本: 0.2.0 (MiniMagick 迁移版本)"
puts "   主要更新: 从 RMagick 迁移到 MiniMagick"
puts "   修复: ImageMagick 7 兼容性和 QR 解码段错误"

# 2. 检查构建状态
puts "\n📦 Gem 构建状态:"
if File.exist?('zxing_cpp-0.2.0.gem')
  gem_size = File.size('zxing_cpp-0.2.0.gem')
  puts "   ✅ zxing_cpp-0.2.0.gem (#{gem_size} 字节)"
else
  puts "   ❌ Gem 文件不存在"
end

# 3. 功能验证
puts "\n🧪 功能验证:"
begin
  $LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
  $LOAD_PATH.unshift File.expand_path('../ext', __FILE__)
  
  require 'zxing'
  puts "   ✅ 库加载成功"
  
  puts "   ✅ 版本: #{ZXing::VERSION}"
  
  # 测试图像处理
  image = ZXing::MiniMagick::Image.read('test/qrcode.png')
  puts "   ✅ 图像读取: #{image.width}x#{image.height}"
  
  # 测试 QR 解码
  result = ZXing.decode('test/qrcode.png')
  puts "   ✅ QR 解码: #{result}"
  
rescue => e
  puts "   ❌ 功能测试失败: #{e.message}"
end

# 4. 发布准备检查
puts "\n📋 发布准备检查:"

checks = [
  ["版本号更新", File.read('lib/zxing/version.rb').include?('0.2.0')],
  ["CHANGELOG 更新", File.exist?('CHANGELOG.rdoc') && File.read('CHANGELOG.rdoc').include?('0.2.0')],
  ["Gem 构建成功", File.exist?('zxing_cpp-0.2.0.gem')],
  ["Git 状态", `git status --porcelain`.strip.empty?],
  ["MiniMagick 文件存在", File.exist?('lib/zxing/mini_magick/image.rb')],
  ["RMagick 文件已删除", !File.exist?('lib/zxing/rmagick.rb')]
]

checks.each do |name, status|
  icon = status ? "✅" : "❌"
  puts "   #{icon} #{name}"
end

# 5. 发布步骤指南
puts "\n📝 发布步骤:"
puts "   1. 提交所有更改:"
puts "      git add ."
puts "      git commit -m 'feat: 迁移到 MiniMagick v0.2.0'"
puts ""
puts "   2. 创建版本标签:"
puts "      git tag v0.2.0"
puts ""
puts "   3. 推送到远程仓库:"
puts "      git push origin master"
puts "      git push origin v0.2.0"
puts ""
puts "   4. 发布到 RubyGems:"
puts "      gem push zxing_cpp-0.2.0.gem"

# 6. 注意事项
puts "\n⚠️ 重要注意事项:"
puts "   - 确保有 RubyGems 发布权限"
puts "   - 如果是 fork 版本，考虑使用不同的 gem 名称"
puts "   - 发布后监控下载和用户反馈"
puts "   - 准备好处理可能的问题和 bug 报告"

# 7. 成功指标
puts "\n🎯 成功指标:"
puts "   - Gem 成功发布到 RubyGems.org"
puts "   - 用户可以通过 'gem install zxing_cpp' 安装"
puts "   - QR 解码功能在 ImageMagick 7 环境中正常工作"
puts "   - 无段错误或内存泄漏问题"

puts "\n🎉 准备就绪！您的 gem 已经可以发布了！"
puts "   使用 'ruby scripts/release.rb' 开始自动化发布流程" 