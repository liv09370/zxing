require 'mkmf'

ZXING_CPP = "#{File.dirname(__FILE__)}/zxing-cpp"
ZXING_CPP_BUILD = "#{ZXING_CPP}/build"

# 检查并初始化子模块
def check_and_init_submodule
  puts "🔍 检查 zxing-cpp 子模块..."
  
  # 检查子模块目录是否存在且不为空
  if !Dir.exist?(ZXING_CPP) || Dir.empty?(ZXING_CPP)
    puts "⚠️  zxing-cpp 子模块未初始化，尝试自动初始化..."
    
    # 尝试使用 git 初始化子模块
    project_root = File.expand_path("../..", File.dirname(__FILE__))
    Dir.chdir(project_root) do
      if system("git submodule update --init --recursive >/dev/null 2>&1")
        puts "✅ 子模块初始化成功"
      else
        puts "❌ 无法通过 git 初始化子模块，尝试手动下载..."
        
        # 尝试直接下载
        require 'fileutils'
        
        zxing_cpp_url = "https://github.com/zxing-cpp/zxing-cpp/archive/refs/heads/master.zip"
        temp_zip = "/tmp/zxing-cpp-master.zip"
        temp_dir = "/tmp/zxing-cpp-master"
        
        begin
          puts "📥 下载 zxing-cpp 源代码..."
          
          # 下载 zip 文件
          if system("curl -L -s -o #{temp_zip} #{zxing_cpp_url}")
            # 解压到临时目录
            if system("cd /tmp && unzip -q #{temp_zip}")
              # 复制到目标目录
              FileUtils.rm_rf(ZXING_CPP) if Dir.exist?(ZXING_CPP)
              extracted_dir = "#{temp_dir}/zxing-cpp-master"
              if Dir.exist?(extracted_dir)
                FileUtils.cp_r(extracted_dir, ZXING_CPP)
                puts "✅ zxing-cpp 源代码下载完成"
              else
                raise "解压后目录不存在"
              end
            else
              raise "解压失败"
            end
          else
            raise "下载失败"
          end
          
          # 清理临时文件
          FileUtils.rm_f(temp_zip)
          FileUtils.rm_rf(temp_dir)
          
        rescue => e
          puts "❌ 下载失败: #{e.message}"
          puts ""
          puts "请手动执行以下命令之一："
          puts "1. git submodule update --init --recursive"
          puts "2. 或者手动下载 zxing-cpp 源代码到 #{ZXING_CPP}"
          puts ""
          puts "如果问题持续，请查看: https://github.com/liv09370/zxing/blob/master/SUBMODULES.md"
          exit 1
        ensure
          # 清理临时文件
          FileUtils.rm_f(temp_zip) rescue nil
          FileUtils.rm_rf(temp_dir) rescue nil
        end
      end
    end
  end
  
  # 验证关键文件是否存在
  cmake_file = File.join(ZXING_CPP, "CMakeLists.txt")
  unless File.exist?(cmake_file)
    puts "❌ 错误：#{cmake_file} 不存在"
    puts "请确保 zxing-cpp 子模块正确初始化"
    puts "查看详细说明: https://github.com/liv09370/zxing/blob/master/SUBMODULES.md"
    exit 1
  end
  
  puts "✅ zxing-cpp 子模块检查完成"
end

# 执行子模块检查
check_and_init_submodule

# 检查 cmake
`cmake --version` rescue raise "zxing_cpp.rb installation requires cmake"

# 构建 zxing-cpp
puts "🔨 构建 zxing-cpp..."
Dir.mkdir ZXING_CPP_BUILD unless File.exist? ZXING_CPP_BUILD
Dir.chdir ZXING_CPP_BUILD do
  `cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_CXX_FLAGS="-fPIC" -DZXING_READERS=ON -DZXING_WRITERS=OFF -DZXING_EXAMPLES=OFF -DZXING_BLACKBOX_TESTS=OFF -DZXING_UNIT_TESTS=OFF -DZXING_PYTHON_MODULE=OFF -DZXING_C_API=OFF ..`
end

Dir.chdir ZXING_CPP_BUILD do
  `make -j$(nproc)`
end

cpp_include = File.join File.expand_path("#{ZXING_CPP}/core/src")
lib = File.expand_path "#{ZXING_CPP_BUILD}/core/libZXing.a"

$CPPFLAGS = %(-I#{cpp_include})
$DLDFLAGS = %(-lstdc++ #{lib})

if Dir["/usr/lib/libiconv.*"].size > 0
  $DLDFLAGS << %( -liconv)
end

create_makefile 'zxing/zxing'
