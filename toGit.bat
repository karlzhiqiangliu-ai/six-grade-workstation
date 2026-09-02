@echo off
chcp 65001 >nul
cd /d "%~dp0"
:: start "" 空标题参数不能丢！
start "" "C:\Program Files\Git\git-bash.exe" --cd="%~dp0"
