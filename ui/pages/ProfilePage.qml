import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * 个人中心页面
 * 用户个人信息和统计
 */
Rectangle {
    id: profilePage
    color: "white"
    
    ScrollView {
        anchors.fill: parent
        
        ColumnLayout {
            width: parent.width
            spacing: 24
            
            // 页面标题
            RowLayout {
                spacing: 12
                
                Text {
                    text: "👤"
                    font.pixelSize: 32
                }
                
                Text {
                    text: "个人中心"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#333333"
                }
            }
            
            // 用户信息卡片
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                radius: 8
                border.color: "#E0E0E0"
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20
                    
                    // 头像
                    Rectangle {
                        Layout.preferredWidth: 80
                        Layout.preferredHeight: 80
                        radius: 40
                        color: "#2196F3"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "😊"
                            font.pixelSize: 40
                        }
                    }
                    
                    // 用户信息
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "用户名"
                            font.pixelSize: 18
                            font.bold: true
                            color: "#333333"
                        }
                        
                        Text {
                            text: "user@example.com"
                            font.pixelSize: 14
                            color: "#666666"
                        }
                        
                        Text {
                            text: "注册时间：2024-01-01"
                            font.pixelSize: 12
                            color: "#999999"
                        }
                    }
                    
                    Button {
                        text: "编辑资料"
                        Layout.preferredHeight: 36
                        
                        onClicked: {
                            console.log("编辑资料")
                        }
                    }
                }
            }
            
            // 使用统计
            GroupBox {
                Layout.fillWidth: true
                title: "使用统计"
                
                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    rowSpacing: 16
                    columnSpacing: 16
                    
                    // 使用天数
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        radius: 4
                        color: "#E3F2FD"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "365"
                                font.pixelSize: 24
                                font.bold: true
                                color: "#2196F3"
                            }
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "使用天数"
                                font.pixelSize: 13
                                color: "#666666"
                            }
                        }
                    }
                    
                    // 使用次数
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        radius: 4
                        color: "#E8F5E9"
                        
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "1,234"
                                font.pixelSize: 24
                                font.bold: true
                                color: "#4CAF50"
                            }
                            
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "使用次数"
                                font.pixelSize: 13
                                color: "#666666"
                            }
                        }
                    }
                }
            }
            
            // 最近使用
            GroupBox {
                Layout.fillWidth: true
                title: "最近使用"
                
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    
                    Repeater {
                        model: ["文本工具", "图片工具", "代码工具"]
                        
                        delegate: RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "•"
                                font.pixelSize: 16
                                color: "#2196F3"
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: modelData
                                font.pixelSize: 14
                                color: "#333333"
                            }
                        }
                    }
                }
            }
            
            Item {
                Layout.fillHeight: true
            }
        }
    }
}
