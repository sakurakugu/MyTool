# -*- coding: utf-8 -*-
"""
应用程序核心类
负责应用程序的初始化和主要逻辑
"""
import sys
from pathlib import Path
from PySide6.QtCore import QObject, Slot, Signal, Property, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterSingletonType

from .models.tool_manager import ToolManager
from .models.windows_tools import WindowsTools
from .models.linux_tools import LinuxTools
from .models.git_tools import GitTools
from .models.qt_tools import QtTools
from .models.file_time_tools import FileTimeTools
from .models.file_filter_tools import FileFilterTools
from .models.edge_tools import EdgeTools
from .utils.config import APP_NAME, APP_VERSION
from .utils.logger import get_logger

logger = get_logger("app")


class Application(QObject):
    """应用程序主类"""
    
    # 信号
    toolChanged = Signal(str)  # 工具切换信号
    addTabRequested = Signal(str, str)
    
    def __init__(self):
        super().__init__()
        self._current_tool = "all_tools"  # 当前选中的工具
        self._tool_manager = ToolManager()  # 工具管理器
        self._app_name = APP_NAME
        self._app_version = APP_VERSION
        
        # 创建工具实例
        self._windows_tools = WindowsTools()
        self._linux_tools = LinuxTools()
        self._git_tools = GitTools()
        self._qt_tools = QtTools()
        self._file_time_tools = FileTimeTools()
        self._file_filter_tools = FileFilterTools()
        self._edge_tools = EdgeTools()
        
    @Property(str, notify=toolChanged)
    def currentTool(self):
        """当前工具属性"""
        return self._current_tool
    
    @currentTool.setter
    def currentTool(self, tool):
        """设置当前工具"""
        if self._current_tool != tool:
            self._current_tool = tool
            self.toolChanged.emit(tool)
    
    @Slot(str)
    def switchTool(self, tool_id):
        """切换工具"""
        logger.info(f"切换到工具: {tool_id}")
        self.currentTool = tool_id
    
    @Slot()
    def openSettings(self):
        """打开设置"""
        logger.info("打开设置")
        self.currentTool = "settings"
    
    @Property(str, constant=True)
    def appName(self):
        """应用名称属性"""
        return self._app_name
    
    @Property(str, constant=True)
    def appVersion(self):
        """应用版本属性"""
        return self._app_version
    
    @Slot()
    def openProfile(self):
        """打开个人中心"""
        logger.info("打开个人中心")
        self.currentTool = "profile"
    
    @Slot(str)
    def requestAddTab(self, tool_id):
        tool = self._tool_manager.get_tool_by_id(tool_id)
        title = tool["name"] if tool and "name" in tool else tool_id
        self.addTabRequested.emit(tool_id, title)

    def get_tool_manager(self):
        """获取工具管理器"""
        return self._tool_manager
    
    def get_windows_tools(self):
        """获取Windows工具"""
        return self._windows_tools
    
    def get_linux_tools(self):
        """获取Linux工具"""
        return self._linux_tools
    
    def get_git_tools(self):
        """获取Git工具"""
        return self._git_tools
    
    def get_qt_tools(self):
        """获取Qt工具"""
        return self._qt_tools
    
    def get_file_time_tools(self):
        """获取文件时间工具"""
        return self._file_time_tools
    
    def get_file_filter_tools(self):
        """获取文件过滤转移工具"""
        return self._file_filter_tools
    
    def get_edge_tools(self):
        """获取Edge工具"""
        return self._edge_tools
    
    def get_sidebar_model(self):
        """获取侧边栏模型"""
        return self._sidebar_model
