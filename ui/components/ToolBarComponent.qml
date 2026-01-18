import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * 工具栏组件
 * 顶部工具栏，包含应用标题、搜索框和功能按钮
 */
Rectangle {
    id: toolbar
    color: "#2196F3"
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 16
        
        // 应用图标和标题
        RowLayout {
            spacing: 12
            
            // 应用图标
            Rectangle {
                width: 32
                height: 32
                radius: 6
                color: "#1976D2"
                
                Text {
                    anchors.centerIn: parent
                    text: "🛠️"
                    font.pixelSize: 20
                }
            }
            
            // 应用标题
            Text {
                text: "MyTool"
                font.pixelSize: 18
                font.bold: true
                color: "white"
            }
        }
        
        // 弹性空间
        Item {
            Layout.fillWidth: true
        }
        
        // 搜索框
        Rectangle {
            Layout.preferredWidth: 300
            Layout.preferredHeight: 32
            radius: 16
            color: "#1976D2"
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8
                
                Text {
                    text: "🔍"
                    font.pixelSize: 16
                }
                
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "搜索工具..."
                    color: "white"
                    selectByMouse: true
                }
            }
        }
        
        // 功能按钮
        RowLayout {
            spacing: 8
            
            // 通知按钮
            Button {
                text: "🔔"
                font.pixelSize: 18
                flat: true
                
                onClicked: {
                    console.log("通知")
                }
            }
            
            // 帮助按钮
            Button {
                text: "❓"
                font.pixelSize: 18
                flat: true
                
                onClicked: {
                    console.log("帮助")
                }
            }
        }
    }
}
