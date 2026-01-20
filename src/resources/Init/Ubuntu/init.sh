# 该文件用于Ubuntu等Linux系统的初始化配置
# 这个文件是用于在安装新系统后，自动配置一些文件，比如配置环境变量，配置软件等等

# 在安装时，若长期卡住，要在"Try install Ubuntu"时，按下E键，进入编辑模式，然后在"---"中输入 "nomodeset noapic", 然后按下Ctrl+X键，进入安装界面

# 当前是否在虚拟机
if systemd-detect-virt --quiet; then
    is_virt=true
else
    is_virt=false
fi

# 当前是否是桌面端
if dpkg -l | grep -qE 'gnome-shell|plasma-desktop|xfce4-session|mate-session'; then
    is_desktop=true
elif ls /usr/share/xsessions/*.desktop >/dev/null 2>&1; then
    is_desktop=true
elif systemctl list-unit-files | grep -qE 'gdm3|lightdm|sddm'; then
    is_desktop=true
else
    is_desktop=false
fi

software_list_cli=(
    "git"   # 版本控制工具
    "vim"   # 文本编辑器
    "tmux"  # 终端复用器
    "htop"  # 交互式进程查看器
    "curl"  # 网络工具
    "wget"  # 下载工具
    "tldr"  # 命令行工具手册
    "neofetch" # 系统信息工具
    "ntpdate" # 网络时间同步工具
    "util-linux" # Linux实用工具
    "util-linux-extra" # Linux实用工具扩展
)

software_list_gui=(
    "clash-verge" # 网络代理工具
    "gnome-tweaks" # GNOME桌面美化工具
    "tweak" # 软件包管理器
    "nemo"  # 文件管理器
    "dconf-editor" # GNOME配置编辑器
)

# 待安装的软件列表
software_list=()
software_list+=("${software_list_cli[@]}")
if [ "$is_desktop" = true ]; then
    software_list+=("${software_list_gui[@]}")
fi

# 设置系统语言为中文
sudo apt update
sudo apt install -y language-pack-zh-hans
sudo update-locale LANG=zh_CN.UTF-8
sudo locale-gen zh_CN.UTF-8
sudo dpkg-reconfigure locales

# 安装软件
for software in "${software_list[@]}"; do
    if ! command -v $software &> /dev/null
    then
        echo "$software 未安装，正在安装..."
        sudo apt install -y $software
    else
        echo "$software 已安装"
    fi
done

# git 全局配置
git config --global user.email "171350650@qq.com"
git config --global user.name "sakurakugu"
git config --global core.autocrlf input # 提交时转换为LF，检出时不转换
git config --global core.safecrlf warn # 仅警告即可
git config --global core.quotepath false # 禁止字符串转义
git config --global gui.encoding utf-8 # 图形界面编码改为utf-8
git config --global i18n.commitencoding utf-8 # 提交信息编码改为utf-8
git config --global i18n.logoutputencoding utf-8 # 输出log编码改为utf-8

# 关闭 ~[[200 ~  这种格式
LINE="echo -ne '\e[?2004l'"
if grep -Fxq "$LINE" ~/.bashrc
then
    echo "该命令已存在于 ~/.bashrc 中，无需重复添加。"
else
    echo "" >> ~/.bashrc
    echo "#关闭 粘贴 自动添加 ^[[200~ -v~" >> ~/.bashrc
    echo "$LINE" >> ~/.bashrc
    echo "已将命令添加到 ~/.bashrc。"
fi

# 同步时间（仅在非虚拟机执行）
if [ "$is_virt" = false ]; then
    sudo ntpdate -u time.windows.com
    sudo timedatectl set-local-rtc 1
    sudo hwclock --localtime --systohc
fi

# 仅在桌面端执行
if [ "$is_desktop" = true ]; then

    # 解决搜狗输入法闪的问题
    if grep -Fxq "QT_QPA_PLATFORM=\"xcb\"" /etc/environment
    then
        echo "该命令已存在于 /etc/environment 中，无需重复添加。"
    else
        echo "已将命令添加到 /etc/environment。"
        echo "QT_QPA_PLATFORM=\"xcb\"" | sudo tee -a /etc/environment >/dev/null
    fi

    # 桌面显示回收站图标
    gsettings set org.gnome.shell.extensions.ding show-trash true
fi

# 要手动修改的部分
echo "请手动修改以下文件："
if [ "$is_desktop" = true ]; then
echo "    • 修改Grub引导菜单"
echo "        1. 输入：sudo vim /etc/default/grub"
echo "        2. 修改：GRUB_DEFAULT=0 ==> 4（自己数，不一定是第四个，记得从0开始数）"
echo "        3. 输入：sudo update-grub"
echo "    • 修改apt源"
echo "        1. 打开软件更新器设置，修改下载源为：http://mirrors.aliyun.com/ubuntu/"
fi

echo "    • 修改系统更新版本"
echo "        修改/etc/update-manager/release-upgrades"
echo "        Prompt=lts 为安装长期支持版本"
echo "        Prompt=normal 为安装最新版本"


# 各种软件的图标都放在：/usr/share/applications
