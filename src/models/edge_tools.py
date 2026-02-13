# -*- coding: utf-8 -*-
"""
Edge 浏览器工具
配置 Edge 不安全内容允许 URL 策略
"""
import winreg
import ctypes
import subprocess
from PySide6.QtCore import QObject, Signal, Slot, Property
from ..utils.logger import get_logger

logger = get_logger("edge_tools")


class EdgeTools(QObject):
    """Edge工具类"""
    
    # 信号
    messageChanged = Signal(str)  # 消息信号
    patternsChanged = Signal(list)  # URL规则列表变化信号
    operationFinished = Signal(bool, str)  # 操作完成信号 (成功/失败, 消息)
    
    POLICY_KEY_PATH = r"SOFTWARE\Policies\Microsoft\Edge\InsecureContentAllowedForUrls"
    
    def __init__(self):
        super().__init__()
        self._message = ""
        self._patterns = []
        self._load_patterns()
    
    def _is_admin(self):
        """检查是否有管理员权限"""
        try:
            return ctypes.windll.shell32.IsUserAnAdmin() == 1
        except Exception:
            return False
    
    @Property(str, notify=messageChanged)
    def message(self):
        """当前消息"""
        return self._message
    
    def _set_message(self, msg):
        """设置消息"""
        self._message = msg
        self.messageChanged.emit(msg)
        logger.info(f"[Edge工具] {msg}")
    
    @Property(list, notify=patternsChanged)
    def patterns(self):
        """获取所有URL规则"""
        return self._patterns
    
    def _load_patterns(self):
        """从注册表加载现有的URL规则"""
        self._patterns = []
        try:
            key = winreg.OpenKey(
                winreg.HKEY_LOCAL_MACHINE,
                self.POLICY_KEY_PATH,
                0,
                winreg.KEY_READ
            )
        except FileNotFoundError:
            logger.info("注册表路径不存在，将创建新的")
            return
        
        try:
            index = 0
            while True:
                try:
                    name, value, _ = winreg.EnumValue(key, index)
                    if name.isdigit() and isinstance(value, str) and value.strip():
                        self._patterns.append(value.strip())
                    index += 1
                except OSError:
                    break
        finally:
            winreg.CloseKey(key)
        
        self.patternsChanged.emit(self._patterns)
    
    @Slot()
    def refreshPatterns(self):
        """刷新URL规则列表"""
        self._load_patterns()
        self._set_message(f"✅ 已刷新，当前 {len(self._patterns)} 条规则")
    
    @Slot(str)
    def addPattern(self, pattern):
        """添加新的URL规则"""
        if not self._is_admin():
            self._set_message("❌ 需要管理员权限")
            self.operationFinished.emit(False, "需要管理员权限")
            return
        
        pattern = pattern.strip()
        if not pattern:
            self._set_message("❌ 规则不能为空")
            self.operationFinished.emit(False, "规则不能为空")
            return
        
        if pattern in self._patterns:
            self._set_message("⚠️ 规则已存在")
            self.operationFinished.emit(False, "规则已存在")
            return
        
        try:
            self._patterns.append(pattern)
            self._write_patterns()
            self._set_message(f"✅ 已添加: {pattern}")
            self.operationFinished.emit(True, f"已添加规则: {pattern}")
        except Exception as e:
            self._set_message(f"❌ 添加失败: {str(e)}")
            self.operationFinished.emit(False, str(e))
    
    @Slot(int)
    def removePattern(self, index):
        """删除指定索引的URL规则"""
        if not self._is_admin():
            self._set_message("❌ 需要管理员权限")
            self.operationFinished.emit(False, "需要管理员权限")
            return
        
        if index < 0 or index >= len(self._patterns):
            self._set_message("❌ 无效的索引")
            self.operationFinished.emit(False, "无效的索引")
            return
        
        try:
            removed = self._patterns.pop(index)
            self._write_patterns()
            self._set_message(f"✅ 已删除: {removed}")
            self.operationFinished.emit(True, f"已删除规则: {removed}")
        except Exception as e:
            self._set_message(f"❌ 删除失败: {str(e)}")
            self.operationFinished.emit(False, str(e))
    
    @Slot(str, str)
    def updatePattern(self, old_pattern, new_pattern):
        """更新指定的URL规则"""
        if not self._is_admin():
            self._set_message("❌ 需要管理员权限")
            self.operationFinished.emit(False, "需要管理员权限")
            return
        
        old_pattern = old_pattern.strip()
        new_pattern = new_pattern.strip()
        
        if not new_pattern:
            self._set_message("❌ 新规则不能为空")
            self.operationFinished.emit(False, "新规则不能为空")
            return
        
        try:
            if old_pattern in self._patterns:
                idx = self._patterns.index(old_pattern)
                self._patterns[idx] = new_pattern
                self._write_patterns()
                self._set_message(f"✅ 已更新: {old_pattern} -> {new_pattern}")
                self.operationFinished.emit(True, f"已更新规则")
            else:
                self._set_message("❌ 找不到该规则")
                self.operationFinished.emit(False, "找不到该规则")
        except Exception as e:
            self._set_message(f"❌ 更新失败: {str(e)}")
            self.operationFinished.emit(False, str(e))
    
    def _write_patterns(self):
        """将URL规则写入注册表"""
        try:
            key = winreg.CreateKey(winreg.HKEY_LOCAL_MACHINE, self.POLICY_KEY_PATH)
            try:
                # 删除所有数字键名，避免残留
                to_delete = []
                index = 0
                while True:
                    try:
                        name, _, _ = winreg.EnumValue(key, index)
                        if name.isdigit():
                            to_delete.append(name)
                        index += 1
                    except OSError:
                        break
                
                for name in to_delete:
                    winreg.DeleteValue(key, name)
                
                # 重写为连续编号
                for idx, pattern in enumerate(self._patterns, start=1):
                    winreg.SetValueEx(key, str(idx), 0, winreg.REG_SZ, pattern)
            finally:
                winreg.CloseKey(key)
            
            self.patternsChanged.emit(self._patterns)
        except Exception as e:
            logger.error(f"写入注册表失败: {str(e)}")
            raise
    
    @Slot(bool)
    def restartEdge(self, should_restart):
        """重启 Edge 浏览器"""
        if not should_restart:
            self._set_message("👉 可选：手动重启 Edge 让策略即时生效")
            return
        
        try:
            # 关闭 Edge
            subprocess.run(
                ["taskkill", "/F", "/IM", "msedge.exe"],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                check=False
            )
            # 启动 Edge
            subprocess.Popen(["cmd", "/c", "start", "", "msedge"])
            self._set_message("✅ 已重启 Edge")
            self.operationFinished.emit(True, "已重启 Edge")
        except Exception as e:
            self._set_message(f"❌ 重启失败: {str(e)}")
            self.operationFinished.emit(False, str(e))
    
    @Slot(result=bool)
    def isAdmin(self):
        """检查是否有管理员权限"""
        return self._is_admin()
    
    @Slot()
    def clearAllPatterns(self):
        """清除所有规则"""
        if not self._is_admin():
            self._set_message("❌ 需要管理员权限")
            self.operationFinished.emit(False, "需要管理员权限")
            return
        
        try:
            self._patterns.clear()
            self._write_patterns()
            self._set_message("✅ 已清除所有规则")
            self.operationFinished.emit(True, "已清除所有规则")
        except Exception as e:
            self._set_message(f"❌ 清除失败: {str(e)}")
            self.operationFinished.emit(False, str(e))
