import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

/**
 * Edge 工具页面
 * 配置 Edge 浏览器不安全内容允许的 URL 规则
 */
Item {
    id: edgeToolPage
    
    // 消息对话框
    MessageDialog {
        id: messageDialog
        buttons: MessageDialog.Ok
    }
    
    // 输入对话框 for 添加规则
    Dialog {
        id: addPatternDialog
        title: "添加新规则"
        width: 500
        modal: true
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 15
            
            Text {
                text: "输入 URL 规则模式 (例如: [*.]bilibili.com)"
                color: "#333333"
            }
            
            TextField {
                id: patternInput
                placeholderText: "[*.]example.com"
                Layout.fillWidth: true
                onAccepted: addPatternDialog.accept()
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    text: "添加"
                    Layout.fillWidth: true
                    onClicked: {
                        if (patternInput.text.trim()) {
                            if (typeof edgeTools !== 'undefined') {
                                edgeTools.addPattern(patternInput.text.trim())
                            }
                            addPatternDialog.close()
                            patternInput.text = ""
                        }
                    }
                }
                
                Button {
                    text: "取消"
                    Layout.fillWidth: true
                    onClicked: {
                        addPatternDialog.close()
                        patternInput.text = ""
                    }
                }
            }
        }
    }
    
    // 编辑对话框
    Dialog {
        id: editPatternDialog
        title: "编辑规则"
        width: 500
        modal: true
        
        property string oldPattern: ""
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 15
            
            Text {
                text: "修改URL规则"
                color: "#333333"
            }
            
            TextField {
                id: editPatternInput
                placeholderText: "[*.]example.com"
                Layout.fillWidth: true
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    text: "更新"
                    Layout.fillWidth: true
                    onClicked: {
                        if (editPatternInput.text.trim()) {
                            if (typeof edgeTools !== 'undefined') {
                                edgeTools.updatePattern(editPatternDialog.oldPattern, editPatternInput.text.trim())
                            }
                            editPatternDialog.close()
                            editPatternInput.text = ""
                        }
                    }
                }
                
                Button {
                    text: "取消"
                    Layout.fillWidth: true
                    onClicked: {
                        editPatternDialog.close()
                        editPatternInput.text = ""
                    }
                }
            }
        }
    }
    
    // 确认清空对话框
    Dialog {
        id: clearConfirmDialog
        title: "确认清空"
        width: 400
        modal: true
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 15
            
            Text {
                text: "确定要清除所有规则吗？此操作无法撤销。"
                color: "#D32F2F"
                wrapMode: Text.Wrap
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Button {
                    text: "确认清空"
                    Layout.fillWidth: true
                    onClicked: {
                        if (typeof edgeTools !== 'undefined') {
                            edgeTools.clearAllPatterns()
                        }
                        clearConfirmDialog.close()
                    }
                }
                
                Button {
                    text: "取消"
                    Layout.fillWidth: true
                    onClicked: clearConfirmDialog.close()
                }
            }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // 标题
        Text {
            text: "Edge 浏览器配置"
            font.pixelSize: 24
            font.bold: true
            color: "#1976D2"
        }
        
        // 说明文本
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: "#E3F2FD"
            radius: 8
            border.color: "#1976D2"
            border.width: 1
            
            Text {
                anchors.fill: parent
                anchors.margins: 15
                text: "配置 Edge 浏览器允许访问不安全内容的 URL 规则。<br/>
设置的规则将被写入 Windows 注册表。<br/>
<b>需要管理员权限</b>"
                color: "#0D47A1"
                wrapMode: Text.Wrap
                verticalAlignment: Text.AlignVCenter
            }
        }
        
        // 操作栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Button {
                text: "➕ 添加规则"
                Layout.fillWidth: true
                onClicked: {
                    patternInput.text = ""
                    addPatternDialog.open()
                }
            }
            
            Button {
                text: "🔄 刷新"
                Layout.fillWidth: true
                onClicked: {
                    if (typeof edgeTools !== 'undefined') {
                        edgeTools.refreshPatterns()
                    }
                }
            }
            
            Button {
                text: "🗑️ 清空所有"
                Layout.fillWidth: true
                onClicked: clearConfirmDialog.open()
            }
            
            Item { Layout.fillWidth: true }
        }
        
        // 消息显示
        Text {
            Layout.fillWidth: true
            text: typeof edgeTools !== 'undefined' ? edgeTools.message : "初始化中..."
            color: edgeTools && edgeTools.message.startsWith("❌") ? "#D32F2F" : 
                   edgeTools && edgeTools.message.startsWith("✅") ? "#388E3C" :
                   edgeTools && edgeTools.message.startsWith("⚠️") ? "#F57C00" :
                   edgeTools && edgeTools.message.startsWith("👉") ? "#1976D2" : "#666666"
            wrapMode: Text.Wrap
            font.pixelSize: 12
        }
        
        // 规则列表标题
        Text {
            Layout.fillWidth: true
            text: "当前规则 (" + (typeof edgeTools !== 'undefined' ? edgeTools.patterns.length : 0) + ")"
            font.bold: true
            font.pixelSize: 14
            color: "#333333"
        }
        
        // 规则列表
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            border.color: "#CCCCCC"
            border.width: 1
            radius: 4
            color: "#FFFFFF"
            clip: true
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // 表头
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    color: "#F5F5F5"
                    border.color: "#CCCCCC"
                    border.width: 1
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 40
                            text: "#"
                            font.bold: true
                            color: "#333333"
                            horizontalAlignment: Text.AlignCenter
                        }
                        
                        Text {
                            Layout.fillWidth: true
                            text: "URL 规则"
                            font.bold: true
                            color: "#333333"
                        }
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "操作"
                            font.bold: true
                            color: "#333333"
                            horizontalAlignment: Text.AlignCenter
                        }
                    }
                }
                
                // 规则列表
                ListView {
                    id: patternsList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 1
                    
                    model: typeof edgeTools !== 'undefined' ? edgeTools.patterns : []
                    
                    delegate: Rectangle {
                        width: patternsList.width
                        height: 50
                        color: index % 2 === 0 ? "#FFFFFF" : "#F9F9F9"
                        border.color: "#EEEEEE"
                        border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10
                            
                            Text {
                                Layout.preferredWidth: 40
                                text: (index + 1)
                                color: "#666666"
                                horizontalAlignment: Text.AlignCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: modelData
                                color: "#333333"
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                                font.family: "Courier New"
                            }
                            
                            RowLayout {
                                Layout.preferredWidth: 120
                                spacing: 5
                                
                                Button {
                                    text: "✏️"
                                    Layout.preferredWidth: 35
                                    onClicked: {
                                        editPatternDialog.oldPattern = modelData
                                        editPatternInput.text = modelData
                                        editPatternDialog.open()
                                    }
                                }
                                
                                Button {
                                    text: "🗑️"
                                    Layout.preferredWidth: 35
                                    onClicked: {
                                        if (typeof edgeTools !== 'undefined') {
                                            edgeTools.removePattern(index)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // 底部操作栏
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "♻️ 重启 Edge"
                onClicked: {
                    if (typeof edgeTools !== 'undefined') {
                        edgeTools.restartEdge(true)
                    }
                }
            }
            
            Text {
                text: "访问 <b>edge://policy</b> 查看和验证策略"
                color: "#666666"
                font.pixelSize: 11
            }
        }
    }
    
    // 连接 edgeTools 的信号
    Connections {
        target: typeof edgeTools !== 'undefined' ? edgeTools : null
        
        function onOperationFinished(success, message) {
            messageDialog.title = success ? "成功" : "错误"
            messageDialog.text = message
            messageDialog.open()
        }
    }
}
