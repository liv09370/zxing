#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# 准备和验证 zxing-cpp 子模块的脚本

require 'fileutils'
require 'net/http'
require 'uri'

class SubmoduleManager
  ZXING_CPP_DIR = File.expand_path('../../ext/zxing/zxing-cpp', __FILE__)
  ZXING_CPP_URL = 'https://github.com/zxing-cpp/zxing-cpp/archive/refs/heads/master.zip'
  
  def self.run
    manager = new
    manager.prepare_submodule
  end
  
  def prepare_submodule
    puts "🔍 检查 zxing-cpp 子模块状态..."
    
    if submodule_exists_and_valid?
      puts "✅ zxing-cpp 子模块已存在且有效"
      return true
    end
    
    puts "⚠️  zxing-cpp 子模块缺失或无效，开始初始化..."
    
    # 尝试 git 子模块初始化
    if init_git_submodule
      puts "✅ Git 子模块初始化成功"
      return true
    end
    
    # 如果 git 失败，尝试下载
    if download_zxing_cpp
      puts "✅ zxing-cpp 源代码下载成功"
      return true
    end
    
    puts "❌ 无法获取 zxing-cpp 源代码"
    return false
  end
  
  private
  
  def submodule_exists_and_valid?
    return false unless Dir.exist?(ZXING_CPP_DIR)
    return false if Dir.empty?(ZXING_CPP_DIR)
    
    # 检查关键文件
    cmake_file = File.join(ZXING_CPP_DIR, 'CMakeLists.txt')
    core_dir = File.join(ZXING_CPP_DIR, 'core')
    
    File.exist?(cmake_file) && Dir.exist?(core_dir)
  end
  
  def init_git_submodule
    project_root = File.expand_path('../..', __FILE__)
    
    Dir.chdir(project_root) do
      system('git submodule update --init --recursive >/dev/null 2>&1')
    end
  end
  
  def download_zxing_cpp
    puts "📥 从 GitHub 下载 zxing-cpp..."
    
    temp_zip = '/tmp/zxing-cpp-master.zip'
    temp_dir = '/tmp/zxing-cpp-master'
    
    begin
      # 清理旧文件
      FileUtils.rm_f(temp_zip)
      FileUtils.rm_rf(temp_dir)
      FileUtils.rm_rf(ZXING_CPP_DIR) if Dir.exist?(ZXING_CPP_DIR)
      
      # 下载
      if system("curl -L -s -o #{temp_zip} #{ZXING_CPP_URL}")
        puts "📦 下载完成，解压中..."
        
        # 解压
        if system("cd /tmp && unzip -q #{temp_zip}")
          # 移动到目标位置
          extracted_dir = "#{temp_dir}/zxing-cpp-master"
          if Dir.exist?(extracted_dir)
            FileUtils.mkdir_p(File.dirname(ZXING_CPP_DIR))
            FileUtils.mv(extracted_dir, ZXING_CPP_DIR)
            
            # 清理
            FileUtils.rm_f(temp_zip)
            FileUtils.rm_rf(temp_dir)
            
            return submodule_exists_and_valid?
          end
        end
      end
      
      false
    rescue => e
      puts "❌ 下载失败: #{e.message}"
      false
    ensure
      # 清理临时文件
      FileUtils.rm_f(temp_zip)
      FileUtils.rm_rf(temp_dir)
    end
  end
end

if __FILE__ == $0
  success = SubmoduleManager.run
  exit(success ? 0 : 1)
end 