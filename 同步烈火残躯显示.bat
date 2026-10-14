@echo off
setlocal
cd /d "%~dp0"
set "PYTHONIOENCODING=utf-8"
set "FLAME_PYTHON=C:\Users\qq303\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
"%FLAME_PYTHON%" .workbuddy\bind_flame_cast_rp.py
if errorlevel 1 goto fail
"%FLAME_PYTHON%" .workbuddy\verify_flame_cast.py
if errorlevel 1 goto fail
"%FLAME_PYTHON%" .workbuddy\deploy_flame_cast.py --apply --rp-only
if errorlevel 1 goto fail
"%FLAME_PYTHON%" .workbuddy\deploy_flame_cast.py --zip
if errorlevel 1 goto fail
echo Display synchronized. Press F3+T in Minecraft to reload textures and models.
pause
exit /b 0
:fail
echo Sync failed. Files after the failed step were not deployed. Please share the error above.
pause
exit /b 1
