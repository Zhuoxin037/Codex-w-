@echo off
chcp 65001 >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\..\.workbuddy\sync_aurora_display.ps1"
if errorlevel 1 goto failed
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\..\..\.workbuddy\deploy_aurora_binding.ps1"
if errorlevel 1 goto failed
echo 显示同步与部署完成。请重载游戏资源包。
pause
exit /b 0
:failed
echo 同步未完成，请保留上方错误文字。
pause
exit /b 1
