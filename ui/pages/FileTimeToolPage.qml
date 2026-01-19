import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

/**
 * 文件时间修改工具页面
 * 批量修改文件的创建时间、修改时间和访问时间
 */
Rectangle {
    id: fileTimeToolPage
    color: "white"
    
    // 文件列表模型
    ListModel {
        id: fileListModel
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16
        
        // 页面标题
        RowLayout {
            spacing: 12
            
            Text {
                text: "🕒"
                font.pixelSize: 32
            }
            
            ColumnLayout {
                spacing: 4
                
                Text {
                    text: "文件时间修改工具"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#333333"
                }
                
                Text {
                    text: "批量修改文件的时间属性（创建、修改、访问时间）"
                    font.pixelSize: 14
                    color: "#666666"
                }
            }
        }
        
        // 工具选项区域
        GroupBox {
            Layout.fillWidth: true
            title: "修改选项"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 12
                
                // 修改类型选择
                RowLayout {
                    spacing: 8
                    
                    Label {
                        text: "修改类型:"
                        Layout.preferredWidth: 80
                    }
                    
                    ComboBox {
                        id: modifyTypeCombo
                        Layout.fillWidth: true
                        model: [
                            "1 - 仅修改创建时间",
                            "2 - 仅修改修改时间",
                            "3 - 修改创建+修改时间（推荐）",
                            "4 - 仅修改访问时间",
                            "5 - 修改创建+访问时间",
                            "6 - 修改修改+访问时间",
                            "7 - 修改全部时间"
                        ]
                        currentIndex: 2  // 默认选择类型3
                    }
                }
                
                // 自定义时间输入
                RowLayout {
                    spacing: 8
                    
                    Label {
                        text: "自定义时间:"
                        Layout.preferredWidth: 80
                    }
                    
                    TextField {
                        id: customTimeInput
                        Layout.fillWidth: true
                        placeholderText: "格式: yyyy-MM-dd HH:mm:ss (留空则从文件名提取)"
                    }
                    
                    Button {
                        text: "清除"
                        onClicked: customTimeInput.text = ""
                    }
                }
                
                // 说明文字
                Text {
                    text: "💡 提示：如不填写自定义时间，将尝试从文件名或图片EXIF信息中提取时间"
                    font.pixelSize: 12
                    color: "#888888"
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
            }
        }
        
        // 文件操作区域
        GroupBox {
            Layout.fillWidth: true
            title: "文件列表 (" + fileListModel.count + " 个文件)"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 8
                
                // 按钮组
                RowLayout {
                    spacing: 8
                    
                    Button {
                        text: "选择文件"
                        icon.name: "document-open"
                        onClicked: fileDialog.open()
                    }
                    
                    Button {
                        text: "清空列表"
                        enabled: fileListModel.count > 0
                        onClicked: {
                            fileListModel.clear()
                            messageText.text = "文件列表已清空"
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        text: "开始修改"
                        highlighted: true
                        enabled: fileListModel.count > 0
                        onClicked: {
                            console.log("开始修改按钮被点击")
                            if (typeof fileTimeTools !== 'undefined' && fileTimeTools !== null) {
                                var filePaths = []
                                for (var i = 0; i < fileListModel.count; i++) {
                                    filePaths.push(fileListModel.get(i).path)
                                }
                                console.log("准备修改文件数量:", filePaths.length)
                                console.log("修改类型:", modifyTypeCombo.currentIndex + 1)
                                
                                var modifyType = modifyTypeCombo.currentIndex + 1
                                var customTime = customTimeInput.text.trim()
                                
                                console.log("调用 modifyFilesTime...")
                                fileTimeTools.modifyFilesTime(filePaths, modifyType, customTime)
                            } else {
                                console.log("fileTimeTools 未定义或为 null")
                                messageText.text = "⚠️ 工具未初始化，请重启应用"
                            }
                        }
                    }
                }
                
                // 文件列表
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 200
                    border.color: "#E0E0E0"
                    border.width: 1
                    radius: 4
                    
                    // 启用拖放
                    DropArea {
                        id: dropArea
                        anchors.fill: parent
                        
                        onDropped: function(drop) {
                            if (drop.hasUrls) {
                                var urls = drop.urls
                                for (var i = 0; i < urls.length; i++) {
                                    var url = urls[i]
                                    var path = url.toString()
                                    
                                    // 移除 file:/// 前缀
                                    if (path.startsWith("file:///")) {
                                        path = path.substring(8)
                                    }
                                    
                                    // 获取文件名
                                    var fileName = path.substring(path.lastIndexOf("/") + 1)
                                    
                                    // 检查是否已存在
                                    var exists = false
                                    for (var j = 0; j < fileListModel.count; j++) {
                                        if (fileListModel.get(j).path === path) {
                                            exists = true
                                            break
                                        }
                                    }
                                    
                                    if (!exists) {
                                        fileListModel.append({
                                            name: fileName,
                                            path: path
                                        })
                                    }
                                }
                                messageText.text = "已通过拖放添加 " + urls.length + " 个文件"
                            }
                        }
                        
                        // 拖动悬停效果
                        Rectangle {
                            anchors.fill: parent
                            color: dropArea.containsDrag ? "#E3F2FD" : "transparent"
                            opacity: 0.5
                            visible: dropArea.containsDrag
                        }
                    }
                    
                    ListView {
                        id: fileListView
                        anchors.fill: parent
                        anchors.margins: 1
                        clip: true
                        model: fileListModel
                        
                        delegate: Rectangle {
                            width: fileListView.width
                            height: 40
                            color: index % 2 === 0 ? "#FAFAFA" : "white"
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8
                                
                                Text {
                                    text: "📄"
                                    font.pixelSize: 16
                                }
                                
                                Text {
                                    text: model.name
                                    font.pixelSize: 13
                                    Layout.fillWidth: true
                                    elide: Text.ElideMiddle
                                }
                                
                                Button {
                                    text: "×"
                                    flat: true
                                    font.pixelSize: 16
                                    onClicked: fileListModel.remove(index)
                                }
                            }
                        }
                        
                        // 空状态提示
                        Label {
                            visible: fileListModel.count === 0
                            anchors.centerIn: parent
                            text: "📂\n\n拖放文件到这里\n或点击「选择文件」添加要修改的文件"
                            horizontalAlignment: Text.AlignHCenter
                            color: "#999999"
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }
        
        // 进度和消息区域
        GroupBox {
            Layout.fillWidth: true
            title: "执行状态"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 8
                
                // 进度条
                ProgressBar {
                    id: progressBar
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: 0
                }
                
                // 消息显示
                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    
                    TextArea {
                        id: messageText
                        readOnly: true
                        wrapMode: Text.Wrap
                        text: "就绪，等待操作..."
                        font.family: "Consolas"
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
    
    // 文件选择对话框
    FileDialog {
        id: fileDialog
        title: "选择要修改时间的文件"
        fileMode: FileDialog.OpenFiles
        onAccepted: {
            var urls = fileDialog.selectedFiles
            for (var i = 0; i < urls.length; i++) {
                var url = urls[i]
                var path = url.toString()
                
                // 移除 file:/// 前缀
                if (path.startsWith("file:///")) {
                    path = path.substring(8)
                }
                
                // 获取文件名
                var fileName = path.substring(path.lastIndexOf("/") + 1)
                
                // 检查是否已存在
                var exists = false
                for (var j = 0; j < fileListModel.count; j++) {
                    if (fileListModel.get(j).path === path) {
                        exists = true
                        break
                    }
                }
                
                if (!exists) {
                    fileListModel.append({
                        name: fileName,
                        path: path
                    })
                }
            }
            
            messageText.text = "已添加 " + urls.length + " 个文件"
        }
    }
    
    // 信息对话框
    Dialog {
        id: infoDialog
        title: "提示"
        modal: true
        standardButtons: Dialog.Ok
        width: 350
        
        property alias message: dialogText.text
        
        anchors.centerIn: parent
        
        Text {
            id: dialogText
            wrapMode: Text.WordWrap
            width: parent.width
        }
    }
    
    // 连接后端信号
    Connections {
        target: typeof fileTimeTools !== 'undefined' ? fileTimeTools : null
        
        function onMessageChanged(msg) {
            messageText.text = msg
        }
        
        function onProgressChanged(current, total) {
            if (total > 0) {
                progressBar.value = (current / total) * 100
            }
        }
        
        function onOperationFinished(success, msg) {
            infoDialog.message = msg
            infoDialog.open()
            progressBar.value = 0
        }
        
        function onFileProcessed(filePath, success, msg) {
            // 可以在这里添加更详细的文件处理反馈
        }
    }
    
    Component.onCompleted: {
        // 页面加载完成后的初始化
        console.log("FileTimeToolPage loaded")
        console.log("typeof fileTimeTools:", typeof fileTimeTools)
        console.log("fileTimeTools:", fileTimeTools)
        
        if (typeof fileTimeTools !== 'undefined' && fileTimeTools !== null) {
            console.log("fileTimeTools is available")
            messageText.text = "就绪，等待操作..."
        } else {
            console.log("fileTimeTools is NOT available")
            messageText.text = "⚠️ 文件时间工具未初始化"
        }
    }
}
