# -*- coding: utf-8 -*-
"""
工具管理器
管理所有可用的工具
"""
from PySide6.QtCore import QObject, Property, Signal, Slot


class ToolManager(QObject):
    """工具管理器类"""
    
    # 信号
    toolsChanged = Signal()
    
    def __init__(self):
        super().__init__()
        # 定义所有可用的工具
        self._tools = [
            {
                "id": "all_tools",
                "name": "全部工具",
                "icon": "⊞",
                "category": "main"
            },
            {
                "id": "windows_tool",
                "name": "Windows工具",
                "icon": "🪟",
                "category": "tool"
            },
            {
                "id": "git_tool",
                "name": "Git工具",
                "icon": "🔧",
                "category": "tool"
            },
            {
                "id": "qt_tool",
                "name": "Qt翻译工具",
                "icon": "🌐",
                "category": "tool"
            },
            {
                "id": "text_tool",
                "name": "文本工具（例子）",
                "icon": "📝",
                "category": "tool"
            },
            {
                "id": "image_tool",
                "name": "图片工具（例子）",
                "icon": "🖼️",
                "category": "tool"
            },
            {
                "id": "code_tool",
                "name": "代码工具（例子）",
                "icon": "💻",
                "category": "tool"
            },
            {
                "id": "file_tool",
                "name": "文件工具（例子）",
                "icon": "📁",
                "category": "tool"
            },
            {
                "id": "file_time_tool",
                "name": "文件时间修改",
                "icon": "🕒",
                "category": "tool"
            }
        ]
    
    @Property('QVariantList', notify=toolsChanged)
    def tools(self):
        """获取所有工具列表"""
        return self._tools
    @Slot(str, result='QVariant')
    def get_tool_by_id(self, tool_id):
        """根据ID获取工具"""
        for tool in self._tools:
            if tool["id"] == tool_id:
                return tool
        return None
