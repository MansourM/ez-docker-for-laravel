---
inclusion: no
---

### Core Command Guideline for Windows

- **Always assume the host system is Windows** when generating terminal commands.  
- Use **Windows-compatible syntax** for:
  - File paths (`C:\path\to\file` or relative paths using `\` or `/`)  
  - Commands (`dir` instead of `ls` if appropriate, `copy` instead of `cp`)  
  - Environment variables (`%VARIABLE%` instead of `$VARIABLE`)  

- If a command is cross-platform, clearly indicate both Windows and Unix versions.  
- **Avoid Unix-only utilities** unless explicitly stated (e.g., `grep`, `sed`, `chmod`).  
- Test commands mentally for Windows Command Prompt or PowerShell compatibility before suggesting them.
