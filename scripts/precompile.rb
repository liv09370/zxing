#!/usr/bin/env ruby
# ZXing-C++ Ruby Gem 预编译脚本
# 用于确保在 bundle install 之前所有依赖都正确配置

require 'fileutils'

puts "🚀 ZXing-C++ Ruby Gem 预编译检查"
puts "=" * 50

# 检查系统依赖
def check_system_dependencies
  puts "📋 检查系统依赖..."
  
  missing_deps = []
  
  # 检查 CMake
  unless system("cmake --version > /dev/null 2>&1")
    missing_deps << "cmake"
  end
  
  # 检查 GCC
  unless system("gcc --version > /dev/null 2>&1")
    missing_deps << "gcc/g++"
  end
  
  # 检查 Make
  unless system("make --version > /dev/null 2>&1")
    missing_deps << "make"
  end
  
  if missing_deps.empty?
    puts "✅ 所有系统依赖都已安装"
    return true
  else
    puts "❌ 缺少以下依赖: #{missing_deps.join(', ')}"
    puts "\n📦 安装命令:"
    
    if File.exist?("/etc/redhat-release") || system("which dnf > /dev/null 2>&1")
      puts "   sudo dnf groupinstall 'Development Tools'"
      puts "   sudo dnf install cmake ruby-devel"
    elsif system("which apt > /dev/null 2>&1")
      puts "   sudo apt update"
      puts "   sudo apt install build-essential cmake ruby-dev"
    else
      puts "   请手动安装: cmake, gcc, g++, make"
    end
    
    return false
  end
end

# 检查 Ruby 开发环境
def check_ruby_environment
  puts "\n🔴 检查 Ruby 开发环境..."
  
  # 检查 mkmf
  begin
    require 'mkmf'
    puts "✅ mkmf 可用"
  rescue LoadError
    puts "❌ 缺少 mkmf (Ruby 开发头文件)"
    puts "   安装命令: sudo dnf install ruby-devel 或 sudo apt install ruby-dev"
    return false
  end
  
  # 检查 bundler
  unless system("bundle --version > /dev/null 2>&1")
    puts "❌ 缺少 bundler"
    puts "   安装命令: gem install bundler"
    return false
  end
  
  puts "✅ Ruby 开发环境正常"
  return true
end

# 检查源代码完整性
def check_source_code
  puts "\n📂 检查源代码完整性..."
  
  zxing_cpp_path = File.join(File.dirname(__FILE__), "..", "ext", "zxing", "zxing-cpp")
  core_src_path = File.join(zxing_cpp_path, "core", "src")
  
  required_files = [
    "ReadBarcode.h",
    "ReadBarcode.cpp", 
    "ImageView.h",
    "Barcode.h"
  ]
  
  missing_files = []
  required_files.each do |file|
    file_path = File.join(core_src_path, file)
    unless File.exist?(file_path)
      missing_files << file
    end
  end
  
  if missing_files.empty?
    puts "✅ zxing-cpp 源代码完整"
    return true
  else
    puts "❌ 缺少关键源文件: #{missing_files.join(', ')}"
    puts "   请确保从 GitHub 正确克隆了完整仓库"
    puts "   git clone https://github.com/liv09370/zxing.git"
    return false
  end
end

# 预编译测试
def test_precompile
  puts "\n🔧 测试预编译..."
  
  ext_dir = File.join(File.dirname(__FILE__), "..", "ext", "zxing")
  
  Dir.chdir(ext_dir) do
    puts "   当前目录: #{Dir.pwd}"
    
    # 清理之前的构建
    if File.exist?("Makefile")
      puts "   清理之前的构建..."
      system("make clean > /dev/null 2>&1")
    end
    
    FileUtils.rm_rf("zxing-cpp/build") if File.exist?("zxing-cpp/build")
    
    # 运行 extconf.rb
    puts "   运行 extconf.rb..."
    unless system("ruby extconf.rb")
      puts "❌ extconf.rb 失败"
      return false
    end
    
    # 测试编译
    puts "   测试编译..."
    unless system("make > /dev/null 2>&1")
      puts "❌ 编译失败"
      return false
    end
    
    puts "✅ 预编译测试成功"
    return true
  end
end

# 主流程
def main
  success = true
  
  success &= check_system_dependencies
  success &= check_ruby_environment  
  success &= check_source_code
  
  if success
    success &= test_precompile
  end
  
  puts "\n" + "=" * 50
  if success
    puts "🎉 预编译检查完成，可以安全运行 bundle install"
    puts "\n📋 后续步骤:"
    puts "   1. bundle install"
    puts "   2. bundle exec ruby -e \"require 'zxing'; puts ZXing::VERSION\""
  else
    puts "❌ 预编译检查失败，请解决上述问题后重试"
    puts "\n🆘 如需帮助，请查看安装指南："
    puts "   https://github.com/liv09370/zxing/blob/master/README_安装指南.md"
  end
  
  exit success ? 0 : 1
end

main if __FILE__ == $0 