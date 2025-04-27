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

REM Установка переменной Directory
reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" >nul 2>&1
if errorlevel 1 (
    REM Если ключ не существует, создаем его и директорию
    if not exist "%ProgramFiles%" (
        echo Ошибка 02: Директория Program Files не найдена.
        echo Проверьте целостность системы Windows.
        pause
        exit /b 1
    )
    reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /t REG_SZ /v "Directory" /d "%ProgramFiles%\ASX" /f >nul 2>&1
    set "ASX-Directory=%ProgramFiles%\ASX"
    
    REM Создаем структуру директорий
    if not exist "!ASX-Directory!\Files\Logs" (
        md "!ASX-Directory!\Files\Logs" >nul 2>&1
    )
) else (
    REM Если ключ существует, получаем значение
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" 2^>nul ^| find /i "Directory"') do set "ASX-Directory=%%b"
    
    if not exist "!ASX-Directory!" (
        REM Если директория не существует, создаем ее и устанавливаем флаг первого запуска
        md "!ASX-Directory!\Files\Logs" >nul 2>&1
        reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Firstlaunch" /t REG_SZ /d "Yes" /f >nul 2>&1
        set "SaveData=HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data"
        call:ASX_First_launch
        echo [INFO ] %TIME% - Создана директория !ASX-Directory! >> "!ASX-Directory!\Files\Logs\%date%.txt"
    ) else (
        REM Проверка структуры директорий
        if not exist "!ASX-Directory!\Files\Temp" md "!ASX-Directory!\Files\Temp" >nul 2>&1
    )
)

	echo  Отключение повышенной точности установки указателя мыши
    reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1
    echo  Успешно
  pause >nul 2>&1