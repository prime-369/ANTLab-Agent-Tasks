# 在 PowerShell 7 内本机输入密钥，并在同一进程会话只执行一次 D01 请求。
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath (Split-Path -Parent $PSScriptRoot)
$env:PYTHONIOENCODING = 'utf-8'

if (-not (Test-Path -LiteralPath '基础/config.local.json')) {
    throw '缺少基础/config.local.json，请先按 README 完成本机配置。'
}
foreach ($runFile in Get-ChildItem -LiteralPath '基础/runs' -Filter '*.json' -ErrorAction SilentlyContinue) {
    $record = Get-Content -LiteralPath $runFile.FullName -Raw -Encoding utf8 | ConvertFrom-Json
    if ($record.case_id -eq 'D01' -and $record.mode -eq 'paid') {
        throw '已有 D01 真实尝试记录。请先核查原始结果，本脚本不会再次调用。'
    }
}

Write-Host '本窗口将执行一次 D01 / E / baseline 真实 API 请求，使用你的模型额度。'
Write-Host '请只在本窗口输入密钥；输入显示为掩码，不会写入命令历史或文件。'
try {
    $env:ASSESSMENT_API_KEY = Read-Host 'DeepSeek API Key' -MaskInput
    if ([string]::IsNullOrWhiteSpace($env:ASSESSMENT_API_KEY)) {
        throw '密钥为空，尚未发送请求。'
    }
    py 基础/starter/runner.py --case D01 --condition E --variant baseline --limit 1 --paid --config 基础/config.local.json
    if ($LASTEXITCODE -ne 0) { throw '运行未正常结束，请保留窗口报错，不要重试。' }
    Write-Host '本次尝试结束。原始记录位于 基础/runs/，请回到聊天通知助手。'
}
finally {
    Remove-Item Env:ASSESSMENT_API_KEY -ErrorAction SilentlyContinue
}
