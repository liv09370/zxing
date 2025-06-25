#!/usr/bin/env ruby
# ZXing-C++ Ruby Gem 使用示例

require 'zxing'

# 你的 QR 码图片路径
pic = '/home/sanyu/test_qr_0.jpg'

puts "🚀 ZXing-C++ Ruby Gem v#{ZXing::VERSION} 使用示例"
puts "=" * 50

# 方法 1: 基本解码（推荐用于大多数情况）
puts "📱 基本 QR 解码:"
begin
  result = ZXing.decode(pic)
  if result && !result.empty?
    puts "  ✅ 解码成功: #{result}"
  else
    puts "  ❌ 未找到条码或解码失败"
  end
rescue => e
  puts "  ❌ 解码错误: #{e.message}"
end

# 方法 2: 增强解码（用于难以识别的图片）
puts "\n🔍 增强解码选项:"
begin
  result = ZXing.decode!(pic, try_harder: true, try_rotate: true, try_invert: true)
  puts "  ✅ 增强解码结果: #{result}"
rescue => e
  puts "  ❌ 增强解码失败: #{e.message}"
end

# 方法 3: 多条码解码（如果图片中有多个条码）
puts "\n📋 多条码解码:"
begin
  results = ZXing.decode_all(pic)
  if results && results.length > 0
    puts "  ✅ 找到 #{results.length} 个条码:"
    results.each_with_index do |result, index|
      puts "    #{index + 1}. #{result}"
    end
  else
    puts "  ❌ 未找到任何条码"
  end
rescue => e
  puts "  ❌ 多条码解码失败: #{e.message}"
end

# 方法 4: 文件存在性检查（推荐在生产环境中使用）
puts "\n🛡️  安全解码（推荐）:"
def safe_decode(image_path)
  return nil unless File.exist?(image_path)
  
  result = ZXing.decode(image_path)
  return result if result && !result.empty?
  
  # 如果基本解码失败，尝试增强解码
  ZXing.decode!(image_path, try_harder: true, try_rotate: true)
rescue => e
  puts "解码错误: #{e.message}"
  nil
end

result = safe_decode(pic)
if result
  puts "  ✅ 安全解码成功: #{result}"
else
  puts "  ❌ 安全解码失败"
end

puts "\n" + "=" * 50
puts "🎯 解码完成！" 