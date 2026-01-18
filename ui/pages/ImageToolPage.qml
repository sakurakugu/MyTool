import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * 图片工具页面
 * 提供图片处理相关功能
 */
Rectangle {
    id: imageToolPage
    color: "white"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // 页面标题
        RowLayout {
            spacing: 12
            
            Text {
                text: "🖼️"
                font.pixelSize: 32
            }
            
            Text {
                text: "图片工具"
                font.pixelSize: 24
                font.bold: true
                color: "#333333"
            }
        }
        
        // 工具描述
        Text {
            text: "提供图片编辑、格式转换、压缩等功能"
            font.pixelSize: 14
            color: "#666666"
        }
        
        // 功能按钮区域
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 12
            columnSpacing: 12
            
            // 图片压缩
            Button {
                text: "图片压缩"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                
                onClicked: {
                    console.log("图片压缩")
                }
            }
            
            // 格式转换
            Button {
                text: "格式转换"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                
                onClicked: {
                    console.log("格式转换")
                }
            }
            
            // 图片裁剪
            Button {
                text: "图片裁剪"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                
                onClicked: {
                    console.log("图片裁剪")
                }
            }
        }
        
        // 图片预览区域
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            border.color: "#E0E0E0"
            border.width: 1
            radius: 4
            
            Text {
                anchors.centerIn: parent
                text: "拖拽图片到此处或点击上传"
                font.pixelSize: 16
                color: "#999999"
            }
        }
    }
}
