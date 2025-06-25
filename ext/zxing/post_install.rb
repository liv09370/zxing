#!/usr/bin/env ruby
# Post-install script for ZXing-C++ Ruby Gem
# 确保在 bundle install 后扩展被正确编译

require 'fileutils'

puts "🔧 ZXing-C++ Post-Install: 检查扩展编译状态..."

# 获取当前 gem 目录
gem_dir = File.dirname(File.dirname(__FILE__))
ext_dir = File.join(gem_dir, 'zxing')
lib_dir = File.join(File.dirname(gem_dir), '..', 'lib', 'zxing')

# 检查是否已编译
so_file = Dir.glob(File.join(lib_dir, 'zxing.{so,bundle}')).first
ext_so_file = Dir.glob(File.join(ext_dir, 'zxing.{so,bundle}')).first

if so_file && File.exist?(so_file)
  puts "✅ 扩展已编译: #{so_file}"
  exit 0
elsif ext_so_file && File.exist?(ext_so_file)
  puts "📁 发现编译文件，复制到 lib 目录..."
  FileUtils.mkdir_p(lib_dir)
  FileUtils.cp(ext_so_file, lib_dir)
  puts "✅ 扩展复制完成"
  exit 0
end

puts "⚠️  扩展未编译，尝试编译..."

# 切换到扩展目录
Dir.chdir(ext_dir) do
  puts "📁 当前目录: #{Dir.pwd}"
  
  # 检查 Makefile 是否存在
  unless File.exist?('Makefile')
    puts "🔧 运行 extconf.rb..."
    system('ruby extconf.rb') or begin
      puts "❌ extconf.rb 失败"
      exit 1
    end
  end
  
  # 编译
  puts "🔨 编译扩展..."
  system('make') or begin
    puts "❌ 编译失败"
    exit 1
  end
  
  # 复制到 lib 目录
  so_file = Dir.glob('zxing.{so,bundle}').first
  if so_file
    FileUtils.mkdir_p(lib_dir)
    FileUtils.cp(so_file, lib_dir)
    puts "✅ 扩展编译并安装成功: #{lib_dir}/#{so_file}"
  else
    puts "❌ 找不到编译后的扩展文件"
    exit 1
  end
end

puts "🎉 Post-Install 完成！" 