@echo off
taskkill /f /im smartscreen.exe
if exist "%SystemRoot%\System32\smartscreen.exe" (
del /f /q "%SystemRoot%\System32\smartscreen.exe" >nul 2>&1
)

if exist "%SystemRoot%\System32\smartscreen.dll" (
del /f /q "%SystemRoot%\System32\smartscreen.dll" >nul 2>&1
)