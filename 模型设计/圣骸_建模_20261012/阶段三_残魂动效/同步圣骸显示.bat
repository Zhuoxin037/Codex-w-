@echo off
chcp 65001 >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\..\.workbuddy\sync_sacred_relic_display.ps1"
if errorlevel 1 (
    echo 圣骸显示同步失败，请查看上方信息。
) else (
    echo 圣骸整体握姿和全部动画部件已同步。请再运行部署到存档.bat。
)
pause
