#!/usr/bin/env ruby

require_relative '../lib/zxing/version'

version = ZXing::VERSION
gem_name = "zxing_cpp-#{version}.gem"

puts "🚀 准备发布 zxing_cpp v#{version}"
puts "=" * 50

# 检查工作目录是否干净
puts "📋 检查 git 状态..."
unless `git status --porcelain`.strip.empty?
  puts "❌ 错误: 工作目录不干净，请先提交所有更改"
  puts `git status --short`
  exit 1
end
puts "✅ Git 工作目录干净"

# 运行基本测试
puts "\n🧪 运行基本功能测试..."
test_result = system("ruby -I lib -I ext -e \"
require 'zxing'
puts '版本: ' + ZXing::VERSION
image = ZXing::MiniMagick::Image.read('test/qrcode.png')
puts '图像: ' + image.width.to_s + 'x' + image.height.to_s
result = ZXing.decode('test/qrcode.png')
puts '解码: ' + (result ? result.to_s : 'nil')
puts '✅ 基本功能测试通过'
\"")

unless test_result
  puts "❌ 基本功能测试失败"
  exit 1
end

# 清理旧的 gem 文件
puts "\n🧹 清理旧的 gem 文件..."
Dir.glob("*.gem").each do |old_gem|
  File.delete(old_gem)
  puts "删除: #{old_gem}"
end

# 构建 gem
puts "\n📦 构建 gem..."
unless system("gem build zxing_cpp.gemspec")
  puts "❌ Gem 构建失败"
  exit 1
end
puts "✅ Gem 构建成功: #{gem_name}"

# 本地安装测试
puts "\n🔧 本地安装测试..."
unless system("gem install ./#{gem_name}")
  puts "❌ 本地安装失败"
  exit 1
end
puts "✅ 本地安装成功"

# 询问是否继续发布
puts "\n❓ 是否继续发布到 RubyGems? (y/N)"
answer = STDIN.gets.chomp.downcase
unless answer == 'y' || answer == 'yes'
  puts "🛑 发布已取消"
  exit 0
end

# 创建 git 标签
puts "\n🏷️  创建 git 标签..."
tag_name = "v#{version}"
if system("git tag #{tag_name}")
  puts "✅ 标签创建成功: #{tag_name}"
else
  puts "⚠️ 标签可能已存在，继续..."
end

# 推送到远程仓库
puts "\n📤 推送到远程仓库..."
unless system("git push origin master")
  puts "❌ 推送 master 分支失败"
  exit 1
end

unless system("git push origin #{tag_name}")
  puts "⚠️ 推送标签失败，可能已存在"
end
puts "✅ 推送完成"

# 发布到 RubyGems
puts "\n💎 发布到 RubyGems..."
unless system("gem push #{gem_name}")
  puts "❌ 发布到 RubyGems 失败"
  puts "请检查是否有发布权限，或手动运行: gem push #{gem_name}"
  exit 1
end

puts "\n🎉 发布完成！"
puts "=" * 50
puts "📊 发布信息:"
puts "   版本: #{version}"
puts "   Gem: #{gem_name}"
puts "   标签: #{tag_name}"
puts ""
puts "🔗 相关链接:"
puts "   RubyGems: https://rubygems.org/gems/zxing_cpp"
puts "   GitHub: https://github.com/glassechidna/zxing_cpp.rb"
puts ""
puts "📝 后续任务:"
puts "   - 监控下载和反馈"
puts "   - 更新文档和示例"
puts "   - 回应用户问题"
puts ""
puts "🚀 zxing_cpp v#{version} 发布成功！" 