#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# 测试在新环境中 bundle install 的脚本

puts "🧪 测试 Bundle Install 自动子模块初始化"
puts "=" * 50

require 'fileutils'
require 'tmpdir'

test_dir = nil

begin
  # 创建临时测试目录
  test_dir = Dir.mktmpdir('zxing_test_')
  puts "📁 创建测试目录: #{test_dir}"
  
  Dir.chdir(test_dir) do
    # 创建测试 Gemfile
    File.write('Gemfile', <<~GEMFILE)
      source 'https://rubygems.org'
      gem 'zxing_cpp', git: 'https://github.com/liv09370/zxing.git'
    GEMFILE
    
    puts "📝 创建 Gemfile"
    puts File.read('Gemfile')
    puts
    
    puts "📦 运行 bundle install..."
    
    # 运行 bundle install
    if system('bundle install')
      puts "✅ Bundle install 成功！"
      
      # 测试库是否可用
      puts "🔍 测试库功能..."
      
      test_code = <<~RUBY
        require 'zxing'
        puts "ZXing version: \#{ZXing::VERSION}"
        puts "ZXing loaded successfully!"
      RUBY
      
      if system("bundle exec ruby -e \"#{test_code}\"")
        puts "🎉 ZXing 库测试成功！"
        success = true
      else
        puts "❌ ZXing 库测试失败"
        success = false
      end
    else
      puts "❌ Bundle install 失败"
      success = false
    end
  end
  
rescue => e
  puts "❌ 测试过程出错: #{e.message}"
  success = false
ensure
  # 清理测试目录
  if test_dir && Dir.exist?(test_dir)
    FileUtils.rm_rf(test_dir)
    puts "🧹 清理测试目录"
  end
end

puts
if success
  puts "🎉 测试通过！用户现在可以直接在 Gemfile 中使用："
  puts "   gem 'zxing_cpp', git: 'https://github.com/liv09370/zxing.git'"
else
  puts "❌ 测试失败，需要进一步检查问题"
end 