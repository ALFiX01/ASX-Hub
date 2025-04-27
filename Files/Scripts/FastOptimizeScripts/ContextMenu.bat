@echo off

:: Запуск от имени администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    REM start "" /wait /I /min powershell -NoProfile -Command "Start-Process -FilePath '%~s0' -Verb RunAs"
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"' -Verb RunAs"
    exit /b
)
chcp 65001 >nul 2>&1
setlocal EnableDelayedExpansion

REM Setting the Directory variable
reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" >nul 2>&1
if errorlevel 1 (
    REM If the key does not exist, create it and the directory
) else (
    REM If the key exists, gets the value
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" 2^>nul ^| find /i "Directory"') do set "ASX-Directory=%%b"
)

echo  Установка старого контекстного меню из Windows 10
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /d "" /f >nul 2>&1
taskkill /f /im explorer.exe
start explorer.exe
echo  Успешно
