# -*- coding: utf-8 -*-
"""
文件时间修改工具
提供批量修改文件时间属性的功能
"""
import os
import re
import subprocess
from pathlib import Path
from datetime import datetime
from PySide6.QtCore import QObject, Signal, Slot, Property


class FileTimeTools(QObject):
    """文件时间修改工具类"""
    
    # 信号
    messageChanged = Signal(str)  # 消息信号
    progressChanged = Signal(int, int)  # 进度信号 (当前进度, 总数)
    operationFinished = Signal(bool, str)  # 操作完成信号 (成功/失败, 消息)
    fileProcessed = Signal(str, bool, str)  # 文件处理完成 (文件路径, 成功/失败, 消息)
    
    def __init__(self):
        super().__init__()
        self._message = ""
        self._ps_process = None
        self._init_powershell()
    
    def _init_powershell(self):
        """初始化PowerShell进程"""
        try:
            # 获取PowerShell脚本路径
            script_dir = Path(__file__).resolve().parent.parent / "resources"
            script_path = script_dir / "modify_file_time.ps1"
            
            # 启动PowerShell进程
            self._ps_process = subprocess.Popen(
                ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", "-"],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                encoding='utf-8'
            )
            
            # 加载PowerShell脚本
            if script_path.exists():
                load_cmd = f'. "{script_path}"\n'
                self._ps_process.stdin.write(load_cmd)
                self._ps_process.stdin.flush()
                self._set_message("✅ PowerShell环境初始化成功")
            else:
                self._set_message(f"⚠️ PowerShell脚本未找到: {script_path}")
        except Exception as e:
            self._set_message(f"❌ PowerShell初始化失败: {str(e)}")
            self._ps_process = None
    
    def __del__(self):
        """清理资源"""
        self._cleanup_powershell()
    
    def _cleanup_powershell(self):
        """清理PowerShell进程"""
        if self._ps_process:
            try:
                self._ps_process.stdin.close()
                self._ps_process.kill()
                self._ps_process = None
            except Exception:
                pass
    
    @Property(str, notify=messageChanged)
    def message(self):
        """当前消息"""
        return self._message
    
    def _set_message(self, msg):
        """设置消息"""
        self._message = msg
        self.messageChanged.emit(msg)
        print(f"[文件时间工具] {msg}")
    
    def _extract_time_from_filename(self, file_path):
        """从文件名中提取时间
        
        Args:
            file_path: 文件路径
            
        Returns:
            str: 时间字符串 (格式: yyyy-MM-dd HH:mm:ss)，如果提取失败返回None
        """
        try:
            # 获取文件名（不含扩展名）
            filename = Path(file_path).stem.strip()
            # 替换常见分隔符为连字符
            filename = filename.replace("_", "-").replace(" ", "-")
            
            # 只保留数字和连字符
            filename = "".join([c for c in filename if c.isdigit() or c in "-_"])
            
            # 去除首尾非数字字符
            if filename and not filename[0].isdigit():
                filename = filename[1:]
            if filename and not filename[-1].isdigit():
                filename = filename[:-1]
            
            # 尝试多种日期时间格式
            formats = [
                "%Y%m%d_%H%M%S",
                "%Y%m%d%H%M%S",
                "%Y%m%d-%H%M%S",
                "%Y-%m-%d%H%M%S",
                "%Y-%m-%d_%H-%M-%S",
                "%Y-%m-%d%H-%M-%S",
                "%Y-%m-%d-%H-%M-%S",   # 新增：2026-01-14-15-48-00
                "%Y-%m-%d-%H-%M",      # 新增：2026-01-14-15-48
            ]
            
            for fmt in formats:
                try:
                    time_obj = datetime.strptime(filename, fmt)
                    return time_obj.strftime("%Y-%m-%d %H:%M:%S")
                except ValueError:
                    continue
            
            return None
        except Exception as e:
            print(f"从文件名提取时间失败: {str(e)}")
            return None
    
    def _extract_time_from_exif(self, file_path):
        """从图片EXIF信息中提取时间
        
        Args:
            file_path: 文件路径
            
        Returns:
            str: 时间字符串 (格式: yyyy-MM-dd HH:mm:ss)，如果提取失败返回None
        """
        try:
            from PIL import Image
            from PIL.ExifTags import TAGS
            
            # 检查是否为图片文件
            image_extensions = ['.jpg', '.jpeg', '.png', '.tiff', '.bmp']
            if Path(file_path).suffix.lower() not in image_extensions:
                return None
            
            # 打开图片并读取EXIF
            image = Image.open(file_path)
            exif = image._getexif()
            
            if exif:
                for tag, value in exif.items():
                    tag_name = TAGS.get(tag, tag)
                    if tag_name == "DateTimeOriginal":
                        # EXIF时间格式: "YYYY:MM:DD HH:MM:SS"
                        time_obj = datetime.strptime(value, "%Y:%m:%d %H:%M:%S")
                        return time_obj.strftime("%Y-%m-%d %H:%M:%S")
            
            return None
        except ImportError:
            # 如果Pillow未安装，返回None
            return None
        except Exception as e:
            print(f"从EXIF提取时间失败: {str(e)}")
            return None
    
    def _modify_file_time_ps(self, file_path, time_str, modify_type):
        """使用PowerShell修改文件时间
        
        Args:
            file_path: 文件路径
            time_str: 时间字符串 (格式: yyyy-MM-dd HH:mm:ss)
            modify_type: 修改类型 (1=创建时间, 2=修改时间, 3=创建和修改, 4=访问时间, 5=创建和访问, 6=修改和访问, 7=全部)
            
        Returns:
            bool: 是否成功
        """
        if not self._ps_process:
            self._set_message("❌ PowerShell未初始化")
            return False
        
        try:
            # 构造PowerShell命令
            cmd = f'修改时间 "{file_path}" "{time_str}" {modify_type}\n'
            self._ps_process.stdin.write(cmd)
            self._ps_process.stdin.flush()
            
            # 检查返回码
            if self._ps_process.poll() is not None and self._ps_process.returncode != 0:
                return False
            
            return True
        except Exception as e:
            self._set_message(f"❌ PowerShell命令执行失败: {str(e)}")
            return False
    
    @Slot('QVariantList', int, str)
    def modifyFilesTime(self, file_paths, modify_type=3, custom_time=""):
        """批量修改文件时间
        
        Args:
            file_paths: 文件路径列表
            modify_type: 修改类型 (1=创建时间, 2=修改时间, 3=创建和修改, 4=访问时间, 5=创建和访问, 6=修改和访问, 7=全部)
            custom_time: 自定义时间字符串，如果为空则从文件名或EXIF中提取
        """
        if not file_paths:
            self._set_message("⚠️ 没有选择文件")
            self.operationFinished.emit(False, "请先选择要修改的文件")
            return
        
        total = len(file_paths)
        success_count = 0
        failed_count = 0
        
        self._set_message(f"开始处理 {total} 个文件...")
        
        for i, file_path in enumerate(file_paths):
            try:
                # 转换为绝对路径
                file_path = os.path.abspath(file_path)
                
                # 确定要使用的时间
                if custom_time:
                    time_to_use = custom_time
                else:
                    # 尝试从文件名提取
                    time_to_use = self._extract_time_from_filename(file_path)
                    
                    # 如果文件名提取失败，尝试从EXIF提取
                    if not time_to_use:
                        time_to_use = self._extract_time_from_exif(file_path)
                
                # 如果仍然没有时间，跳过该文件
                if not time_to_use:
                    msg = f"⚠️ {Path(file_path).name}: 未找到时间信息，跳过"
                    self._set_message(msg)
                    self.fileProcessed.emit(file_path, False, "未找到时间信息")
                    failed_count += 1
                    self.progressChanged.emit(i + 1, total)
                    continue
                
                # 修改文件时间
                success = self._modify_file_time_ps(file_path, time_to_use, modify_type)
                
                if success:
                    msg = f"✅ {Path(file_path).name}: 修改为 {time_to_use}"
                    self._set_message(msg)
                    self.fileProcessed.emit(file_path, True, time_to_use)
                    success_count += 1
                else:
                    msg = f"❌ {Path(file_path).name}: 修改失败"
                    self._set_message(msg)
                    self.fileProcessed.emit(file_path, False, "修改失败")
                    failed_count += 1
                
                # 发送进度
                self.progressChanged.emit(i + 1, total)
                
            except Exception as e:
                msg = f"❌ {Path(file_path).name}: {str(e)}"
                self._set_message(msg)
                self.fileProcessed.emit(file_path, False, str(e))
                failed_count += 1
                self.progressChanged.emit(i + 1, total)
        
        # 完成
        final_msg = f"处理完成！成功: {success_count}, 失败: {failed_count}"
        self._set_message(final_msg)
        self.operationFinished.emit(success_count > 0, final_msg)
    
    @Slot(result=str)
    def getModifyTypeDescription(self):
        """获取修改类型说明"""
        return (
            "1 = 仅修改创建时间\n"
            "2 = 仅修改修改时间\n"
            "3 = 修改创建时间和修改时间（默认）\n"
            "4 = 仅修改访问时间\n"
            "5 = 修改创建时间和访问时间\n"
            "6 = 修改修改时间和访问时间\n"
            "7 = 修改所有时间（创建、修改、访问）"
        )
