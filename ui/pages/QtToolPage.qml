import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

/**
 * Qt翻译工具页面
 * 提供Qt TS翻译文件处理功能
 */
Rectangle {
    id: qtToolPage
    color: "white"
    
    // 消息对话框
    MessageDialog {
        id: messageDialog
        buttons: MessageDialog.Ok
    }
    
    // 文件夹选择对话框
    FolderDialog {
        id: folderDialog
        title: "选择i18n文件夹"
        currentFolder: "file:///"
        
        onAccepted: {
            let path = selectedFolder.toString()
            // 移除 file:/// 前缀
            if (path.startsWith("file:///")) {
                path = path.substring(8)
            }
            i18nPathField.text = path
            if (typeof qtTools !== 'undefined') {
                qtTools.setI18nDirectory(path)
            }
        }
    }
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 24
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            
            // 页面标题
            Text {
                text: "Qt翻译工具"
                font.pixelSize: 24
                font.bold: true
                color: "#333333"
            }
            
            // 工具卡片容器
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16
                
                // 选择目录
                GroupBox {
                    Layout.fillWidth: true
                    title: "📁 选择i18n目录"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        Text {
                            Layout.fillWidth: true
                            text: "选择包含.ts翻译文件的i18n目录"
                            wrapMode: Text.WordWrap
                            color: "#666666"
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            TextField {
                                id: i18nPathField
                                Layout.fillWidth: true
                                placeholderText: "i18n文件夹路径..."
                                readOnly: true
                            }
                            
                            Button {
                                text: "浏览..."
                                onClicked: folderDialog.open()
                            }
                            
                            Button {
                                text: "查找TS文件"
                                enabled: i18nPathField.text.length > 0
                                onClicked: {
                                    if (typeof qtTools !== 'undefined') {
                                        qtTools.findTsFiles()
                                    }
                                }
                            }
                        }
                    }
                }
                
                // 处理选项
                GroupBox {
                    Layout.fillWidth: true
                    title: "⚙️ 处理选项"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        Text {
                            Layout.fillWidth: true
                            text: "功能说明：\n1. 移除有内容的<translation type=\"unfinished\">标签中的type=\"unfinished\"属性\n2. 自动填充中文到中文的空翻译（可选）"
                            wrapMode: Text.WordWrap
                            color: "#666666"
                        }
                        
                        CheckBox {
                            id: autoFillCheckbox
                            text: "自动填充中文翻译（对于中文→中文的翻译文件）"
                        }
                        
                        Button {
                            text: "处理所有TS文件"
                            enabled: i18nPathField.text.length > 0
                            onClicked: {
                                if (typeof qtTools !== 'undefined') {
                                    qtTools.processAllFiles(autoFillCheckbox.checked)
                                }
                            }
                        }
                        
                        // 进度条
                        ProgressBar {
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: (typeof qtTools !== 'undefined') ? qtTools.progress : 0
                            visible: value > 0 && value < 100
                        }
                    }
                }
                
                // 状态消息显示区域
                Rectangle {
                    Layout.fillWidth: true
                    Layout.minimumHeight: 120
                    border.color: "#E0E0E0"
                    border.width: 1
                    radius: 4
                    color: "#F9F9F9"
                    
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 10
                        
                        Text {
                            width: parent.width
                            text: (typeof qtTools !== 'undefined') ? qtTools.message : "等待操作..."
                            wrapMode: Text.Wrap
                            color: "#333333"
                        }
                    }
                }
                
                // 提示信息
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: noteText.height + 20
                    color: "#E8F5E9"
                    border.color: "#4CAF50"
                    border.width: 1
                    radius: 4
                    
                    Text {
                        id: noteText
                        anchors.fill: parent
                        anchors.margins: 10
                        text: "💡 使用说明：\n• 选择包含.ts文件的i18n文件夹\n• 工具会自动创建备份文件（.backup后缀）\n• 支持批量处理多个TS文件\n• 可选：自动填充中文到中文的翻译内容"
                        wrapMode: Text.WordWrap
                        color: "#2E7D32"
                    }
                }
            }
        }
    }
    
    // 连接工具信号
    Connections {
        target: (typeof qtTools !== 'undefined') ? qtTools : null
        
        function onOperationFinished(success, message) {
            messageDialog.text = message
            messageDialog.open()
        }
    }
}
