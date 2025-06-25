require 'rake/clean'
require 'rake/testtask'
require 'bundler/gem_tasks'

# 加载 gemspec
spec = Gem::Specification.load('zxing_cpp.gemspec')

# 清理规则
CLEAN.include('ext/zxing/*.{o,so,bundle}')
CLEAN.include('ext/zxing/Makefile')
CLEAN.include('ext/zxing/zxing-cpp/build/')
CLOBBER.include('lib/zxing/zxing.{so,bundle}')
CLEAN.include('tmp/')

desc 'Regenerate Manifest.txt'
task :manifest do
  File.open('Manifest.txt', 'w') do |f|
    f.puts(spec.files)
  end
end

# 测试任务
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test*.rb', 'test/zxing/test*.rb']
  t.verbose = true
end

# 编译任务
desc 'Compile the native extension'
task :compile do
  Dir.chdir('ext/zxing') do
    puts "🔧 编译 ZXing-C++ 扩展..."
    
    # 清理之前的构建
    system('make clean') if File.exist?('Makefile')
    
    # 运行 extconf.rb
    system('ruby extconf.rb') or raise "extconf.rb 失败"
    
    # 编译
    system('make') or raise "make 失败"
    
    # 复制 .so 文件到 lib 目录
    so_file = Dir.glob('zxing.{so,bundle}').first
    if so_file
      target_dir = '../../lib/zxing'
      require 'fileutils'
      FileUtils.mkdir_p(target_dir)
      FileUtils.cp(so_file, target_dir)
      puts "✅ 扩展编译成功：#{target_dir}/#{so_file}"
    else
      raise "找不到编译后的扩展文件"
    end
  end
end

# 确保编译在测试之前
task :test => :compile

# 构建任务
task :build => [:compile, :manifest]

# 安装任务
task :install => :build

# 默认任务
task :default => [:compile, :test]

# 添加预检查任务
desc 'Run precompile checks'
task :precheck do
  system('ruby scripts/precompile.rb') or puts "⚠️  预检查建议查看，但继续构建"
end

# 完整构建流程
desc 'Full build with precheck'
task :full_build => [:precheck, :compile, :test, :build]

# 发布准备
desc 'Prepare for release'
task :release_prep => [:full_build] do
  puts "🎯 准备发布 v#{spec.version}"
  puts "📦 文件数量: #{spec.files.length}"
  puts "🔧 扩展: #{spec.extensions}"
  puts "💎 依赖: #{spec.dependencies.map(&:name).join(', ')}"
end

# 重新构建（清理后重新编译）
desc 'Clean and rebuild'
task :rebuild => [:clean, :compile]
