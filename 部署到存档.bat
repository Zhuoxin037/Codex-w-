@echo off
rem ============================================================
rem  ASCII-only launcher for deploy.ps1
rem  Do NOT put Chinese text in this file: cmd.exe reads .bat in the
rem  OEM codepage (GBK here), so UTF-8 Chinese turns into garbage and
rem  cmd tries to run the fragments as commands. All Chinese messages
rem  live in deploy.ps1, which is saved as UTF-8 with BOM.
rem ============================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy.ps1" %*
