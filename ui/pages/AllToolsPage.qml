import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * 全部工具页面
 * 展示所有可用的工具
 */
Rectangle {
    id: allToolsPage
    color: "white"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 24
        
        // 页面标题
        Text {
            text: "全部工具"
            font.pixelSize: 24
            font.bold: true
            color: "#333333"
        }
        
        // 工具网格
        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 180
            cellHeight: 180
            clip: true
            
            model: (typeof toolManager !== 'undefined' && toolManager && toolManager.tools) ? toolManager.tools.filter(function(t) { return t.category === "tool" }) : []
            
            delegate: Rectangle {
                width: 160
                height: 160
                radius: 8
                border.color: "#E0E0E0"
                border.width: 1
                color: mouseArea.containsMouse ? "#F5F5F5" : "white"
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    // 工具图标
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.icon
                        font.pixelSize: 48
                    }
                    
                    // 工具名称
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        text: modelData.name
                        font.pixelSize: 16
                        color: "#333333"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    
                    Item {
                        Layout.fillHeight: true
                    }
                }
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        console.log("点击工具:", modelData.id)
                        if (typeof app !== 'undefined') {
                            app.requestAddTab(modelData.id)
                        }
                    }
                }
            }
        }
    }
}
