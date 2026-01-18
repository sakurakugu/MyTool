import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * 代码工具页面
 * 提供代码处理相关功能
 */
Rectangle {
    id: codeToolPage
    color: "white"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 16
        
        // 页面标题
        RowLayout {
            spacing: 12
            
            Text {
                text: "💻"
                font.pixelSize: 32
            }
            
            Text {
                text: "代码工具"
                font.pixelSize: 24
                font.bold: true
                color: "#333333"
            }
        }
        
        // 工具描述
        Text {
            text: "提供代码格式化、压缩、转换等功能"
            font.pixelSize: 14
            color: "#666666"
        }
        
        // 功能按钮区域
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 12
            columnSpacing: 12
            
            // JSON格式化
            Button {
                text: "JSON 格式化"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                
                onClicked: {
                    console.log("JSON格式化")
                }
            }
            
            // XML格式化
            Button {
                text: "XML 格式化"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                
                onClicked: {
                    console.log("XML格式化")
                }
            }
            
            // 代码压缩
            Button {
                text: "代码压缩"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                
                onClicked: {
                    console.log("代码压缩")
                }
            }
        }
        
        // 代码编辑区域
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            TextArea {
                placeholderText: "在此输入或粘贴代码..."
                wrapMode: TextArea.NoWrap
                selectByMouse: true
                font.family: "Consolas, Monaco, monospace"
                font.pixelSize: 13
            }
        }
    }
}
