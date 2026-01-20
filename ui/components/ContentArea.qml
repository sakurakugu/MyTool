import QtQuick
import QtQuick.Controls
import "../pages"

/**
 * 内容区域组件
 * 显示不同工具的页面内容
 */
Rectangle {
    id: contentArea
    color: "white"
    
    // 当前显示的工具
    property string currentTool: "all_tools"
    
    // 页面加载器
    Loader {
        id: pageLoader
        anchors.fill: parent
        anchors.margins: 16
        
        // 根据当前工具加载对应页面
        source: {
            if (typeof app === 'undefined' || app === null) {
                return "../pages/AllToolsPage.qml"
            }
            switch (app.currentTool) {
                case "all_tools":
                    return "../pages/AllToolsPage.qml"
                case "windows_tool":
                    return "../pages/WindowsToolPage.qml"
                case "linux_tool":
                    return "../pages/LinuxToolPage.qml"
                case "git_tool":
                    return "../pages/GitToolPage.qml"
                case "qt_tool":
                    return "../pages/QtToolPage.qml"
                case "text_tool":
                    return "../pages/TextToolPage.qml"
                case "image_tool":
                    return "../pages/ImageToolPage.qml"
                case "code_tool":
                    return "../pages/CodeToolPage.qml"
                case "file_tool":
                    return "../pages/FileToolPage.qml"
                case "file_time_tool":
                    return "../pages/FileTimeToolPage.qml"
                case "file_filter_tool":
                    return "../pages/FileFilterToolPage.qml"
                case "settings":
                    return "../pages/SettingsPage.qml"
                case "profile":
                    return "../pages/ProfilePage.qml"
                default:
                    return "../pages/AllToolsPage.qml"
            }
        }
    }
}
