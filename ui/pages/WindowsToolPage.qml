import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

/**
 * Windows工具页面
 * 提供各种Windows系统相关的实用工具
 */
Item {
    id: windowsToolPage
    
    // 消息对话框
    MessageDialog {
        id: messageDialog
        buttons: MessageDialog.Ok
    }
    
    // 文件夹选择对话框
    FolderDialog {
        id: folderDialog
        title: "选择包含desktop.ini的文件夹"
        currentFolder: "file:///"
        
        onAccepted: {
            let path = selectedFolder.toString()
            // 移除 file:/// 前缀
            if (path.startsWith("file:///")) {
                path = path.substring(8)
            }
            desktopIniFolderField.text = path
            // 自动检查是否存在desktop.ini
            if (typeof windowsTools !== 'undefined') {
                windowsTools.checkDesktopIni(path)
            }
        }
    }
    
    // CSV导出对话框
    FileDialog {
        id: csvExportDialog
        title: "导出电源事件到CSV"
        fileMode: FileDialog.SaveFile
        defaultSuffix: "csv"
        nameFilters: ["CSV 文件 (*.csv)"]
        currentFolder: "file:///" + (typeof windowsTools !== 'undefined' ? "C:/Users/" : "")
        
        onAccepted: {
            let path = selectedFile.toString()
            if (path.startsWith("file:///")) {
                path = path.substring(8)
            }
            if (typeof windowsTools !== 'undefined') {
                windowsTools.exportPowerEventsToCsv(path)
            }
        }
    }
    
    // 电源事件查看对话框
    Dialog {
        id: powerEventsDialog
        title: "系统电源时间线"
        width: 900
        height: 600
        modal: true
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            
            // 顶部按钮栏
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    text: "刷新"
                    onClicked: {
                        if (typeof windowsTools !== 'undefined') {
                            windowsTools.getSystemPowerEvents()
                        }
                    }
                }
                
                Button {
                    text: "导出CSV"
                    onClicked: csvExportDialog.open()
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "关闭"
                    onClicked: powerEventsDialog.close()
                }
            }
            
            // 表头
            Rectangle {
                Layout.fillWidth: true
                height: 40
                color: "#F0F0F0"
                border.width: 1
                border.color: "#CCCCCC"
                
                Row {
                    anchors.fill: parent
                    
                    Rectangle {
                        width: parent.width * 0.2
                        height: parent.height
                        color: "transparent"
                        border.width: 1
                        border.color: "#CCCCCC"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "类型"
                            font.bold: true
                            color: "#333333"
                        }
                    }
                    
                    Rectangle {
                        width: parent.width * 0.3
                        height: parent.height
                        color: "transparent"
                        border.width: 1
                        border.color: "#CCCCCC"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "时间"
                            font.bold: true
                            color: "#333333"
                        }
                    }
                    
                    Rectangle {
                        width: parent.width * 0.5
                        height: parent.height
                        color: "transparent"
                        border.width: 1
                        border.color: "#CCCCCC"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "详情"
                            font.bold: true
                            color: "#333333"
                        }
                    }
                }
            }
            
            // 事件列表
            ListView {
                id: powerEventsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                
                model: ListModel {
                    id: powerEventsModel
                }
                
                delegate: Rectangle {
                    width: powerEventsList.width
                    height: 50
                    border.width: 1
                    border.color: "#E0E0E0"
                    color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"
                    
                    Row {
                        anchors.fill: parent
                        
                        // 类型列
                        Rectangle {
                            width: parent.width * 0.2
                            height: parent.height
                            color: "transparent"
                            
                            Text {
                                anchors.fill: parent
                                anchors.margins: 8
                                text: model.type || ""
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                color: "#333333"
                                font.bold: true
                            }
                        }
                        
                        // 时间列
                        Rectangle {
                            width: parent.width * 0.3
                            height: parent.height
                            color: "transparent"
                            
                            Text {
                                anchors.fill: parent
                                anchors.margins: 8
                                text: model.time || ""
                                verticalAlignment: Text.AlignVCenter
                                color: "#333333"
                            }
                        }
                        
                        // 详情列
                        Rectangle {
                            width: parent.width * 0.5
                            height: parent.height
                            color: "transparent"
                            
                            Text {
                                anchors.fill: parent
                                anchors.margins: 8
                                text: model.details || ""
                                wrapMode: Text.WordWrap
                                verticalAlignment: Text.AlignVCenter
                                color: "#666666"
                            }
                        }
                    }
                }
                
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                }
            }
        }
    }
    
    // 主内容区域
    Rectangle {
        anchors.fill: parent
        color: "white"
        
        ScrollView {
            anchors.fill: parent
            anchors.margins: 24
            
            ColumnLayout {
                width: parent.width
                spacing: 20
                
                // 页面标题
                Text {
                    text: "Windows工具"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#333333"
                }
                
                // Windows初始化工具
                GroupBox {
                    Layout.fillWidth: true
                    title: "🚀 Windows系统初始化"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        Text {
                            Layout.fillWidth: true
                            text: "初始化Windows系统配置，包括：\n• 安装并配置网速显示工具（TrafficMonitor）\n• Git全局配置（用户名、邮箱、编码等）\n• Git命令提示中文化"
                            wrapMode: Text.WordWrap
                            color: "#666666"
                        }
                        
                        Button {
                            text: "开始初始化"
                            onClicked: {
                                if (typeof windowsTools !== 'undefined') {
                                    windowsTools.initializeWindows()
                                }
                            }
                        }
                    }
                }
                
                // 桌面壁纸工具
                GroupBox {
                    Layout.fillWidth: true
                    title: "🖼️ 桌面壁纸"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        Text {
                            Layout.fillWidth: true
                            text: "获取并保存当前桌面壁纸到下载文件夹"
                            wrapMode: Text.WordWrap
                            color: "#666666"
                        }
                        
                        Button {
                            text: "保存当前壁纸"
                            onClicked: {
                                if (typeof windowsTools !== 'undefined') {
                                    windowsTools.saveWallpaper()
                                }
                            }
                        }
                    }
                }
                
                // Win11搜索栏工具
                GroupBox {
                    Layout.fillWidth: true
                    title: "🔍 搜索栏网页搜索"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        Text {
                            Layout.fillWidth: true
                            text: "开关Win11搜索栏的Bing网页搜索功能"
                            wrapMode: Text.WordWrap
                            color: "#666666"
                        }
                        
                        RowLayout {
                            spacing: 10
                            
                            Button {
                                text: "开启网页搜索"
                                onClicked: {
                                    if (typeof windowsTools !== 'undefined') {
                                        windowsTools.toggleSearchWebSearch(true)
                                    }
                                }
                            }
                            
                            Button {
                                text: "关闭网页搜索"
                                onClicked: {
                                    if (typeof windowsTools !== 'undefined') {
                                        windowsTools.toggleSearchWebSearch(false)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 图标工具
                GroupBox {
                    Layout.fillWidth: true
                    title: "🎨 图标设置"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        Text {
                            Layout.fillWidth: true
                            text: "图标相关的系统设置和修复工具"
                            wrapMode: Text.WordWrap
                            color: "#666666"
                        }
                        
                        RowLayout {
                            spacing: 10
                            
                            Button {
                                text: "恢复图标默认间距"
                                onClicked: {
                                    if (typeof windowsTools !== 'undefined') {
                                        windowsTools.resetIconSpacing()
                                    }
                                }
                            }
                            
                            Button {
                                text: "刷新图标缓存"
                                onClicked: {
                                    if (typeof windowsTools !== 'undefined') {
                                        windowsTools.refreshIcons()
                                    }
                                }
                            }
                        }
                        
                        RowLayout {
                            spacing: 10
                            
                            Button {
                                text: "去除快捷方式角标"
                                onClicked: {
                                    if (typeof windowsTools !== 'undefined') {
                                        windowsTools.removeShortcutOverlay()
                                    }
                                }
                            }
                            
                            Button {
                                text: "恢复快捷方式角标"
                                onClicked: {
                                    if (typeof windowsTools !== 'undefined') {
                                        windowsTools.restoreShortcutOverlay()
                                    }
                                }
                            }
                        }
                    }
                }
                
                GroupBox {
                    Layout.fillWidth: true
                    title: "💠 PowerShell 设置"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        Text {
                            Layout.fillWidth: true
                            text: "配置PowerShell环境：允许运行脚本、初始化Profile、中文提示编码设置"
                            wrapMode: Text.WordWrap
                            color: "#666666"
                        }
                        
                        RowLayout {
                            spacing: 10
                            
                            Button {
                                text: "允许运行脚本"
                                onClicked: {
                                    if (typeof windowsTools !== 'undefined') {
                                        windowsTools.allowPowershellScripts()
                                    }
                                }
                            }
                            
                            Button {
                                text: "初始化Profile"
                                onClicked: {
                                    if (typeof windowsTools !== 'undefined') {
                                        windowsTools.initPowershellProfile()
                                    }
                                }
                            }
                            
                            Button {
                                text: "中文提示编码设置"
                                onClicked: {
                                    if (typeof windowsTools !== 'undefined') {
                                        windowsTools.setPowershellChineseEncoding()
                                    }
                                }
                            }
                        }
                    }
                }
                
                // desktop.ini工具
                GroupBox {
                    Layout.fillWidth: true
                    title: "📄 desktop.ini启用"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        Text {
                            Layout.fillWidth: true
                            text: "为文件夹中的desktop.ini文件设置系统和隐藏属性，使其生效。\n注意：需要先在文件夹中创建desktop.ini文件。"
                            wrapMode: Text.WordWrap
                            color: "#666666"
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            TextField {
                                id: desktopIniFolderField
                                Layout.fillWidth: true
                                placeholderText: "选择包含desktop.ini的文件夹..."
                                readOnly: true
                            }
                            
                            Button {
                                text: "浏览..."
                                onClicked: folderDialog.open()
                            }
                        }
                        
                        RowLayout {
                            spacing: 10
                            
                            Button {
                                text: "检查desktop.ini"
                                enabled: desktopIniFolderField.text.length > 0
                                onClicked: {
                                    if (typeof windowsTools !== 'undefined') {
                                        windowsTools.checkDesktopIni(desktopIniFolderField.text)
                                    }
                                }
                            }
                            
                            Button {
                                text: "启用desktop.ini"
                                enabled: desktopIniFolderField.text.length > 0
                                onClicked: {
                                    if (typeof windowsTools !== 'undefined') {
                                        windowsTools.enableDesktopIni(desktopIniFolderField.text)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 系统电源时间线
                GroupBox {
                    Layout.fillWidth: true
                    title: "⚡ 系统电源时间线"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        Text {
                            Layout.fillWidth: true
                            text: "查看系统的开机、关机、休眠、唤醒等电源事件记录"
                            wrapMode: Text.WordWrap
                            color: "#666666"
                        }
                        
                        Button {
                            text: "查看电源时间线"
                            onClicked: {
                                powerEventsDialog.open()
                                if (typeof windowsTools !== 'undefined') {
                                    windowsTools.getSystemPowerEvents()
                                }
                            }
                        }
                    }
                }
                
                // 状态消息显示区域
                Rectangle {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 80
                    border.color: "#E0E0E0"
                    border.width: 1
                    radius: 4
                    color: "#F9F9F9"
                    
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 10
                        
                        Text {
                            width: parent.width
                            text: (typeof windowsTools !== 'undefined') ? windowsTools.message : "等待操作..."
                            wrapMode: Text.Wrap
                            color: "#333333"
                        }
                    }
                }
            }
        }
    }
    
    // 连接工具信号
    Connections {
        target: (typeof windowsTools !== 'undefined') ? windowsTools : null
        
        function onOperationFinished(success, message) {
            messageDialog.text = message
            messageDialog.open()
        }
        
        function onPowerEventsLoaded(events) {
            powerEventsModel.clear()
            for (let i = 0; i < events.length; i++) {
                powerEventsModel.append({
                    type: events[i].type,
                    time: events[i].time,
                    details: events[i].details
                })
            }
        }
    }
}
