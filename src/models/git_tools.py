# -*- coding: utf-8 -*-
"""
Git工具
提供Git相关的实用工具
"""
import os
import sys
import shutil
import subprocess
import urllib.request
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property, QThread
from ..utils.logger import get_logger

logger = get_logger("git_tools")


class GitTranslationWorker(QThread):
    """Git翻译下载和安装的工作线程"""
    
    progressChanged = Signal(int, str)  # 进度和消息
    finished = Signal(bool, str)  # 完成信号 (成功/失败, 消息)
    
    def run(self):
        """执行翻译安装"""
        try:
            # 检查是否在Windows系统
            if sys.platform != "win32":
                self.finished.emit(False, "该功能仅适用于 Windows 系统")
                return
            
            self.progressChanged.emit(10, "检查依赖库...")
            
            # 检查并安装 polib 库
            try:
                import polib
            except ImportError:
                self.progressChanged.emit(15, "正在安装 polib 库...")
                subprocess.check_call([sys.executable, "-m", "pip", "install", "polib"])
                import polib
            
            self.progressChanged.emit(20, "查找 Git 安装路径...")
            
            # 获取 git 安装路径
            git_path = shutil.which("git")
            if not git_path:
                self.finished.emit(False, "未找到 Git 安装路径，请确保 Git 已安装并在系统路径中")
                return
            
            self.progressChanged.emit(30, f"找到 Git: {git_path}")
            
            # 切换到临时目录并创建翻译文件夹
            temp_dir = os.environ.get("TEMP", os.getcwd())
            temp_dir = os.path.join(temp_dir, "git中文翻译")
            os.makedirs(temp_dir, exist_ok=True)
            os.chdir(temp_dir)
            
            self.progressChanged.emit(40, "正在下载中文翻译文件...")
            
            # 下载 Git 中文翻译文件
            po_url = "https://raw.githubusercontent.com/git/git/master/po/zh_CN.po"
            po_file = "zh_CN.po"
            
            try:
                urllib.request.urlretrieve(po_url, po_file)
            except Exception as e:
                self.finished.emit(False, f"下载翻译文件失败: {str(e)}")
                return
            
            self.progressChanged.emit(60, "正在转换翻译文件...")
            
            # 将 zh_CN.po 文件转换为 git.mo 文件
            mo_file = "git.mo"
            try:
                import polib
                po = polib.pofile(po_file)
                po.save_as_mofile(mo_file)
            except Exception as e:
                self.finished.emit(False, f"转换翻译文件失败: {str(e)}")
                return
            
            self.progressChanged.emit(80, "正在安装翻译文件...")
            
            # 根据 git 的安装路径定位目标目录并创建
            git_dir = os.path.dirname(git_path)
            target_dir = os.path.abspath(os.path.join(git_dir, "..", "mingw64", "share", "locale", "zh_CN", "LC_MESSAGES"))
            os.makedirs(target_dir, exist_ok=True)
            
            # 复制 git.mo 到目标目录
            target_path = os.path.join(target_dir, "git.mo")
            try:
                shutil.copyfile(os.path.join(temp_dir, mo_file), target_path)
            except Exception as e:
                self.finished.emit(False, f"复制文件失败: {str(e)}\n可能需要管理员权限")
                return
            
            self.progressChanged.emit(100, "安装完成！")
            self.finished.emit(True, "✅ 已将 Git 的界面翻译为中文\n重启终端即可生效")
            
        except Exception as e:
            self.finished.emit(False, f"发生错误: {str(e)}")


class GitTools(QObject):
    """Git工具类"""
    
    # 信号
    messageChanged = Signal(str)  # 消息信号
    progressChanged = Signal(int)  # 进度信号 (0-100)
    operationFinished = Signal(bool, str)  # 操作完成信号 (成功/失败, 消息)
    
    def __init__(self):
        super().__init__()
        self._message = ""
        self._progress = 0
        self._worker = None
    
    @Property(str, notify=messageChanged)
    def message(self):
        """当前消息"""
        return self._message
    
    def _set_message(self, msg):
        """设置消息"""
        self._message = msg
        self.messageChanged.emit(msg)
        logger.info(f"[Git工具] {msg}")
    
    @Property(int, notify=progressChanged)
    def progress(self):
        """当前进度"""
        return self._progress
    
    def _set_progress(self, value):
        """设置进度"""
        self._progress = value
        self.progressChanged.emit(value)
    
    @Slot()
    def installChineseTranslation(self):
        """安装Git中文翻译"""
        if self._worker and self._worker.isRunning():
            self._set_message("⚠️ 已有任务正在运行...")
            return
        
        self._set_message("开始安装Git中文翻译...")
        self._set_progress(0)
        
        # 创建工作线程
        self._worker = GitTranslationWorker()
        
        # 连接信号
        self._worker.progressChanged.connect(self._on_progress_changed)
        self._worker.finished.connect(self._on_worker_finished)
        
        # 启动线程
        self._worker.start()
    
    def _on_progress_changed(self, progress, message):
        """处理进度变化"""
        self._set_progress(progress)
        self._set_message(message)
    
    def _on_worker_finished(self, success, message):
        """处理工作完成"""
        self._set_message(message)
        self.operationFinished.emit(success, message)
        
        # 清理工作线程
        if self._worker:
            self._worker.deleteLater()
            self._worker = None
    
    @Slot(result=bool)
    def checkGitInstalled(self):
        """检查Git是否已安装"""
        try:
            git_path = shutil.which("git")
            if git_path:
                self._set_message(f"✅ Git已安装: {git_path}")
                return True
            else:
                self._set_message("❌ 未检测到Git安装")
                return False
        except Exception as e:
            self._set_message(f"❌ 检查失败: {str(e)}")
            return False
    
    @Slot(result=str)
    def getGitVersion(self):
        """获取Git版本"""
        try:
            result = subprocess.run(['git', '--version'], 
                                    capture_output=True, 
                                    text=True, 
                                    encoding='utf-8')
            if result.returncode == 0:
                version = result.stdout.strip()
                self._set_message(f"✅ {version}")
                return version
            else:
                self._set_message("❌ 无法获取Git版本")
                return ""
        except Exception as e:
            self._set_message(f"❌ 获取版本失败: {str(e)}")
            return ""
