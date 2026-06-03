---
name: export-old-word
description: Use when exporting a Word .docx file from an older Git commit without overwriting the current working file, especially on Windows PowerShell where redirection can corrupt binary docx output.
---

# Export Old Word Versions

Use this skill when the user asks to inspect, export, recover, or compare an older Git version of a Word `.docx` file without replacing the current file.

## Workflow

1. Confirm the target commit exists with `git log --oneline` or the user-provided commit hash.
2. Confirm the target file exists at that commit with `git cat-file -e COMMIT:"path/to/file.docx"`.
3. Do not use PowerShell `>` / `Out-File` / `Set-Content` to write `.docx` bytes. Windows PowerShell 5.1 may encode binary output as text and corrupt it.
4. Prefer the bundled script `scripts/export-old-word.ps1`, or use `git archive --format=zip --output=TEMP.zip COMMIT -- "path/to/file.docx"` and extract the docx from that zip.
5. Validate the exported `.docx` as a zip containing `[Content_Types].xml` and `word/document.xml`.
6. Add temporary exports such as `old-*.docx` and `old-*.zip` to `.gitignore` when working in a repo.

## Example

```powershell
.\tools\export-old-word.ps1 028bd05 "第一章 绪论2(田)二次修改.docx" "old-028bd05.docx"
```

Report the exported file path and validation result to the user.
