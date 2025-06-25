#!/bin/bash

# ZXing-C++ Ruby Gem 自动安装脚本
# 使用方法: curl -sSL https://raw.githubusercontent.com/liv09370/zxing/master/install.sh | bash

set -e

echo "🚀 ZXing-C++ Ruby Gem 自动安装器"
echo "================================="

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null; then
            OS="ubuntu"
        elif command -v dnf >/dev/null; then
            OS="fedora"
        elif command -v yum >/dev/null; then
            OS="centos"
        else
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
}

# 安装系统依赖
install_dependencies() {
    echo "📦 安装系统依赖..."
    
    case $OS in
        ubuntu)
            sudo apt-get update
            sudo apt-get install -y build-essential cmake ruby-dev imagemagick libmagick++-dev
            ;;
        fedora)
            sudo dnf install -y gcc-c++ cmake ruby-devel ImageMagick ImageMagick-devel
            ;;
        centos)
            sudo yum install -y gcc-c++ cmake ruby-devel ImageMagick ImageMagick-devel
            ;;
        macos)
            if ! command -v brew >/dev/null; then
                echo "❌ 请先安装 Homebrew: https://brew.sh/"
                exit 1
            fi
            xcode-select --install 2>/dev/null || true
            brew install cmake imagemagick
            ;;
        *)
            echo "⚠️  未知操作系统，请手动安装依赖"
            echo "   需要：build tools, cmake, ruby-dev, imagemagick"
            ;;
    esac
}

# 检查 Ruby
check_ruby() {
    if ! command -v ruby >/dev/null; then
        echo "❌ Ruby 未安装，请先安装 Ruby >= 2.7"
        exit 1
    fi
    
    ruby_version=$(ruby -v | grep -o '[0-9]\+\.[0-9]\+' | head -1)
    echo "✅ Ruby $ruby_version 已安装"
}

# 安装 gem
install_gem() {
    echo "💎 安装 ZXing-C++ gem..."
    
    # 安装 specific_install 如果不存在
    if ! gem list specific_install -i >/dev/null 2>&1; then
        echo "   安装 specific_install..."
        gem install specific_install
    fi
    
    # 安装 zxing-cpp
    echo "   从 GitHub 安装 zxing-cpp..."
    gem specific_install https://github.com/liv09370/zxing.git
}

# 验证安装
verify_installation() {
    echo "🔍 验证安装..."
    
    cat > /tmp/test_zxing.rb << 'EOF'
require 'zxing'
puts "✅ ZXing-C++ v#{ZXing::VERSION} 安装成功！"
puts "📚 使用示例："
puts "   result = ZXing.decode('qrcode.png')"
puts "   results = ZXing.decode_all('image.png')"
EOF
    
    if ruby /tmp/test_zxing.rb; then
        echo "🎉 安装完成！"
    else
        echo "❌ 验证失败，请检查错误信息"
        exit 1
    fi
    
    rm -f /tmp/test_zxing.rb
}

# 显示帮助信息
show_help() {
    echo ""
    echo "📚 快速开始："
    echo "   ruby -e \"require 'zxing'; puts ZXing.decode('qrcode.png')\""
    echo ""
    echo "📖 更多信息："
    echo "   GitHub: https://github.com/liv09370/zxing"
    echo "   文档: https://github.com/liv09370/zxing/wiki"
    echo ""
}

# 主函数
main() {
    detect_os
    echo "🖥️  检测到操作系统: $OS"
    
    check_ruby
    install_dependencies
    install_gem
    verify_installation
    show_help
}

# 运行安装
main "$@" 