# -*- coding: utf-8 -*-
"""
Windows系统工具
提供各种Windows系统相关的实用工具
"""
import os
import ctypes
import shutil
import subprocess
import json
from pathlib import Path
from PySide6.QtCore import QObject, Signal, Slot, Property


class WindowsTools(QObject):
    """Windows系统工具类"""
    
    # 信号
    messageChanged = Signal(str)  # 消息信号
    progressChanged = Signal(int)  # 进度信号
    operationFinished = Signal(bool, str)  # 操作完成信号 (成功/失败, 消息)
    powerEventsLoaded = Signal('QVariantList')  # 电源事件加载完成信号
    
    def __init__(self):
        super().__init__()
        self._message = ""
        self._progress = 0
    
    def _is_admin(self):
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
        print(f"[Windows工具] {msg}")
    
    @Property(int, notify=progressChanged)
    def progress(self):
        """当前进度"""
        return self._progress
    
    def _set_progress(self, value):
        """设置进度"""
        self._progress = value
        self.progressChanged.emit(value)
    
    @Slot(result=str)
    def getWallpaper(self):
        """获取当前桌面壁纸路径"""
        try:
            MAX_PATH = 260
            wallpaper = ctypes.create_unicode_buffer(MAX_PATH)
            SPI_GETDESKWALLPAPER = 0x0073
            
            # 获取当前桌面壁纸路径
            if ctypes.windll.user32.SystemParametersInfoW(SPI_GETDESKWALLPAPER, MAX_PATH, wallpaper, 0) == 0:
                self._set_message("❌ 无法获取当前桌面壁纸的路径")
                return ""
            
            wallpaper_path = wallpaper.value
            self._set_message(f"✅ 当前壁纸: {wallpaper_path}")
            return wallpaper_path
        
        except Exception as e:
            self._set_message(f"❌ 获取壁纸失败: {str(e)}")
            return ""
    
    @Slot()
    def saveWallpaper(self):
        """保存当前桌面壁纸到下载文件夹"""
        try:
            self._set_message("正在获取壁纸路径...")
            wallpaper_path = self.getWallpaper()
            
            if not wallpaper_path:
                self.operationFinished.emit(False, "无法获取壁纸路径")
                return
            
            # 获取用户下载目录
            user_profile = os.getenv("USERPROFILE")
            if not user_profile:
                self._set_message("❌ 无法获取用户目录")
                self.operationFinished.emit(False, "无法获取用户目录")
                return
            
            downloads_path = os.path.join(user_profile, "Downloads")
            
            # 获取壁纸文件扩展名
            _, ext = os.path.splitext(wallpaper_path)
            if not ext:
                ext = ".jpg"
            
            output_path = os.path.join(downloads_path, f"wallpaper{ext}")
            
            self._set_message("正在复制壁纸...")
            shutil.copy(wallpaper_path, output_path)
            
            self._set_message(f"✅ 壁纸已保存到: {output_path}")
            self.operationFinished.emit(True, f"壁纸已保存到:\n{output_path}")
            
        except Exception as e:
            error_msg = f"保存壁纸失败: {str(e)}"
            self._set_message(f"❌ {error_msg}")
            self.operationFinished.emit(False, error_msg)
    
    @Slot(bool)
    def toggleSearchWebSearch(self, enable):
        """开关Win11搜索栏网页搜索功能
        
        Args:
            enable: True为开启，False为关闭
        """
        try:
            reg_path = r"HKCU\Software\Microsoft\Windows\CurrentVersion\Search"
            value_name = "BingSearchEnabled"
            
            if enable:
                # 开启网页搜索 - 删除注册表项
                self._set_message("正在开启网页搜索...")
                cmd = f'reg delete "{reg_path}" /v {value_name} /f'
            else:
                # 关闭网页搜索 - 设置为0
                self._set_message("正在关闭网页搜索...")
                cmd = f'reg add "{reg_path}" /v {value_name} /t REG_DWORD /d 0 /f'
            
            # 执行命令
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            
            if result.returncode == 0 or "成功" in result.stdout:
                action = "开启" if enable else "关闭"
                self._set_message(f"✅ {action}网页搜索成功")
                self.operationFinished.emit(True, f"{action}成功，可能需要重启资源管理器生效")
            else:
                self._set_message(f"❌ 操作失败: {result.stderr}")
                self.operationFinished.emit(False, f"操作失败:\n{result.stderr}")
                
        except Exception as e:
            error_msg = f"操作失败: {str(e)}"
            self._set_message(f"❌ {error_msg}")
            self.operationFinished.emit(False, error_msg)
    
    @Slot(str, result=bool)
    def checkDesktopIni(self, folder_path):
        """检查文件夹是否存在desktop.ini文件
        
        Args:
            folder_path: 文件夹路径
            
        Returns:
            bool: 是否存在desktop.ini
        """
        try:
            desktop_ini_path = os.path.join(folder_path, "desktop.ini")
            exists = os.path.exists(desktop_ini_path)
            
            if exists:
                self._set_message(f"✅ 发现desktop.ini文件: {desktop_ini_path}")
            else:
                self._set_message(f"⚠️ 当前目录下没有desktop.ini文件")
            
            return exists
            
        except Exception as e:
            self._set_message(f"❌ 检查失败: {str(e)}")
            return False
    
    @Slot(str)
    def enableDesktopIni(self, folder_path):
        """启用文件夹中的desktop.ini文件
        
        设置文件夹为系统文件夹，并设置desktop.ini为系统+隐藏属性
        
        Args:
            folder_path: 文件夹路径
        """
        try:
            if not folder_path:
                self._set_message("❌ 请先选择文件夹")
                self.operationFinished.emit(False, "请先选择文件夹")
                return
            
            desktop_ini_path = os.path.join(folder_path, "desktop.ini")
            
            # 检查desktop.ini是否存在
            if not os.path.exists(desktop_ini_path):
                self._set_message("❌ 当前目录下没有desktop.ini文件")
                self.operationFinished.emit(False, "当前目录下没有desktop.ini文件\n请先在该文件夹中创建desktop.ini文件")
                return
            
            self._set_message("正在启用desktop.ini...")
            
            # 设置当前目录为系统文件夹
            cmd1 = f'attrib +s "{folder_path}"'
            result1 = subprocess.run(cmd1, shell=True, capture_output=True, text=True)
            
            # 设置desktop.ini为系统和隐藏属性
            cmd2 = f'attrib +s +h "{desktop_ini_path}"'
            result2 = subprocess.run(cmd2, shell=True, capture_output=True, text=True)
            
            if result1.returncode == 0 and result2.returncode == 0:
                self._set_message("✅ desktop.ini已启用")
                self.operationFinished.emit(True, f"✅ desktop.ini已成功启用\n\n文件夹: {folder_path}\n已设置为系统文件夹\n\ndesktop.ini已设置为系统+隐藏属性\n\n可能需要刷新文件夹或重启资源管理器才能看到效果")
            else:
                error_msg = f"设置失败\n{result1.stderr}\n{result2.stderr}"
                self._set_message(f"❌ {error_msg}")
                self.operationFinished.emit(False, error_msg)
                
        except Exception as e:
            error_msg = f"操作失败: {str(e)}"
            self._set_message(f"❌ {error_msg}")
            self.operationFinished.emit(False, error_msg)
    
    @Slot()
    def refreshIcons(self):
        """刷新图标缓存"""
        try:
            self._set_message("正在刷新图标缓存...")
            
            # 删除图标缓存并重启资源管理器
            cmd = '''
            @REM chcp 936 >nul
            taskkill /f /im explorer.exe
            cd /d %userprofile%\\AppData\\Local
            attrib -h IconCache.db
            del IconCache.db /f /q
            start explorer.exe
            '''
            
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            
            self._set_message("✅ 图标缓存已刷新")
            self.operationFinished.emit(True, "图标缓存已刷新，资源管理器已重启")
            
        except Exception as e:
            error_msg = f"操作失败: {str(e)}"
            self._set_message(f"❌ {error_msg}")
            self.operationFinished.emit(False, error_msg)
    
    @Slot()
    def resetIconSpacing(self):
        """恢复图标默认间距"""
        try:
            self._set_message("正在恢复图标默认间距...")
            
            # 删除图标间距的注册表设置，恢复默认值
            cmds = [
                # 'reg delete "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v IconSpacing /f',
                # 'reg delete "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v IconVerticalSpacing /f'
                'reg add "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v IconSpacing /t REG_SZ /d -1125 /f',
                'reg add "HKCU\\Control Panel\\Desktop\\WindowMetrics" /v IconVerticalSpacing /t REG_SZ /d -1125 /f'
            ]
            
            for cmd in cmds:
                subprocess.run(cmd, shell=True, capture_output=True, text=True)
            
            # 刷新桌面
            subprocess.run('rundll32.exe user32.dll,UpdatePerUserSystemParameters', shell=True)
            
            self._set_message("✅ 图标间距已恢复默认值")
            self.operationFinished.emit(True, "图标间距已恢复默认值\n可能需要注销或重启生效")
            
        except Exception as e:
            error_msg = f"操作失败: {str(e)}"
            self._set_message(f"❌ {error_msg}")
            self.operationFinished.emit(False, error_msg)
    
    @Slot(result='QVariantList')
    def getSystemPowerEvents(self):
        """获取系统电源事件时间线
        
        返回开机、关机、休眠、唤醒等事件列表
        """
        try:
            self._set_message("正在读取系统电源事件...")
            
            # PowerShell 脚本用于获取电源事件
            # 使用简化的输出格式，避免复杂的JSON编码问题
            ps_script = """
            $OutputEncoding = [System.Text.Encoding]::UTF8
            $events = @()
            
            # 获取启动事件 (ID 12)
            $startupFilter = @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-General'; Id = 12 }
            $startupEvents = Get-WinEvent -FilterHashtable $startupFilter -ErrorAction SilentlyContinue -MaxEvents 50
            
            # 获取关机事件 (ID 13)
            $shutdownFilter = @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-General'; Id = 13 }
            $shutdownEvents = Get-WinEvent -FilterHashtable $shutdownFilter -ErrorAction SilentlyContinue -MaxEvents 50
            
            # 获取休眠/睡眠事件 (ID 42)
            $sleepFilter = @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-Power'; Id = 42 }
            $sleepEvents = Get-WinEvent -FilterHashtable $sleepFilter -ErrorAction SilentlyContinue -MaxEvents 50
            
            # 获取唤醒事件 (ID 107)
            $resumeFilter = @{ LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-Power'; Id = 107 }
            $resumeEvents = Get-WinEvent -FilterHashtable $resumeFilter -ErrorAction SilentlyContinue -MaxEvents 50
            
            foreach ($e in $startupEvents) {
                $events += [PSCustomObject]@{
                    Type = 'Startup'
                    Time = $e.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')
                    Details = 'System boot'
                }
            }
            
            foreach ($e in $shutdownEvents) {
                $events += [PSCustomObject]@{
                    Type = 'Shutdown'
                    Time = $e.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')
                    Details = 'System shutdown'
                }
            }
            
            foreach ($e in $sleepEvents) {
                $events += [PSCustomObject]@{
                    Type = 'Sleep'
                    Time = $e.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')
                    Details = 'Enter sleep/hibernate'
                }
            }
            
            foreach ($e in $resumeEvents) {
                $events += [PSCustomObject]@{
                    Type = 'Resume'
                    Time = $e.TimeCreated.ToString('yyyy-MM-dd HH:mm:ss')
                    Details = 'Resume from sleep'
                }
            }
            
            $events | Sort-Object Time -Descending | ConvertTo-Json -Compress
            """
            
            # 执行 PowerShell 脚本
            # 使用 UTF-8 BOM 输出格式，避免编码问题
            result = subprocess.run(
                ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", 
                 f"[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; {ps_script}"],
                capture_output=True,
                text=True,
                encoding='utf-8',
                errors='replace'  # 替换无法解码的字符
            )
            
            if result.returncode == 0 and result.stdout:
                stdout_clean = result.stdout.strip()
                if not stdout_clean:
                    self._set_message("⚠️ 未找到电源事件")
                    return []
                    
                try:
                    # 解析 JSON 结果
                    events_data = json.loads(stdout_clean)
                    
                    # 确保是列表格式
                    if isinstance(events_data, dict):
                        events_data = [events_data]
                    elif not isinstance(events_data, list):
                        events_data = []
                    
                    # 转换为 QVariantList 格式
                    events_list = []
                    type_map = {
                        'Startup': '启动',
                        'Shutdown': '关机',
                        'Sleep': '休眠/睡眠',
                        'Resume': '唤醒'
                    }
                    
                    for event in events_data:
                        if isinstance(event, dict):
                            event_type = event.get('Type', 'Unknown')
                            events_list.append({
                                'type': type_map.get(event_type, event_type),
                                'time': event.get('Time', ''),
                                'details': event.get('Details', '')
                            })
                    
                    if events_list:
                        self._set_message(f"✅ 成功读取 {len(events_list)} 条电源事件")
                        self.powerEventsLoaded.emit(events_list)
                        return events_list
                    else:
                        self._set_message("⚠️ 未找到电源事件")
                        return []
                    
                except json.JSONDecodeError as e:
                    self._set_message(f"❌ JSON解析失败: {str(e)}\n输出: {stdout_clean[:200]}")
                    return []
                except Exception as e:
                    self._set_message(f"❌ 处理数据失败: {str(e)}")
                    return []
            else:
                error_msg = result.stderr.strip() if result.stderr else "未找到电源事件或权限不足"
                self._set_message(f"❌ 读取失败: {error_msg}")
                return []
                
        except Exception as e:
            self._set_message(f"❌ 获取电源事件失败: {str(e)}")
            return []
    
    @Slot()
    def removeShortcutOverlay(self):
        try:
            if not self._is_admin():
                self._set_message("❌ 需要管理员权限")
                self.operationFinished.emit(False, "请以管理员权限运行应用后再执行")
                return
            self._set_message("正在去除快捷方式角标...")
            cmd_reg = r'reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /d "%systemroot%\system32\imageres.dll,197" /t REG_SZ /f'
            subprocess.run(cmd_reg, shell=True, capture_output=True, text=True)
            subprocess.run('taskkill /f /im explorer.exe', shell=True, capture_output=True, text=True)
            subprocess.run(r'attrib -s -r -h "%localappdata%\iconcache.db"', shell=True, capture_output=True, text=True)
            subprocess.run(r'del "%localappdata%\iconcache.db" /f /q', shell=True, capture_output=True, text=True)
            subprocess.run('start explorer', shell=True)
            self._set_message("✅ 已去除快捷方式角标")
            self.operationFinished.emit(True, "已去除快捷方式角标")
        except Exception as e:
            self._set_message(f"❌ 操作失败: {str(e)}")
            self.operationFinished.emit(False, f"操作失败:\n{str(e)}")
    
    @Slot()
    def restoreShortcutOverlay(self):
        try:
            if not self._is_admin():
                self._set_message("❌ 需要管理员权限")
                self.operationFinished.emit(False, "请以管理员权限运行应用后再执行")
                return
            self._set_message("正在恢复快捷方式角标...")
            cmd_reg = r'reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f'
            subprocess.run(cmd_reg, shell=True, capture_output=True, text=True)
            subprocess.run('taskkill /f /im explorer.exe', shell=True, capture_output=True, text=True)
            subprocess.run(r'attrib -s -r -h "%localappdata%\iconcache.db"', shell=True, capture_output=True, text=True)
            subprocess.run(r'del "%localappdata%\iconcache.db" /f /q', shell=True, capture_output=True, text=True)
            subprocess.run('start explorer', shell=True)
            self._set_message("✅ 已恢复快捷方式角标")
            self.operationFinished.emit(True, "已恢复快捷方式角标")
        except Exception as e:
            self._set_message(f"❌ 操作失败: {str(e)}")
            self.operationFinished.emit(False, f"操作失败:\n{str(e)}")
    
    @Slot()
    def allowPowershellScripts(self):
        try:
            self._set_message("正在设置允许运行PowerShell脚本...")
            temp_dir = os.environ.get("TEMP", os.getcwd())
            script_path = os.path.join(temp_dir, "allow_ps_scripts.ps1")
            result_path = os.path.join(temp_dir, "ps_script_result.txt")
            
            # 使用临时文件来传递结果，避免 stdout 捕获问题
            ps_script = f"""
            $ErrorActionPreference = 'Continue'

            # 尝试加载模块
            if (Get-Module -ListAvailable -Name Microsoft.PowerShell.Security) {{
                Import-Module Microsoft.PowerShell.Security -ErrorAction SilentlyContinue
            }}

            function Get-Policy-Robust {{
                try {{
                    $p = Get-ExecutionPolicy -Scope CurrentUser -ErrorAction Stop
                    return $p
                }} catch {{
                    # Fallback to registry
                    $regPath = "HKCU:\\Software\\Microsoft\\PowerShell\\1\\ShellIds\\Microsoft.PowerShell"
                    $val = Get-ItemProperty -Path $regPath -Name "ExecutionPolicy" -ErrorAction SilentlyContinue
                    if ($val) {{ return $val.ExecutionPolicy }}
                    return "Undefined"
                }}
            }}

            function Set-Policy-Robust {{
                param($policy)
                try {{
                    Set-ExecutionPolicy $policy -Scope CurrentUser -Force -ErrorAction Stop
                }} catch {{
                    # Fallback to registry
                    $regPath = "HKCU:\\Software\\Microsoft\\PowerShell\\1\\ShellIds\\Microsoft.PowerShell"
                    if (!(Test-Path $regPath)) {{
                        New-Item -Path $regPath -Force | Out-Null
                    }}
                    Set-ItemProperty -Path $regPath -Name "ExecutionPolicy" -Value $policy -Force
                }}
            }}

            try {{
                $p1 = Get-Policy-Robust
                $output = "原先的执行策略：$p1`r`n"
                
                Set-Policy-Robust "RemoteSigned"
                
                $p2 = Get-Policy-Robust
                $output += "已修改执行策略`r`n"
                $output += "当前的执行策略：$p2"
                
                $output | Out-File -FilePath "{result_path}" -Encoding utf8
                exit 0
            }} catch {{
                $_.Exception.Message | Out-File -FilePath "{result_path}" -Encoding utf8
                exit 1
            }}
            """
            with open(script_path, "w", encoding="utf-8") as f:
                f.write(ps_script)
            try:
                result = subprocess.run(
                    ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", script_path],
                    capture_output=True, # 依然捕获但不依赖它
                    check=False
                )
                
                if os.path.exists(result_path):
                    with open(result_path, "r", encoding="utf-8-sig") as f: # PowerShell UTF8 可能有 BOM
                        out = f.read().strip()
                    
                    if result.returncode == 0:
                        self._set_message(f"✅ 设置完成\n{out}")
                        self.operationFinished.emit(True, out)
                    else:
                        self._set_message(f"❌ 设置失败: {out}")
                        self.operationFinished.emit(False, out)
                else:
                    self._set_message("❌ 设置完成，但无法读取结果")
                    self.operationFinished.emit(True, "设置完成，但无法读取结果")
                    
            finally:
                try:
                    if os.path.exists(script_path):
                        os.remove(script_path)
                    if os.path.exists(result_path):
                        os.remove(result_path)
                except Exception:
                    pass
        except Exception as e:
            self._set_message(f"❌ 操作失败: {str(e)}")
            self.operationFinished.emit(False, f"操作失败:\n{str(e)}")
    
    @Slot()
    def initPowershellProfile(self):
        try:
            self._set_message("正在初始化PowerShell配置...")
            ps_script = r"""
            # 初始化我的powershell环境

            # 该脚本只在win下运行
            if($env:OS -ne "Windows_NT") {
                Write-Host ("该脚本只在Windows下运行。")
                return
            }

            # $Profile是否存在，如果不存在则创建
            if(!(Test-Path -Path $Profile)) {
                New-Item -ItemType File -Path $Profile -Force
            }

            $flag = 0
            $init_text = Get-Content -Path $Profile

            function 检测是否存在([string]$text) {
                # 去除$text前后的所有空格
                $text = $text.Trim()

                foreach ($line in $init_text) {
                    if ($line -match '^(?!\s*#).*?' + $text) {
                        return $true
                    }
                }
                $flag = 1
                return $false
            }

            function 检测Profile最后一行是否空() {
                # 如果文件不为空，并且最后一行不是空行，则添加一个空行
                if ($init_text.Count -gt 0 -and $init_text[-1].Trim() -ne "") {
                    Add-Content -Path $Profile -Value ""
                }
            }

            # 将where.exe设置一个默认别名为which
            # 检测是否存在"Set-Alias which"
            if(!(检测是否存在('Set-Alias\s+which'))) {
                检测Profile最后一行是否空
                Add-Content -Path $Profile -Value '# 将where.exe设置一个默认别名为which'
                Add-Content -Path $Profile -Value 'Set-Alias which where.exe'
                Add-Content -Path $Profile -Value ''

                Write-Host ("已将where.exe设置一个默认别名为which")
                $flag = 1
            }

            # 输出最后的提示语
            if ($flag -eq 0) {
                Write-Host "未修改任何内容。"
            }
            else {
                Write-Host "请重新打开Powershell窗口生效。"
            }
            """
            result = subprocess.run(
                ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", ps_script],
                capture_output=True,
                text=True,
                encoding="gbk",
                errors="replace"
            )
            if result.returncode == 0:
                out = result.stdout.strip()
                self._set_message(f"✅ 初始化完成\n{out}")
                self.operationFinished.emit(True, out)
            else:
                err = result.stderr.strip()
                self._set_message(f"❌ 初始化失败: {err}")
                self.operationFinished.emit(False, err)
        except Exception as e:
            self._set_message(f"❌ 操作失败: {str(e)}")
            self.operationFinished.emit(False, f"操作失败:\n{str(e)}")
    
    @Slot()
    def setPowershellChineseEncoding(self):
        try:
            self._set_message("正在设置PowerShell中文显示...")
            ps_script = r"""
            # 在UTF-8格式下，或系统语言为英文等，无法正常显示中文，可使用此脚本解决

            # 该脚本只在win下运行
            if($env:OS -ne "Windows_NT") {
                Write-Host ("该脚本只在Windows下运行。")
                return
            }

            # 获取当前版本信息
            $ps_Info = ""
            if ($Host.Version.Major -ge 7) {
                $ps_Info = "PowerShell "+$($PSVersionTable.PSVersion)
            } else {
                $ps_Info = "PowerShell "+$($PSVersionTable.PSVersion.Major)+"."+$($PSVersionTable.PSVersion.Minor)
            }

            # $Profile是否存在，如果不存在则创建
            if(!(Test-Path -Path $Profile)) {
                New-Item -ItemType File -Path $Profile -Force
            }

            function 检测是否要添加() {
                # 如果本身编码为936，则不需要设置
                if ([Console]::OutputEncoding.CodePage -eq 936) {
                    Write-Host ("$ps_Info" + "本身就为中文GB2312编码，无需重复设置。")
                    return $false
                }

                function 检测是否已设置() {
                    foreach ($line in Get-Content -Path $Profile) {
                        if ($line -match '^(?!\s*#).*?\[Console\]::OutputEncoding\s*=\s*\[System\.Text\.Encoding\]::GetEncoding\(\s*"gb2312"\s*\)') {
                            return $true
                        }
                    }
                    return $false
                }

                if (检测是否已设置) {
                    Write-Host ("$ps_Info" + "已设置为使用中文GB2312编码，无需重复设置。")
                    return $false
                } else {
                    return $true
                }
            }

            function 检测Profile最后一行是否空() {
                $lines = Get-Content -Path $Profile
                # 如果文件不为空，并且最后一行不是空行，则添加一个空行
                if ($lines.Count -gt 0 -and $lines[-1].Trim() -ne "") {
                    Add-Content -Path $Profile -Value ""
                }
            }

            # 检测 "chcp 936" 是否存在，如果不存在则添加
            if (检测是否要添加) {
                $versionInfo = "# 设置"+$ps_Info+"在系统为UTF-8编码下显示中文"
                $profileContent = "[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(`"gb2312`")"

                检测Profile最后一行是否空
                Add-Content -Path $Profile -Value $versionInfo
                Add-Content -Path $Profile -Value $profileContent
                Add-Content -Path $Profile -Value ""

                Write-Host ("已将 $ps_Info" + "设置为使用中文GB2312编码，请重新打开Powershell窗口生效。")
            }
            """
            result = subprocess.run(
                ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", ps_script],
                capture_output=True,
                text=True,
                encoding="gbk",
                errors="replace"
            )
            if result.returncode == 0:
                out = result.stdout.strip()
                self._set_message(f"✅ 设置完成\n{out}")
                self.operationFinished.emit(True, out)
            else:
                err = result.stderr.strip()
                self._set_message(f"❌ 设置失败: {err}")
                self.operationFinished.emit(False, err)
        except Exception as e:
            self._set_message(f"❌ 操作失败: {str(e)}")
            self.operationFinished.emit(False, f"操作失败:\n{str(e)}")
    
    @Slot(str)
    def exportPowerEventsToCsv(self, file_path):
        """导出电源事件到CSV文件
        
        Args:
            file_path: 导出的CSV文件路径
        """
        try:
            self._set_message("正在导出电源事件...")
            
            # PowerShell 脚本导出CSV
            ps_script = f"""
            $OutputEncoding = [System.Text.Encoding]::UTF8
            $events = @()
            
            $startupFilter = @{{ LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-General'; Id = 12 }}
            $startupEvents = Get-WinEvent -FilterHashtable $startupFilter -ErrorAction SilentlyContinue -MaxEvents 200
            
            $shutdownFilter = @{{ LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-General'; Id = 13 }}
            $shutdownEvents = Get-WinEvent -FilterHashtable $shutdownFilter -ErrorAction SilentlyContinue -MaxEvents 200
            
            $sleepFilter = @{{ LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-Power'; Id = 42 }}
            $sleepEvents = Get-WinEvent -FilterHashtable $sleepFilter -ErrorAction SilentlyContinue -MaxEvents 200
            
            $resumeFilter = @{{ LogName = 'System'; ProviderName = 'Microsoft-Windows-Kernel-Power'; Id = 107 }}
            $resumeEvents = Get-WinEvent -FilterHashtable $resumeFilter -ErrorAction SilentlyContinue -MaxEvents 200
            
            foreach ($e in $startupEvents) {{
                $events += [PSCustomObject]@{{
                    Type = 'Startup'
                    Time = $e.TimeCreated
                    Details = 'System boot'
                }}
            }}
            
            foreach ($e in $shutdownEvents) {{
                $events += [PSCustomObject]@{{
                    Type = 'Shutdown'
                    Time = $e.TimeCreated
                    Details = 'System shutdown'
                }}
            }}
            
            foreach ($e in $sleepEvents) {{
                $events += [PSCustomObject]@{{
                    Type = 'Sleep'
                    Time = $e.TimeCreated
                    Details = 'Enter sleep/hibernate'
                }}
            }}
            
            foreach ($e in $resumeEvents) {{
                $events += [PSCustomObject]@{{
                    Type = 'Resume'
                    Time = $e.TimeCreated
                    Details = 'Resume from sleep'
                }}
            }}
            
            $events | Sort-Object Time -Descending | Export-Csv -Path '{file_path}' -NoTypeInformation -Encoding UTF8
            """
            
            result = subprocess.run(
                ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-Command",
                 f"[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; {ps_script}"],
                capture_output=True,
                text=True,
                encoding='utf-8',
                errors='replace'
            )
            
            if result.returncode == 0:
                self._set_message(f"✅ 已导出到: {file_path}")
                self.operationFinished.emit(True, f"✅ 电源事件已导出到:\n{file_path}")
            else:
                error_msg = result.stderr if result.stderr else "导出失败"
                self._set_message(f"❌ 导出失败: {error_msg}")
                self.operationFinished.emit(False, f"导出失败:\n{error_msg}")
                
        except Exception as e:
            error_msg = f"导出失败: {str(e)}"
            self._set_message(f"❌ {error_msg}")
            self.operationFinished.emit(False, error_msg)
    
    @Slot()
    def initializeWindows(self):
        """初始化Windows系统"""
        try:
            self._set_message("开始初始化Windows系统...")
            self._set_progress(0)
            
            # 获取脚本路径
            script_dir = Path(__file__).parent / "resources" / "Init" / "Windows"
            init_script = script_dir / "初始化Windows.ps1"
            
            if not init_script.exists():
                self._set_message(f"❌ 初始化脚本不存在: {init_script}")
                self.operationFinished.emit(False, "初始化脚本不存在")
                return
            
            self._set_progress(20)
            
            # 执行PowerShell脚本
            result = subprocess.run(
                ["powershell.exe", "-ExecutionPolicy", "Bypass", "-File", str(init_script)],
                capture_output=True,
                text=True,
                encoding='utf-8',
                errors='ignore'
            )
            
            self._set_progress(80)
            
            output = result.stdout if result.stdout else ""
            error = result.stderr if result.stderr else ""
            
            self._set_progress(100)
            
            if result.returncode == 0:
                self._set_message("✅ Windows系统初始化完成")
                self.operationFinished.emit(True, f"初始化完成\n{output}")
            else:
                self._set_message(f"⚠️ 初始化脚本执行返回代码: {result.returncode}")
                self.operationFinished.emit(True, f"初始化完成，返回代码: {result.returncode}\n{output}\n{error}")
        
        except Exception as e:
            self._set_message(f"❌ 初始化失败: {str(e)}")
            self.operationFinished.emit(False, f"初始化失败: {str(e)}")
    
    @Slot()
    def installTrafficMonitor(self):
        """安装并配置网速显示工具"""
        try:
            self._set_message("开始安装网速显示工具...")
            self._set_progress(0)
            
            # 获取脚本路径
            script_dir = Path(__file__).parent / "resources" / "Init" / "Windows"
            script = script_dir / "安装并配置网速显示工具.ps1"
            
            if not script.exists():
                self._set_message(f"❌ 安装脚本不存在: {script}")
                self.operationFinished.emit(False, "安装脚本不存在")
                return
            
            self._set_progress(20)
            
            # 执行PowerShell脚本
            result = subprocess.run(
                ["powershell.exe", "-ExecutionPolicy", "Bypass", "-File", str(script)],
                capture_output=True,
                text=True,
                encoding='utf-8',
                errors='ignore'
            )
            
            self._set_progress(80)
            
            output = result.stdout if result.stdout else ""
            error = result.stderr if result.stderr else ""
            
            self._set_progress(100)
            
            if result.returncode == 0:
                self._set_message("✅ 网速显示工具安装完成")
                self.operationFinished.emit(True, f"安装完成\n{output}")
            else:
                self._set_message(f"⚠️ 安装脚本执行返回代码: {result.returncode}")
                self.operationFinished.emit(True, f"安装完成，返回代码: {result.returncode}\n{output}\n{error}")
        
        except Exception as e:
            self._set_message(f"❌ 安装失败: {str(e)}")
            self.operationFinished.emit(False, f"安装失败: {str(e)}")
    
    @Slot()
    def configureGitChinese(self):
        """将Git的命令提示改为中文"""
        try:
            self._set_message("开始配置Git中文提示...")
            self._set_progress(0)
            
            # 获取脚本路径
            script_dir = Path(__file__).parent / "resources" / "Init" / "Windows"
            script = script_dir / "将git的命令提示改为中文.py"
            
            if not script.exists():
                self._set_message(f"❌ 配置脚本不存在: {script}")
                self.operationFinished.emit(False, "配置脚本不存在")
                return
            
            self._set_progress(20)
            
            # 执行Python脚本
            import sys
            result = subprocess.run(
                [sys.executable, str(script), "-y"],
                capture_output=True,
                text=True,
                encoding='utf-8',
                errors='ignore'
            )
            
            self._set_progress(80)
            
            output = result.stdout if result.stdout else ""
            error = result.stderr if result.stderr else ""
            
            self._set_progress(100)
            
            if result.returncode == 0:
                self._set_message("✅ Git中文配置完成")
                self.operationFinished.emit(True, f"配置完成\n{output}")
            else:
                self._set_message(f"⚠️ 配置脚本执行返回代码: {result.returncode}")
                self.operationFinished.emit(True, f"配置完成，返回代码: {result.returncode}\n{output}\n{error}")
        
        except Exception as e:
            self._set_message(f"❌ 配置失败: {str(e)}")
            self.operationFinished.emit(False, f"配置失败: {str(e)}")
    
    @Slot()
    def initializeWindows(self):
        """
        初始化Windows系统
        调用初始化脚本进行系统配置
        """
        try:
            self._set_message("🔧 开始初始化Windows系统...")
            self._set_progress(0)
            
            # 获取脚本路径
            current_file = Path(__file__)
            project_root = current_file.parent.parent.parent
            script = project_root / "src" / "resources" / "Init" / "Windows" / "初始化Windows.ps1"
            
            if not script.exists():
                self._set_message(f"❌ 初始化脚本不存在: {script}")
                self.operationFinished.emit(False, "初始化脚本不存在")
                return
            
            self._set_progress(10)
            self._set_message("📦 正在执行初始化脚本...")
            
            # 执行PowerShell脚本
            result = subprocess.run(
                ["powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(script)],
                capture_output=True,
                text=True,
                encoding='utf-8',
                errors='replace'
            )
            
            self._set_progress(90)
            
            output = result.stdout if result.stdout else ""
            error = result.stderr if result.stderr else ""
            
            self._set_progress(100)
            
            if result.returncode == 0:
                self._set_message("✅ Windows系统初始化完成")
                self.operationFinished.emit(True, f"初始化完成\n{output}")
            else:
                self._set_message(f"⚠️ 初始化脚本执行返回代码: {result.returncode}")
                self.operationFinished.emit(True, f"初始化完成，返回代码: {result.returncode}\n{output}\n{error}")
        
        except Exception as e:
            self._set_message(f"❌ 初始化失败: {str(e)}")
            self.operationFinished.emit(False, f"初始化失败: {str(e)}")
