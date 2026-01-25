# -*- coding: utf-8 -*-
"""
Linux系统工具
提供各种Linux系统相关的实用工具
"""
import os
import subprocess
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property
from ..utils.logger import get_logger

logger = get_logger("linux_tools")


class LinuxTools(QObject):
    """Linux系统工具类"""
    
    # 信号
    messageChanged = Signal(str)  # 消息信号
    progressChanged = Signal(int)  # 进度信号
    operationFinished = Signal(bool, str)  # 操作完成信号 (成功/失败, 消息)
    
    def __init__(self):
        super().__init__()
        self._message = ""
        self._progress = 0
    
    @Property(str, notify=messageChanged)
    def message(self):
        """当前消息"""
        return self._message
    
    def _set_message(self, msg):
        """设置消息"""
        self._message = msg
        self.messageChanged.emit(msg)
        logger.info(f"[Linux工具] {msg}")
    
    @Property(int, notify=progressChanged)
    def progress(self):
        """当前进度"""
        return self._progress
    
    def _set_progress(self, value):
        """设置进度"""
        self._progress = value
        self.progressChanged.emit(value)
    
    @Slot()
    def initializeUbuntu(self):
        """初始化Ubuntu系统"""
        try:
            self._set_message("开始初始化Ubuntu系统...")
            self._set_progress(0)
            
            # 获取脚本路径
            script_dir = Path(__file__).parent / "resources" / "Init" / "Ubuntu"
            init_script = script_dir / "init.sh"
            
            if not init_script.exists():
                self._set_message(f"❌ 初始化脚本不存在: {init_script}")
                self.operationFinished.emit(False, "初始化脚本不存在")
                return
            
            self._set_progress(20)
            
            # 确保脚本有执行权限
            os.chmod(init_script, 0o755)
            
            # 执行bash脚本
            # 注意: 某些操作可能需要sudo权限
            result = subprocess.run(
                ["bash", str(init_script)],
                capture_output=True,
                text=True
            )
            
            self._set_progress(80)
            
            output = result.stdout if result.stdout else ""
            error = result.stderr if result.stderr else ""
            
            self._set_progress(100)
            
            if result.returncode == 0:
                self._set_message("✅ Ubuntu系统初始化完成")
                self.operationFinished.emit(True, f"初始化完成\n\n{output}")
            else:
                self._set_message(f"⚠️ 初始化脚本执行返回代码: {result.returncode}")
                self.operationFinished.emit(True, f"初始化完成，返回代码: {result.returncode}\n\n标准输出:\n{output}\n\n错误输出:\n{error}")
        
        except Exception as e:
            self._set_message(f"❌ 初始化失败: {str(e)}")
            self.operationFinished.emit(False, f"初始化失败: {str(e)}")
    
    @Slot(result=str)
    def getSystemInfo(self):
        """获取系统信息"""
        try:
            # 获取系统信息
            info_lines = []
            
            # 获取发行版信息
            try:
                result = subprocess.run(
                    ["lsb_release", "-a"],
                    capture_output=True,
                    text=True
                )
                if result.returncode == 0:
                    info_lines.append("发行版信息:")
                    info_lines.append(result.stdout)
            except:
                pass
            
            # 获取内核版本
            try:
                result = subprocess.run(
                    ["uname", "-r"],
                    capture_output=True,
                    text=True
                )
                if result.returncode == 0:
                    info_lines.append(f"内核版本: {result.stdout.strip()}")
            except:
                pass
            
            # 获取CPU信息
            try:
                result = subprocess.run(
                    ["lscpu"],
                    capture_output=True,
                    text=True
                )
                if result.returncode == 0:
                    info_lines.append("\nCPU信息:")
                    info_lines.append(result.stdout)
            except:
                pass
            
            # 获取内存信息
            try:
                result = subprocess.run(
                    ["free", "-h"],
                    capture_output=True,
                    text=True
                )
                if result.returncode == 0:
                    info_lines.append("\n内存信息:")
                    info_lines.append(result.stdout)
            except:
                pass
            
            system_info = "\n".join(info_lines) if info_lines else "无法获取系统信息"
            self._set_message("✅ 系统信息已获取")
            return system_info
            
        except Exception as e:
            error_msg = f"获取系统信息失败: {str(e)}"
            self._set_message(f"❌ {error_msg}")
            return error_msg
    
    @Slot(result=bool)
    def checkVirtualization(self):
        """检查是否在虚拟机中运行"""
        try:
            result = subprocess.run(
                ["systemd-detect-virt", "--quiet"],
                capture_output=True
            )
            is_virt = result.returncode == 0
            msg = "✅ 当前运行在虚拟机中" if is_virt else "✅ 当前运行在物理机上"
            self._set_message(msg)
            return is_virt
        except Exception as e:
            self._set_message(f"❌ 检测失败: {str(e)}")
            return False
    
    @Slot(result=bool)
    def checkDesktopEnvironment(self):
        """检查是否为桌面环境"""
        try:
            # 检查是否安装了桌面环境
            result1 = subprocess.run(
                ["dpkg", "-l"],
                capture_output=True,
                text=True
            )
            
            has_desktop = False
            if result1.returncode == 0:
                desktop_packages = ['gnome-shell', 'plasma-desktop', 'xfce4-session', 'mate-session']
                for pkg in desktop_packages:
                    if pkg in result1.stdout:
                        has_desktop = True
                        break
            
            if not has_desktop:
                # 检查是否有.desktop文件
                try:
                    result2 = subprocess.run(
                        ["ls", "/usr/share/xsessions/"],
                        capture_output=True
                    )
                    if result2.returncode == 0 and result2.stdout:
                        has_desktop = True
                except:
                    pass
            
            msg = "✅ 检测到桌面环境" if has_desktop else "✅ 未检测到桌面环境（服务器版本）"
            self._set_message(msg)
            return has_desktop
            
        except Exception as e:
            self._set_message(f"❌ 检测失败: {str(e)}")
            return False
