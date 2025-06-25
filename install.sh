#!/bin/bash
# ZXing-C++ Ruby Gem 一键安装脚本
# 支持多操作系统，自动处理依赖和编译问题

set -e

echo "🚀 ZXing-C++ Ruby Gem 一键安装脚本"
echo "=================================="

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/redhat-release ]; then
            echo "rhel"
        elif [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/arch-release ]; then
            echo "arch"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# 安装系统依赖
install_dependencies() {
    local os_type=$1
    echo "📦 安装系统依赖..."
    
    case $os_type in
        "rhel")
            echo "   检测到 RHEL/CentOS/Fedora 系统"
            if command -v dnf &> /dev/null; then
                sudo dnf groupinstall -y 'Development Tools' || echo "   ⚠️  Development Tools 可能已安装"
                sudo dnf install -y cmake ruby-devel || echo "   ⚠️  依赖可能已安装"
            elif command -v yum &> /dev/null; then
                sudo yum groupinstall -y 'Development Tools'
                sudo yum install -y cmake ruby-devel
            fi
            ;;
        "debian")
            echo "   检测到 Debian/Ubuntu 系统"
            sudo apt update
            sudo apt install -y build-essential cmake ruby-dev
            ;;
        "arch")
            echo "   检测到 Arch Linux 系统"
            sudo pacman -S --noconfirm base-devel cmake ruby
            ;;
        "macos")
            echo "   检测到 macOS 系统"
            if ! command -v brew &> /dev/null; then
                echo "   ❌ 需要安装 Homebrew: https://brew.sh"
                exit 1
            fi
            brew install cmake
            ;;
        *)
            echo "   ⚠️  未知操作系统，请手动安装: cmake, gcc, g++, make, ruby-dev"
            ;;
    esac
}

# 检查 Ruby 环境
check_ruby() {
    echo "🔴 检查 Ruby 环境..."
    
    if ! command -v ruby &> /dev/null; then
        echo "   ❌ 未找到 Ruby，请先安装 Ruby"
        exit 1
    fi
    
    ruby_version=$(ruby -v)
    echo "   ✅ 找到 Ruby: $ruby_version"
    
    if ! command -v gem &> /dev/null; then
        echo "   ❌ 未找到 RubyGems"
        exit 1
    fi
    
    if ! command -v bundle &> /dev/null; then
        echo "   📦 安装 Bundler..."
        gem install bundler
    fi
    
    echo "   ✅ Ruby 环境正常"
}

# 检查网络连接
check_network() {
    echo "🌐 检查网络连接..."
    
    if ! curl -sSf https://api.github.com > /dev/null 2>&1; then
        echo "   ❌ 无法连接到 GitHub，请检查网络连接"
        echo "   💡 如果在中国，可能需要配置代理"
        exit 1
    fi
    
    echo "   ✅ 网络连接正常"
}

# 创建临时目录
setup_temp_dir() {
    TEMP_DIR=$(mktemp -d)
    echo "📁 创建临时目录: $TEMP_DIR"
    
    # 确保在退出时清理临时目录
    trap "rm -rf $TEMP_DIR" EXIT
}

# 安装方法1：使用 gem specific_install
install_method_1() {
    echo "📦 方法1: 使用 gem specific_install..."
    
    if ! gem list specific_install -i > /dev/null 2>&1; then
        echo "   安装 specific_install gem..."
        gem install specific_install
    fi
    
    echo "   从 GitHub 安装 zxing_cpp..."
    gem specific_install https://github.com/liv09370/zxing.git
    
    return $?
}

# 安装方法2：手动构建
install_method_2() {
    echo "📦 方法2: 手动构建安装..."
    
    cd "$TEMP_DIR"
    
    echo "   克隆仓库..."
    git clone https://github.com/liv09370/zxing.git
    cd zxing
    
    echo "   运行预编译检查..."
    if ruby scripts/precompile.rb; then
        echo "   ✅ 预编译检查通过"
    else
        echo "   ❌ 预编译检查失败"
        return 1
    fi
    
    echo "   安装依赖..."
    bundle install
    
    echo "   构建 gem..."
    bundle exec rake build
    
    echo "   安装 gem..."
    gem install pkg/zxing_cpp-*.gem
    
    return $?
}

# 验证安装
verify_installation() {
    echo "🧪 验证安装..."
    
    if ruby -e "require 'zxing'; puts ZXing::VERSION" 2>/dev/null; then
        version=$(ruby -e "require 'zxing'; puts ZXing::VERSION")
        echo "   ✅ 安装成功！版本: $version"
        return 0
    else
        echo "   ❌ 安装验证失败"
        return 1
    fi
}

# 显示使用示例
show_usage() {
    echo ""
    echo "🎉 安装完成！使用示例："
    echo "=================================="
    cat << 'EOF'
require 'zxing'

# 基本用法
result = ZXing.decode('/path/to/qrcode.jpg')
puts result

# 在 Gemfile 中使用
gem 'zxing_cpp', git: 'https://github.com/liv09370/zxing.git'
EOF
    echo ""
    echo "📚 更多信息请查看："
    echo "   GitHub: https://github.com/liv09370/zxing"
    echo "   安装指南: https://github.com/liv09370/zxing/blob/master/README_安装指南.md"
}

# 主安装流程
main() {
    local os_type
    os_type=$(detect_os)
    
    # 安装系统依赖
    install_dependencies "$os_type"
    
    # 检查 Ruby 环境
    check_ruby
    
    # 检查网络连接
    check_network
    
    # 设置临时目录
    setup_temp_dir
    
    # 尝试安装
    echo ""
    echo "🚀 开始安装 ZXing-C++ Ruby Gem..."
    
    if install_method_1; then
        echo "   ✅ 方法1安装成功"
    elif install_method_2; then
        echo "   ✅ 方法2安装成功"
    else
        echo "   ❌ 所有安装方法都失败"
        echo ""
        echo "🆘 故障排除："
        echo "   1. 检查是否安装了所有依赖"
        echo "   2. 检查网络连接"
        echo "   3. 查看详细日志信息"
        echo "   4. 访问 GitHub 仓库寻求帮助"
        exit 1
    fi
    
    # 验证安装
    if verify_installation; then
        show_usage
    else
        echo "   ❌ 安装验证失败，请检查错误信息"
        exit 1
    fi
}

# 运行主函数
main "$@" 