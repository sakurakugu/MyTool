# -*- coding: utf-8 -*-
"""
MyTool - 多功能工具箱
主入口文件
"""
import sys
from pathlib import Path
from PySide6.QtCore import QUrl, qInstallMessageHandler
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from src.app import Application


if __name__ == "__main__":
    # 更改控制台编码，让qml可以正常显示中文
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except Exception:
        pass
    
    def _qt_msg_handler(mode, context, message):
        try:
            print(f"qml: {message}")
        except Exception:
            pass
    
    qInstallMessageHandler(_qt_msg_handler)
    
    # 创建应用程序实例
    app = QGuiApplication(sys.argv)
    app.setApplicationName("MyTool")
    app.setOrganizationName("MyCompany")
    
    engine = QQmlApplicationEngine()
    
    # 创建 Application 对象
    application = Application()
    
    # 注册到上下文
    context = engine.rootContext()
    context.setContextProperty("app", application)
    context.setContextProperty("toolManager", application.get_tool_manager())
    
    # 加载 QML 文件
    qml_file = Path(__file__).resolve().parent / "ui" / "Main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))
    
    if not engine.rootObjects():
        print("错误：QML 加载失败")
        sys.exit(-1)
    
    # 运行应用程序
    sys.exit(app.exec())
