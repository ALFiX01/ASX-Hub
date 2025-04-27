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

	echo  Отключение Cortana
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
    :: Disable Cortana via Group Policy
    REG add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1

    :: Stop Cortana process
    taskkill /f /im Cortana.exe >nul 2>&1

    REM Переменная для хранения пути к папке с Cortana.exe
    set "cortana_path="

    :: Перебираем все папки внутри C:\Program Files\WindowsApps\
    for /d %%d in ("%ProgramFiles%\WindowsApps\*") do (
        :: Проверяем, есть ли в текущей папке файл Cortana.exe
        if exist "%%d\Cortana.exe" (
            set "cortana_path=%%d"
            :: Выводим путь к папке с Cortana.exe
            echo [INFO ] %TIME% - Файл Cortana.exe найден в папке: !cortana_path! >> "%ASX-Directory%\Files\Logs\%date%.txt"
            :: Take ownership of the folder
            takeown /f "!cortana_path!" /r /d y >nul 2>&1
            icacls "!cortana_path!" /grant %username%:F /t >nul 2>&1
            :: Удаляем папку
            rmdir /s /q "!cortana_path!" >nul 2>&1
            :: Проверяем, удалена ли папка
            if exist "!cortana_path!" (
                echo [ERROR] %TIME% - Папка !cortana_path! не была удалена. >> "%ASX-Directory%\Files\Logs\%date%.txt"
            ) else (
                echo [INFO ] %TIME% - Папка !cortana_path! успешно удалена. >> "%ASX-Directory%\Files\Logs\%date%.txt"
            )
        )
    )

    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /t REG_DWORD /d 0 /f >nul 2>&1

    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Speech_OneCore\Preferences" /v "ModelDownloadAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCloudSearch" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d "1" /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization" /v "RestrictImplicitInkCollection" /t REG_DWORD /d "1" /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization" /v "RestrictImplicitTextCollection" /t REG_DWORD /d "1" /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Software\Microsoft\InputPersonalization\TrainedDataStore" /v "HarvestContacts" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Personalization\Settings" /v "AcceptedPrivacyPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Windows Search" /v "CortanaConsent" /t REG_DWORD /d "0" /f >nul 2>&1

    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCortanaButton" /t REG_DWORD /d "0" /f >nul 2>&1
    taskkill /f /im explorer.exe >nul 2>&1
    start explorer.exe >nul 2>&1
    echo  Успешно
