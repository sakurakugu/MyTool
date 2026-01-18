import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * 文件工具页面
 * 提供文件处理相关功能
 */
Rectangle {
    id: fileToolPage
    color: "white"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // 页面标题
        RowLayout {
            spacing: 12
            
            Text {
                text: "📁"
                font.pixelSize: 32
            }
            
            Text {
                text: "文件工具"
                font.pixelSize: 24
                font.bold: true
                color: "#333333"
            }
        }
        
        // 工具描述
        Text {
            text: "提供文件转换、压缩、批量处理等功能"
            font.pixelSize: 14
            color: "#666666"
        }
        
        // 功能按钮区域
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 12
            columnSpacing: 12
            
            // 文件压缩
            Button {
                text: "文件压缩"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                
                onClicked: {
                    console.log("文件压缩")
                }
            }
            
            // 文件解压
            Button {
                text: "文件解压"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                
                onClicked: {
                    console.log("文件解压")
                }
            }
            
            // 批量重命名
            Button {
                text: "批量重命名"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                
                onClicked: {
                    console.log("批量重命名")
                }
            }
        }
        
        // 文件列表区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            border.color: "#E0E0E0"
            border.width: 1
            radius: 4
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 12
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "📂"
                    font.pixelSize: 48
                }
                
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "拖拽文件到此处或点击上传"
                    font.pixelSize: 16
                    color: "#999999"
                }
            }
        }
    }
}
