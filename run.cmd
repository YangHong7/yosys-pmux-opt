@echo off
setlocal
chcp 65001 >nul
pushd "%~dp0"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0project\runner\run_all.ps1" %*
set "PMUX_RUN_RC=%ERRORLEVEL%"
popd
if "%~1"=="" pause
exit /b %PMUX_RUN_RC%
