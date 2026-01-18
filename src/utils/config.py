# -*- coding: utf-8 -*-
"""
配置管理
应用程序配置常量
"""
import tomli
from pathlib import Path

# 读取版本信息
def _read_version():
    """从 pyproject.toml 读取版本信息"""
    try:
        pyproject_path = Path(__file__).parent.parent.parent / "pyproject.toml"
        with open(pyproject_path, "rb") as f:
            data = tomli.load(f)
            return data.get("project", {}).get("version", "0.0.0")
    except Exception:
        return "0.0.0" # 表示未知，不使用“未知”字符串是为了避免奇怪的问题

# 应用信息
APP_NAME = "MyTool"
APP_VERSION = _read_version()
APP_TITLE = f"{APP_NAME} - 多功能工具箱"

# 窗口配置
WINDOW_WIDTH = 1200
WINDOW_HEIGHT = 800
WINDOW_TITLE = APP_TITLE

# 侧边栏配置
SIDEBAR_WIDTH = 200
SIDEBAR_COLLAPSED_WIDTH = 60

# 工具栏配置
TOOLBAR_HEIGHT = 50

# 标签栏配置
TABBAR_HEIGHT = 40

# 颜色配置
COLOR_PRIMARY = "#2196F3"
COLOR_BACKGROUND = "#FFFFFF"
COLOR_SIDEBAR = "#F5F5F5"
COLOR_BORDER = "#E0E0E0"
COLOR_TEXT = "#333333"
COLOR_TEXT_SECONDARY = "#666666"
COLOR_HOVER = "#E3F2FD"
COLOR_SELECTED = "#BBDEFB"

# 字体配置
FONT_SIZE_NORMAL = 14
FONT_SIZE_SMALL = 12
FONT_SIZE_LARGE = 16
