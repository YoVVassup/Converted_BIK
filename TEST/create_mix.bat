@echo off
setlocal
set "TARGET=%~1"
if "%TARGET%"=="" exit /b 1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0create_mix.ps1" -Target "%TARGET%"
exit /b %errorlevel%
