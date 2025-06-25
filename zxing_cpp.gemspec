lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'zxing/version'

GEMSPEC_DIR = File.expand_path('..', __FILE__)

module ZXingCppSpec
  def self.submodule_files
    # 尝试从 git 子模块获取文件列表
    begin
      `git submodule --quiet foreach pwd 2>/dev/null`.split("\n").inject([]) do |files, submodule_path|
        next files unless Dir.exist?(submodule_path)
        Dir.chdir(submodule_path) do
          submodule_files = `git ls-files -z 2>/dev/null`.split("\x0")
          files += submodule_files.map do |f|
            "#{submodule_path}/#{f}".gsub "#{GEMSPEC_DIR}/", ''
          end
        end
        files
      end
    rescue
      # 如果 git 命令失败，手动扫描 zxing-cpp 目录
      zxing_cpp_dir = File.join(GEMSPEC_DIR, 'ext', 'zxing', 'zxing-cpp')
      if Dir.exist?(zxing_cpp_dir)
        Dir.glob("#{zxing_cpp_dir}/**/*").select { |f| File.file?(f) }.map do |f|
          f.gsub("#{GEMSPEC_DIR}/", '')
        end
      else
        []
      end
    end
  end
end

Gem::Specification.new do |s|
  s.name = 'zxing_cpp'
  s.version = ZXing::VERSION

  s.authors = ['liv09370', 'Benjamin Dobell']
  s.email = ['benjamin.dobell@glassechidna.com.au']
  s.description = 'A modern barcode and QR code library for Ruby with ImageMagick 7 support. Uses the latest official zxing-cpp with C++20 support and enhanced performance. Features include multi-barcode decoding, improved error handling, and MiniMagick integration.'
  s.licenses = ['MIT', 'Apache-2.0']

  s.homepage = 'https://github.com/liv09370/zxing'
  s.summary = 'Modern barcode and QR code library with ImageMagick 7 support.'

  # 获取所有文件，包括子模块文件
  all_files = `git ls-files -z 2>/dev/null`.split("\x0") rescue []
  submodule_files = ZXingCppSpec.submodule_files
  
  s.files = all_files + submodule_files
  s.extensions = ['ext/zxing/extconf.rb']
  s.rdoc_options = ['--main', 'README.md']
  s.extra_rdoc_files = ['README.md', 'CHANGELOG.rdoc']
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^test/})
  s.require_paths = ['lib', 'ext']

  s.add_development_dependency 'bundler', '>= 1.6'
  s.add_development_dependency 'rake', '>= 10.4'
  s.add_development_dependency 'rake-compiler', '>= 0.9'
  s.add_development_dependency 'shoulda', '>= 3.5'

  s.add_dependency 'ffi', '>= 1.1'
  s.add_dependency 'mini_magick', '>= 4.0'
  
  # 添加安装后的提示信息
  s.post_install_message = <<-MSG
🎉 ZXing-C++ v#{ZXing::VERSION} 安装成功！

✨ 新特性:
  - ImageMagick 7 完全兼容
  - 最新官方 zxing-cpp 支持
  - 多条码解码功能
  - 增强的性能和稳定性

📚 快速开始:
  require 'zxing'
  result = ZXing.decode('qrcode.png')
  results = ZXing.decode_all('multiple_barcodes.png')

📖 更多信息: https://github.com/liv09370/zxing
MSG
end
