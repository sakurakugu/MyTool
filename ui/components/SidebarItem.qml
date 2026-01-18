import QtQuick
import QtQuick.Controls

/**
 * 侧边栏项组件
 * 单个侧边栏导航项
 */
Rectangle {
    id: sidebarItem
    height: 48
    color: mouseArea.containsMouse ? "#E3F2FD" : "transparent"
    
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
        }
        
        // 文本
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: sidebarItem.itemText
            font.pixelSize: 14
            color: "#333333"
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
        color: "#2196F3"
    }
}
