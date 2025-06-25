# Git 子模块说明

## 🔧 关于 zxing-cpp 子模块

本项目使用 Git 子模块来包含最新的官方 `zxing-cpp` 源代码，位于 `ext/zxing/zxing-cpp` 目录。

### 🚀 为什么使用子模块？

- 保持与上游 zxing-cpp 项目的同步
- 确保使用最新的 C++ 代码和 bug 修复
- 便于版本管理和更新

### 📥 正确克隆方法

#### 首次克隆（推荐）
```bash
git clone --recursive https://github.com/liv09370/zxing.git
```

#### 如果已经克隆但缺少子模块内容
```bash
cd zxing
git submodule update --init --recursive
```

### 🔍 验证子模块

检查子模块是否正确加载：
```bash
ls -la ext/zxing/zxing-cpp/
# 应该显示 zxing-cpp 的源代码文件
```

如果目录为空或不存在文件，运行：
```bash
git submodule update --init --recursive
```

### 🛠️ 开发者说明

#### 更新子模块到最新版本
```bash
cd ext/zxing/zxing-cpp
git fetch origin
git checkout master
git pull origin master
cd ../../..
git add ext/zxing/zxing-cpp
git commit -m "更新 zxing-cpp 子模块到最新版本"
```

#### 检查子模块状态
```bash
git submodule status
```

### 🔧 使用 specific_install 安装

如果你使用 `gem specific_install` 安装，它会自动处理子模块：

```bash
gem install specific_install
gem specific_install https://github.com/liv09370/zxing.git
```

这种方法会自动：
1. 克隆主仓库
2. 初始化并更新子模块
3. 编译和安装 gem

### ❓ 常见问题

**Q: 编译时提示找不到 zxing-cpp 源文件？**
A: 运行 `git submodule update --init --recursive`

**Q: 子模块目录存在但为空？**
A: 删除目录并重新初始化：
```bash
rm -rf ext/zxing/zxing-cpp
git submodule update --init --recursive
```

**Q: 为什么不直接包含源代码？**
A: 使用子模块可以：
- 保持与上游同步
- 减少仓库大小
- 便于跟踪 zxing-cpp 版本

### 📚 相关链接

- [上游 zxing-cpp 项目](https://github.com/zxing-cpp/zxing-cpp)
- [Git 子模块文档](https://git-scm.com/book/en/v2/Git-Tools-Submodules) 