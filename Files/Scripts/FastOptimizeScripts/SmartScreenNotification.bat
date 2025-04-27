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

echo  Отключение уведомлений о запуске приложений
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Security" /F /V "DisableSecuritySettingsCheck" /T REG_DWORD /d 1 >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v LowRiskFileTypes /t REG_SZ /d ".exe;.bat;.cmd;.reg;.vbs;.msi;.msp;.com;.ps1;.ps2;.cpl" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /F /V "1806" /T REG_DWORD /d 0 >nul 2>&1
echo  Успешно