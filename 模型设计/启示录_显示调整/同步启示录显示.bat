@echo off
chcp 65001 >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\.workbuddy\deploy_angel_binding.ps1"
pause
