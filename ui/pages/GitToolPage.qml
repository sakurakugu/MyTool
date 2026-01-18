import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

/**
 * Git工具页面
 * 提供Git相关的实用工具
 */
Rectangle {
    id: gitToolPage
    color: "white"
    
    // 消息对话框
    MessageDialog {
        id: messageDialog
        buttons: MessageDialog.Ok
    }
    
    ScrollView {
        anchors.fill: parent
        anchors.margins: 24
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            
            // 页面标题
            Text {
                text: "Git工具"
                font.pixelSize: 24
                font.bold: true
                color: "#333333"
            }
            
            // 工具卡片容器
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16
                
                // Git检查
                GroupBox {
                    Layout.fillWidth: true
                    title: "ℹ️ Git信息"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        Text {
                            Layout.fillWidth: true
                            text: "检查Git安装状态和版本信息"
                            wrapMode: Text.WordWrap
                            color: "#666666"
                        }
                        
                        RowLayout {
                            spacing: 10
                            
                            Button {
                                text: "检查Git安装"
                                onClicked: {
                                    if (typeof gitTools !== 'undefined') {
                                        gitTools.checkGitInstalled()
                                    }
                                }
                            }
                            
                            Button {
                                text: "获取Git版本"
                                onClicked: {
                                    if (typeof gitTools !== 'undefined') {
                                        gitTools.getGitVersion()
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Git中文翻译
                GroupBox {
                    Layout.fillWidth: true
                    title: "🌏 Git中文化"
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 12
                        
                        Text {
                            Layout.fillWidth: true
                            text: "将Git命令行界面翻译为中文。此操作会下载中文翻译文件并安装到Git目录，可能需要管理员权限。安装后需要重启终端才能生效。"
                            wrapMode: Text.WordWrap
                            color: "#666666"
                        }
                        
                        Button {
                            text: "安装Git中文翻译"
                            enabled: (typeof gitTools !== 'undefined') ? gitTools.progress === 0 || gitTools.progress === 100 : true
                            onClicked: {
                                if (typeof gitTools !== 'undefined') {
                                    gitTools.installChineseTranslation()
                                }
                            }
                        }
                        
                        // 进度条
                        ProgressBar {
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: (typeof gitTools !== 'undefined') ? gitTools.progress : 0
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
                            text: (typeof gitTools !== 'undefined') ? gitTools.message : "等待操作..."
                            wrapMode: Text.Wrap
                            color: "#333333"
                        }
                    }
                }
                
                // 提示信息
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: noteText.height + 20
                    color: "#FFF3CD"
                    border.color: "#FFC107"
                    border.width: 1
                    radius: 4
                    
                    Text {
                        id: noteText
                        anchors.fill: parent
                        anchors.margins: 10
                        text: "💡 注意事项：\n• 此功能需要系统已安装Git\n• 可能需要管理员权限\n• 需要网络连接下载翻译文件\n• 安装完成后需重启终端生效"
                        wrapMode: Text.WordWrap
                        color: "#856404"
                    }
                }
            }
        }
    }
    
    // 连接工具信号
    Connections {
        target: (typeof gitTools !== 'undefined') ? gitTools : null
        
        function onOperationFinished(success, message) {
            messageDialog.text = message
            messageDialog.open()
        }
    }
}
