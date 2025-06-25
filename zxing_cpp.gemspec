lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'zxing/version'

Gem::Specification.new do |s|
  s.name = 'zxing_cpp'
  s.version = ZXing::VERSION

  s.authors = ['Benjamin Dobell', 'liv09370']
  s.email = ['benjamin.dobell@glassechidna.com.au', 'liv09370@github.com']
  s.description = 'ZXing-C++ Ruby 绑定：支持多种条码格式的高性能条码/QR码识别库。使用最新的官方 zxing-cpp 版本，支持 MiniMagick，兼容 ImageMagick 7。提供简单易用的 Ruby API，支持基础解码和高级选项（try_harder, try_rotate, try_invert）。'
  s.licenses = ['MIT', 'Apache-2.0']

  s.homepage = 'https://github.com/liv09370/zxing'
  s.summary = 'ZXing-C++ Ruby 绑定：高性能条码/QR码识别库'

  # 包含所有文件，包括 zxing-cpp 源代码
  s.files = Dir.glob('**/*').reject do |f|
    File.directory?(f) || 
    f.match(%r{^\.git/}) || 
    f.match(%r{^ext/zxing/zxing-cpp/build/}) ||
    f.match(%r{^ext/zxing/Makefile$}) ||
    f.match(%r{^ext/zxing/.*\.o$}) ||
    f.match(%r{^ext/zxing/.*\.so$}) ||
    f.match(%r{^ext/zxing/.*\.bundle$})
  end
  
  # 确保包含关键文件
  s.files += Dir.glob('ext/zxing/zxing-cpp/**/*').reject { |f| File.directory?(f) }
  s.files = s.files.uniq.sort

  # 扩展配置 - 确保 Bundler 会编译动态库
  s.extensions = ['ext/zxing/extconf.rb']
  
  # Post-install message
  s.post_install_message = <<~MSG
    🎉 ZXing-C++ Ruby Gem 安装完成！
    
    如果遇到加载问题，请运行:
      bundle exec rake compile
      bundle exec ruby -e "require 'zxing'; puts ZXing::VERSION"
    
    更多信息: https://github.com/liv09370/zxing
  MSG
  
  # 确保在安装时强制编译扩展
  s.require_paths = ['lib']
  
  s.executables = Dir.glob('bin/*').map { |f| File.basename(f) }
  s.test_files = Dir.glob('test/**/*').reject { |f| File.directory?(f) }

  # 开发依赖
  s.add_development_dependency 'bundler', '>= 1.6'
  s.add_development_dependency 'rake', '>= 10.4'
  s.add_development_dependency 'rake-compiler', '>= 0.9'
  s.add_development_dependency 'shoulda', '>= 3.5'

  # 运行时依赖
  s.add_dependency 'ffi', '>= 1.1'
  s.add_dependency 'mini_magick', '>= 4.0'
  
  # 元数据
  s.metadata = {
    'homepage_uri' => s.homepage,
    'source_code_uri' => 'https://github.com/liv09370/zxing',
    'bug_tracker_uri' => 'https://github.com/liv09370/zxing/issues',
    'changelog_uri' => 'https://github.com/liv09370/zxing/blob/master/CHANGELOG.rdoc',
    'documentation_uri' => 'https://github.com/liv09370/zxing/blob/master/README.md'
  }
  
  # Ruby 版本要求
  s.required_ruby_version = '>= 2.7.0'
  
  # 平台支持
  s.platform = Gem::Platform::RUBY
end
