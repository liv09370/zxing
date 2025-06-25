require 'mkmf'

# 配置路径
ZXING_CPP = "#{File.dirname(__FILE__)}/zxing-cpp"
ZXING_CPP_BUILD = "#{ZXING_CPP}/build"

puts "🔧 配置 ZXing-C++ 动态库..."

# 检查 zxing-cpp 源代码是否存在
unless File.exist?("#{ZXING_CPP}/core/src/ReadBarcode.h")
  puts "❌ 错误: 找不到 zxing-cpp 源代码"
  puts "   预期路径: #{ZXING_CPP}/core/src/ReadBarcode.h"
  puts "   请确保从 GitHub 正确克隆了完整仓库"
  exit 1
end

# 检查 CMake
begin
  cmake_version = `cmake --version 2>/dev/null`
  if $?.exitstatus != 0
    puts "❌ 错误: 未找到 CMake"
    puts "   请安装 CMake: sudo dnf install cmake (RHEL/Fedora) 或 sudo apt install cmake (Ubuntu/Debian)"
    exit 1
  end
  puts "✅ 找到 CMake: #{cmake_version.lines.first.strip}"
rescue
  puts "❌ 错误: CMake 检查失败"
  exit 1
end

# 检查编译器
begin
  gcc_version = `gcc --version 2>/dev/null`
  if $?.exitstatus != 0
    puts "❌ 错误: 未找到 GCC 编译器"
    puts "   请安装: sudo dnf groupinstall 'Development Tools' (RHEL/Fedora)"
    puts "           sudo apt install build-essential (Ubuntu/Debian)"
    exit 1
  end
  puts "✅ 找到编译器: #{gcc_version.lines.first.strip}"
rescue
  puts "❌ 错误: 编译器检查失败"
  exit 1
end

# 创建构建目录
puts "📁 创建构建目录: #{ZXING_CPP_BUILD}"
Dir.mkdir ZXING_CPP_BUILD unless File.exist? ZXING_CPP_BUILD

# CMake 配置
puts "⚙️  配置 CMake..."
Dir.chdir ZXING_CPP_BUILD do
  cmake_cmd = [
    "cmake",
    "-DCMAKE_BUILD_TYPE=Release",
    "-DBUILD_SHARED_LIBS=OFF", 
    "-DCMAKE_CXX_FLAGS='-fPIC'",
    "-DZXING_READERS=ON",
    "-DZXING_WRITERS=OFF",
    "-DZXING_EXAMPLES=OFF", 
    "-DZXING_BLACKBOX_TESTS=OFF",
    "-DZXING_UNIT_TESTS=OFF",
    "-DZXING_PYTHON_MODULE=OFF",
    "-DZXING_C_API=OFF",
    ".."
  ].join(" ")
  
  result = system(cmake_cmd)
  unless result
    puts "❌ CMake 配置失败"
    exit 1
  end
  puts "✅ CMake 配置成功"
end

# 编译 zxing-cpp
puts "🔨 编译 zxing-cpp 库..."
Dir.chdir ZXING_CPP_BUILD do
  # 获取 CPU 核心数，但限制最大并行数以避免内存问题
  nproc = `nproc 2>/dev/null`.strip.to_i
  nproc = [nproc, 4].min if nproc > 4  # 限制最大并行数
  nproc = 2 if nproc < 1  # 至少使用2个核心
  
  make_cmd = "make -j#{nproc}"
  puts "   使用 #{nproc} 个并行进程编译..."
  
  result = system(make_cmd)
  unless result
    puts "❌ 编译失败，尝试单线程编译..."
    result = system("make")
    unless result
      puts "❌ 编译失败"
      exit 1
    end
  end
  puts "✅ zxing-cpp 编译成功"
end

# 验证库文件
lib_path = File.expand_path "#{ZXING_CPP_BUILD}/core/libZXing.a"
unless File.exist?(lib_path)
  puts "❌ 错误: 找不到编译后的库文件 #{lib_path}"
  exit 1
end
puts "✅ 找到库文件: #{lib_path}"

# 配置编译选项
cpp_include = File.join File.expand_path("#{ZXING_CPP}/core/src")
$CPPFLAGS = %(-I#{cpp_include})
$DLDFLAGS = %(-lstdc++ #{lib_path})

# 检查并添加 iconv 库（如果需要）
if Dir["/usr/lib*/libiconv.*"].size > 0 || Dir["/usr/local/lib/libiconv.*"].size > 0
  $DLDFLAGS << %( -liconv)
  puts "✅ 添加 iconv 库支持"
end

# 设置构建为动态库
$LDSHARED = "#{CONFIG['CXX']} -shared"

puts "🎯 生成 Makefile..."

# 创建自定义 Makefile 来构建动态库而不是 Ruby 扩展
makefile_content = <<-EOF
SHELL = /bin/sh
CXX = #{CONFIG['CXX']}
CXXFLAGS = #{CONFIG['CXXFLAGS']} #{$CPPFLAGS} -fPIC
LDFLAGS = #{$DLDFLAGS}
LDSHARED = #{$LDSHARED}

TARGET = zxing.so
OBJS = zxing.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LDSHARED) $(OBJS) $(LDFLAGS) -o $(TARGET)

zxing.o: zxing.cc
	$(CXX) $(CXXFLAGS) -c zxing.cc -o zxing.o

clean:
	rm -f $(OBJS) $(TARGET)

install: $(TARGET)
	# 动态库构建完成

.PHONY: all clean install
EOF

File.open('Makefile', 'w') { |f| f.write(makefile_content) }

puts "✅ 动态库 Makefile 生成完成！"
