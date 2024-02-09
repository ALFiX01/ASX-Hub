@echo off
taskkill /f /im smartscreen.exe
del /f /q "%SystemRoot%\System32\smartscreen.exe" >nul 2>&1
del /f /q "%SystemRoot%\System32\smartscreen.dll" >nul 2>&1
