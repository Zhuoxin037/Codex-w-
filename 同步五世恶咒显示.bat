@echo off
chcp 65001 >nul
cd /d "%~dp0"
set "FIVE_CURSES_PY=C:\Users\qq303\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
set "PYTHONIOENCODING=utf-8"
"%FIVE_CURSES_PY%" .workbuddy\sync_five_curses_display.py
if errorlevel 1 goto failed
"%FIVE_CURSES_PY%" .workbuddy\deploy_five_curses.py --apply --rp-only
if errorlevel 1 goto failed
"%FIVE_CURSES_PY%" .workbuddy\deploy_five_curses.py --zip
if errorlevel 1 goto failed
echo 已同步五世恶咒显示。请在游戏中按 F3+T。
pause
exit /b 0
:failed
echo 同步未完成，请查看上方提示。
pause
exit /b 1
