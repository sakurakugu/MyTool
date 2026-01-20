
# 该文件用于Windows系统的初始化配置
# 这个文件是用于在安装新系统后，自动配置一些文件，比如配置环境变量，配置软件等等

& "$PSScriptRoot\安装并配置网速实时显示.ps1"

# git全局配置
& git config --global user.email "171350650@qq.com"
& git config --global user.name "sakurakugu"
& git config --global core.autocrlf true # 提交时转换为LF，检出时不转换
& git config --global core.safecrlf warn # 仅警告即可
& git config --global core.quotepath false # 禁止字符串转义
& git config --global gui.encoding utf-8 # 图形界面编码改为utf-8
& git config --global i18n.commitencoding utf-8 # 提交信息编码改为utf-8
& git config --global i18n.logoutputencoding utf-8 # 输出log编码改为utf-8
& git config --global init.defaultBranch main # 默认分支改为main

# 将git的命令提示改成中文
& python "$PSScriptRoot\将git的命令提示改为中文.py" -y
