#!/usr/bin/env pwsh
# 修改时间工具

function 修改时间{

    # 接受参数
    param(
        [Parameter(Mandatory = $true)] # 必须参数
        [string]$path, # 文件路径
        [Parameter(Mandatory = $true)]
        [string]$time, # 要修改的时间
        [Parameter(Mandatory = $true)]
        [ValidateSet(1, 2, 3, 4, 5, 6, 7)]
        [int]$Type # 1.创建时间 2.修改时间 3.访问时间 4.创建和修改时间 5.创建和访问时间 6.修改和访问时间 7.创建、修改和访问时间
    )

    # 设置编码
    # $OutputEncoding = [Console]::OutputEncoding = [Text.Encoding]::UTF8

    # 获取文件信息
    $Time = [datetime]::Parse($time)
    $File = Get-Item $path

    switch ($Type) {
        1 { $File.CreationTime = $Time }
        2 { $File.LastWriteTime = $Time }
        3 { 
            $File.CreationTime = $Time
            $File.LastWriteTime = $Time 
        }
        4 { $File.LastAccessTime = $Time }
        5 { 
            $File.CreationTime = $Time
            $File.LastAccessTime = $Time 
        }
        6 { 
            $File.LastWriteTime = $Time
            $File.LastAccessTime = $Time 
        }
        7 { 
            $File.CreationTime = $Time
            $File.LastWriteTime = $Time
            $File.LastAccessTime = $Time
        }
        default { Write-Error "输入了无效的`"修改类型`": $Type"; exit 1 }
    }
}
