# 下载TrafficMonitor Lite(github)
# 获取最新 release JSON
$release = Invoke-RestMethod -Uri "https://api.github.com/repos/zhongyang219/TrafficMonitor/releases/latest"
# 获取 zip 下载链接，匹配 x64
$URL = $release.assets | Where-Object { $_.browser_download_url -match "x64_Lite\.zip$" } | Select-Object -First 1 | Select-Object -ExpandProperty browser_download_url
$temp = [System.IO.Path]::GetTempPath()
$zipName = Split-Path $URL -Leaf
$zipPath = Join-Path $temp $zipName
Write-Output "正在下载到 $zipPath ..."
Invoke-WebRequest -Uri $URL -OutFile $zipPath
Write-Output "下载完成 TrafficMonitor Lite"
$extractDir = Join-Path $temp ("TrafficMonitorLite_" + [System.Guid]::NewGuid().ToString())
Expand-Archive -Path $zipPath -DestinationPath $extractDir # 解压
$destBase = "C:\Software\Apps\小工具"
New-Item -ItemType Directory -Path $destBase -ErrorAction SilentlyContinue | Out-Null # 创建目录
$destDir = Join-Path $destBase "网速实时显示"
Remove-Item -Recurse $destDir -ErrorAction SilentlyContinue # 删除旧目录
Move-Item -Path $extractDir -Destination $destDir
Write-Output "已解压并移动到 $destDir"

$tmDir = Join-Path $destDir "TrafficMonitor"
$cfgPath = Join-Path $tmDir "global_cfg.ini"
New-Item -ItemType Directory -Path $tmDir -ErrorAction SilentlyContinue | Out-Null # 创建目录
if (!(Test-Path $cfgPath)) {
    Set-Content -Path $cfgPath -Value "[config]`nportable_mode = true"
} else {
    $content = Get-Content -Path $cfgPath -Raw
    $needsSection = ($content -notmatch '(?m)^\[config\]')
    $needsPortable = ($content -notmatch '(?m)^\s*portable_mode\s*=\s*true\s*$')
    if ($needsSection -or $needsPortable) { # 如果需要添加[config]或portable_mode = true
        $add = ""
        if ($needsSection) { $add += "[config]`n" }
        if ($needsPortable) { $add += "portable_mode = true`n" }
        Add-Content -Path $cfgPath -Value $add
    }
}

$configPath = Join-Path $tmDir "config.ini"
if (!(Test-Path $configPath)) {
    Set-Content -Path $configPath -Value "[config]`nshow_task_bar_wnd = true`nhide_main_window = 1`nshow_notify_icon = false`n`n[task_bar]`ndouble_click_action = 2"
} else {
    $content = Get-Content -Path $configPath -Raw
    $newContent = $content
    $newContent = [regex]::Replace($newContent, '(?m)^\s*show_task_bar_wnd\s*=\s*.*$', 'show_task_bar_wnd = true')
    $newContent = [regex]::Replace($newContent, '(?m)^\s*hide_main_window\s*=\s*.*$', 'hide_main_window = 1')
    $newContent = [regex]::Replace($newContent, '(?m)^\s*show_notify_icon\s*=\s*.*$', 'show_notify_icon = false')
    $newContent = [regex]::Replace($newContent, '(?m)^\s*double_click_action\s*=\s*.*$', 'double_click_action = 2')

    $configSectionExists = $newContent -match '(?m)^\[config\]'
    $taskBarSectionExists = $newContent -match '(?m)^\[task_bar\]'

    $hasShowTaskBarWnd = $newContent -match '(?m)^\s*show_task_bar_wnd\s*=\s*true\s*$'
    $hasHideMainWindow = $newContent -match '(?m)^\s*hide_main_window\s*=\s*1\s*$'
    $hasShowNotifyIcon = $newContent -match '(?m)^\s*show_notify_icon\s*=\s*false\s*$'
    $hasDoubleClickAction = $newContent -match '(?m)^\s*double_click_action\s*=\s*2\s*$'

    $insertConfig = ""
    if (!$hasShowTaskBarWnd) { $insertConfig += "show_task_bar_wnd = true`n" }
    if (!$hasHideMainWindow) { $insertConfig += "hide_main_window = 1`n" }
    if (!$hasShowNotifyIcon) { $insertConfig += "show_notify_icon = false`n" }

    $insertTaskBar = ""
    if (!$hasDoubleClickAction) { $insertTaskBar += "double_click_action = 2`n" }

    $toAppend = ""
    if (!$configSectionExists -and ($insertConfig -ne "")) {
        $toAppend += "[config]`n$insertConfig"
        $insertConfig = ""
    }
    if (!$taskBarSectionExists -and ($insertTaskBar -ne "")) {
        $toAppend += "[task_bar]`n$insertTaskBar"
        $insertTaskBar = ""
    }

    if ($insertConfig -ne "") {
        $newContent = [regex]::Replace($newContent, '(?m)^\[config\]\s*$', "[config]`n$insertConfig")
    }
    if ($insertTaskBar -ne "") {
        $newContent = [regex]::Replace($newContent, '(?m)^\[task_bar\]\s*$', "[task_bar]`n$insertTaskBar")
    }

    if ($newContent -ne $content) {
        Set-Content -Path $configPath -Value $newContent
    }
    if ($toAppend -ne "") {
        Add-Content -Path $configPath -Value $toAppend
    }
}

# 定义 Run 键路径
$runKey = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
# 确保 Run 键存在
if (-not (Test-Path $runKey)) {
    New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion' -Name 'Run' | Out-Null
}
# 你的可执行文件路径
$exePath = Join-Path $tmDir 'TrafficMonitor.exe'
# 获取已有 TrafficMonitor 的值
try {
    $currentValue = (Get-ItemProperty -Path $runKey -Name 'TrafficMonitor' -ErrorAction Stop).TrafficMonitor
} catch {
    $currentValue = $null
}
# 如果不存在或路径不同，则添加或更新
if (-not $currentValue) {
    # 添加新启动项
    New-ItemProperty -Path $runKey -Name 'TrafficMonitor' -Value $exePath -PropertyType String | Out-Null
    Write-Host "TrafficMonitor 已添加到开机自启"
} elseif ($currentValue -ne $exePath) {
    # 更新路径
    Set-ItemProperty -Path $runKey -Name 'TrafficMonitor' -Value $exePath
    Write-Host "TrafficMonitor 路径已更新"
} else {
    Write-Host "TrafficMonitor 已存在且路径正确，无需修改"
}

# 运行
& "$tmDir\TrafficMonitor.exe"
