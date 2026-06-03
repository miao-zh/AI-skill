# AI-skill

一些好用的 AI skills，用来保存和复用日常工作里沉淀出来的 Codex / AI 工作流。

## Skills

### export-old-word

从 Git 的旧提交中安全导出 `.docx` 文件，不覆盖当前工作区里的 Word 文件。

这个 skill 主要解决 Windows PowerShell 5.1 下的一个坑：直接用 `>` 重定向导出 Word 二进制文件时，PowerShell 可能会把内容当文本编码，导致导出的 `.docx` 损坏。该 skill 使用 `git archive` 方式导出，并验证导出的文件是否是合法 Word 文档。

目录：

```text
export-old-word/
  SKILL.md
  scripts/
    export-old-word.ps1
```

示例用法：

```powershell
.\export-old-word\scripts\export-old-word.ps1 028bd05 "第一章 绪论2(田)二次修改.docx" "old-028bd05.docx"
```

参数说明：

```text
第 1 个参数：Git 提交号
第 2 个参数：旧提交中的 Word 文件路径
第 3 个参数：导出的新文件名，可选
```

## 安装到本地 Codex skills

把整个 skill 目录复制到本地 Codex skills 目录，例如：

```powershell
Copy-Item -Recurse .\export-old-word "C:\Users\你的用户名\.codex\skills\export-old-word"
```

安装后，当你要求导出某个 Git 提交里的旧版 Word 文件时，Codex 可以优先使用这个安全流程。
