@echo off
chcp 65001 >nul
cd /d "%~dp0"
:: start 独立进程，不阻塞cmd宿主，不会闪退
start "" powershell.exe -NoExit -Command "Set-Location '%~dp0'"
