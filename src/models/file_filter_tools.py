# -*- coding: utf-8 -*-
"""
文件过滤转移工具
支持按文件类型和关键词过滤文件并转移到指定文件夹
"""
import os
import shutil
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property


class FileFilterTools(QObject):
    """文件过滤转移工具类"""
    
    # 信号
    messageChanged = Signal(str)  # 消息信号
    progressChanged = Signal(int, int)  # 进度信号 (当前进度, 总数)
    operationFinished = Signal(bool, str)  # 操作完成信号 (成功/失败, 消息)
    fileProcessed = Signal(str, bool, str)  # 文件处理完成 (文件路径, 成功/失败, 消息)
    rulesChanged = Signal()  # 规则列表变化信号
    
    # 预定义的文件类型
    IMAGE_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.svg', '.ico', '.tiff', '.tif', '.heic', '.heif'}
    VIDEO_EXTENSIONS = {'.mp4', '.avi', '.mkv', '.mov', '.wmv', '.flv', '.webm', '.m4v', '.mpg', '.mpeg', '.3gp', '.f4v', '.rmvb', '.rm'}
    
    def __init__(self):
        super().__init__()
        self._message = ""
        self._filter_rules = []  # 过滤规则列表
        self._is_notifying = False  # 防止信号递归的标志
        
    @Property(str, notify=messageChanged)
    def message(self):
        """获取消息"""
        return self._message
    
    @message.setter
    def message(self, msg):
        """设置消息"""
        if self._message != msg:
            self._message = msg
            self.messageChanged.emit()
    
    @Property('QVariantList', notify=rulesChanged)
    def filterRules(self):
        """获取过滤规则列表 - 注意：只返回数据，不触发信号"""
        return self._filter_rules
    
    @Slot(str, str, str, str, result=bool)
    def addFilterRule(self, file_type, keywords, target_folder, rule_name=""):
        """
        添加过滤规则
        :param file_type: 文件类型 ("image", "video", "all", "custom")
        :param keywords: 关键词，多个关键词用逗号分隔
        :param target_folder: 目标文件夹路径
        :param rule_name: 规则名称（可选）
        :return: 是否添加成功
        """
        print(f"[DEBUG] addFilterRule called: type={file_type}, keywords={keywords}")
        try:
            if not target_folder:
                self.message = "目标文件夹不能为空"
                return False
            
            # 处理关键词
            keyword_list = [k.strip() for k in keywords.split(',') if k.strip()]
            
            # 确定文件扩展名列表
            if file_type == "image":
                extensions = self.IMAGE_EXTENSIONS
                type_name = "图片"
            elif file_type == "video":
                extensions = self.VIDEO_EXTENSIONS
                type_name = "视频"
            elif file_type == "all":
                extensions = self.IMAGE_EXTENSIONS | self.VIDEO_EXTENSIONS
                type_name = "图片/视频"
            else:
                extensions = set()
                type_name = "自定义"
            
            # 生成规则名称
            if not rule_name:
                rule_name = f"{type_name}规则 - {keywords if keywords else '全部'}"
            
            # 添加规则
            rule = {
                "id": len(self._filter_rules) + 1,
                "name": rule_name,
                "file_type": file_type,
                "type_name": type_name,
                "keywords": keyword_list,
                "keywords_text": keywords,
                "target_folder": target_folder,
                "extensions": list(extensions),
                "enabled": True
            }
            
            self._filter_rules.append(rule)
            print(f"[DEBUG] Rule added, total rules: {len(self._filter_rules)}")
            
            # 先设置消息，再发送信号，避免信号处理时消息还未更新
            self.message = f"规则添加成功: {rule_name}"
            
            # 只触发一次信号
            if not self._is_notifying:
                self._is_notifying = True
                print(f"[DEBUG] Emitting rulesChanged signal")
                self.rulesChanged.emit()
                self._is_notifying = False
                print(f"[DEBUG] Signal emitted")
            
            print(f"[DEBUG] addFilterRule completed successfully")
            return True
            
        except Exception as e:
            self.message = f"添加规则失败: {str(e)}"
            return False
    
    @Slot(int)
    def removeFilterRule(self, rule_id):
        """
        删除过滤规则
        :param rule_id: 规则ID
        """
        try:
            self._filter_rules = [r for r in self._filter_rules if r["id"] != rule_id]
            self.message = "规则删除成功"
            if not self._is_notifying:
                self._is_notifying = True
                self.rulesChanged.emit()
                self._is_notifying = False
        except Exception as e:
            self.message = f"删除规则失败: {str(e)}"
    
    @Slot(int, bool)
    def toggleRuleEnabled(self, rule_id, enabled):
        """
        切换规则启用状态
        :param rule_id: 规则ID
        :param enabled: 是否启用
        """
        for rule in self._filter_rules:
            if rule["id"] == rule_id:
                rule["enabled"] = enabled
                if not self._is_notifying:
                    self._is_notifying = True
                    self.rulesChanged.emit()
                    self._is_notifying = False
                break
    
    @Slot()
    def clearAllRules(self):
        """清空所有规则"""
        self._filter_rules = []
        self.message = "所有规则已清空"
        if not self._is_notifying:
            self._is_notifying = True
            self.rulesChanged.emit()
            self._is_notifying = False
    
    @Slot(str, bool, bool, result='QVariantList')
    def scanFolder(self, source_folder, include_subfolders=False, preview_only=True):
        """
        扫描文件夹并应用过滤规则
        :param source_folder: 源文件夹路径
        :param include_subfolders: 是否包含子文件夹
        :param preview_only: 是否仅预览（不实际移动文件）
        :return: 匹配的文件列表
        """
        try:
            if not source_folder or not os.path.isdir(source_folder):
                self.message = "请选择有效的源文件夹"
                return []
            
            if not self._filter_rules:
                self.message = "请至少添加一个过滤规则"
                return []
            
            # 启用的规则
            enabled_rules = [r for r in self._filter_rules if r.get("enabled", True)]
            if not enabled_rules:
                self.message = "没有启用的规则"
                return []
            
            matched_files = []
            source_path = Path(source_folder)
            
            # 获取所有文件
            if include_subfolders:
                files = list(source_path.rglob('*'))
            else:
                files = list(source_path.glob('*'))
            
            # 过滤出文件（排除文件夹）
            files = [f for f in files if f.is_file()]
            
            total_files = len(files)
            processed = 0
            
            self.message = f"开始扫描，共 {total_files} 个文件..."
            
            # 处理每个文件
            for file_path in files:
                processed += 1
                self.progressChanged.emit(processed, total_files)
                
                file_name = file_path.name
                file_ext = file_path.suffix.lower()
                
                # 检查每个规则
                for rule in enabled_rules:
                    # 检查文件类型
                    if rule["extensions"] and file_ext not in rule["extensions"]:
                        continue
                    
                    # 检查关键词
                    keywords = rule.get("keywords", [])
                    if keywords:
                        # 检查文件名是否包含任一关键词
                        if not any(keyword.lower() in file_name.lower() for keyword in keywords):
                            continue
                    
                    # 匹配成功
                    matched_files.append({
                        "file_path": str(file_path),
                        "file_name": file_name,
                        "file_size": file_path.stat().st_size,
                        "rule_id": rule["id"],
                        "rule_name": rule["name"],
                        "target_folder": rule["target_folder"],
                        "matched": True
                    })
                    break  # 只匹配第一个规则
            
            self.message = f"扫描完成，找到 {len(matched_files)} 个匹配文件"
            return matched_files
            
        except Exception as e:
            self.message = f"扫描失败: {str(e)}"
            return []
    
    @Slot('QVariantList', bool)
    def moveFiles(self, matched_files, copy_mode=False):
        """
        移动或复制匹配的文件
        :param matched_files: 匹配的文件列表
        :param copy_mode: 是否复制模式（False为移动）
        """
        try:
            if not matched_files:
                self.message = "没有要处理的文件"
                return
            
            total = len(matched_files)
            success_count = 0
            failed_count = 0
            
            operation = "复制" if copy_mode else "移动"
            self.message = f"开始{operation}文件，共 {total} 个..."
            
            for idx, file_info in enumerate(matched_files):
                source_path = Path(file_info["file_path"])
                target_folder = Path(file_info["target_folder"])
                
                # 创建目标文件夹
                target_folder.mkdir(parents=True, exist_ok=True)
                
                # 目标文件路径
                target_path = target_folder / source_path.name
                
                # 如果目标文件已存在，添加序号
                counter = 1
                original_name = target_path.stem
                extension = target_path.suffix
                while target_path.exists():
                    target_path = target_folder / f"{original_name}_{counter}{extension}"
                    counter += 1
                
                try:
                    if copy_mode:
                        shutil.copy2(source_path, target_path)
                    else:
                        shutil.move(str(source_path), str(target_path))
                    
                    success_count += 1
                    self.fileProcessed.emit(str(source_path), True, f"{operation}成功")
                    
                except Exception as e:
                    failed_count += 1
                    self.fileProcessed.emit(str(source_path), False, f"{operation}失败: {str(e)}")
                
                # 更新进度
                self.progressChanged.emit(idx + 1, total)
            
            # 完成
            result_msg = f"{operation}完成！成功: {success_count}, 失败: {failed_count}"
            self.message = result_msg
            self.operationFinished.emit(failed_count == 0, result_msg)
            
        except Exception as e:
            error_msg = f"{operation}文件失败: {str(e)}"
            self.message = error_msg
            self.operationFinished.emit(False, error_msg)
    
    @Slot(str, result=int)
    def getFileCount(self, folder_path):
        """
        获取文件夹中的文件数量
        :param folder_path: 文件夹路径
        :return: 文件数量
        """
        try:
            if not os.path.isdir(folder_path):
                return 0
            path = Path(folder_path)
            return len([f for f in path.rglob('*') if f.is_file()])
        except:
            return 0
    
    @Slot(result='QVariantList')
    def getImageExtensions(self):
        """获取图片扩展名列表"""
        return sorted(list(self.IMAGE_EXTENSIONS))
    
    @Slot(result='QVariantList')
    def getVideoExtensions(self):
        """获取视频扩展名列表"""
        return sorted(list(self.VIDEO_EXTENSIONS))
