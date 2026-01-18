import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * 侧边栏组件
 * 左侧导航栏，包含工具列表、个人中心和设置
 */
Rectangle {
    id: sidebar
    color: "#F5F5F5"
    
    // 信号
    signal toolSelected(string toolId)
    signal settingsClicked()
    signal profileClicked()
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 工具列表区域
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ColumnLayout {
                width: sidebar.width
                spacing: 4
                
                // 工具列表
                Repeater {
                    model: (typeof toolManager !== 'undefined' && toolManager && toolManager.tools) ? toolManager.tools.filter(function(t) { return t.category === "main" || t.category === "tool" }) : []
                    
                    delegate: SidebarItem {
                        Layout.fillWidth: true
                        itemIcon: modelData.icon
                        itemText: modelData.name
                        
                        onClicked: {
                            sidebar.toolSelected(modelData.id)
                        }
                    }
                }
                
                // 填充空间
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
        
        // 分隔线
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#E0E0E0"
        }
        
        // 底部固定项（个人中心和设置）
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            
            // 个人中心
            SidebarItem {
                Layout.fillWidth: true
                itemIcon: "👤"
                itemText: "个人中心(占位)"
                
                onClicked: {
                    sidebar.profileClicked()
                }
            }
            
            // 设置
            SidebarItem {
                Layout.fillWidth: true
                itemIcon: "⚙️"
                itemText: "设置(占位)"
                
                onClicked: {
                    sidebar.settingsClicked()
                }
            }
        }
    }
}
