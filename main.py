# -*- coding: utf-8 -*-
"""
MyTool - 多功能工具箱
主入口文件
"""
import os
import sys
from pathlib import Path
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterSingletonType
from src.app import Application
from src.utils.config import APP_NAME, APP_VERSION
from src.utils.logger import init_logging, install_qt_message_handler, get_logger


if __name__ == "__main__":
    # 更改控制台编码，让qml可以正常显示中文
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except Exception:
        pass
    
    debug_env = os.getenv("MYTOOL_DEBUG", "").lower() in {"1", "true", "yes", "on"}
    init_logging(APP_NAME, log_level=os.getenv("MYTOOL_LOG_LEVEL"), debug=debug_env)
    install_qt_message_handler()
    logger = get_logger("main")
    
    # 创建应用程序实例
    app = QGuiApplication(sys.argv)
    app.setApplicationName(APP_NAME)
    app.setApplicationVersion(APP_VERSION)
    # app.setOrganizationName("MyCompany")
    
    engine = QQmlApplicationEngine()
    theme_qml = Path(__file__).resolve().parent / "ui" / "theme" / "Theme.qml"
    qmlRegisterSingletonType(QUrl.fromLocalFile(str(theme_qml)), "MyTool", 1, 0, "Theme")
    
    # 创建 Application 对象
    application = Application()
    
    # 注册到上下文
    context = engine.rootContext()
    context.setContextProperty("app", application)
    context.setContextProperty("toolManager", application.get_tool_manager())
    context.setContextProperty("windowsTools", application.get_windows_tools())
    context.setContextProperty("linuxTools", application.get_linux_tools())
    context.setContextProperty("gitTools", application.get_git_tools())
    context.setContextProperty("qtTools", application.get_qt_tools())
    context.setContextProperty("fileTimeTools", application.get_file_time_tools())
    context.setContextProperty("fileFilterTools", application.get_file_filter_tools())
    
    # 加载 QML 文件
    qml_file = Path(__file__).resolve().parent / "ui" / "Main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))
    
    if not engine.rootObjects():
        logger.error("QML 加载失败")
        sys.exit(-1)
    
    # 运行应用程序
    sys.exit(app.exec())
