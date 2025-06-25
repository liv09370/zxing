require 'mkmf'

ZXING_CPP = "#{File.dirname(__FILE__)}/zxing-cpp"
ZXING_CPP_BUILD = "#{ZXING_CPP}/build"

`cmake --version` rescue raise "zxing_cpp.rb installation requires cmake"

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
