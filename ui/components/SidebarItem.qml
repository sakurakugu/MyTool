import QtQuick
import QtQuick.Controls
import MyTool 1.0

/**
 * 侧边栏项组件
 * 单个侧边栏导航项
 */
Rectangle {
    id: sidebarItem
    height: 48
    color: sidebarItem.selected ? Theme.highlight : (mouseArea.containsMouse ? Theme.surfaceAlt : "transparent")
    
    // 属性
    property string itemIcon: ""
    property string itemText: ""
    property bool selected: false
    
    // 信号
    signal clicked()
    
    Row {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12
        
        // 图标
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: sidebarItem.itemIcon
            font.pixelSize: 20
            color: Theme.text
        }
        
        // 文本
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: sidebarItem.itemText
            font.pixelSize: 14
            color: Theme.text
        }
    }
    
    // 鼠标交互
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            sidebarItem.clicked()
        }
    }
    
    // 选中状态指示器
    Rectangle {
        visible: sidebarItem.selected
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 3
        color: Theme.primary
    }
}
