import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "components"

/**
 * 主窗口
 * 应用程序的主界面，包含工具栏、标签栏、侧边栏和内容区域
 */
ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: "MyTool - 多功能工具箱"
    
    // 主布局
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // 工具栏
        ToolBarComponent {
            id: toolbar
            Layout.fillWidth: true
            Layout.preferredHeight: 50
        }
        
        // 主内容区域
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            
            // 左侧边栏
            SidebarComponent {
                id: sidebar
                Layout.preferredWidth: 200
                Layout.fillHeight: true
                
                onToolSelected: function(toolId) {
                    // 获取工具标题并添加标签页
                    var title = tabbar.getToolTitle(toolId)
                    tabbar.addTab(toolId, title)
                    
                    // 切换工具
                    app.switchTool(toolId)
                }
                
                onSettingsClicked: {
                    tabbar.addTab("settings", "设置(占位)")
                    app.openSettings()
                }
                
                onProfileClicked: {
                    tabbar.addTab("profile", "个人中心(占位)")
                    app.openProfile()
                }
            }
            
            // 分隔线
            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: "#E0E0E0"
            }
            
            // 标签栏和内容区域的垂直布局
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0
                
                // 标签栏
                TabBarComponent {
                    id: tabbar
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    
                    onTabSwitched: function(toolId) {
                        app.switchTool(toolId)
                    }
                    
                    onTabClosed: function(toolId) {
                        console.log("标签已关闭:", toolId)
                    }
                }
                
                // 中间内容区域
                ContentArea {
                    id: contentArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
            }
        }
    }
    Connections {
        target: app
        function onAddTabRequested(toolId, title) {
            tabbar.addTab(toolId, title)
        }
    }
}
