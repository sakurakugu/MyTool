import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

/**
 * 文件过滤转移工具页面
 * 根据文件类型和关键词过滤并转移文件
 */
Rectangle {
    id: fileFilterToolPage
    color: "white"
    
    // 防止信号循环的标志
    property bool isUpdating: false
    
    // 匹配文件列表模型
    ListModel {
        id: matchedFilesModel
    }
    
    // 规则列表模型
    ListModel {
        id: rulesModel
    }
    
    // 源文件夹选择对话框
    FolderDialog {
        id: sourceFolderDialog
        title: "选择源文件夹"
        onAccepted: {
            sourceFolderInput.text = selectedFolder.toString().replace("file:///", "")
        }
    }
    
    // 目标文件夹选择对话框
    FolderDialog {
        id: targetFolderDialog
        title: "选择目标文件夹"
        onAccepted: {
            targetFolderInput.text = selectedFolder.toString().replace("file:///", "")
        }
    }
    
    // 延迟更新定时器
    Timer {
        id: updateTimer
        interval: 50
        repeat: false
        onTriggered: {
            console.log("[QML] Updating rules list")
            updateRulesList()
        }
    }
    
    Component.onCompleted: {
        console.log("[QML] Component completed")
        // 监听规则变化
        if (typeof fileFilterTools !== 'undefined') {
            updateTimer.start()
        }
    }
    
    // 更新规则列表
    function updateRulesList() {
        if (isUpdating) {
            console.log("[QML] Already updating, skipping")
            return
        }
        
        if (typeof fileFilterTools === 'undefined') {
            console.log("[QML] fileFilterTools is undefined")
            return
        }
        
        isUpdating = true
        console.log("[QML] Clearing rules model")
        rulesModel.clear()
        console.log("[QML] Getting rules from fileFilterTools")
        var rules = fileFilterTools.filterRules
        console.log("[QML] Got " + rules.length + " rules")
        for (var i = 0; i < rules.length; i++) {
            rulesModel.append(rules[i])
        }
        console.log("[QML] Rules list updated")
        isUpdating = false
    }
    
    // 连接信号
    Connections {
        target: typeof fileFilterTools !== 'undefined' ? fileFilterTools : null
        
        function onRulesChanged() {
            if (isUpdating) {
                console.log("[QML] onRulesChanged received but already updating, ignoring")
                return
            }
            console.log("[QML] onRulesChanged signal received")
            updateTimer.start()
        }
        
        function onOperationFinished(success, message) {
            console.log("[QML] onOperationFinished:", success, message)
            if (success) {
                messageArea.text = "✓ " + message
                messageArea.color = "#4CAF50"
            } else {
                messageArea.text = "✗ " + message
                messageArea.color = "#F44336"
            }
        }
        
        function onProgressChanged(current, total) {
            progressBar.value = total > 0 ? current / total : 0
            progressText.text = current + " / " + total
        }
        
        function onMessageChanged() {
            console.log("[QML] onMessageChanged signal received")
            if (typeof fileFilterTools !== 'undefined') {
                messageArea.text = fileFilterTools.message
                messageArea.color = "#2196F3"
            }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16
        
        // 页面标题
        RowLayout {
            spacing: 12
            
            Text {
                text: "🎯"
                font.pixelSize: 32
            }
            
            ColumnLayout {
                spacing: 4
                
                Text {
                    text: "文件过滤转移工具"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#333333"
                }
                
                Text {
                    text: "根据文件类型和关键词智能过滤并转移文件"
                    font.pixelSize: 14
                    color: "#666666"
                }
            }
        }
        
        // 主内容区域（使用分割视图）
        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Horizontal
            
            // 左侧：规则管理
            Rectangle {
                SplitView.preferredWidth: 400
                SplitView.minimumWidth: 300
                color: "#F5F5F5"
                border.color: "#E0E0E0"
                border.width: 1
                radius: 8
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    // 规则管理标题
                    Text {
                        text: "过滤规则管理"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#333333"
                    }
                    
                    // 添加规则区域
                    GroupBox {
                        Layout.fillWidth: true
                        title: "添加新规则"
                        
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10
                            
                            // 规则名称
                            RowLayout {
                                spacing: 8
                                Label {
                                    text: "规则名称:"
                                    Layout.preferredWidth: 80
                                }
                                TextField {
                                    id: ruleNameInput
                                    Layout.fillWidth: true
                                    placeholderText: "可选，留空自动生成"
                                }
                            }
                            
                            // 文件类型选择
                            RowLayout {
                                spacing: 8
                                Label {
                                    text: "文件类型:"
                                    Layout.preferredWidth: 80
                                }
                                ComboBox {
                                    id: fileTypeCombo
                                    Layout.fillWidth: true
                                    model: ["图片文件", "视频文件", "图片+视频", "自定义"]
                                    currentIndex: 0
                                }
                            }
                            
                            // 关键词输入
                            RowLayout {
                                spacing: 8
                                Label {
                                    text: "关键词:"
                                    Layout.preferredWidth: 80
                                }
                                TextField {
                                    id: keywordsInput
                                    Layout.fillWidth: true
                                    placeholderText: "多个关键词用逗号分隔，留空匹配全部"
                                }
                            }
                            
                            // 目标文件夹
                            RowLayout {
                                spacing: 8
                                Label {
                                    text: "目标文件夹:"
                                    Layout.preferredWidth: 80
                                }
                                TextField {
                                    id: targetFolderInput
                                    Layout.fillWidth: true
                                    placeholderText: "选择目标文件夹"
                                    readOnly: true
                                }
                                Button {
                                    text: "浏览"
                                    onClicked: targetFolderDialog.open()
                                }
                            }
                            
                            // 添加规则按钮
                            Button {
                                Layout.fillWidth: true
                                text: "添加规则"
                                highlighted: true
                                enabled: typeof fileFilterTools !== 'undefined'
                                onClicked: {
                                    console.log("[QML] Add rule button clicked")
                                    if (!targetFolderInput.text) {
                                        messageArea.text = "⚠ 请选择目标文件夹"
                                        messageArea.color = "#FF9800"
                                        return
                                    }
                                    
                                    var fileType = ""
                                    switch(fileTypeCombo.currentIndex) {
                                        case 0: fileType = "image"; break
                                        case 1: fileType = "video"; break
                                        case 2: fileType = "all"; break
                                        case 3: fileType = "custom"; break
                                    }
                                    
                                    console.log("[QML] Calling addFilterRule with type:", fileType)
                                    if (typeof fileFilterTools !== 'undefined') {
                                        try {
                                            var success = fileFilterTools.addFilterRule(
                                                fileType,
                                                keywordsInput.text,
                                                targetFolderInput.text,
                                                ruleNameInput.text
                                            )
                                            console.log("[QML] addFilterRule returned:", success)
                                            
                                            if (success) {
                                                // 清空输入
                                                ruleNameInput.text = ""
                                                keywordsInput.text = ""
                                                targetFolderInput.text = ""
                                                fileTypeCombo.currentIndex = 0
                                            }
                                        } catch (e) {
                                            console.log("[QML ERROR]", e)
                                            messageArea.text = "错误: " + e
                                            messageArea.color = "#F44336"
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // 规则列表标题
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "已添加的规则"
                            font.pixelSize: 14
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        
                        Button {
                            text: "清空全部"
                            flat: true
                            enabled: typeof fileFilterTools !== 'undefined'
                            onClicked: {
                                if (typeof fileFilterTools !== 'undefined') {
                                    fileFilterTools.clearAllRules()
                                }
                            }
                        }
                    }
                    
                    // 规则列表
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        
                        ListView {
                            id: rulesListView
                            model: rulesModel
                            spacing: 8
                            clip: true
                            
                            delegate: Rectangle {
                                width: ListView.view.width
                                height: ruleContent.height + 16
                                color: model.enabled ? "white" : "#F0F0F0"
                                border.color: "#E0E0E0"
                                border.width: 1
                                radius: 6
                                
                                ColumnLayout {
                                    id: ruleContent
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 4
                                    
                                    RowLayout {
                                        Layout.fillWidth: true
                                        
                                        CheckBox {
                                            checked: model.enabled
                                            onCheckedChanged: {
                                                if (typeof fileFilterTools !== 'undefined') {
                                                    fileFilterTools.toggleRuleEnabled(model.id, checked)
                                                }
                                            }
                                        }
                                        
                                        Text {
                                            text: model.name
                                            font.bold: true
                                            Layout.fillWidth: true
                                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        }
                                        
                                        Button {
                                            text: "删除"
                                            flat: true
                                            enabled: typeof fileFilterTools !== 'undefined'
                                            onClicked: {
                                                if (typeof fileFilterTools !== 'undefined') {
                                                    fileFilterTools.removeFilterRule(model.id)
                                                }
                                            }
                                        }
                                    }
                                    
                                    Text {
                                        text: "类型: " + model.type_name
                                        font.pixelSize: 12
                                        color: "#666666"
                                    }
                                    
                                    Text {
                                        text: "关键词: " + (model.keywords_text || "全部")
                                        font.pixelSize: 12
                                        color: "#666666"
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        Layout.fillWidth: true
                                    }
                                    
                                    Text {
                                        text: "目标: " + model.target_folder
                                        font.pixelSize: 11
                                        color: "#999999"
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                        Layout.fillWidth: true
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // 右侧：文件扫描和处理
            Rectangle {
                SplitView.fillWidth: true
                color: "white"
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    // 源文件夹选择
                    GroupBox {
                        Layout.fillWidth: true
                        title: "源文件夹设置"
                        
                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10
                            
                            RowLayout {
                                spacing: 8
                                Label {
                                    text: "源文件夹:"
                                    Layout.preferredWidth: 80
                                }
                                TextField {
                                    id: sourceFolderInput
                                    Layout.fillWidth: true
                                    placeholderText: "选择要扫描的源文件夹"
                                    readOnly: true
                                }
                                Button {
                                    text: "浏览"
                                    onClicked: sourceFolderDialog.open()
                                }
                            }
                            
                            CheckBox {
                                id: includeSubfoldersCheck
                                text: "包含子文件夹"
                                checked: false
                            }
                        }
                    }
                    
                    // 操作按钮
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Button {
                            text: "扫描预览"
                            Layout.fillWidth: true
                            highlighted: true
                            enabled: typeof fileFilterTools !== 'undefined'
                            onClicked: {
                                if (!sourceFolderInput.text) {
                                    messageArea.text = "⚠ 请选择源文件夹"
                                    messageArea.color = "#FF9800"
                                    return
                                }
                                
                                if (typeof fileFilterTools !== 'undefined') {
                                    matchedFilesModel.clear()
                                    var files = fileFilterTools.scanFolder(
                                        sourceFolderInput.text,
                                        includeSubfoldersCheck.checked,
                                        true
                                    )
                                    
                                    for (var i = 0; i < files.length; i++) {
                                        matchedFilesModel.append(files[i])
                                    }
                                }
                            }
                        }
                        
                        Button {
                            text: "移动文件"
                            Layout.fillWidth: true
                            enabled: matchedFilesModel.count > 0 && typeof fileFilterTools !== 'undefined'
                            onClicked: {
                                if (typeof fileFilterTools !== 'undefined') {
                                    var files = []
                                    for (var i = 0; i < matchedFilesModel.count; i++) {
                                        files.push(matchedFilesModel.get(i))
                                    }
                                    fileFilterTools.moveFiles(files, false)
                                }
                            }
                        }
                        
                        Button {
                            text: "复制文件"
                            Layout.fillWidth: true
                            enabled: matchedFilesModel.count > 0 && typeof fileFilterTools !== 'undefined'
                            onClicked: {
                                if (typeof fileFilterTools !== 'undefined') {
                                    var files = []
                                    for (var i = 0; i < matchedFilesModel.count; i++) {
                                        files.push(matchedFilesModel.get(i))
                                    }
                                    fileFilterTools.moveFiles(files, true)
                                }
                            }
                        }
                    }
                    
                    // 进度显示
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        ProgressBar {
                            id: progressBar
                            Layout.fillWidth: true
                            value: 0
                        }
                        
                        Text {
                            id: progressText
                            text: "0 / 0"
                            font.pixelSize: 12
                            color: "#666666"
                        }
                    }
                    
                    // 消息显示
                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        color: "#F5F5F5"
                        border.color: "#E0E0E0"
                        border.width: 1
                        radius: 4
                        
                        Text {
                            id: messageArea
                            anchors.fill: parent
                            anchors.margins: 10
                            text: "就绪"
                            color: "#666666"
                            verticalAlignment: Text.AlignVCenter
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        }
                    }
                    
                    // 匹配文件列表
                    GroupBox {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "匹配的文件 (" + matchedFilesModel.count + ")"
                        
                        ScrollView {
                            anchors.fill: parent
                            
                            ListView {
                                id: matchedFilesListView
                                model: matchedFilesModel
                                spacing: 4
                                clip: true
                                
                                delegate: Rectangle {
                                    width: ListView.view.width
                                    height: 60
                                    color: index % 2 === 0 ? "white" : "#FAFAFA"
                                    border.color: "#E0E0E0"
                                    border.width: 1
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 10
                                        
                                        // 文件图标
                                        Text {
                                            text: model.file_name.toLowerCase().match(/\.(jpg|jpeg|png|gif|bmp|webp|svg|ico|tiff|tif)$/) ? "🖼️" : "🎬"
                                            font.pixelSize: 24
                                        }
                                        
                                        // 文件信息
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            
                                            Text {
                                                text: model.file_name
                                                font.bold: true
                                                elide: Text.ElideMiddle
                                                Layout.fillWidth: true
                                            }
                                            
                                            Text {
                                                text: "规则: " + model.rule_name
                                                font.pixelSize: 11
                                                color: "#2196F3"
                                            }
                                            
                                            Text {
                                                text: "目标: " + model.target_folder
                                                font.pixelSize: 10
                                                color: "#999999"
                                                elide: Text.ElideMiddle
                                                Layout.fillWidth: true
                                            }
                                        }
                                        
                                        // 文件大小
                                        Text {
                                            text: (model.file_size / 1024 / 1024).toFixed(2) + " MB"
                                            font.pixelSize: 11
                                            color: "#666666"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
