import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * 文本工具页面
 * 提供文本处理相关功能
 */
Rectangle {
    id: textToolPage
    color: "white"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // 页面标题
        RowLayout {
            spacing: 12
            
            Text {
                text: "📝"
                font.pixelSize: 32
            }
            
            Text {
                text: "文本工具"
                font.pixelSize: 24
                font.bold: true
                color: "#333333"
            }
        }
        
        // 工具描述
        Text {
            text: "提供文本编辑、格式化、转换等功能"
            font.pixelSize: 14
            color: "#666666"
        }
        
        // 功能按钮区域
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 12
            columnSpacing: 12
            
            // 大小写转换
            Button {
                text: "大小写转换"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                
                onClicked: {
                    console.log("大小写转换")
                }
            }
            
            // Base64编码
            Button {
                text: "Base64 编码"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                
                onClicked: {
                    console.log("Base64编码")
                }
            }
            
            // URL编码
            Button {
                text: "URL 编码"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                
                onClicked: {
                    console.log("URL编码")
                }
            }
        }
        
        // 文本编辑区域
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            TextArea {
                placeholderText: "在此输入或粘贴文本..."
                wrapMode: TextArea.Wrap
                selectByMouse: true
                font.pixelSize: 14
            }
        }
    }
}
