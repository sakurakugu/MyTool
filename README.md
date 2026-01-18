# MyTool - 多功能工具箱

一个基于 PySide6 和 QML 的多功能工具箱应用程序（自用）。

## 快速开始

```
pip install -r requirements.txt
python main.py
```

## 项目结构

```
MyTool/
├── main.py                 # 应用程序入口
├── src/                    # Python 源代码
│   ├── __init__.py
│   ├── app.py             # 应用程序主类
│   ├── models/            # 数据模型
│   │   ├── __init__.py
│   │   ├── tool_manager.py      # 工具管理器
│   │   └── sidebar_model.py     # 侧边栏模型
│   └── utils/             # 工具函数
│       ├── __init__.py
│       └── config.py            # 配置文件
├── ui/                    # QML 界面文件
│   ├── Main.qml           # 主窗口
│   ├── components/        # UI 组件
│   │   ├── ToolBarComponent.qml    # 工具栏
│   │   ├── TabBarComponent.qml     # 标签栏
│   │   ├── SidebarComponent.qml    # 侧边栏
│   │   ├── SidebarItem.qml         # 侧边栏项
│   │   └── ContentArea.qml         # 内容区域
│   └── pages/             # 页面
│       ├── AllToolsPage.qml        # 全部工具页面
│       ├── TextToolPage.qml        # 文本工具页面
│       ├── ImageToolPage.qml       # 图片工具页面
│       ├── CodeToolPage.qml        # 代码工具页面
│       ├── FileToolPage.qml        # 文件工具页面
│       ├── SettingsPage.qml        # 设置页面
│       └── ProfilePage.qml         # 个人中心页面
├── resources/             # 资源文件
│   └── icons/            # 图标
├── requirements.txt       # Python 依赖
└── pyproject.toml        # 项目配置
```

## 功能特性

### 界面布局

- **顶部工具栏**：包含应用标题、搜索框和功能按钮
- **标签栏**：管理多个打开的工具标签页
- **左侧边栏**：
  - 全部工具（默认首页）
  - 各类工具快捷入口
  - 底部固定：个人中心和设置
- **中间内容区**：显示当前选中工具的页面

### 内置工具

1. **文本工具（例子）** 📝
   - 大小写转换
   - Base64 编码/解码
   - URL 编码/解码

2. **图片工具（例子）** 🖼️
   - 图片压缩
   - 格式转换
   - 图片裁剪

3. **代码工具（例子）** 💻
   - JSON 格式化
   - XML 格式化
   - 代码压缩

4. **文件工具（例子）** 📁
   - 文件压缩/解压
   - 批量重命名

## 安装和运行

### 环境要求

- Python 3.8+
- PySide6

### 安装依赖

```bash
pip install -r requirements.txt
```

### 运行应用

```bash
python main.py
```

## 开发指南

### 添加新工具

1. 在 `src/models/tool_manager.py` 中注册新工具
2. 在 `src/models/sidebar_model.py` 中添加侧边栏项
3. 在 `ui/pages/` 创建新的工具页面 QML 文件
4. 在 `ui/components/ContentArea.qml` 中添加页面路由

### 代码规范

- Python 代码遵循 PEP 8 规范
- QML 代码使用 4 空格缩进
- 所有代码文件包含中文注释说明

## 技术栈

- **Python**: 应用程序逻辑
- **PySide6**: Qt for Python 框架
- **QML**: 声明式 UI 框架
- **Qt Quick Controls**: 现代化 UI 组件

## 许可证

MIT License

## 更新日志

### v1.0.0 (2026-01-18)
- 初始版本发布
- 实现基本框架和 UI 布局
- 添加文本、图片、代码、文件四类工具
