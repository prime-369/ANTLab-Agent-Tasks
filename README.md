# ANTLab Agent Tasks

## 本轮开发入口（2026-10-15）

本轮仅打通基础开发题 D01/E：最小消息组织、预览与一次真实请求。总体暂选基础题＋进阶 B；未实现改进算法，未运行正式评测或进阶 B。最新进展与结果索引见 [STATUS.md](STATUS.md)，AI 影响与实际决定见 [decisions.md](decisions.md)。

本机验证环境：Windows 11、PowerShell 7.6.6、Python 3.14.3（使用 `py`）、Git 2.54.0.windows.1。骨架仅使用 Python 标准库，无需安装额外依赖。

在 PowerShell 中进入仓库；若仓库位置不同，请替换第一行路径：

```powershell
Set-Location -LiteralPath 'D:\AN\ANTLab-Agent-Tasks'
$env:PYTHONIOENCODING = 'utf-8'
if (-not (Test-Path -LiteralPath '基础/config.local.json')) {
    Copy-Item -LiteralPath '基础/config.example.json' -Destination '基础/config.local.json'
}
```

复制配置只需首次执行，已有 `config.local.json` 时跳过，避免覆盖。用编辑器将本机配置填写为以下内容（不含密钥；endpoint 只保留在本机）：

```json
{
  "provider": "DeepSeek",
  "endpoint": "https://api.deepseek.com/chat/completions",
  "model": "deepseek-flash",
  "parameters": {
    "temperature": 0,
    "max_tokens": 256,
    "thinking": {"type": "disabled"},
    "response_format": {"type": "json_object"}
  },
  "timeout_seconds": 90
}
```

预览与启动现有页面（下列命令不调用模型）：

```powershell
py 基础/starter/runner.py --case D01 --condition E --dry-run --config 基础/config.local.json
py 基础/starter/server.py --config 基础/config.local.json
```

浏览器打开 `http://127.0.0.1:8765`，选择 D01、E、基线、仅预览，点击“执行一次”。服务默认没有启用付费模式。停止服务：在启动服务的终端按 Ctrl+C。

唯一一次真实请求通过下面的脚本执行，**会使用本人模型额度**。只在本机 PowerShell 提示处输入密钥，不把密钥粘贴到命令或聊天。脚本设置环境变量并在同一会话调用 Python，结束即清除变量。已有 D01 真实尝试记录时脚本拒绝再次调用，不自动重试。

```powershell
pwsh -NoProfile -File .\scripts\Invoke-D01.ps1
```

`dry`/`dry_run` 只准备输入，没有模型输出；`mock` 是写死的模拟结果，不能作为实验证据；`paid` 才是实际 API 尝试，仍需检查 `status`、响应格式与引用语义。本轮未使用模拟模式。

原始记录位于 `基础/runs/`，包含实际消息、响应或失败、耗时、配置及数据/代码哈希，该目录与本机配置均被 Git 忽略。离线导出单条公开记录时使用实际文件名：

```powershell
py scripts/export_public_run.py 基础/runs/<run_id>.json
```

公开记录位于 `runs/basic/`；仅删除配置中的 endpoint，并注明原文件 SHA256，输入、响应、失败不作改写。公开导出不是新请求，原始记录继续留在本机。每条待提交记录仍须检查凭据与私人信息。

复用来源：[上游题包](https://github.com/Shiina413/ANTLab-Agent-Tasks)，本轮修改前基点 `b028d90`。保留题包数据及原骨架；本人仓库改动由用户要求、Codex 协助完成，不能将 AI 检查冒称用户已亲自核验。最新提交可执行 `git log -1` 查看，个人改动可执行 `git diff b028d90 HEAD --` 查看。以下保留题包原始介绍。

文档阅读与信息核验方向 Agent 项目的应用层开发者招募考核：先完成基础题，再从进阶 A/B/C 中选择一套完成。

**截止时间：北京时间 2026 年 10 月 16 日 23:59（UTC+8）。**

## 从哪开始

1. 先读 [开始阅读.md](开始阅读.md)（总体规则、时间、提交方式）。
2. 基础题（必做）：[基础/README.md](基础/README.md) 与 基础/01_考核题目.md。
3. 进阶题（三选一）：[进阶/README.md](进阶/README.md)，在 A / B / C 中选一套。

## 目录结构

```text
开始阅读.md              入口：总体规则、截止时间、提交方式
基础/                    基础题：12 题（4 开发题有公开答案 + 8 评测题），
                         R0/R1/R2/K 四种输入组织条件；模型 API 自费，
                         主请求量与运行命令见 基础/README.md
进阶/                    进阶题（A/B/C 三选一）
├─ 01_A_研究机制迁移.md        A：主张→证据→支持状态机制迁移与对照
├─ 02_B_系统失效诊断.md        B：源码审查、故障归因与修复
├─ 03_C_产品假设验证.md        C：围绕自选用户任务的产品假设验证
├─ materials/                 两份 CC Attribution 公开论文（P1/P2）及抽取数据
├─ challenge_b/               B 题文档查证样机（30 行 Engine，含预埋故障）
└─ templates/                 声明与整合报告模板
```

## 规则要点

- 准备时间为一周（包含基础题和进阶题）；模型调用使用自己的 API，费用自理；实验输入、原始响应、失败和前后对照须保留在仓库中。
- AI 可辅助阅读、实现和排错；需记录它对关键决定的影响、本人如何核验，以及实际完成和未完成的内容。
- 提交：把作品推送到自己的 GitHub 仓库，并在收集表登记仓库链接与最终 commit SHA；收集表地址与仓库评审账号见 Q 群公布（详见 进阶/05_提交与报告格式.md 与 进阶/06_收集表填写说明.md）。
- 本包不含评委参考答案、评测标签、内部开发教程或商业书籍全文。
- 文件完整性：`基础/文件校验.json` 与 `进阶/文件校验.json` 提供逐文件 SHA256，可自行校验。
