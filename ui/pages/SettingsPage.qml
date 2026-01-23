import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MyTool 1.0

/**
 * 设置页面
 * 应用程序设置和配置
 */
Rectangle {
    id: settingsPage
    color: Theme.background
    
    ScrollView {
        anchors.fill: parent
        
        ColumnLayout {
            width: parent.width
            anchors.margins: 24
            spacing: 24
            
            // 页面标题
            RowLayout {
                spacing: 12
                
                Text {
                    text: "⚙️"
                    font.pixelSize: 32
                }
                
                Text {
                    text: "设置"
                    font.pixelSize: 24
                    font.bold: true
                    color: Theme.text
                }
            }
            
            // 通用设置
            GroupBox {
                Layout.fillWidth: true
                title: "通用设置"
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12
                    
                    // 语言设置
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "语言："
                            font.pixelSize: 14
                            color: Theme.text
                        }
                        
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["简体中文", "English", "日本語"]
                        }
                    }
                    
                    // 主题设置
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "主题："
                            font.pixelSize: 14
                            color: Theme.text
                        }
                        
                        ComboBox {
                            id: themeComboBox
                            Layout.fillWidth: true
                            model: ["浅色", "深色", "跟随系统"]
                            currentIndex: Theme.mode === "dark" ? 1 : (Theme.mode === "system" ? 2 : 0)
                            onActivated: {
                                if (currentIndex === 0) {
                                    Theme.mode = "light"
                                } else if (currentIndex === 1) {
                                    Theme.mode = "dark"
                                } else {
                                    Theme.mode = "system"
                                }
                            }
                        }
                    }
                }
            }
            
            // 行为设置
            GroupBox {
                Layout.fillWidth: true
                title: "行为设置"
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12
                    
                    CheckBox {
                        text: "启动时打开上次的工具"
                        checked: true
                    }
                    
                    CheckBox {
                        text: "自动保存工作区"
                        checked: true
                    }
                    
                    CheckBox {
                        text: "启用通知"
                        checked: false
                    }
                }
            }
            
            // 关于
            GroupBox {
                Layout.fillWidth: true
                title: "关于"
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    
                    Text {
                        text: application.appName + " v" + application.appVersion
                        font.pixelSize: 14
                        color: Theme.text
                    }
                    
                    Text {
                        text: "多功能工具箱应用程序"
                        font.pixelSize: 13
                        color: Theme.textMuted
                    }
                }
            }
            
            // 版本信息说明
            GroupBox {
                Layout.fillWidth: true
                title: "版本信息"
                visible: false  // 可选：显示详细版本信息
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    
                    Text {
                        text: "应用名称: " + application.appName
                        font.pixelSize: 13
                    }
                    
                    Text {
                        text: "版本号: " + application.appVersion
                        font.pixelSize: 13
                    }
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
