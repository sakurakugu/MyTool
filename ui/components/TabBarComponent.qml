import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * 标签栏组件
 * 显示当前打开的标签页
 */
Rectangle {
    id: tabbar
    color: "#F5F5F5"
    border.color: "#E0E0E0"
    border.width: 1
    
    // 属性
    property string currentTab: "all_tools"
    
    // 信号
    signal tabSwitched(string toolId)
    signal tabClosed(string toolId)
    
    // 标签页数据模型
    ListModel {
        id: tabsModel
        ListElement { title: "全部工具"; toolId: "all_tools" }
    }
    
    // 添加标签页的函数
    function addTab(toolId, title) {
        // 检查标签是否已存在
        for (var i = 0; i < tabsModel.count; i++) {
            if (tabsModel.get(i).toolId === toolId) {
                // 标签已存在，切换到该标签
                currentTab = toolId
                tabSwitched(toolId)
                return
            }
        }
        
        // 添加新标签
        tabsModel.append({title: title, toolId: toolId})
        currentTab = toolId
        tabSwitched(toolId)
    }
    
    // 关闭标签页的函数
    function closeTab(toolId) {
        for (var i = 0; i < tabsModel.count; i++) {
            if (tabsModel.get(i).toolId === toolId) {
                tabsModel.remove(i)
                
                // 如果关闭的是当前标签，切换到第一个标签
                if (currentTab === toolId && tabsModel.count > 0) {
                    var newToolId = tabsModel.get(0).toolId
                    currentTab = newToolId
                    tabSwitched(newToolId)
                }
                
                tabClosed(toolId)
                break
            }
        }
    }
    
    // 工具ID到标题的映射
    function getToolTitle(toolId) {
        var tool = typeof toolManager !== 'undefined' ? toolManager.get_tool_by_id(toolId) : null
        if (tool && tool.name)
            return tool.name
        if (toolId === "settings")
            return "设置"
        if (toolId === "profile")
            return "个人中心"
        return toolId
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 4
        
        // 标签页列表
        Repeater {
            model: tabsModel
            
            delegate: Rectangle {
                Layout.preferredHeight: 32
                Layout.preferredWidth: 120
                radius: 4
                color: tabbar.currentTab === toolId ? "#2196F3" : 
                       (mouseArea.containsMouse ? "#E3F2FD" : "transparent")
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 8
                    spacing: 8
                    z: 1
                    
                    Text {
                        Layout.fillWidth: true
                        text: title
                        font.pixelSize: 13
                        color: tabbar.currentTab === toolId ? "#FFFFFF" : "#333333"
                        elide: Text.ElideRight
                        z: 1
                    }
                    
                    // 关闭按钮
                    Text {
                        text: "✕"
                        font.pixelSize: 12
                        color: tabbar.currentTab === toolId ? "#FFFFFF" : "#666666"
                        visible: tabsModel.count > 1  // 至少保留一个标签
                        z: 2
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            z: 2
                            onClicked: function(mouse) {
                                mouse.accepted = true  // 阻止事件传播
                                tabbar.closeTab(toolId)
                            }
                        }
                    }
                }
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    z: 0
                    onClicked: {
                        tabbar.currentTab = toolId
                        tabbar.tabSwitched(toolId)
                    }
                }
            }
        }
        
        // 弹性空间
        Item {
            Layout.fillWidth: true
        }
    }
}
