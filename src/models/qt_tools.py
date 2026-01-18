# -*- coding: utf-8 -*-
"""
Qt翻译工具
提供Qt TS翻译文件处理功能
"""
import os
import re
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property


class QtTools(QObject):
    """Qt工具类"""
    
    # 信号
    messageChanged = Signal(str)  # 消息信号
    progressChanged = Signal(int)  # 进度信号
    operationFinished = Signal(bool, str)  # 操作完成信号 (成功/失败, 消息)
    filesFound = Signal('QVariantList')  # 找到的文件列表
    
    def __init__(self):
        super().__init__()
        self._message = ""
        self._progress = 0
        self._i18n_dir = ""
    
    @Property(str, notify=messageChanged)
    def message(self):
        """当前消息"""
        return self._message
    
    def _set_message(self, msg):
        """设置消息"""
        self._message = msg
        self.messageChanged.emit(msg)
        print(f"[Qt工具] {msg}")
    
    @Property(int, notify=progressChanged)
    def progress(self):
        """当前进度"""
        return self._progress
    
    def _set_progress(self, value):
        """设置进度"""
        self._progress = value
        self.progressChanged.emit(value)
    
    @Slot(str)
    def setI18nDirectory(self, directory):
        """设置i18n目录"""
        self._i18n_dir = directory
        self._set_message(f"设置目录: {directory}")
    
    @Slot(result='QVariantList')
    def findTsFiles(self):
        """查找所有TS文件"""
        try:
            if not self._i18n_dir:
                self._set_message("❌ 请先选择i18n目录")
                return []
            
            i18n_path = Path(self._i18n_dir)
            if not i18n_path.exists():
                self._set_message(f"❌ 目录不存在: {self._i18n_dir}")
                return []
            
            ts_files = list(i18n_path.glob("*.ts"))
            
            if not ts_files:
                self._set_message("❌ 未找到任何.ts文件")
                return []
            
            file_list = [str(f) for f in ts_files]
            self._set_message(f"✅ 找到 {len(ts_files)} 个.ts文件")
            self.filesFound.emit(file_list)
            return file_list
            
        except Exception as e:
            self._set_message(f"❌ 查找文件失败: {str(e)}")
            return []
    
    @Slot(str, result=int)
    def processUnfinishedTranslations(self, file_path):
        """处理unfinished标记的移除
        
        移除有内容的<translation type="unfinished">标签中的type="unfinished"属性
        """
        try:
            self._set_message(f"处理文件: {file_path}")
            
            # 读取文件内容
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 备份原文件
            backup_path = Path(file_path).with_suffix('.ts.backup')
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(content)
            self._set_message(f"已创建备份: {backup_path.name}")
            
            # 统计处理的数量
            processed_count = 0
            
            # 使用正则表达式查找并处理有内容的unfinished翻译
            pattern = r'<translation\s+type="unfinished">([^<]+)</translation>'
            
            def replace_func(match):
                nonlocal processed_count
                content_text = match.group(1).strip()
                if content_text:  # 如果有内容
                    processed_count += 1
                    return f'<translation>{content_text}</translation>'
                else:
                    return match.group(0)  # 保持原样
            
            # 执行替换
            new_content = re.sub(pattern, replace_func, content)
            
            # 写回文件
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            self._set_message(f"✅ 已处理 {processed_count} 个unfinished翻译")
            return processed_count
            
        except Exception as e:
            self._set_message(f"❌ 处理失败: {str(e)}")
            return 0
    
    @Slot(str, result=bool)
    def isChineseToChineseFile(self, file_path):
        """检查是否是中文到中文的翻译文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 查找TS标签中的language和sourcelanguage属性
            ts_match = re.search(r'<TS[^>]*language="([^"]*)"[^>]*sourcelanguage="([^"]*)"', content)
            if ts_match:
                language = ts_match.group(1)
                sourcelanguage = ts_match.group(2)
                return language == "zh_CN" and sourcelanguage == "zh_CN"
            return False
            
        except Exception as e:
            self._set_message(f"❌ 检查文件失败: {str(e)}")
            return False
    
    @Slot(str, result=int)
    def fillChineseTranslations(self, file_path):
        """为中文到中文的翻译文件自动填充翻译"""
        try:
            self._set_message(f"填充中文翻译: {file_path}")
            
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # 备份原文件
            backup_path = Path(file_path).with_suffix('.ts(自动填充中文).backup')
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(content)
            self._set_message(f"已创建备份: {backup_path.name}")
            
            filled_count = 0
            
            # 查找空的translation标签，并从对应的source标签获取内容
            def process_message_block(match):
                nonlocal filled_count
                message_block = match.group(0)
                
                # 在这个message块中查找source和translation
                source_match = re.search(r'<source>([^<]+)</source>', message_block)
                translation_match = re.search(r'<translation[^>]*></translation>', message_block)
                
                if source_match and translation_match:
                    source_text = source_match.group(1)
                    filled_count += 1
                    # 替换空的translation标签
                    new_message_block = re.sub(
                        r'<translation[^>]*></translation>',
                        f'<translation>{source_text}</translation>',
                        message_block
                    )
                    return new_message_block
                
                return message_block
            
            # 处理每个message块
            new_content = re.sub(
                r'<message>.*?</message>',
                process_message_block,
                content,
                flags=re.DOTALL
            )
            
            # 写回文件
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            
            self._set_message(f"✅ 已填充 {filled_count} 个中文翻译")
            return filled_count
            
        except Exception as e:
            self._set_message(f"❌ 填充失败: {str(e)}")
            return 0
    
    @Slot(bool)
    def processAllFiles(self, auto_fill_chinese=False):
        """处理所有TS文件"""
        try:
            ts_files = self.findTsFiles()
            
            if not ts_files:
                self.operationFinished.emit(False, "未找到任何.ts文件")
                return
            
            total_processed = 0
            total_filled = 0
            total_files = len(ts_files)
            
            for i, ts_file in enumerate(ts_files):
                # 更新进度
                self._set_progress(int((i / total_files) * 100))
                
                # 处理unfinished标记
                processed = self.processUnfinishedTranslations(ts_file)
                total_processed += processed
                
                # 如果是中文到中文的文件且用户选择自动填充
                if auto_fill_chinese and self.isChineseToChineseFile(ts_file):
                    filled = self.fillChineseTranslations(ts_file)
                    total_filled += filled
            
            self._set_progress(100)
            
            result_msg = f"✅ 处理完成！\n"
            result_msg += f"处理了 {total_files} 个文件\n"
            result_msg += f"移除了 {total_processed} 个unfinished标记"
            
            if auto_fill_chinese:
                result_msg += f"\n填充了 {total_filled} 个中文翻译"
            
            self._set_message(result_msg)
            self.operationFinished.emit(True, result_msg)
            
        except Exception as e:
            error_msg = f"处理失败: {str(e)}"
            self._set_message(f"❌ {error_msg}")
            self.operationFinished.emit(False, error_msg)
