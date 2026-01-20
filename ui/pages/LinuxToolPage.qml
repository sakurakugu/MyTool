import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

/**
 * Linux工具页面
 * 提供各种Linux系统相关的实用工具
 */
Rectangle {
    id: linuxToolPage
    color: "white"
    
    // 消息对话框
    MessageDialog {
        id: messageDialog
        buttons: MessageDialog.Ok
    }
    
    // 结果显示对话框
    Dialog {
        id: resultDialog
        title: "操作结果"
        width: 700
        height: 500
        modal: true
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                TextArea {
                    id: resultText
                    readOnly: true
                    wrapMode: TextArea.Wrap
                    selectByMouse: true
                }
            }
            
            Button {
                text: "关闭"
                Layout.alignment: Qt.AlignRight
                onClicked: resultDialog.close()
            }
        }
    }
    
    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        
        ColumnLayout {
            width: parent.width
            spacing: 0
            
            // 标题
            Rectangle {
                Layout.fillWidth: true
                height: 60
                color: "#f5f5f5"
                
                Label {
                    anchors.centerIn: parent
                    text: "Linux 工具"
                    font.pixelSize: 24
                    font.bold: true
                }
            }
            
            // 系统初始化区域
            GroupBox {
                title: "系统初始化"
                Layout.fillWidth: true
                Layout.margins: 10
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10
                    
                    Label {
                        text: "Ubuntu/Linux系统初始化工具，用于新安装的系统进行配置"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    RowLayout {
                        spacing: 10
                        Layout.fillWidth: true
                        
                        Button {
                            text: "初始化Ubuntu系统"
                            Layout.preferredWidth: 180
                            onClicked: {
                                if (typeof linuxTools !== 'undefined') {
                                    linuxTools.initializeUbuntu()
                                }
                            }
                        }
                        
                        Label {
                            text: "执行Ubuntu系统初始化（需要sudo权限）"
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                    
                    Label {
                        text: "注意：初始化脚本将会：\n" +
                              "• 设置系统语言为中文\n" +
                              "• 安装常用软件（git、vim、tmux等）\n" +
                              "• 配置Git全局设置\n" +
                              "• 同步系统时间\n" +
                              "• 桌面环境优化（如果检测到桌面）"
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                        font.italic: true
                        color: "#666"
                    }
                }
            }
            
            // 系统信息区域
            GroupBox {
                title: "系统信息"
                Layout.fillWidth: true
                Layout.margins: 10
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 10
                    
                    RowLayout {
                        spacing: 10
                        Layout.fillWidth: true
                        
                        Button {
                            text: "获取系统信息"
                            Layout.preferredWidth: 180
                            onClicked: {
                                if (typeof linuxTools !== 'undefined') {
                                    let info = linuxTools.getSystemInfo()
                                    resultText.text = info
                                    resultDialog.title = "系统信息"
                                    resultDialog.open()
                                }
                            }
                        }
                        
                        Label {
                            text: "查看系统发行版、内核、CPU、内存等信息"
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                    
                    RowLayout {
                        spacing: 10
                        Layout.fillWidth: true
                        
                        Button {
                            text: "检查虚拟化"
                            Layout.preferredWidth: 180
                            onClicked: {
                                if (typeof linuxTools !== 'undefined') {
                                    let isVirt = linuxTools.checkVirtualization()
                                    let msg = isVirt ? "当前运行在虚拟机中" : "当前运行在物理机上"
                                    messageDialog.title = "虚拟化检测"
                                    messageDialog.text = msg
                                    messageDialog.open()
                                }
                            }
                        }
                        
                        Label {
                            text: "检测当前系统是否运行在虚拟机中"
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                    
                    RowLayout {
                        spacing: 10
                        Layout.fillWidth: true
                        
                        Button {
                            text: "检查桌面环境"
                            Layout.preferredWidth: 180
                            onClicked: {
                                if (typeof linuxTools !== 'undefined') {
                                    let hasDesktop = linuxTools.checkDesktopEnvironment()
                                    let msg = hasDesktop ? "检测到桌面环境" : "未检测到桌面环境（服务器版本）"
                                    messageDialog.title = "桌面环境检测"
                                    messageDialog.text = msg
                                    messageDialog.open()
                                }
                            }
                        }
                        
                        Label {
                            text: "检测当前系统是否安装了桌面环境"
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
            }
            
            // 进度条
            ProgressBar {
                id: progressBar
                Layout.fillWidth: true
                Layout.margins: 10
                from: 0
                to: 100
                value: typeof linuxTools !== 'undefined' ? linuxTools.progress : 0
            }
            
            // 状态消息
            Label {
                id: statusLabel
                Layout.fillWidth: true
                Layout.margins: 10
                text: typeof linuxTools !== 'undefined' ? linuxTools.message : ""
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            
            // 占位符
            Item {
                Layout.fillHeight: true
            }
        }
    }
    
    Connections {
        target: typeof linuxTools !== 'undefined' ? linuxTools : null
        
        function onOperationFinished(success, message) {
            resultText.text = message
            resultDialog.title = success ? "操作成功" : "操作失败"
            resultDialog.open()
        }
    }
}
