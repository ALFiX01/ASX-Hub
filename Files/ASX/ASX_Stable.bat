::[Bat To Exe Converter]
::
::YAwzoRdxOk+EWAjk
::fBw5plQjdCuDJOlERJKA/6q0/NQy7dtkt1esMlgr08u0mg01QeADcYzU1IivE9gsxkrjeqk7hDRTm8Rs
::YAwzuBVtJxjWCl3EqQJgSA==
::ZR4luwNxJguZRRnk
::Yhs/ulQjdF65
::cxAkpRVqdFKZSjk=
::cBs/ulQjdF65
::ZR41oxFsdFKZSDk=
::eBoioBt6dFKZSDk=
::cRo6pxp7LAbNWATEpCI=
::egkzugNsPRvcWATEpCI=
::dAsiuh18IRvcCxnZtBJQ
::cRYluBh/LU+EWAnk
::YxY4rhs+aU+JeA==
::cxY6rQJ7JhzQF1fEqQJQ
::ZQ05rAF9IBncCkqN+0xwdVs0
::ZQ05rAF9IAHYFVzEqQJQ
::eg0/rx1wNQPfEVWB+kM9LVsJDGQ=
::fBEirQZwNQPfEVWB+kM9LVsJDGQ=
::cRolqwZ3JBvQF1fEqQJQ
::dhA7uBVwLU+EWDk=
::YQ03rBFzNR3SWATElA==
::dhAmsQZ3MwfNWATElA==
::ZQ0/vhVqMQ3MEVWAtB9wSA==
::Zg8zqx1/OA3MEVWAtB9wSA==
::dhA7pRFwIByZRRnk
::Zh4grVQjdCyDJGyX8VAjFD9VQg2LMFeeCbYJ5e31+/m7hUQJfPc9RK7o4vmmNeIv7krnZqoM5UIXsN4OQh5Ae3I=
::YB416Ek+ZW8=
::
::
::978f952a14a936cc963da21a135fa983
 
@echo off

:: Copyright (C) 2025 ALFiX, Inc.
:: Any tampering with the program code is forbidden (Запрещены любые вмешательства)

:: Запуск от имени администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo  Requesting administrator privileges...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs -ArgumentList '--elevated'" >nul 2>&1
    exit /b
)

:: Получение информации о текущем языке интерфейса и выход, если язык не ru-RU
for /f "tokens=3" %%i in ('reg query "HKCU\Control Panel\International" /v "LocaleName"') do set WinLang=%%i
if /I "%WinLang%" NEQ "ru-RU" (
    cls
    echo  Error 01: Invalid interface language.
    pause
    exit /b
)

:RR
:: Внутренний перезапуск ASX
mode con: cols=146 lines=45 >nul 2>&1
chcp 65001 >nul 2>&1

setlocal EnableDelayedExpansion 

title Подготовка [0/3]

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
    reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /t REG_SZ /v "Directory" /d "%Windir%\ASX" /f >nul 2>&1
    set "ASX-Directory=%Windir%\ASX"
    
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

REM Логируем запуск ASX Hub
echo. >> "!ASX-Directory!\Files\Logs\%date%.txt"
echo 📌 Запуск ASX Hub >> "!ASX-Directory!\Files\Logs\%date%.txt"

REM ИНФОРМАЦИЯ О ВЕРСИИ
:: BranchCurrentVersion - ветка текущей версии
set "Version=1.7.1"
set "FullVersionNameCurrent=1.7.1"
set "VersionNumberCurrent=YL21S1"

set "BranchCurrentVersion=Stable"

set "DateUpdate=21.07.2025"
set "Dynamic_Upd_on_startPC=No"
set "ASX_Version_OLD="
set "SaveData=HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data"

reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "DisplayVersion" /t REG_SZ /d "%Version%" /f >nul 2>&1

echo ------------------------------------------------ >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo   Версия: %Version% ^| Номер сборки: %VersionNumberCurrent% >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo ------------------------------------------------ >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo [INFO ] %TIME% - Запущен >> "%ASX-Directory%\Files\Logs\%date%.txt"

REM Цветной текст
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")

REM -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

REM Настройки UAC
set "L_ConsentPromptBehaviorAdmin=0"
set "L_ConsentPromptBehaviorUser=3"
set "L_EnableInstallerDetection=1"
set "L_EnableLUA=1"
set "L_EnableSecureUIAPaths=1"
set "L_FilterAdministratorToken=0"
set "L_PromptOnSecureDesktop=0"
set "L_ValidateAdminCodeSignatures=0"

REM Путь к реестру UAC
set "UAC_HKLM=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

REM Основной цикл проверки и обновления значений UAC
set "UAC_check=Success"
for %%i in (
    ConsentPromptBehaviorAdmin
    ConsentPromptBehaviorUser
    EnableInstallerDetection
    EnableLUA
    EnableSecureUIAPaths
    FilterAdministratorToken
    PromptOnSecureDesktop
    ValidateAdminCodeSignatures
) do (
    for /f "tokens=3" %%a in ('reg query "%UAC_HKLM%" /v "%%i" 2^>nul ^| find /i "%%i"') do (
        REM Удаляем префикс "0x" из текущего значения
        set "current_value=%%a"
        set "current_value=!current_value:0x=!"

        REM Получаем ожидаемое значение
        call set "expected_value=%%L_%%i%%"

        REM Сравниваем значения
        if not "!current_value!" == "!expected_value!" (
            echo [WARN ] %TIME% - Параметр UAC '%%i' имеет неожиданное значение. Текущее: 0x!current_value!, Ожидаемое: 0x!expected_value!. >> "%ASX-Directory%\Files\Logs\%date%.txt"
            reg add "%UAC_HKLM%" /v "%%i" /t REG_DWORD /d !expected_value! /f >nul 2>&1
            if errorlevel 1 (
                echo [ERROR] %TIME% - Не удалось изменить параметр UAC '%%i'. Возможно, недостаточно прав. >> "%ASX-Directory%\Files\Logs\%date%.txt"
                set "UAC_check=Error"
            ) else (
                echo [INFO ] %TIME% - Параметр UAC '%%i' успешно изменён на 0x!expected_value!. >> "%ASX-Directory%\Files\Logs\%date%.txt"
            )
        )
    )
)

rem Если ошибка была то сообщить
if "%UAC_Check%"=="Error" (
    echo [ERROR] %TIME% - Обнаружены ошибки при настройке UAC. Требуется перезапуск системы. >> "%ASX-Directory%\Files\Logs\%date%.txt"
    set /a "error_on_loading_2+=1"
    cls
    title Внимание: Некорректный запуск
	color 07
    echo.
    echo %COL%[91m^[ОШИБКА^] Произошёл некорректный запуск.%COL%[97m
    echo.
    echo Причина: %COL%[91mКонтроль учётных записей ^(UAC^) настроен неправильно.%COL%[97m
	echo.
	echo.
    echo %COL%[37mASX Hub уже попытался внести необходимые изменения в реестр.
    echo Для применения изменений требуется перезапуск системы.
    echo.
    echo Вы можете:
    echo 1. Перезапустить систему вручную.
    echo 2. Ввести команду %COL%[92mrestart%COL%[37m для автоматического перезапуска.
    echo.
    goto EnterToRestart
)

:Disclaimer
reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "SkipDisclaimer" >nul 2>&1 && goto ASX_First_launch
mode con: cols=146 lines=45 >nul 2>&1
set "screen=Disclaimer"
chcp 65001 >nul 2>&1
cls
echo [INFO ] %TIME% - Запущена панель "Disclaimer" >> "%ASX-Directory%\Files\Logs\%date%.txt" >nul 2>&1
echo.
echo.
echo.
echo.
echo.
TITLE Дисклеймер - ASX Hub
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
echo.
echo.
echo.
echo                                  %COL%[91mДля продолжения использования ASX Hub, пожалуйста, ознакомьтесь с дисклеймером. %COL%[37m
echo.
echo.
echo        %COL%[90m───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────%COL%[37m
echo.
echo         █  Мы не несем ответственности за возможные повреждения, возникшие при использовании ASX Hub на вашем устройстве.
echo.
echo.
echo         █  Мы не отвечаем за удаление или повреждение важных файлов и данных в результате работы ASX Hub.
echo.
echo.
echo         █  Производительность системы зависит от множества факторов, поэтому мы не гарантируем её улучшение.
echo.
echo.
echo         █  Используйте ASX Hub осознанно. Если у вас есть вопросы, обратитесь за поддержкой в наш Discord.
echo.
echo.
echo         █  В случае непредвиденных проблем воспользуйтесь автоматически созданной точкой восстановления.
echo.
echo        %COL%[90m───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
echo.
echo                                                   Присоединяйтесь к нам в discord.gg/ALFiX-Zone %COL%[37m
echo.
echo.
echo.
set /p "input=%DEL%                                                         Введите %COL%[96m"ОК"%COL%[37m для продолжения >: %COL%[96m"
if /i "!input!" equ "Ок" (
echo %COL%[90m
echo                                                               Перенаправление...
reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "SkipDisclaimer" /f >nul 2>&1 && goto ASX_First_launch
)

if /i "!input!" equ "Ok" (
echo %COL%[90m
echo                                                               Перенаправление...
reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "SkipDisclaimer" /f >nul 2>&1 && goto ASX_First_launch
)

call:WrongInput
goto Disclaimer

REM Окно первого запуска

:ASX_First_launch
REM Setup initial launch registry if not set
reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Firstlaunch" >nul 2>&1
if errorlevel 1 (
    reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Firstlaunch" /t REG_SZ /d "Yes" /f >nul 2>&1
    set "firstlaunch=1"
	goto ASX_First_launch
) else (
    REM Проверка и установка флага первого запуска
    set "firstlaunch=0"
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Firstlaunch" 2^>nul') do (
		if "%%b"=="No" goto ASX_Start
    )
)

set "firstlaunch_dynamic_on=0"
echo [INFO ] %TIME% - Инициализация ASX Hub - Первоначальная настройка >> "%ASX-Directory%\Files\Logs\%date%.txt"
cls
Title Первоначальная настройка ASX Hub [0/5]
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
echo.
echo.
echo.
echo                                            Пожалуйста, подождите, выполняется первоначальная настройка.
Timeout 1 >nul

ping -n 1 google.ru >nul 2>&1
IF %ERRORLEVEL% EQU 1 (
    echo.
    echo.
    echo.
    echo                            %COL%[91mНевозможно выполнить первоначальную настройку в связи с отсутствием подключения к интернету.%COL%[90m
    echo.
    echo.
    echo                                                     ASX Hub будет закрыт через 10 секунд.
    Timeout 10 >nul
    exit
)

if not exist "%ASX-Directory%\Files\Resources" md "%ASX-Directory%\Files\Resources" >nul 2>&1
if not exist "%ASX-Directory%\Files\Logs" md "%ASX-Directory%\Files\Logs" >nul 2>&1
if not exist "%ASX-Directory%\Files\Downloads" md "%ASX-Directory%\Files\Downloads" >nul 2>&1
if not exist "%ASX-Directory%\Files\Restore" md "%ASX-Directory%\Files\Restore" >nul 2>&1

set error_on_setup=0

Title Первоначальная настройка ASX Hub [1/5]
if not exist "%ASX-Directory%\Files\ASX.ico" (
     title Загрузка отсутствующих компонентов...
     echo [INFO ] %TIME% - Загрузка отсутствующего компонента ASX.ico >> "%ASX-Directory%\Files\Logs\%date%.txt"
     curl -g -L -# -o "%ASX-Directory%\Files\ASX.ico" "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/ASX/ASX.ico" >nul 2>&1
     if errorlevel 1 (
         echo [ERROR] %TIME% - Ошибка при загрузке ASX.ico >> "%ASX-Directory%\Files\Logs\%date%.txt"
         set /a error_on_setup+=1
     )
)

if not exist "%ASX-Directory%\Uninst.exe" (
     title Загрузка отсутствующих компонентов...
     echo [INFO ] %TIME% - Загрузка отсутствующего компонента Uninst.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
     curl -g -L -# -o "%ASX-Directory%\Uninst.exe" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Updater/Uninst.exe" >nul 2>&1
     if errorlevel 1 (
         echo [ERROR] %TIME% - Ошибка при загрузке Uninst.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
         set /a error_on_setup+=1
     )
)

REM проверка наличия EXE 👇
if not exist "%ASX-Directory%\ASX Hub.exe" (
	title Загрузка отсутствующих компонентов...
    echo [INFO ] %TIME% - Загрузка отсутствующего компонента ASX Hub.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
	curl -g -L -# -o "%ASX-Directory%\ASX Hub.exe" "https://github.com/ALFiX01/ASX-Hub/releases/latest/download/ASX-Hub.exe" >nul 2>&1
	if errorlevel 1 (
		echo [ERROR] %TIME% - Ошибка при загрузке ASX Hub.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
		set /a error_on_setup+=1
	)    

	set /a Launch_status+=1
	set "Reason_launch_info=Отсутствует файл ASX Hub.exe"
)

if not exist "%ASX-Directory%\Files\Utilites\PyDebloatX\PyDebloatX.exe" (
    title Загрузка отсутствующих компонентов...
    echo [INFO ] %TIME% - Загрузка отсутствующего компонента PyDebloatX.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
    if not exist "%ASX-Directory%\Files\Utilites\PyDebloatX" (
        md "%ASX-Directory%\Files\Utilites\PyDebloatX" >nul 2>&1
    )
    curl -g -L -# -o "%ASX-Directory%\Files\Utilites\PyDebloatX\PyDebloatX.exe" "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Utilities/PyDebloatX/PyDebloatX.exe" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] %TIME% - Ошибка при загрузке компонента PyDebloatX.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
        set /a "error_on_loading_1+=1"
    )
    set /a Launch_status+=1
    set "Reason_launch_info=Отсутствует файл PyDebloatX.exe"
)

REM if not exist "%ASX-Directory%\Files\Utilites\ASX_DriverFinder\DriverFinder.exe" (
REM     title Загрузка отсутствующих компонентов...
REM     echo [INFO ] %TIME% - Загрузка отсутствующего компонента DriverFinder.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
REM     if not exist "%ASX-Directory%\Files\Utilites\ASX_DriverFinder" (
REM         md "%ASX-Directory%\Files\Utilites\ASX_DriverFinder" >nul 2>&1
REM     )
REM     curl -g -L -# -o "%ASX-Directory%\Files\Utilites\ASX_DriverFinder\DriverFinder.exe" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Utilities/ASX_DriverFinder/DriverFinder.exe" >nul 2>&1
REM     curl -g -L -# -o "%ASX-Directory%\Files\Utilites\ASX_DriverFinder\DriverFinder_FindService.exe" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Utilities/ASX_DriverFinder/DriverFinder_FindService.exe" >nul 2>&1
REM     if errorlevel 1 (
REM         echo [ERROR] %TIME% - Ошибка при загрузке компонентов DriverFinder >> "%ASX-Directory%\Files\Logs\%date%.txt"
REM         set /a "error_on_loading_1+=1"
REM     )
REM     set /a Launch_status+=1
REM 	set "Reason_launch_info=Отсутствует файлы утилиты DriverFinder"
REM )

Title Первоначальная настройка ASX Hub [2/5]

reg add "%SaveData%\Dynamic" /v "BackupDate" /t REG_SZ /d "%date%" /f >nul
if errorlevel 1 set /a error_on_setup+=1

chcp 850 >nul 2>&1
powershell.exe -Command "Enable-ComputerRestore -Drive %systemdrive%"
if errorlevel 1 set /a error_on_setup+=1

reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul
if errorlevel 1 set /a error_on_setup+=1

powershell.exe -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description 'ASX Hub Restore Point %date%' -RestorePointType 'MODIFY_SETTINGS'"
if errorlevel 1 set /a error_on_setup+=1

reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /f >nul
if errorlevel 1 set /a error_on_setup+=1

chcp 65001 >nul 2>&1
SET RegBackupPath=%ASX-Directory%\Files\Restore\%date%
if exist "%ASX-Directory%\Files\Restore\%date%" rd /s /q "%ASX-Directory%\Files\Restore\%date%" >nul
if not exist "%ASX-Directory%\Files\Restore\%date%" mkdir "%ASX-Directory%\Files\Restore\%date%" >nul

Title Первоначальная настройка ASX Hub [3/5]

REG export HKCR "%RegBackupPath%\HKCR.Reg" /y >nul
if errorlevel 1 set /a error_on_setup+=1

REG export HKCU "%RegBackupPath%\HKCU.Reg" /y >nul
if errorlevel 1 set /a error_on_setup+=1

REG export HKLM "%RegBackupPath%\HKLM.reg" /y >nul
if errorlevel 1 set /a error_on_setup+=1

REG export HKU "%RegBackupPath%\HKU.Reg" /y >nul
if errorlevel 1 set /a error_on_setup+=1

REG export HKCC "%RegBackupPath%\HKCC.Reg" /y >nul
if errorlevel 1 set /a error_on_setup+=1

COPY "%RegBackupPath%\HKLM.reg"+"%RegBackupPath%\HKCU.reg"+"%RegBackupPath%\HKCR.reg"+"%RegBackupPath%\HKU.reg"+"%RegBackupPath%\HKCC.reg" "%RegBackupPath%\Backup.reg" >nul
if errorlevel 1 set /a error_on_setup+=1

reg query "HKCU\Software\ALFiX inc.\ASX" /v "Run_data" >nul 2>&1
if errorlevel 1 (
     reg add "HKCU\Software\ALFiX inc.\ASX" /t REG_SZ /v "Run_data" /d "%date%" /f >nul 2>&1
     if errorlevel 1 set /a error_on_setup+=1
     set "Run_data=%date%"
) else (
     for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX" /v "Run_data" 2^>nul ^| find /i "Run_data"') do set "Run_data=%%b"
)

REM Получение и установка имени пользователя на user
reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CustomUserName" >nul 2>&1
if errorlevel 1 (
     reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /t REG_SZ /v "CustomUserName" /d "User" /f >nul 2>&1
     if errorlevel 1 set /a error_on_setup+=1
) else (
     for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CustomUserName" 2^>nul ^| find /i "CustomUserName"') do set "CustomUserName=%%b"
     echo [INFO ] %TIME% - Имя пользователя определено как "%CustomUserName%" >> "%ASX-Directory%\Files\Logs\%date%.txt"	
)

echo [INFO ] %TIME% - Количество ошибок при настройке: %error_on_setup% >> "%ASX-Directory%\Files\Logs\%date%.txt"
Reg add "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "DisplayIcon" /t REG_SZ /d "%ASX-Directory%\ASX Hub.exe" /f >nul
Reg add "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "URLInfoAbout" /t REG_SZ /d "https://github.com/ALFiX01/ASX-Hub" /f >nul

Title Первоначальная настройка ASX Hub [4/5]

chcp 850 >nul 2>&1
powershell -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%userprofile%\Desktop\ASX Hub.lnk'); $s.TargetPath = '%ASX-Directory%\ASX Hub.exe'; $s.Save()" >nul

powershell -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%SystemDrive%\Windows\ASX Hub.lnk'); $s.TargetPath = '%ASX-Directory%\ASX Hub.exe'; $s.WorkingDirectory = '%ASX-Directory%'; $s.Save()"
powershell -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%SystemDrive%\Windows\ASX.lnk'); $s.TargetPath = '%ASX-Directory%\ASX Hub.exe'; $s.WorkingDirectory = '%ASX-Directory%'; $s.Save()"
powershell -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%SystemDrive%\Windows\ASX-dir.lnk'); $s.TargetPath = '%ASX-Directory%'; $s.WorkingDirectory = '%ASX-Directory%'; $s.Save()"

powershell -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Desktop') + '\ASX Hub.lnk'); $s.TargetPath = '%ASX-Directory%\ASX Hub.exe'; $s.Save()"
chcp 65001 >nul 2>&1

reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "DisplayName" /t REG_SZ /d "ASX Hub" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "DisplayVersion" /t REG_SZ /d "%Version%" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "Publisher" /t REG_SZ /d "ALFiX.inc" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "NoModify" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "NoRepair" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "DisplayIcon" /t REG_SZ /d "%ASX-Directory%\ASX Hub.exe" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "UninstallString" /t REG_SZ /d "%ASX-Directory%\Uninst.exe" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "QuietUninstallString" /t REG_SZ /d "%ASX-Directory%\Uninst.exe" /SILENT /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "URLInfoAbout" /t REG_SZ /d "https://github.com/ALFiX01/ASX-Hub" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "HelpLink" /t REG_SZ /d "https://discord.gg/MreKhdN2Ns" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "Contact" /t REG_SZ /d "https://discord.gg/MreKhdN2Ns" /f >nul 2>&1

Title Первоначальная настройка ASX Hub [5/5]

reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Firstlaunch" /t REG_SZ /d "No" /f >nul 2>&1

cls
Title Инициализация ASX Hub Завершена
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: ::::::::: 
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+: 
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+  
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+    
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+    
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#     
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########    
echo.
echo.
echo.
echo                                                               Настройка завершена.
echo                                                    Добро пожаловать. ASX Hub готов к работе.
echo.
echo.
echo.
echo.
echo                                                  %COL%[36mНажмите любую клавишу чтобы перейти к ASX Hub
pause >nul

:ASX_Start
REM Переменные 
set Launch_status=0
set NoUpd=0
REM set /a randomNumber=%random% %% 10 + 1
set NotFoundRestoreFolder=0
set Dynamic_st=On
set "Reason_launch_info=Ошибка"
set CustomUserNameWarn=0
set DynamicProcessErrorCount=0
set "WinVer=Windows 10"
set "Dynamic_Used=No"
set "CustomUserName=User"
set "length=4"

set "history="

title Подготовка [1/3]

echo [INFO ] %TIME% - Получение времени суток >> "%ASX-Directory%\Files\Logs\%date%.txt"
REM set "year=%DATE:~6,4%"
REM set "month=%DATE:~3,2%"
set "day=%DATE:~0,2%"
set "hour=%time:~0,2%"
if "%hour%"==" " set "hour=0"
if "%hour%"=="" set "hour=0"

title Загрузка...

:loading_screen
::loading
set "screen=loading_screen"
FOR /F %%A in ('"PROMPT $H&FOR %%B in (1) DO REM"') DO SET "BS=%%A"
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
echo.
echo.
echo.

REM Получение имени пользователя
reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CustomUserName" >nul 2>&1
if errorlevel 1 (
    reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /t REG_SZ /v "CustomUserName" /d "User" /f >nul 2>&1
    set "CustomUserName=User"
) else (
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CustomUserName" 2^>nul ^| find /i "CustomUserName"') do set "CustomUserName=%%b"
)
echo [INFO ] %TIME% - Имя пользователя определено как "%CustomUserName%" >> "%ASX-Directory%\Files\Logs\%date%.txt"    

REM Получаем текущий час (24-часовой формат)
for /f "tokens=1 delims=:" %%a in ("%time%") do set "hour=%%a"
REM Удаляем ведущий ноль
if "!hour:~0,1!"=="0" set "hour=!hour:~1!"

REM Проверка на пустое значение часа
if not defined hour set "hour=0"

REM Определяем тип приветствия в зависимости от времени суток
set "timeType=night"
if %hour% LSS 3 (
    set "timeType=night"
) else if %hour% LSS 12 (
    set "timeType=morning"
) else if %hour% LSS 17 (
    set "timeType=day"
) else if %hour% LSS 22 (
    set "timeType=evening"
) else (
    set "timeType=night"
)

REM Задаем варианты приветствий для каждого времени суток
set "morning[0]=Доброе утро, %CustomUserName%. Надеюсь, вы чувствуете себя отлично."
set "morning[1]=Доброе утро, %CustomUserName%, получилось выспаться?"
set "morning[2]=Доброе утро, %CustomUserName%, как спалось?"
set "morning_count=3"

set "day[0]=Добрый день, %CustomUserName%. Я к вашим услугам."
set "day[1]=Добрый день, %CustomUserName%. ASX настроен и готов к работе."
set "day[2]=Добрый день, %CustomUserName%. Солнце уже давно в деле, а вы?"
set "day[3]=Добрый день, %CustomUserName%."
set "day_count=4"

set "evening[0]=Добрый вечер, %CustomUserName%. Отличный момент для отдыха."
set "evening[1]=Добрый вечер, %CustomUserName%, как прошел ваш день?"
set "evening[2]=Добрый вечер, %CustomUserName%, чем планируете заняться?"
set "evening[3]=Добрый вечер, %CustomUserName%. Самое время расслабиться."
set "evening_count=4"

set "night[0]=Доброй ночи, %CustomUserName%. Напоминаю, что отдых — ключ к продуктивности."
set "night[1]=Доброй ночи, %CustomUserName%, может, пора отдохнуть?"
set "night[2]=Доброй ночи, %CustomUserName%, надеюсь, у вас есть причина быть бодрым."
set "night[3]=Доброй ночи, %CustomUserName%. Может, чашечку чая перед сном?"
set "night[4]=Доброй ночи, %CustomUserName%. Надеюсь, вы найдете время для отдыха."
set "night_count=5"

REM Защита от ошибки деления на ноль
if !%timeType%_count! LEQ 0 set "%timeType%_count=1"
set /a "randomIndex=%random% %% !%timeType%_count!"

REM Получаем приветствие через call set
call set "HiMessage=%%%timeType%[!randomIndex!]%%"

REM Проверка на пустое сообщение
if "!HiMessage!"=="" (
    set "HiMessage=Здравствуйте, %CustomUserName%. ASX Hub готов к работе."
    echo [WARN ] %TIME% - Ошибка при выборе приветствия, установлено значение по умолчанию >> "%ASX-Directory%\Files\Logs\%date%.txt"
)

REM Найдем длину строки HiMessage
set "length=0"
for /L %%i in (0,1,146) do (
    set "char=!HiMessage:~%%i,1!"
    if "!char!"=="" goto end_HiMessage
    set /A length+=1
)
:end_HiMessage

REM Рассчитаем количество пробелов для выравнивания по центру
set /A spaces=(146-length)/2
if %spaces% LSS 0 set "spaces=0"

REM Создадим строку с пробелами
set "padding_HiMessage="
for /L %%i in (1,1,%spaces%) do set "padding_HiMessage=!padding_HiMessage! "

REM Добавим пробелы перед HiMessage
set "HiMessage=!padding_HiMessage!!HiMessage!"
echo [INFO ] %TIME% - Сформировано приветствие: "!HiMessage!" >> "%ASX-Directory%\Files\Logs\%date%.txt"



REM ----- ОБНОВЛЕНИЯ -----
:UpdateCheck
echo [INFO ] %TIME% - Проверка обновлений >> "%ASX-Directory%\Files\Logs\%date%.txt"

REM Разделение версии
for /f "tokens=1-3 delims=." %%a in ("%Version%") do (
    set "Major=%%a"
    set "Minor=%%b"
    set "Patch=%%c"
)
if "%Patch%"=="0" set "Version=%Major%.%Minor%"

:: Проверка подключения к интернету
ping -n 1 google.ru >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [WARN ] %TIME% - Соединение с интернетом отсутствует >> "%ASX-Directory%\Files\Logs\%date%.txt"
    set "WiFi=Off"    
    goto loading_procces    
) else (
    set "WiFi=On"        
)

:: Получение текущей версии ASX из реестра
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX" /v "ASX_Version" 2^>nul ^| find /i "ASX_Version"') do set "ASX_Version_OLD=%%b"

:: Проверка и установка ключа CheckUpdateOnWinStartUp в реестре
reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CheckUpdateOnWinStartUp" >nul 2>&1
if errorlevel 1 (
    reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CheckUpdateOnWinStartUp" /t REG_SZ /d "On" /f >nul 2>&1
    set "CheckUpdateOnWinStartUp=On"
) else (
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CheckUpdateOnWinStartUp" 2^>nul ^| find /i "CheckUpdateOnWinStartUp"') do set "CheckUpdateOnWinStartUp=%%b"
)

:: Загрузка и регистрация ASX-Hub-Updater, если включена проверка при запуске Windows и файл отсутствует
if "%CheckUpdateOnWinStartUp%"=="On" (
    if not exist "%ASX-Directory%\Files\ASX-Hub-Updater.exe" (
        curl -g -L -# -o "%ASX-Directory%\Files\ASX-Hub-Updater.exe" "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Updater/UpdateCheck_OnStartPC.exe" >nul 2>&1
        if !errorlevel! equ 0 (
            reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "ASX-Hub-Updater" /t REG_SZ /d "\"%ASX-Directory%\Files\ASX-Hub-Updater.exe\" --minimized" /f >nul 2>&1
            echo [INFO ] %TIME% - ASX-Hub-Updater успешно установлен >> "%ASX-Directory%\Files\Logs\%date%.txt"
        ) else (
            echo [ERROR] %TIME% - Ошибка при загрузке ASX-Hub-Updater.exe ^(первая установка^) >> "%ASX-Directory%\Files\Logs\%date%.txt"
        )
    )
)

:: Обновление версии ASX в реестре, если она изменилась
if "%ASX_Version_OLD%" NEQ "%Version%" (
    set "Dynamic_Upd_on_startPC=Yes"
    reg add "HKCU\Software\ALFiX inc.\ASX" /t REG_SZ /v "ASX_Version" /d "%Version%" /f >nul 2>&1
    reg add "HKCU\Software\ALFiX inc.\ASX" /t REG_SZ /v "ASX_Version_Number" /d "%VersionNumberCurrent%" /f >nul 2>&1
    echo [INFO ] %TIME% - Обновлена версия в реестре с %ASX_Version_OLD% на %Version% >> "%ASX-Directory%\Files\Logs\%date%.txt"

    :: Повторная загрузка и регистрация ASX-Hub-Updater при обновлении версии, если включена проверка при запуске
    if "%CheckUpdateOnWinStartUp%"=="On" (
        if not exist "%ASX-Directory%\Files\ASX-Hub-Updater.exe" (
            curl -g -L -# -o "%ASX-Directory%\Files\ASX-Hub-Updater.exe" "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Updater/UpdateCheck_OnStartPC.exe" >nul 2>&1
            if !errorlevel! equ 0 (
                reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "ASX-Hub-Updater" /t REG_SZ /d "\"%ASX-Directory%\Files\ASX-Hub-Updater.exe\" --minimized" /f >nul 2>&1
                echo [INFO ] %TIME% - ASX-Hub-Updater успешно обновлен >> "%ASX-Directory%\Files\Logs\%date%.txt"
            ) else (
                echo [ERROR] %TIME% - Ошибка при загрузке ASX-Hub-Updater.exe ^(обновление версии^) >> "%ASX-Directory%\Files\Logs\%date%.txt"
            )
        )
    )
) else (
    set "Dynamic_Upd_on_startPC=No"
)

:: Установка ветки обновлений
set "FileVerCheckName=ASX_Version"

:: Проверка флага NoUpd
if %NoUpd% equ 1 (
    REM Переход к процессу загрузки
    echo [INFO ] %TIME% - Пропуск проверки обновлений ^(NoUpd=1^) >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto loading_procces
)

:: Проверка настройки пропуска обновлений
reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "SkipUpdate" >nul 2>&1
if !errorlevel! equ 0 (
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "SkipUpdate" 2^>nul ^| find /i "SkipUpdate"') do (
        set "SkipUpdate=%%b"
    )
    if /i "!SkipUpdate!"=="Yes" (
        echo [INFO ] %TIME% - Пропуск проверки обновлений ^(SkipUpdate=Yes^) >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto loading_procces
    )
) else (
    set "SkipUpdate=No"
)

:: Проверка наличия ASX-Hub-Updater в автозагрузке, если он существует и включена проверка при запуске
if "%CheckUpdateOnWinStartUp%"=="On" (
    if exist "%ASX-Directory%\Files\ASX-Hub-Updater.exe" (
        reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "ASX-Hub-Updater" >nul 2>&1
        if !errorlevel! equ 0 (
            echo [INFO ] %TIME% - ASX-Hub-Updater уже зарегистрирован в автозагрузке >> "%ASX-Directory%\Files\Logs\%date%.txt"
            goto loading_procces
        )
    )
)

:: Проверка наличия curl
where curl >nul 2>&1
if errorlevel 1 (
    echo [ERROR] %TIME% - Не найден curl, обновление невозможно >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto loading_procces
)


TITLE Проверка обновлений
echo [INFO ] %TIME% - Проверка обновлений >> "%ASX-Directory%\Files\Logs\%date%.txt"

:: Очистка старого файла
if exist "%TEMP%\Updater.bat" del /s /q /f "%TEMP%\Updater.bat" >nul 2>&1

:: Загрузка нового файла Updater.bat
curl -s -o "%TEMP%\Updater.bat" "https://raw.githubusercontent.com/ALFiX01/ASX-Hub/main/Files/ASX/%FileVerCheckName%" 
if errorlevel 1 (
    echo [ERROR] %TIME% - Ошибка связи с сервером проверки обновлений >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto loading_procces
)

:: Проверка успешной загрузки файла
if not exist "%TEMP%\Updater.bat" (
    echo [ERROR] %TIME% - Файл Updater.bat не был загружен >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto loading_procces
)

:: Проверка размера файла (если файл пустой, то пропускаем)
for %%A in ("%TEMP%\Updater.bat") do if %%~zA equ 0 (
    echo [ERROR] %TIME% - Загруженный файл Updater.bat пуст >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto loading_procces
)

:: Выполнение загруженного файла Updater.bat
call "%TEMP%\Updater.bat" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] %TIME% - Ошибка при выполнении Updater.bat >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto loading_procces
)

:: Проверка, определены ли переменные после выполнения Updater.bat
if not defined UPDVER (
    echo [ERROR] %TIME% - Переменная UPDVER не определена после выполнения Updater.bat >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto loading_procces
)

if not defined VersionNumberList (
    echo [ERROR] %TIME% - Переменная VersionNumberList не определена после выполнения Updater.bat >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto loading_procces
)

:: Проверка, изменилась ли версия
echo "%VersionNumberList%" | findstr /i "%VersionNumberCurrent%" >nul
if errorlevel 1 (
    echo [INFO ] %TIME% - Доступно обновление v%UPDVER% >> "%ASX-Directory%\Files\Logs\%date%.txt"    
    goto Update_screen
) else (
    set "VersionFound=1"
    title Загрузка...
    echo [INFO ] %TIME% - Отсутствуют доступные обновления >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto loading_procces
)


:loading_procces
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX" /v "LastLaunchUpdateInstalled" 2^>nul ^| find /i "LastLaunchUpdateInstalled"') do set "ASX_LastLaunchUpdateInstalled=%%b"

if "%ASX_LastLaunchUpdateInstalled%"=="Yes" (
    echo [INFO ] %TIME% - ASX_LastLaunchUpdateInstalled >> "%ASX-Directory%\Files\Logs\%date%.txt"
    reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "DisplayName" /t REG_SZ /d "ASX Hub" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "DisplayVersion" /t REG_SZ /d "%Version%" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "Publisher" /t REG_SZ /d "ALFiX.inc" /f >nul 2>&1
    :: reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "NoModify" /t REG_DWORD /d "1" /f >nul 2>&1
    :: reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "NoRepair" /t REG_DWORD /d "1" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "DisplayIcon" /t REG_SZ /d "%ASX-Directory%\ASX Hub.exe" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "UninstallString" /t REG_SZ /d "%ASX-Directory%\Uninst.exe" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "URLInfoAbout" /t REG_SZ /d "https://github.com/ALFiX01/ASX-Hub" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "HelpLink" /t REG_SZ /d "https://discord.gg/MreKhdN2Ns" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "Contact" /t REG_SZ /d "https://discord.gg/MreKhdN2Ns" /f >nul 2>&1
)

echo %COL%[36m!HiMessage!%COL%[90m
Timeout 1 /nobreak>nul
echo.
echo.
echo.
echo                                                    ASX Hub загружается. Мы ценим ваше терпение.
title Загрузка [1/10]

if "%WiFi%"=="On" (
    echo [INFO ] %TIME% - Проверка отсутствующих компонентов >> "%ASX-Directory%\Files\Logs\%date%.txt"
    set "error_on_loading_1=0"
    if not exist "%ASX-Directory%\Uninst.exe" (
        title Загрузка отсутствующих компонентов...
        echo [INFO ] %TIME% - Загрузка отсутствующего компонента Uninst.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
        curl -g -L -# -o "%ASX-Directory%\Uninst.exe" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Updater/Uninst.exe" >nul 2>&1
        if errorlevel 1 (
           echo [ERROR] %TIME% - Ошибка при загрузке компонента Uninst.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
            set /a "error_on_loading_1+=1"
        )
    )

    if not exist "%ASX-Directory%\Files\Utilites\PyDebloatX\PyDebloatX.exe" (
        title Загрузка отсутствующих компонентов...
        echo [INFO ] %TIME% - Загрузка отсутствующего компонента PyDebloatX.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
        if not exist "%ASX-Directory%\Files\Utilites\PyDebloatX" (
            md "%ASX-Directory%\Files\Utilites\PyDebloatX" >nul 2>&1
        )
        curl -g -L -# -o "%ASX-Directory%\Files\Utilites\PyDebloatX\PyDebloatX.exe" "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Utilities/PyDebloatX/PyDebloatX.exe" >nul 2>&1
        if errorlevel 1 (
            echo [ERROR] %TIME% - Ошибка при загрузке компонента PyDebloatX.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
            set /a "error_on_loading_1+=1"
        )
    )

    if not exist "%ASX-Directory%\Files\Resources\notification.exe" (
        title Загрузка отсутствующих компонентов...
        echo [INFO ] %TIME% - Загрузка отсутствующего компонента notification.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
        if not exist "%ASX-Directory%\Files\Resources" (
            md "%ASX-Directory%\Files\Resources" >nul 2>&1
        )
        curl -g -L -# -o "%ASX-Directory%\Files\Resources\notification.exe" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Other/notification.exe" >nul 2>&1
        if errorlevel 1 (
            echo [ERROR] %TIME% - Ошибка при загрузке компонента notification.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
            set /a "error_on_loading_1+=1"
        )
    )

REM     if not exist "%ASX-Directory%\Files\Utilites\ASX_DriverFinder\DriverFinder.exe" (
REM         title Загрузка отсутствующих компонентов...
REM         echo [INFO ] %TIME% - Загрузка отсутствующего компонента DriverFinder.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
REM         if not exist "%ASX-Directory%\Files\Utilites\ASX_DriverFinder" (
REM             md "%ASX-Directory%\Files\Utilites\ASX_DriverFinder" >nul 2>&1
REM         )
REM         curl -g -L -# -o "%ASX-Directory%\Files\Utilites\ASX_DriverFinder\DriverFinder.exe" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Utilities/ASX_DriverFinder/DriverFinder.exe" >nul 2>&1
REM         curl -g -L -# -o "%ASX-Directory%\Files\Utilites\ASX_DriverFinder\DriverFinder_FindService.exe" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Utilities/ASX_DriverFinder/DriverFinder_FindService.exe" >nul 2>&1
REM         if errorlevel 1 (
REM             echo [ERROR] %TIME% - Ошибка при загрузке компонентов DriverFinder >> "%ASX-Directory%\Files\Logs\%date%.txt"
REM             set /a "error_on_loading_1+=1"
REM         )
REM     )

    title Загрузка...
)

echo [INFO ] %TIME% - Количество ошибок при загрузке компонентов: %error_on_loading_1% >> "%ASX-Directory%\Files\Logs\%date%.txt"

rem Получаем количество букв в переменной (более простой и надежный метод)
set "length=0"
if defined CustomUserName (
  for /L %%i in (0,1,100) do (
    if "!CustomUserName:~%%i,1!" NEQ "" (
      set /a "length+=1"
    ) else (
      goto :length_calculated
    )
  )
)
:length_calculated
echo [INFO ] %TIME% - Количество символов в CustomUserName: %length% >> "%ASX-Directory%\Files\Logs\%date%.txt"

rem Проверка на пустое значение CustomUserName
if %length% EQU 0 (
  set "CustomUserName=User"
  reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /t REG_SZ /v "CustomUserName" /d "User" /f >nul 2>&1
  echo [WARN ] %TIME% - Имя пользователя было пустым, установлено значение по умолчанию >> "%ASX-Directory%\Files\Logs\%date%.txt"
  set "length=4"
)


:: Если количество символов больше 8, оставьте только первые 8 символов
if !length! gtr 7 (
  set "CustomUserName=!CustomUserName:~0,8!..."
  reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /t REG_SZ /v "CustomUserName" /d "!CustomUserName:~0,8!" /f >nul 2>&1  
  set CustomUserNameWarn=1
)


rem Установка ключа Firstlaunch, если он отсутствует
reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Firstlaunch" >nul 2>&1 || reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Firstlaunch" /t REG_SZ /d "Yes" /f >nul 2>&1

title Загрузка [2/10]

set "error_on_loading_2=0"

if /I "%Launch_status%" NEQ "0" ( 
		echo [WARN ] %TIME% - Некорректный запуск ^(%Reason_launch_info%^) >> "%ASX-Directory%\Files\Logs\%date%.txt"
		set /a "error_on_loading_2+=1"
)

echo [INFO ] %TIME% - Количество ошибок при выполнении 2-го этапа загрузки: %error_on_loading_2% >> "%ASX-Directory%\Files\Logs\%date%.txt"

title Загрузка [3/10]

set "error_on_loading_3=0"

echo [INFO ] %TIME% - WiFi - %WiFi% >> "%ASX-Directory%\Files\Logs\%date%.txt"

REM проверка наличия EXE 
if "%WiFi%" == "On" (
    if not exist "%ASX-Directory%\ASX Hub.exe" (
        echo [WARN ] %TIME% - Файл "ASX Hub.exe" отсутствует >> "%ASX-Directory%\Files\Logs\%date%.txt"
        curl -g -L -# -o "%ASX-Directory%\ASX Hub.exe" "https://github.com/ALFiX01/ASX-Hub/releases/latest/download/ASX-Hub.exe" >nul 2>&1
        if errorlevel 1 (
            echo [ERROR] %TIME% - Ошибка при загрузке ASX Hub.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
            set /a "error_on_loading_3+=1"
         ) else (
            echo [INFO ] %TIME% - Файл "ASX Hub.exe" был загружен >> "%ASX-Directory%\Files\Logs\%date%.txt"
            set /a Launch_status+=1
            set "Reason_launch_info=Отсутствует файл ASX Hub.exe"
        )
    )
)

echo [INFO ] %TIME% - Количество ошибок при выполнении 3-го этапа загрузки: %error_on_loading_3% >> "%ASX-Directory%\Files\Logs\%date%.txt"

:loading_procces2

title Загрузка [4/10]

REM проверка наличия папок 👇
set "error_on_loading_4=0"
for %%F in (Resources Logs Downloads Restore) do (
    if not exist "%ASX-Directory%\Files\%%F" (
        mkdir "%ASX-Directory%\Files\%%F" >nul 2>&1
        if errorlevel 1 (
            echo [ERROR] %TIME% - Ошибка при создании подпапки "%%F" >> "%ASX-Directory%\Files\Logs\%date%.txt"
            set /a "error_on_loading_4+=1"
        ) else (
            echo [INFO ] %TIME% - Создание подпапки "%%F" в связи с её отсутствием >> "%ASX-Directory%\Files\Logs\%date%.txt"
        )
    )
)

echo [INFO ] %TIME% - Количество ошибок при выполнении 4-го этапа загрузки: %error_on_loading_4% >> "%ASX-Directory%\Files\Logs\%date%.txt"


title Загрузка [5/10]


set "error_on_loading_5=0"

set "GPU_Brand=Н/Д"
for /f "tokens=2 delims==" %%i in ('wmic path win32_videocontroller get caption /value 2^>nul') do (
    if not "%%i"=="" (
        set "gpu_name=%%i"
        rem Удаляем перенос строки из значения видеокарты
        for /f "delims=" %%j in ("!gpu_name!") do set "gpu_name=%%j"
        echo [INFO ] %TIME% - Обнаружена видеокарта: "!gpu_name!" >> "%ASX-Directory%\Files\Logs\%date%.txt"
        
        echo %%i | findstr /i "NVIDIA" >nul 2>&1
        if !errorlevel! equ 0 (
            set "GPU_Brand=Nvidia"
        ) else (
            echo %%i | findstr /i "AMD ATI Radeon" >nul 2>&1
            if !errorlevel! equ 0 (
                set "GPU_Brand=AMD"
            ) else (
                echo %%i | findstr /i "Intel" >nul 2>&1
                if !errorlevel! equ 0 (
                    set "GPU_Brand=Intel"
                )
            )
        )
    )
)

if "!GPU_Brand!"=="Н/Д" (
    echo [WARN ] %TIME% - Производитель GPU не определен >> "%ASX-Directory%\Files\Logs\%date%.txt"
) else (
    echo [INFO ] %TIME% - Определен производитель GPU: !GPU_Brand! >> "%ASX-Directory%\Files\Logs\%date%.txt"
)

if errorlevel 1 (
    echo [ERROR] %TIME% - Ошибка при получении информации о GPU >> "%ASX-Directory%\Files\Logs\%date%.txt"
    set /a "error_on_loading_5+=1"
)

REM echo [DEBUG] %TIME% - Производитель GPU %GPU_Brand% >> "%ASX-Directory%\Files\Logs\%date%.txt"

REM Проверка и изменение шрифта консоли
reg query "HKEY_CURRENT_USER\Console" /v "FaceName" | findstr /i "Consolas" >nul 2>&1
if %errorlevel% equ 0 (
    reg add "HKEY_CURRENT_USER\Console" /v "FaceName" /t REG_SZ /d "__DefaultTTFont__" /f >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] %TIME% - Ошибка при изменении шрифта консоли >> "%ASX-Directory%\Files\Logs\%date%.txt"
        set /a "error_on_loading_5+=1"
    ) else (
        echo [INFO ] %TIME% - Шрифт консоли изменен с Consolas на __DefaultTTFont__ >> "%ASX-Directory%\Files\Logs\%date%.txt"
        cls
        title Ошибка при запуске ASX Hub
        echo.
        echo.
        echo  Ассистент:
        echo  - Произошла ошибка при запуске ASX Hub. Сейчас я его перезапущу.
        timeout /t 3 /nobreak >nul
        start "" "%ASX-Directory%\ASX Hub.exe"
        exit /b
    )
)


REM Проверка существования ключа Dynamic_System
reg query "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Settings" /v "Dynamic_System" >nul 2>&1
if %errorlevel% equ 0 (
    REM Ключ существует, получение значения
    for /f "tokens=2*" %%a in ('reg query "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Settings" /v "Dynamic_System" ^| findstr /i "Dynamic_System"') do (
        set "Dynamic_System=%%b"
        echo [INFO ] %TIME% - Получено значение ключа Dynamic_System: %%b >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
    if errorlevel 1 (
        echo [ERROR] %TIME% - Ошибка при получении значения ключа Dynamic_System >> "%ASX-Directory%\Files\Logs\%date%.txt"
        set /a "error_on_loading_5+=1"
        set "Dynamic_System=On"
    )
) else (
    REM Ключ не существует, создание с дефолтным значением
    reg add "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Settings" /v "Dynamic_System" /t REG_SZ /d "On" /f >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] %TIME% - Ошибка при создании ключа реестра Dynamic_System >> "%ASX-Directory%\Files\Logs\%date%.txt"
        set /a "error_on_loading_5+=1"
        set "Dynamic_System=On"
    ) else (
        set "Dynamic_System=On"
        echo [INFO ] %TIME% - Создан новый ключ реестра Dynamic_System со значением On >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)
echo [INFO ] %TIME% - Количество ошибок при выполнении 5-го этапа загрузки: %error_on_loading_5% >> "%ASX-Directory%\Files\Logs\%date%.txt"

title Загрузка [6/10]
set "error_on_loading_6=0"


REM Проверка существования ключа AutoControlDirectory
reg query "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Settings" /v "AutoControlDirectory" >nul 2>&1
if %errorlevel% equ 0 (
    REM Ключ существует, получение значения
    for /f "tokens=2*" %%a in ('reg query "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Settings" /v "AutoControlDirectory" ^| findstr /i "AutoControlDirectory"') do (
        set "AutoControlDirectory=%%b"
        echo [INFO ] %TIME% - Получено значение ключа AutoControlDirectory: %%b >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
    if errorlevel 1 (
        echo [ERROR] %TIME% - Ошибка при получении значения ключа AutoControlDirectory >> "%ASX-Directory%\Files\Logs\%date%.txt"
        set /a "error_on_loading_6+=1"
        set "AutoControlDirectory=On"
    )
) else (
    REM Ключ не существует, создание с дефолтным значением
    reg add "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Settings" /v "AutoControlDirectory" /t REG_SZ /d "On" /f >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] %TIME% - Ошибка при создании ключа реестра AutoControlDirectory >> "%ASX-Directory%\Files\Logs\%date%.txt"
        set /a "error_on_loading_6+=1"
        set "AutoControlDirectory=On"
    ) else (
        set "AutoControlDirectory=On"
        echo [INFO ] %TIME% - Создан новый ключ реестра AutoControlDirectory со значением On >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

REM Проверка размера директории Files
for /f "tokens=3" %%a in ('dir /s /-c "%ASX-Directory%\Files" ^| findstr "bytes"') do set "size_in_bytes=%%a"
set /a "size_in_mb=%size_in_bytes:~0,-3%/1024"

if /i "%AutoControlDirectory%"=="On" ( 
    set "AutoControlDirectory=%COL%[92mВКЛ "
    REM echo [DEBUG] %TIME% - No-skip_AutoControlDirectory >> "%ASX-Directory%\Files\Logs\%date%.txt"
    if %size_in_mb% leq 1000 (
        REM echo [DEBUG] %TIME% - skip_AutoControlDirectory - %size_in_mb% >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto skip_AutoControlDirectory
    ) 
) else ( 
    set "AutoControlDirectory=%COL%[91mВЫКЛ"
    REM echo [DEBUG] %TIME% - skip_AutoControlDirectory >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto skip_AutoControlDirectory
)

:: Удаляем файлы логов старше указанного в реестре количества дней и логируем
( 
forfiles -p "%ASX-Directory%\Files\Logs" -s -m *.* -d -30 -c "cmd /c del /Q @path && echo [INFO ] %TIME% - Файл @path был удален для оптимизации директории ASX >> "%ASX-Directory%\Files\Logs\%date%.txt" 
) >nul 2>&1

:: Удаляем папки логов старше 15 дней, включая их содержимое, и логируемforfiles -p "%ASX-Directory%\Files\Logs" -s -d -15 -c "cmd /c if @isdir==TRUE (rd /s /q @path && echo [INFO ] %TIME% - Папка @path была удалена для оптимизации директории ASX >> "%ASX-Directory%\Files\Logs\%date%.txt" || echo [ERROR] %TIME% - Ошибка при удалении папки @path из "%ASX-Directory%\Files\Logs" >> "%ASX-Directory%\Files\Logs\%date%.txt")" 2>nul

:: Проверяем и удаляем пустые папки
for /d %%D in ("%ASX-Directory%\Files\Logs\*") do (
    dir /b /a "%%D" | findstr "^" >nul || (
        rd /s /q "%%D" >nul 2>&1
        if not exist "%%D" (
            echo [INFO ] %TIME% - Удалена пустая папка "%%D" >> "%ASX-Directory%\Files\Logs\%date%.txt"
        ) else (
            echo [ERROR] %TIME% - Ошибка при удалении пустой папки "%%D" >> "%ASX-Directory%\Files\Logs\%date%.txt"
            set /a "error_on_loading_6+=1"
        )
    )
)

for %%F in (%ASX-Directory%\Files\Logs\*) do (
    if "%%F" neq "%ASX-Directory%\Files\Logs\%date%.txt" (
        if %%~zF LSS 2000 (
            del "%%F" >nul 2>&1
            if errorlevel 1 (
                echo [ERROR] %TIME% - Ошибка при удалении файла "%%F" >> "%ASX-Directory%\Files\Logs\%date%.txt"
                set /a "error_on_loading_4+=1"
            ) else (
                echo [INFO ] %TIME% - Файл "%%F" был удален для оптимизации директории ASX >> "%ASX-Directory%\Files\Logs\%date%.txt"
            )
        )
    )
)

:: Удаляем файлы загрузок старше 14 дней и логируем
( 
forfiles -p "%ASX-Directory%\Files\Downloads" -s -m *.* -d -7 -c "cmd /c del /Q @path && echo [INFO ] %TIME% - Файл @path был удален для оптимизации директории ASX >> "%ASX-Directory%\Files\Logs\%date%.txt" 
) >nul 2>&1

:: Удаляем папки загрузок старше 14 дней, включая их содержимое, и логируем
REM forfiles -p "%ASX-Directory%\Files\Downloads" -s -d -14 -c "cmd /c if @isdir==TRUE (rd /s /q @path && echo [INFO ] %TIME% - Папка @path была удален для оптимизации директории ASX >> "%ASX-Directory%\Files\Logs\%date%.txt" || echo [ERROR] %TIME% - Ошибка при удалении папки @path из "%ASX-Directory%\Files\Downloads" >> "%ASX-Directory%\Files\Logs\%date%.txt")" 2>nul
(
forfiles -p "%ASX-Directory%\Files\Downloads" -s -d -7 -c "cmd /c if @isdir==TRUE (rd /s /q @path && echo [INFO ] %TIME% - Папка @path была удалена для оптимизации директории ASX >> "%ASX-Directory%\Files\Logs\%date%.txt"
) >nul 2>&1

:: Удаляем пустые папки в директории Downloads - TEST
for /d /r "%ASX-Directory%\Files\Downloads" %%d in (*) do (
    (
    forfiles /p "%%d" /d -7 /c "cmd /c if @isdir==TRUE (rd /s /q @path && echo [INFO ] %TIME% - Папка @path была удалена для оптимизации директории ASX >> "%ASX-Directory%\Files\Logs\%date%.txt" 
    ) >nul 2>&1
)

echo [INFO ] %TIME% - Количество ошибок при выполнении 6-го этапа загрузки: %error_on_loading_6% >> "%ASX-Directory%\Files\Logs\%date%.txt"

title Загрузка [7/10]

:: Проверяем и удаляем пустые папки загрузок
set /a error_on_loading_7=0
for /d %%D in ("%ASX-Directory%\Files\Downloads\*") do (
    dir /b /a "%%D" | findstr "^" >nul || (
        rd /s /q "%%D" >nul 2>&1
        if not exist "%%D" (
            echo [INFO ] %TIME% - Удалена пустая папка "%%D" >> "%ASX-Directory%\Files\Logs\%date%.txt"
        ) else (
            echo [ERROR] %TIME% - Ошибка при удалении пустой папки "%%D" >> "%ASX-Directory%\Files\Logs\%date%.txt"
            set /a error_on_loading_7+=1
        )
    )
)

:: Проверяем и удаляем пустые папки
for /d %%D in ("%ASX-Directory%\Files\Restore\*") do (
    dir /b /a "%%D" | findstr "^" >nul || (
        rd /s /q "%%D" >nul 2>&1
        if not exist "%%D" (
            echo [INFO ] %TIME% - Папка "%%D" была удалена для оптимизации директории ASX >> "%ASX-Directory%\Files\Logs\%date%.txt"
        ) else (
            echo [ERROR] %TIME% - Ошибка при удалении пустой папки "%%D" >> "%ASX-Directory%\Files\Logs\%date%.txt"
            set /a error_on_loading_7+=1
        )
    )
)

:skip_AutoControlDirectory

echo [INFO ] %TIME% - Количество ошибок при выполнении 7-го этапа загрузки: %error_on_loading_7% >> "%ASX-Directory%\Files\Logs\%date%.txt"

:: Суммируем ошибки загрузки
set /a total_errors=error_on_setup + error_on_loading_1 + error_on_loading_2 + error_on_loading_3 + error_on_loading_4 + error_on_loading_5 + error_on_loading_6 + error_on_loading_7

if %total_errors% GTR 0 (
    echo [WARN ] %TIME% - При загрузке обнаружены ошибки. Общее количество: %total_errors% >> "%ASX-Directory%\Files\Logs\%date%.txt"
)


if "%firstlaunch_dynamic_on%" NEQ "0" ( call :Dynamic )

for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" 2^>nul ^| find /i "Directory"') do set "ASX-Directory=%%b"

REM Попытка включить WMIC
REM dism /online /enable-feature /featurename:MicrosoftWindowsWMICore /NoRestart >nul 2>&1

title Загрузка [8/10]

REM TESTING
reg query "%SaveData%\Info" /v "WinVer" >nul 2>&1
if errorlevel 1 (
    REM Переключаемся на кодовую страницу, поддерживающую символы Unicode
    chcp 850 >nul 2>&1
    for /f "usebackq delims=" %%a in (`powershell -Command "(Get-CimInstance Win32_OperatingSystem).Caption"`) do (
        chcp 65001 >nul 2>&1    
        set "WinVersion=%%a"

        REM Проверяем, является ли система Windows 11
        echo !WinVersion! | find /i "Windows 11" >nul
        if not errorlevel 1 (
            set "WinVer=Windows 11"
            reg add "%SaveData%\Info" /t REG_SZ /v "WinVer" /d "Windows 11" /f >nul 2>&1
        ) else (
            REM Проверяем, является ли система Windows 10
            echo !WinVersion! | find /i "Windows 10" >nul
            if not errorlevel 1 (
                set "WinVer=Windows 10"
                reg add "%SaveData%\Info" /t REG_SZ /v "WinVer" /d "Windows 10" /f >nul 2>&1
            ) else (
                REM Если система не Windows 10 и не Windows 11, помечаем как неподдерживаемую
                set "WinVer=Unsupported"
                reg add "%SaveData%\Info" /t REG_SZ /v "WinVer" /d "Unsupported" /f >nul 2>&1
            )
        )
    )
) else (
    REM Получаем сохраненную версию Windows из реестра
    for /f "tokens=2*" %%a in ('reg query "%SaveData%\Info" /v "WinVer" 2^>nul ^| find /i "WinVer"') do (
        set "WinVer=%%b"
    )
)

if "%WinVer%"=="Unsupported" (
    cls
    echo.
    echo   %COL%[37mВаша Windows не соответствует нашим требованиям.
    echo   %COL%[91mASX Hub может быть запущен только на Windows 10 или 11.%COL%[37m
    echo.
    echo [ERROR] %TIME% - Версия Windows не соответствует требованиям >> "%ASX-Directory%\Files\Logs\%date%.txt"
    reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Firstlaunch" /t REG_SZ /d "Yes" /f >nul 2>&1
    pause >nul
    exit
)

title Загрузка [9/10]

:CheckS
if /i "!screen!" neq "Disclaimer" (
	echo [INFO ] %TIME% - Перенаправлено на панель MainMenu >> "%ASX-Directory%\Files\Logs\%date%.txt"
	goto MainMenu 
) else (
    REM Создание ярлыков
    chcp 850 >nul 2>&1
    powershell -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%SystemDrive%\Windows\ASX Hub.lnk'); $s.TargetPath = '%ASX-Directory%\ASX Hub.exe'; $s.Save()"
    powershell -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%SystemDrive%\Windows\ASX.lnk'); $s.TargetPath = '%ASX-Directory%\ASX Hub.exe'; $s.Save()"
    powershell -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%SystemDrive%\Windows\ASXdir.lnk'); $s.TargetPath = '%ASX-Directory%\'; $s.Save()"
    chcp 65001 >nul 2>&1
    reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Firstlaunch" /t REG_SZ /d "No" /f >nul 2>&1
    call:MainMenu
)


:MainMenu

set "InfoLine=Дата: %Date%                                  [1 / 1]                              Пользователь: %CustomUserName%"

rem Найдем длину строки InfoLine
set "length=0"
for /L %%i in (0,1,146) do (
    set "char=!InfoLine:~%%i,1!"
    if "!char!"=="" goto end
    set /A length+=1
)
:end

rem Рассчитаем количество пробелов для выравнивания по центру
set /A spaces=(146-length)/2

rem Создадим строку с пробелами
set /A spaces-=1
set "padding="
for /L %%i in (1,1,%spaces%) do set "padding=!padding! "

rem Добавим пробелы перед InfoLine
set "InfoLine=!padding!!InfoLine!"

cls
FOR /F %%A in ('"PROMPT $H&FOR %%B in (1) DO REM"') DO SET "BS=%%A"
TITLE Главное  меню - ASX Hub %Version%
echo [INFO ] %TIME% - Открыта панель ":Main Menu" >> "%ASX-Directory%\Files\Logs\%date%.txt"
mode con: cols=146 lines=45 >nul 2>&1
set PageName=MainMenu
set "errorlevel="
set "choice="
echo.

:: Выводим центрированный текст
echo !padding!%COL%[90mДата: %COL%[96m%Date%%COL%[90m                                  [%COL%[96m1 %COL%[90m/ 1%COL%[90m]                              Пользователь: %COL%[96m%CustomUserName%%COL%[90m

echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
echo.
echo.
if "%Dynamic_st%"=="On" (
    if "%Dynamic_Used%"=="Yes" (
        set "Dynamic_Used=No"
        call:Dynamic
    )
    call:Dynamic_Script
) else (
    echo.
)
echo.
echo.
echo.
echo.
echo                                         %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Твики                                      %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Программы
echo.
echo.
echo.
echo                                         %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m Веб-ресурсы                                %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m Утилиты
echo.
echo.
echo.
echo                                         %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m Информация                                 %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m Настройки%COL%[90m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
%SYSTEMROOT%\System32\choice.exe /c:123456СCXчRкKлFаLдi /n /m "%DEL%                                                                      >: " 
set choice=%errorlevel%
if "%choice%"=="1" ( set "history=MainMenu;!history!" && goto TweaksPanel )
REM if "%choice%"=="1" (set "history=MainMenu;!history!" && goto Complete_notice )
if "%choice%"=="2" ( set "history=MainMenu;!history!" && goto AppPanel )
if "%choice%"=="3" ( set "history=MainMenu;!history!" && goto WebResources )
if "%choice%"=="4" ( set "history=MainMenu;!history!" && goto ASX_Utilites )
if "%choice%"=="5" ( set "history=MainMenu;!history!" && goto ASX_Information_UpdateCheck )
if "%choice%"=="6" ( set "history=MainMenu;!history!" && goto ASX_settings )
if "%choice%"=="7" ( set "history=MainMenu;!history!" && goto ASX_CMD )
if "%choice%"=="8" ( set "history=MainMenu;!history!" && goto ASX_CMD )
if "%choice%"=="9" exit
if "%choice%"=="10" exit
if "%choice%"=="11" goto MainMenu
if "%choice%"=="12" goto MainMenu
if "%choice%"=="13" goto RR
if "%choice%"=="14" goto RR

if defined RecomendedPanelNameGOTO (
    if "%choice%"=="15" (set "history=MainMenu;!history!" && set "Dynamic_Used=Yes" && goto %RecomendedPanelNameGOTO% )
    if "%choice%"=="16" (set "history=MainMenu;!history!" && set "Dynamic_Used=Yes" && goto %RecomendedPanelNameGOTO% )
)

if "%choice%"=="17" ( goto OnlineLogs )
if "%choice%"=="18" ( goto OnlineLogs )

goto MainMenu

:OnlineLogs
if exist "%ASX-Directory%\Files\Resources\Log_online.exe" (
    start "ASX Logs" "%ASX-Directory%\Files\Resources\Log_online.exe"
) else (
    echo [ERROR] %TIME% - Log_online.exe not found >> "%ASX-Directory%\Files\Logs\%date%.txt"
    curl -g -L -# -o "%ASX-Directory%\Files\Resources\Log_online.exe" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Scripts/Log_Online.exe" >nul 2>&1
    start "ASX Logs" "%ASX-Directory%\Files\Resources\Log_online.exe"
)
goto MainMenu

:TweaksPanel
cls
TITLE Твики - ASX Hub
echo [INFO ] %TIME% - Открыта панель ":TweaksPanel" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=TweaksPanel
echo.
echo.
echo.
echo                                       %COL%[90m:::::::::::  :::       :::  ::::::::::      :::      :::    :::  ::::::::
echo                                          :+:      :+:       :+:  :+:           :+: :+:    :+:   :+:  :+:    :+:
echo                                         +:+      +:+       +:+  +:+          +:+   +:+   +:+  +:+   +:+
echo                                        +#+      +#+  +:+  +#+  +#++:++#    +#++:++#++:  +#++:++    +#++:++#++
echo                                       +#+      +#+ +#+#+ +#+  +#+         +#+     +#+  +#+  +#+         +#+
echo                                      #+#       #+#+# #+#+#   #+#         #+#     #+#  #+#   #+#  #+#    #+#
echo                                     ###        ###   ###    ##########  ###     ###  ###    ###  ########
echo.
echo.
echo.
echo.
echo.
echo                                                           %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Оптимизация и настройка
echo.
echo.
echo                                                           %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Конфиденциальность
echo.
echo.
echo                                                           %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m Контекстное меню
echo.
echo.
echo                                                           %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m Кастомизация
echo.
echo.
echo                                                           %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m Службы
echo.
echo.
echo                                                           %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m Экспериментальные
echo.
echo.
echo                                                           %COL%[96m[%COL%[37m 7 %COL%[96m]%COL%[37m Исправление проблем
echo.
echo.
echo.
echo.
echo.
echo                                                      %COL%[90m[ F - Быстрая настройка ^(В разработке^) ]
echo.
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
set choice=NoInput
set /p choice="%DEL%                                                                      >: "

if /i "%choice%"=="1" ( set "history=TweaksPanel;!history!" && set Ram_check_count=0 && goto OptimizationCenterPG1 )
if /i "%choice%"=="2" ( set "history=TweaksPanel;!history!" && goto Privacy )
if /i "%choice%"=="3" ( set "history=TweaksPanel;!history!" && goto EditContextMenu )
if /i "%choice%"=="4" ( set "history=TweaksPanel;!history!" && goto WinCustomization )
if /i "%choice%"=="5" ( set "history=TweaksPanel;!history!" && goto Services )
if /i "%choice%"=="6" ( set "history=TweaksPanel;!history!" && goto Exp_tweaks_warn )
if /i "%choice%"=="7" ( set "history=TweaksPanel;!history!" && goto FixProblemPanel )

if /i "%choice%"=="F" ( set "history=TweaksPanel;!history!" && goto FastOpimizePage )
if /i "%choice%"=="а" ( set "history=TweaksPanel;!history!" && goto FastOpimizePage )

if /i "%choice%"=="C" ( set "history=TweaksPanel;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=TweaksPanel;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=TweaksPanel;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=TweaksPanel;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="NoInput" goto WrongInput
goto TweaksPanel


:FastOpimizePage
cls

:: Создание директории, если её нет
if not exist "%ASX-Directory%\Files\Resources\FastOptimizeScripts" ( 
    echo  Отсутствуют необходимые компоненты. Выполняю загрузку...
    echo.
    mkdir "%ASX-Directory%\Files\Resources\FastOptimizeScripts"
)

:: Список файлов
set "files=ASX-Power.bat Cortana.bat StickyKeys.bat Mouse.bat Wallpaper.bat GameBar.bat ContextMenu.bat UAC.bat SmartScreenNotification.bat WindowsDefenderNotification.bat Clipboard.bat Spectre-Meldown-DownFall.bat MapAutoUpdate.bat"

:: Проверка существования файлов и загрузка отсутствующих
for %%f in (%files%) do (
    if not exist "%ASX-Directory%\Files\Resources\FastOptimizeScripts\%%f" (
        echo  Загрузка: %%f
        curl -g -L -# -o "%ASX-Directory%\Files\Resources\FastOptimizeScripts\%%f" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Resources/FastOptimizeScripts/%%f" >nul 2>&1
    )
)

cls
echo Анализ системы...
TITLE Быстрая оптимизация Windows - ASX Hub
echo [INFO ] %TIME% - Открыта панель ":FastOpimizePage" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set "choice="
set PageName=FastOpimizePage

set "OptimizationStatusCount=1"

if "%WinVer%"=="Windows 11" (
    set "Yes-Icon=✔︎"
    set "No-Icon=✖︎"
) else (
    set "Yes-Icon=+"
    set "No-Icon=-"
)

REM Проверка активного плана электропитания
powercfg /GetActiveScheme | findstr /i "ASX" >nul 2>&1 && (
	set "ASXPW=%COL%[92mВКЛ "
	set "AUTO_OPT1=%COL%[90m%No-Icon%"
) || (
	set "ASXPW=%COL%[91mВЫКЛ"
	set "AUTO_OPT1=%Yes-Icon%"
)
	
REM Проверка отключения Cortana
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" | find "0x0" >nul 2>&1 && (
    set "DSCR=%COL%[91mВЫКЛ"
	set "AUTO_OPT2=%COL%[90m%No-Icon%"
    set /A OptimizationStatusCount+=1
) || (
	set "DSCR=%COL%[92mВКЛ "
	set "AUTO_OPT2=%Yes-Icon%"
)

REM Проверка отключения залипания клавиш
reg query "HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys" /v "Flags" | find "506" >nul 2>&1 && (
    set "DSKN=%COL%[91mВЫКЛ"
	set "AUTO_OPT3=%COL%[90m%No-Icon%"
    set /A OptimizationStatusCount+=1
) || (
	set "DSKN=%COL%[92mВКЛ "
	set "AUTO_OPT3=%Yes-Icon%"
)

REM Проверка повышенной точности установки указателя мыши
reg query "HKCU\Control Panel\Mouse" /v "MouseSpeed" | find "0" >nul 2>&1 && (
        set "MOAC=%COL%[91mВЫКЛ"
        set "AUTO_OPT4=%COL%[90m%No-Icon%"
        set /A OptimizationStatusCount+=1
) || (
        set "MOAC=%COL%[92mВКЛ "
        set "AUTO_OPT4=%Yes-Icon%"
)

REM Проверка сжатия обоев рабочего стола
reg query "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" | find "0x100" >nul 2>&1 && (
	set "DWLC=%COL%[91mВЫКЛ"
	set "AUTO_OPT5=%COL%[90m%No-Icon%"
    set /A OptimizationStatusCount+=1
) || (
	set "DWLC=%COL%[92mВКЛ "
	set "AUTO_OPT5=%Yes-Icon%"
)

reg query "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" | find "0x1" >nul 2>&1 && (
	set "FSOOF=%COL%[92mВКЛ "
	set "AUTO_OPT6=%Yes-Icon%"
) || (
	set "FSOOF=%COL%[91mВЫКЛ"
	set "AUTO_OPT6=%COL%[90m%No-Icon%"
    set /A OptimizationStatusCount+=1
)

if "%WinVer%"=="Windows 11" (
    reg query "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" >nul 2>&1
    if errorlevel 1 (
        set "OldContMenuWindows=%COL%[91mВЫКЛ"
        set "AUTO_OPT7=%Yes-Icon%"
    ) else (
        set "OldContMenuWindows=%COL%[92mВКЛ "
        set "AUTO_OPT7=%COL%[90m%No-Icon%"
        set /A OptimizationStatusCount+=1
    )
) else (
    set "OldContMenuWindows=%COL%[91mБлок"
    set "AUTO_OPT7=%COL%[90m%No-Icon%"
    set /A OptimizationStatusCount+=1
)

REM Проверка состояния UAC (Контроль учетных записей пользователей)
for /f "tokens=3" %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" 2^>nul') do (
	if "%%A"=="0x0" (
		set "UACS=%COL%[91mВЫКЛ"
		set "AUTO_OPT8=%COL%[90m%No-Icon%"
        set /A OptimizationStatusCount+=1
	) else (
		set "UACS=%COL%[92mВКЛ "
		set "AUTO_OPT8=%Yes-Icon%"
	)
)

REM Проверка отключения уведомлений о запуске приложений
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Security" /v "DisableSecuritySettingsCheck" | findstr /i "0x1" >nul 2>&1 && (
	set "APSN=%COL%[91mВЫКЛ"
	set "AUTO_OPT9=%COL%[90m%No-Icon%"
    set /A OptimizationStatusCount+=1
) || (
	set "APSN=%COL%[92mВКЛ "
	set "AUTO_OPT9=%Yes-Icon%"
)

REM Проверка отключения уведомлений Windows Defender
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" | findstr /i "0x0" >nul 2>&1 && (
	set "WDNT=%COL%[91mВЫКЛ"
	set "AUTO_OPT10=%COL%[90m%No-Icon%"
    set /A OptimizationStatusCount+=1
) || (
	set "WDNT=%COL%[92mВКЛ "
	set "AUTO_OPT10=%Yes-Icon%"
)


REM Проверка Журнала буфера обмена
reg query "HKEY_CURRENT_USER\Software\Microsoft\Clipboard" /v "EnableClipboardHistory" | find "0x1" >nul 2>&1 && (
	set "ECHR=%COL%[92mВКЛ "
	set "AUTO_OPT11=%COL%[90m%No-Icon%"
    set /A OptimizationStatusCount+=1
) || (
	set "ECHR=%COL%[91mВЫКЛ"
	set "AUTO_OPT11=%Yes-Icon%"
)

REM Проверка Spectre, Meldown, DownFall
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" | find "0x1" >nul 2>&1 && (
	set "SMTSX=%COL%[91mВЫКЛ"
	set "AUTO_OPT12=%COL%[90m%No-Icon%"
    set /A OptimizationStatusCount+=1
) || (
	set "SMTSX=%COL%[92mВКЛ "
	set "AUTO_OPT12=%Yes-Icon%"
)

REM Проверка Автообновления карт
reg query "HKEY_LOCAL_MACHINE\SYSTEM\Maps" /v "AutoUpdateEnabled" | findstr /i "0x0" >nul 2>&1 && (
	set "AUMS=%COL%[91mВЫКЛ"
	set "AUTO_OPT13=%COL%[90m%No-Icon%"
    set /A OptimizationStatusCount+=1
) || (
	set "AUMS=%COL%[92mВКЛ "
	set "AUTO_OPT13=%Yes-Icon%"
)

:ShowOptimizationStatus
set /A OptimizationPercent=OptimizationStatusCount*100/11

if %OptimizationPercent% GEQ 90 (
    set "OptimizationLevel=%COL%[92mПревосходное"
) else if %OptimizationPercent% GEQ 75 (
    set "OptimizationLevel=%COL%[92mОтличное"
) else if %OptimizationPercent% GEQ 60 (
    set "OptimizationLevel=%COL%[93mХорошее"
) else if %OptimizationPercent% GEQ 45 (
    set "OptimizationLevel=%COL%[33mВыше среднего"
) else if %OptimizationPercent% GEQ 30 (
    set "OptimizationLevel=%COL%[33mСреднее"
) else if %OptimizationPercent% GEQ 15 (
    set "OptimizationLevel=%COL%[91mНизкое"
) else if %OptimizationPercent% GEQ 5 (
    set "OptimizationLevel=%COL%[90mОчень низкое"
) else (
    set "OptimizationLevel=%COL%[90mКритическое"
)
cls

echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
echo.
echo                                                         %COL%[90mПанель находится в тестовом режиме.
echo.
echo.
echo  %COL%[37mТекущее состояние оптимизации %COL%[94m%OptimizationLevel%%COL%[37m:
echo.
echo   1. %COL%[94m[%AUTO_OPT1%%COL%[94m]%COL%[37m План электропитания ASX: %COL%[90m[Сейчас: %ASXPW%%COL%[90m]%COL%[37m
echo   2. %COL%[94m[%AUTO_OPT2%%COL%[94m]%COL%[37m Cortana: %COL%[37m%COL%[90m[Сейчас: %DSCR%%COL%[90m]%COL%[37m
echo   3. %COL%[94m[%AUTO_OPT3%%COL%[94m]%COL%[37m Залипание клавиш: %COL%[37m%COL%[90m[Сейчас: %DSKN%%COL%[90m]%COL%[37m

echo   4. %COL%[94m[%AUTO_OPT4%%COL%[94m]%COL%[37m Повышенная точность установки указателя мыши: %COL%[90m[Сейчас: %MOAC%%COL%[90m]%COL%[37m

echo   5. %COL%[94m[%AUTO_OPT5%%COL%[94m]%COL%[37m Сжатия обоев рабочего стола: %COL%[90m[Сейчас: %DWLC%%COL%[90m]%COL%[37m
echo   6. %COL%[94m[%AUTO_OPT6%%COL%[94m]%COL%[37m FSO и GameBar: %COL%[90m[Сейчас: %FSOOF%%COL%[90m]%COL%[37m
echo   7. %COL%[94m[%AUTO_OPT7%%COL%[94m]%COL%[37m Контекстное меню win10: %COL%[90m[Сейчас: %OldContMenuWindows%%COL%[90m]%COL%[37m
echo   8. %COL%[94m[%AUTO_OPT8%%COL%[94m]%COL%[37m Контроль учётных записей пользователей ^(UAC^): %COL%[90m[Сейчас: %UACS%%COL%[90m]%COL%[37m
echo   9. %COL%[94m[%AUTO_OPT9%%COL%[94m]%COL%[37m Уведомления о запуске приложений: %COL%[90m[Сейчас: %APSN%%COL%[90m]%COL%[37m
echo  10. %COL%[94m[%AUTO_OPT10%%COL%[94m]%COL%[37m Уведомлений Windows Defender: %COL%[90m[Сейчас: %WDNT%%COL%[90m]%COL%[37m
echo  11. %COL%[94m[%AUTO_OPT11%%COL%[94m]%COL%[37m Журнал буфера обмена: %COL%[90m[Сейчас: %ECHR%%COL%[90m]%COL%[37m
echo  12. %COL%[94m[%AUTO_OPT12%%COL%[94m]%COL%[37m Spectre, Meldown, DownFall: %COL%[90m[Сейчас: %SMTSX%%COL%[90m]%COL%[37m
echo  13. %COL%[94m[%AUTO_OPT13%%COL%[94m]%COL%[37m Автообновление карт: %COL%[90m[Сейчас: %AUMS%%COL%[90m]%COL%[37m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo  %COL%[90m▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬
echo  %COL%[94m[%COL%[94m%Yes-Icon%%COL%[94m]%COL%[37m — Пункт будет изменён при оптимизации
echo  %COL%[94m[%COL%[90m%No-Icon%%COL%[94m]%COL%[37m — Пункт останется без изменений
echo.
echo.
echo.
echo                       %COL%[90mВведите номер пункта для изменения статуса авто-оптимизации или введите START для начала оптимизации%COL%[37m
echo.
set /p choice="%DEL%                                                                      >: "
echo.
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="ч" goto MainMenu

if "%choice%"=="1" ( if "%AUTO_OPT1%"=="%Yes-Icon%" (set "AUTO_OPT1=%COL%[90m%No-Icon%") else (set "AUTO_OPT1=%Yes-Icon%")) & goto ShowOptimizationStatus
if "%choice%"=="2" ( if "%AUTO_OPT2%"=="%Yes-Icon%" (set "AUTO_OPT2=%COL%[90m%No-Icon%") else (set "AUTO_OPT2=%Yes-Icon%")) & goto ShowOptimizationStatus
if "%choice%"=="3" ( if "%AUTO_OPT3%"=="%Yes-Icon%" (set "AUTO_OPT3=%COL%[90m%No-Icon%") else (set "AUTO_OPT3=%Yes-Icon%")) & goto ShowOptimizationStatus
if "%choice%"=="4" ( if "%AUTO_OPT4%"=="%Yes-Icon%" (set "AUTO_OPT4=%COL%[90m%No-Icon%") else (set "AUTO_OPT4=%Yes-Icon%")) & goto ShowOptimizationStatus
if "%choice%"=="5" ( if "%AUTO_OPT5%"=="%Yes-Icon%" (set "AUTO_OPT5=%COL%[90m%No-Icon%") else (set "AUTO_OPT5=%Yes-Icon%")) & goto ShowOptimizationStatus
if "%choice%"=="6" ( if "%AUTO_OPT6%"=="%Yes-Icon%" (set "AUTO_OPT6=%COL%[90m%No-Icon%") else (set "AUTO_OPT6=%Yes-Icon%")) & goto ShowOptimizationStatus
if "%choice%"=="7" ( if "%AUTO_OPT7%"=="%Yes-Icon%" (set "AUTO_OPT7=%COL%[90m%No-Icon%") else (set "AUTO_OPT7=%Yes-Icon%")) & goto ShowOptimizationStatus
if "%choice%"=="8" ( if "%AUTO_OPT8%"=="%Yes-Icon%" (set "AUTO_OPT8=%COL%[90m%No-Icon%") else (set "AUTO_OPT8=%Yes-Icon%")) & goto ShowOptimizationStatus
if "%choice%"=="9" ( if "%AUTO_OPT9%"=="%Yes-Icon%" (set "AUTO_OPT9=%COL%[90m%No-Icon%") else (set "AUTO_OPT9=%Yes-Icon%")) & goto ShowOptimizationStatus
if "%choice%"=="10" ( if "%AUTO_OPT10%"=="%Yes-Icon%" (set "AUTO_OPT10=%COL%[90m%No-Icon%") else (set "AUTO_OPT10=%Yes-Icon%")) & goto ShowOptimizationStatus
if "%choice%"=="11" ( if "%AUTO_OPT10%"=="%Yes-Icon%" (set "AUTO_OPT11=%COL%[90m%No-Icon%") else (set "AUTO_OPT11=%Yes-Icon%")) & goto ShowOptimizationStatus
if "%choice%"=="12" ( if "%AUTO_OPT10%"=="%Yes-Icon%" (set "AUTO_OPT12=%COL%[90m%No-Icon%") else (set "AUTO_OPT12=%Yes-Icon%")) & goto ShowOptimizationStatus
if "%choice%"=="13" ( if "%AUTO_OPT10%"=="%Yes-Icon%" (set "AUTO_OPT13=%COL%[90m%No-Icon%") else (set "AUTO_OPT13=%Yes-Icon%")) & goto ShowOptimizationStatus

if /i "%choice%"=="start" goto StartOptimization
goto ShowOptimizationStatus

:StartOptimization
echo [INFO ] %TIME% - Вызван ":StartOptimization" >> "%ASX-Directory%\Files\Logs\%date%.txt"
cls
echo.
echo Выполняется процесс автоматической оптимизации и настройки...
echo.

REM ASX-Power
if "%AUTO_OPT1%"=="%Yes-Icon%" (
    call :auto_ASX-Power
)

REM Cortana
if "%AUTO_OPT2%"=="%Yes-Icon%" (
    call :auto_Cortana
)

REM StickyKeys
if "%AUTO_OPT3%"=="%Yes-Icon%" (
    call :auto_StickyKeys
)

REM Mouse
if "%AUTO_OPT4%"=="%Yes-Icon%" (
    call :auto_Mouse
)

REM Wallpaper
if "%AUTO_OPT5%"=="%Yes-Icon%" (
    call :auto_Wallpaper
)

REM GameBar
if "%AUTO_OPT6%"=="%Yes-Icon%" (
    call :auto_GameBar
)

REM ContextMenu
if "%WinVer%"=="Windows 11" (
    if "%AUTO_OPT7%"=="%Yes-Icon%" (
        call :auto_ContextMenu
    )
)

REM UAC
if "%AUTO_OPT8%"=="%Yes-Icon%" (
    call :auto_UAC
)

REM SmartScreenNotification
if "%AUTO_OPT9%"=="%Yes-Icon%" (
    call :auto_SmartScreenNotification
)

REM WindowsDefenderNotification
if "%AUTO_OPT10%"=="%Yes-Icon%" (
    call :auto_WindowsDefenderNotification
)

REM Clipboard
if "%AUTO_OPT11%"=="%Yes-Icon%" (
    call :auto_Clipboard
)

REM Spectre, Meldown, DownFall
if "%AUTO_OPT12%"=="%Yes-Icon%" (
    call :auto_Spectre-Meldown-DownFall
)

REM MapAutoUpdate
if "%AUTO_OPT13%"=="%Yes-Icon%" (
    call :auto_MapAutoUpdate
)

echo.
echo %COL%[92m Оптимизация завершена. Нажмите любую клавишу для возврата... %COL%[37m
set "operation_name=Авто-оптимизация"
set "history=FastOpimizePage;!history!" && call:Complete_notice
goto FastOpimizePage

:auto_ASX-Power
echo Активация плана электропитания ASX-Power
echo [INFO ] %TIME% - Активация плана электропитания ASX-Power >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo Активация плана электропитания ASX-Power
  chcp 850 >nul 2>&1	
  powercfg -restoredefaultschemes
  chcp 65001 >nul 2>&1
  curl -g -L -s -o "%temp%\ASX-Power.pow" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/PowerPlan/ASX-Power.pow"
  if %errorlevel% equ 0 (
      for %%A in ("%temp%\ASX-Power.pow") do (
        if %%~zA gtr 6144 (
          echo [INFO ] %TIME% - Установка плана электропитания ASX-Power прошла успешно >> "%ASX-Directory%\Files\Logs\%date%.txt"
          echo Успешно
          chcp 850 >nul 2>&1
          powercfg /d 44444444-4444-4444-4444-444444444449 >nul 2>&1 
          powercfg -import "%temp%\ASX-Power.pow" 44444444-4444-4444-4444-444444444449 >nul 2>&1 
          powercfg -SETACTIVE "44444444-4444-4444-4444-444444444449" >nul 2>&1 
          chcp 65001 >nul 2>&1
          REM powercfg /changename 44444444-4444-4444-4444-444444444449 "ASX Power" "Оптимизировано для высокой частоты кадров и минимальной задержки." >nul 2>&1 
          del "%temp%\ASX-Power.pow" >nul 2>&1
        ) else (
            echo [INFO ] %TIME% - Ошибка при установке плана электропитания ASX-Power >> "%ASX-Directory%\Files\Logs\%date%.txt"
            echo Ошибка при установке плана электропитания ASX-Power %COL%[37m
        )
      )
  ) else (
      echo [ERROR] %TIME% - Ошибка при загрузке плана электропитания ASX-Power >> "%ASX-Directory%\Files\Logs\%date%.txt"
      echo Ошибка: Загрузка файла плана электропитания ASX-Power не удалась. %COL%[37m
  )
goto :EOF

:auto_Cortana
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
goto :EOF

:auto_StickyKeys
echo  Отключение залипания клавиш
reg add "HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Control Panel\Accessibility\SoundSentry" /v "Flags" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "DelayBeforeAcceptance" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatRate" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatDelay" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f >nul 2>&1
goto :EOF

:auto_Mouse
echo  Отключение повышенной точности установки указателя мыши
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1
goto :EOF

:auto_Wallpaper
echo  Отключение сжатия обоев...
reg add "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /t REG_DWORD /d 256 /f >nul 2>&1
goto :EOF

:auto_GameBar
echo  Отключение FSO и GameBar
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "GamePanelStartupTipIndex" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg delete "HKCU\System\GameConfigStore" /v "Win32_AutoGameModeDefaultProfile" /f >nul 2>&1
reg delete "HKCU\System\GameConfigStore" /v "Win32_GameModeRelatedProcesses" /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
goto :EOF

:auto_ContextMenu
echo  Установка старого контекстного меню из Windows 10
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /d "" /f >nul 2>&1
taskkill /f /im explorer.exe
start explorer.exe
goto :EOF

:auto_UAC
echo  Отключение UAC
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "ConsentPromptBehaviorAdmin" /T REG_DWORD /d 0 >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "ConsentPromptBehaviorUser" /T REG_DWORD /d 3 >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "EnableInstallerDetection" /T REG_DWORD /d 1 >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "EnableLUA" /T REG_DWORD /d 1 >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "EnableVirtualization" /T REG_DWORD /d 1 >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "PromptOnSecureDesktop" /T REG_DWORD /d 0 >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "ValidateAdminCodeSignatures" /T REG_DWORD /d 0 >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "FilterAdministratorToken" /T REG_DWORD /d 0 >nul 2>&1

goto :EOF

:auto_SmartScreenNotification
echo  Отключение уведомлений о запуске приложений
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /F /V "Enabled" /T REG_DWORD /d 0 >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /F /V "Enabled" /T REG_DWORD /d 0 >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /F /V "DisableNotifications" /T REG_DWORD /d 1 >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /F /V "Enabled" /T REG_DWORD /d 0 >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" /F /V "DisableNotifications" /T REG_DWORD /d 1 >nul 2>&1
goto :EOF

:auto_WindowsDefenderNotification
echo  Отключение уведомлений от Windows Defender
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Security" /F /V "DisableSecuritySettingsCheck" /T REG_DWORD /d 1 >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v LowRiskFileTypes /t REG_SZ /d ".exe;.bat;.cmd;.reg;.vbs;.msi;.msp;.com;.ps1;.ps2;.cpl" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /F /V "1806" /T REG_DWORD /d 0 >nul 2>&1
goto :EOF

:auto_Clipboard
echo  Включение журнала буфера обмена
reg add "HKEY_CURRENT_USER\Software\Microsoft\Clipboard" /v "EnableClipboardHistory" /t REG_DWORD /d 1 /f >nul 2>&1
goto :EOF

:auto_Spectre-Meldown-DownFall
echo  Выключение Spectre, Meldown, DownFall
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f >nul 2>&1
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "33554432" /f >nul 2>&1
Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f >nul 2>&1
goto :EOF

:auto_MapAutoUpdate
echo  Выключение Автообновления карт
reg add "HKEY_LOCAL_MACHINE\SYSTEM\Maps" /v "AutoUpdateEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
goto :EOF

REM Exp_tweaks
:Exp_tweaks_warn
cls
TITLE Дисклеймер. Экспериментальные твики - ASX Hub
echo.
echo.
echo.
echo.
echo                                                                         %COL%[91m_
echo                                                                        / \
echo                                                                       /   \
echo                                                                      /     \
echo                                                                     /       \
echo                                                                    /         \
echo                                                                   /           \
echo                                                                  /             \
echo                                                                 /      ___      \
echo                                                                /      ^|   ^|      \
echo                                                               /       ^|   ^|       \
echo                                                              /        ^|   ^|        \
echo                                                             /         ^|   ^|         \
echo                                                            /          ^|   ^|          \
echo                                                           /           ^|   ^|           \
echo                                                          /            ^|   ^|            \
echo                                                         /             ^|___^|             \
echo                                                        /                                 \
echo                                                       /                                   \
echo                                                      /                 ___                 \
echo                                                     /                 ^|___^|                 \
echo                                                    /                                         \
echo                                                   /___________________________________________\
echo.
echo.
echo.
echo.
echo            Внимание:%COL%[37m Вы переходите на страницу экспериментальных твиков. Эти функции находятся на стадии тестирования, и их активация
echo.
echo            может непредсказуемо повлиять на работу вашей системы. Продолжайте с осторожностью и используйте их на свой страх и риск. %COL%[90m
echo.
echo.
echo.
echo                                                Для продолжения нажмите любую клавишу на клавиатуре

if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="B" goto GoBack
pause >nul
goto Exp_tweaks

:Complete_notice
set "operation=>nul 2>&1"
set "operation=%operation_name%"
Title ASX Hub - %operation%
REM set "errorlevel=0"
if not defined operation set "operation=Неизвестная операция"
if %errorlevel% neq 0 (
cls
set /a "total_errors+=1"
echo [ERROR] %TIME% - %operation% - Завершено с ошибкой >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                               %COL%[91m______                    
echo                                                              / ____/_____________  _____
echo                                                             / __/ / ___/ ___/ __ \/ ___/
echo                                                            / /___/ /  / /  / /_/ / /    
echo                                                           /_____/_/  /_/   \____/_/
echo                                     %COL%[97m--------------------------------------------------------------------------
echo                                      %COL%[91mПодробности:
echo.
echo                                      %COL%[94m%operation%
echo                                      └ %COL%[90mОперация завершена с ошибкой
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                           Нажми Enter, чтобы продолжить
echo.
echo.
echo.
echo.
echo.
pause >nul 2>&1
goto GoBack
) else ( 
cls
echo [INFO ] %TIME% - %operation% - Успешно завершено >> "%ASX-Directory%\Files\Logs\%date%.txt"
TITLE ASX Hub
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                    %COL%[92m______                      __     __           __
echo                                                   / ____/___  ____ ___  ____  / /__  / /____  ____/ /
echo                                                  / /   / __ \/ __ `__ \/ __ \/ / _ \/ __/ _ \/ __  / 
echo                                                 / /___/ /_/ / / / / / / /_/ / /  __/ /_/  __/ /_/ /  
echo                                                 \____/\____/_/ /_/ /_/ .___/_/\___/\__/\___/\__,_/   
echo                                                                     /_/ 
echo                                     %COL%[97m--------------------------------------------------------------------------
echo                                      %COL%[92mПодробности:
echo.
echo                                      %COL%[94m%operation%
echo                                      └ %COL%[90mОперация успешно завершена
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                           Нажми Enter, чтобы продолжить
echo.
echo.
echo.
echo.
echo.
pause >nul 2>&1
goto GoBack
)


:: Панель оптимизации
:Optimization-checker
echo [INFO ] %TIME% - Вызван "Optimization-checker" >> "%ASX-Directory%\Files\Logs\%date%.txt"


if not defined OptimizationCheckerCount set "OptimizationCheckerCount=0"
set /a OptimizationCheckerCount+=1

REM echo [DEBUG] %TIME% - "Optimization-checker" Вызван %OptimizationCheckerCount% раз(а) >> "%ASX-Directory%\Files\Logs\%date%.txt"
if %OptimizationCheckerCount% equ 1 (
    REM echo [DEBUG] %TIME% - "Optimization-checker" Вызван впервые >> "%ASX-Directory%\Files\Logs\%date%.txt"
    call:If_First_call
) else (
    REM echo [DEBUG] %TIME% - "Optimization-checker" Уже вызывался ранее >> "%ASX-Directory%\Files\Logs\%date%.txt"
    if "%PageName%"=="OptimizationCenterPG1" (
        call:If_First_call_false
    ) else if "%PageName%"=="OptimizationCenterPG2" (
        call:If_First_call_false2
    )
    
    call:If_First_call_false
)

:If_First_call
echo  Идет получение информации о текущих параметрах...
REM echo [DEBUG] %TIME% - If_First_call >> "%ASX-Directory%\Files\Logs\%date%.txt"
(
    for %%i in (ASXPW PWTH DBGP CTW ETW AUTOF BCDOF NONOF CONG HIBNT INDK DANF WNDF WDNT APSN UACS DWLC FSOOF AUMS AUSA BTEB DSCR DSKN ) do (set "%%i=%COL%[92mВКЛ ")
    for %%i in (HDCP FSBT SMTSX HCCF WDNT PGMT SchM SLMD ONDR ECHR CRIS WINDF NVPIN CPLT WTUL ) do (set "%%i=%COL%[91mВЫКЛ")
    for %%i in (LRAM REDG TIIP ) do (set "%%i=%COL%[90mН/Д ")

    REM Проверка активного плана электропитания
    powercfg /GetActiveScheme | findstr /i "ASX" >nul 2>&1 || set "ASXPW=%COL%[91mВЫКЛ"

    REM Проверка состояния FSO и GameBar и изменение переменной FSOOF
    reg query "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" | find "0x1" >nul 2>&1 && set "FSOOF=%COL%[91mВЫКЛ"

	REM Проверка состояния Spectre, Meldown, DownFall
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" | find "0x1" || set "SMTSX=%COL%[92mВКЛ " >nul 2>&1

	REM Проверка Nvidia Control Panel optimization
	reg query "%SaveData%\ParameterFunction" /v "NvidiaPanelOptimization" >nul 2>&1 && set "NVPIN=%COL%[92mВКЛ "

	REM Проверка HDCP (High-bandwidth Digital Content Protection) для Nvidia
	if "%GPU_Brand%"=="Nvidia" (
		reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /v "RMHdcpKeyglobZero" | find "0x1" >nul 2>&1 || set "HDCP=%COL%[92mВКЛ "
	) else (
		set "HDCP=%COL%[90mБЛОК"
	)

	REM Проверка ограничения мощности процессора
	reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" | find "0x0" >nul 2>&1 || set "PWTH=%COL%[91mВЫКЛ"

	REM Проверка отключения фоновых программ
	reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" | find "0x1" && set "DBGP=%COL%[91mВЫКЛ" >nul 2>&1

	REM Проверка уведомлений
	reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" >nul 2>&1
	if %errorlevel% neq 0 (
		set "DANF=%COL%[91mВЫКЛ "
	) else (
		reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" | find "0x0" >nul 2>&1 && set "DANF=%COL%[91mВЫКЛ"
        reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" | find "0x1" >nul 2>&1 && set "DANF=%COL%[92mВКЛ "
	)

	REM Проверка отключения Cortana
    reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" | find "0x0" >nul 2>&1 && set "DSCR=%COL%[91mВЫКЛ"

	REM Проверка состояния быстрого запуска
	reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" | find "0x0" || set "FSBT=%COL%[92mВКЛ " >nul 2>&1
    
	REM Проверка состояния гибернации
	reg query "%SaveData%\ParameterFunction" /v "Hibernation" >nul 2>&1 || set "HIBNT=%COL%[91mВЫКЛ" >nul 2>&1

    REM Проверка Индексации файлов
    reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WSearch" /v "Start" | findstr /i "0x4" >nul 2>&1 && set "INDK=%COL%[91mВЫКЛ"

    REM Проверка состояния Windows Defender
    reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" | find "0x0" && set "WINDF=%COL%[92mВКЛ " >nul 2>&1

	REM Проверка удаления OneDrive
    reg query "%SaveData%\ParameterFunction" /v "OneDrive" >nul 2>&1 && set "ONDR=%COL%[92mВКЛ "

	REM Проверка сжатия обоев рабочего стола
	reg query "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" | find "0x100" && set "DWLC=%COL%[91mВЫКЛ" >nul 2>&1

	REM Проверка отключения залипания клавиш
    reg query "HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys" /v "Flags" | find "506" && set "DSKN=%COL%[91mВЫКЛ" >nul 2>&1

    REM Проверка Повышенной точности установки указателя мыши
    for /f "tokens=3" %%A in ('reg query "HKCU\Control Panel\Mouse" /v MouseSpeed 2^>nul') do (
        if "%%A"=="0" (
            set "MOAC=%COL%[91mВЫКЛ"
        ) else (
            set "MOAC=%COL%[92mВКЛ "
        )
    )

    REM Проверка видимости файлов Creative Cloud в проводнике
    reg query "HKEY_CLASSES_ROOT\CLSID\{0E270DAA-1BE6-48F2-AC49-12C0502DD12A}" /v "System.IsPinnedToNameSpaceTree" | find "0x0" >nul 2>&1 || (
    	reg query "HKEY_CLASSES_ROOT\CLSID\{0E270DAA-1BE6-48F2-AC49-FA88F404D493}" /v "System.IsPinnedToNameSpaceTree" | find "0x0" >nul 2>&1 || set "HCCF=%COL%[92mВКЛ "
    )

	REM Проверка удаления Microsoft Edge
	reg query "%SaveData%\ParameterFunction" /v "RemoveEdge" >nul 2>&1 && set "REDG=%COL%[92mВКЛ "

    REM Проверка отключения уведомлений Windows Defender
    reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" | findstr /i "0x0" >nul 2>&1 && set "WDNT=%COL%[91mВЫКЛ"

    REM Проверка отключения уведомлений о запуске приложений
    reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Security" /v "DisableSecuritySettingsCheck" | findstr /i "0x1" >nul 2>&1 && set "APSN=%COL%[91mВЫКЛ"

	REM Проверка приоритета игровых процессов
	reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" | find "0x2" >nul 2>&1 || set "PGMT=%COL%[92mВКЛ "

    REM Проверка состояния UAC (Контроль учетных записей пользователей)
    for /f "tokens=3" %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" 2^>nul') do (
    	if "%%A"=="0x0" set "UACS=%COL%[91mВЫКЛ"
    )

	REM Проверка режима аппаратного планирования GPU
	reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" | find "0x1" >nul 2>&1 || set "SchM=%COL%[92mВКЛ "

    REM Проверка отключения Teredo, ISATAP и IPv6
    reg query "%SaveData%\ParameterFunction" /v "TIIP" >nul 2>&1 && set "TIIP=%COL%[91mВЫКЛ"

    REM Проверка режима сна (Sleep Mode)
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled | findstr /i "0x0" >nul 2>&1 && set "SLMD=%COL%[92mВКЛ "

	REM Проверка Журнала буфера обмена
	reg query "HKEY_CURRENT_USER\Software\Microsoft\Clipboard" /v "EnableClipboardHistory" | find "0x1" && set "ECHR=%COL%[92mВКЛ " >nul 2>&1

    REM Проверка Изоляции ядра
    reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" | find "0x1" && set "CRIS=%COL%[92mВКЛ " >nul 2>&1

    REM Проверка автообновления карт
    reg query "HKEY_LOCAL_MACHINE\SYSTEM\Maps" /v "AutoUpdateEnabled" | findstr /i "0x0" >nul 2>&1 && set "AUMS=%COL%[91mВЫКЛ"

    REM Проверка автообновления приложений магазина
    reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore" /v "AutoDownload" | findstr /i "0x2" >nul 2>&1 && set "AUSA=%COL%[91mВЫКЛ"

    REM Проверка фоновой работы браузера Microsoft Edge
    reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" | findstr /i "0x0" >nul 2>&1 && set "BTEB=%COL%[91mВЫКЛ"

    REM Recall
    dism /Online /Get-FeatureInfo /FeatureName:Recall >nul 2>&1 && ( set "RECL=%COL%[91mВЫКЛ" ) || ( set "RECL=%COL%[92mВКЛ " )

    REM Copilot
    reg query "HKCU\Software\Microsoft\Windows\Shell\Copilot\BingChat" /v "IsUserEligible" | findstr /i "0x0" >nul 2>&1 && set "CPLT=%COL%[92mВКЛ "
    reg query "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "HubsSidebarEnabled" | findstr /i "0x0" >nul 2>&1 && set "CPLT=%COL%[92mВКЛ "

    REM Проверка установки виджетов Windows - WebExperience
    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages" /f "MicrosoftWindows.Client.WebExperience" >nul 2>&1 && set "WTUL=%COL%[92mВКЛ " >nul 2>&1
    
    reg query "HKCU\Control Panel\Sound" /v "EnableSystemSounds" 2>nul | find "0x1" >nul
    if !errorlevel! == 0 (
        set "sound_status=Включены"
        set "WSND=%COL%[92mВКЛ "
    ) else (
        set "sound_status=Отключены"
        set "WSND=%COL%[91mВЫКЛ"
    )

	REM Определение типа видеокарты
	for /f "tokens=2 delims==" %%a in ('wmic path Win32_VideoController get VideoProcessor /value') do (
		for %%n in (GeForce NVIDIA RTX GTX) do echo %%a | find "%%n" >nul && set "NVIDIAGPU=Found"
		for %%n in (AMD Ryzen) do echo %%a | find "%%n" >nul && set "AMDGPU=Found"
		for %%n in (Intel UHD) do echo %%a | find "%%n" >nul && set "INTELGPU=Found"
	)
	if "!NVIDIAGPU!" neq "Found" for %%g in (HDCP ) do set "%%g=%COL%[90mН/Д "
) >nul 2>&1
cls
    if "%PageName%"=="OptimizationCenterPG1" (
        call:If_First_call_false
    ) else if "%PageName%"=="OptimizationCenterPG2" (
        call:If_First_call_false2
    )

goto :eof

:OptimizationCenterPG1
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":OptimizationCenterPG1" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=OptimizationCenterPG1
cls
call:Optimization-checker
:If_First_call_false
TITLE Оптимизация и настройка - ASX Hub
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 2%COL%[90m]
echo.
echo          %COL%[36mОптимизация и настройка
echo          %COL%[97m-----------------------%COL%[37m
echo           1 %COL%[36m[%COL%[37m %ASXPW% %COL%[36m]%COL%[37m План электропитания ASX Hub
echo           2 %COL%[36m[%COL%[37m %FSOOF% %COL%[36m]%COL%[37m Выключить FSO и GameBar
echo           3 %COL%[36m[%COL%[37m %SMTSX% %COL%[36m]%COL%[37m Spectre, Meldown, DownFall
echo           4 %COL%[36m[%COL%[37m %NVPIN% %COL%[36m]%COL%[37m Оптимизация настроек Nvidia
echo           5 %COL%[36m[%COL%[37m %HDCP% %COL%[36m]%COL%[37m HDCP
echo           6 %COL%[36m[%COL%[37m %PWTH% %COL%[36m]%COL%[37m Power throttling
echo           7 %COL%[36m[%COL%[37m %DBGP% %COL%[36m]%COL%[37m Работа UWP программ в фоне
echo           8 %COL%[36m[%COL%[37m %DANF% %COL%[36m]%COL%[37m Уведомления
echo           9 %COL%[36m[%COL%[37m %DSCR% %COL%[36m]%COL%[37m Cortana
echo          10 %COL%[36m[%COL%[37m %FSBT% %COL%[36m]%COL%[37m Быстрый запуск ^(Fast Boot^)
echo          11 %COL%[36m[%COL%[37m %HIBNT% %COL%[36m]%COL%[37m Гибернация
echo          12 %COL%[36m[%COL%[37m %INDK% %COL%[36m]%COL%[37m Индексация файлов на дисках
echo          13 %COL%[36m[%COL%[90m %WINDF% %COL%[36m]%COL%[37m Windows Defender
echo          14 %COL%[36m[%COL%[37m %ONDR% %COL%[36m]%COL%[37m Полностью выпилить OneDrive
echo          15 %COL%[36m[%COL%[37m %DWLC% %COL%[36m]%COL%[37m Cжатие обоев рабочего стола
echo          16 %COL%[36m[%COL%[37m %DSKN% %COL%[36m]%COL%[37m Залипание клавиш
echo          17 %COL%[36m[%COL%[37m %MOAC% %COL%[36m]%COL%[37m Повышенная точность установки указателя мыши
echo          18 %COL%[36m[%COL%[37m %HCCF% %COL%[36m]%COL%[37m Скрыть Creative Cloud Files из проводника
echo          19 %COL%[36m[%COL%[37m %REDG% %COL%[36m]%COL%[37m Удалить всё, что связанно с Edge 
echo          20 %COL%[36m[%COL%[37m %WDNT% %COL%[36m]%COL%[37m Надоедливые уведомления о безопасности от Win Defender
echo          21 %COL%[36m[%COL%[37m %APSN% %COL%[36m]%COL%[37m Предупреждения при запуске любых exe
echo          22 %COL%[36m[%COL%[37m %PGMT% %COL%[36m]%COL%[37m Приоритизация игровых задач
echo          23 %COL%[36m[%COL%[37m %UACS% %COL%[36m]%COL%[37m Контроль учётных записей пользователей ^(UAC^)
echo          24 %COL%[36m[%COL%[37m %SchM% %COL%[36m]%COL%[37m Планирование графического процессора с аппаратным ускорением
echo          25 %COL%[36m[%COL%[37m %TIIP% %COL%[36m]%COL%[37m Teredo, ISATAP и IPv6

echo          26 %COL%[36m[%COL%[37m %SLMD% %COL%[36m]%COL%[37m Отключить Спящий режим
echo          27 %COL%[36m[%COL%[37m %ECHR% %COL%[36m]%COL%[37m Журнал буфера обмена

if "%WinVer%"=="Windows 11" (
echo          28 %COL%[36m[%COL%[37m %CRIS% %COL%[36m]%COL%[37m Изоляция ядра
) else (
echo          28 %COL%[36m[%COL%[37m %COL%[91mБЛОК %COL%[36m]%COL%[37m Изоляция ядра  %COL%[91m^(Не доступно на вашем пк^)%COL%[90m
)
echo          29 %COL%[36m[%COL%[37m %AUMS% %COL%[36m]%COL%[37m Автообновление карт
echo          30 %COL%[36m[%COL%[37m %AUSA% %COL%[36m]%COL%[37m Автообновление приложений магазина
echo          31 %COL%[36m[%COL%[37m %BTEB% %COL%[36m]%COL%[37m Ускорение Microsoft Edge и фоновая работа браузера
echo          32 %COL%[36m[%COL%[37m %RECL% %COL%[36m]%COL%[37m Удалить Recall
echo          33 %COL%[36m[%COL%[37m %CPLT% %COL%[36m]%COL%[37m Удалить Copilot
echo          34 %COL%[36m[%COL%[37m %WTUL% %COL%[36m]%COL%[37m Удалить виджеты
echo.
echo.
REM echo                                   %COL%[36m[ B - Назад ]         %COL%[91m[ X - Главное меню ]         %COL%[36m[ N - Слудующая страница ]%COL%[90m
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
set "choice="
set /p choice="%DEL%                                                                      >: "

if not defined choice cls && goto OptimizationCenterPG1

REM echo %NPIOF% | find "Н/Д" >nul && if "%choice%" geq "1" if "%choice%" leq "2" call :ASXHubError "У вас нет графического процессора NVIDIA" && goto OptimizationCenterPG1
if /i "%choice%"=="1" ( set "Warning_Irreversible_goto=ASXPowerPlan" && set "history_Warning_Irreversible_goto=OptimizationCenterPG1" && set "history=OptimizationCenterPG1;!history!" && Call:Warning_Irreversible)
if /i "%choice%"=="2" ( set "history=OptimizationCenterPG1;!history!" && Call:DissableFSOandGameBar )
if /i "%choice%"=="3" ( set "history=OptimizationCenterPG1;!history!" && call:Spectre_Meldown_DownFall )

if /i "%choice%"=="4" ( set "history=OptimizationCenterPG1;!history!" && call:NvidiaPanelOptimization )

if /i "%choice%"=="5" ( set "history=OptimizationCenterPG1;!history!" && call:HDCP )
if /i "%choice%"=="6" ( set "history=OptimizationCenterPG1;!history!" && call:DisablePowerThrottling )
if /i "%choice%"=="7" ( set "history=OptimizationCenterPG1;!history!" && call:DisableBackgroundPrograms )
if /i "%choice%"=="8" ( set "history=OptimizationCenterPG1;!history!" && goto DisableAllNotifications )
if /i "%choice%"=="9" ( set "Warning_Irreversible_goto=DisableCortana" && set "history_Warning_Irreversible_goto=OptimizationCenterPG1" && set "history=OptimizationCenterPG1;!history!" && Call:Warning_Irreversible)
if /i "%choice%"=="10" ( set "history=OptimizationCenterPG1;!history!" && goto FastBoot )
if /i "%choice%"=="11" ( set "history=OptimizationCenterPG1;!history!" && goto Hibernation )
if /i "%choice%"=="12" ( set "history=OptimizationCenterPG1;!history!" && goto Indexing )
if /i "%choice%"=="13" ( set "history=OptimizationCenterPG1;!history!" && goto WindowsDefender )
if /i "%choice%"=="14" ( set "Warning_Irreversible_goto=OneDrive" && set "history_Warning_Irreversible_goto=OptimizationCenterPG1" && set "history=OptimizationCenterPG1;!history!" && Call:Warning_Irreversible)
if /i "%choice%"=="15" ( set "history=OptimizationCenterPG1;!history!" && goto DisableWallpapercompression )
if /i "%choice%"=="16" ( set "history=OptimizationCenterPG1;!history!" && goto DisableStickyKeys )
if /i "%choice%"=="17" ( set "history=OptimizationCenterPG1;!history!" && goto MouseAcceleration )
if /i "%choice%"=="18" ( set "history=OptimizationCenterPG1;!history!" && goto HideCreativeCloudFiles )
if /i "%choice%"=="19" ( set "Warning_Irreversible_goto=RemoveEdge" && set "history_Warning_Irreversible_goto=OptimizationCenterPG1" && set "history=OptimizationCenterPG1;!history!" && Call:Warning_Irreversible)
if /i "%choice%"=="20" ( set "history=OptimizationCenterPG1;!history!" && goto SecurityCenterNotifications )
if /i "%choice%"=="21" ( set "history=OptimizationCenterPG1;!history!" && goto AppStartNotify )
if /i "%choice%"=="22" ( set "history=OptimizationCenterPG1;!history!" && goto PrioritizeGamingTasks )
if /i "%choice%"=="23" ( set "history=OptimizationCenterPG1;!history!" && goto UAC )
if /i "%choice%"=="24" ( set "history=OptimizationCenterPG1;!history!" && goto HwSchMode )
if /i "%choice%"=="25" ( set "history=OptimizationCenterPG1;!history!" && goto TIIP )

if /i "%choice%"=="26" ( set "history=OptimizationCenterPG1;!history!" && goto DisableSleepingMode )
if /i "%choice%"=="27" ( set "history=OptimizationCenterPG1;!history!" && goto ClipboardHistory )
if "%WinVer%"=="Windows 11" (
    if /i "%choice%"=="28" ( set "history=OptimizationCenterPG1;!history!" && goto CoreIsolation )
)
if /i "%choice%"=="29" ( set "history=OptimizationCenterPG1;!history!" && call:AutoUpdateMaps )
if /i "%choice%"=="30" ( set "history=OptimizationCenterPG1;!history!" && call:AutoStoreApps )
if /i "%choice%"=="31" ( set "history=OptimizationCenterPG1;!history!" && call:BackgroundTaskEdgeBrowser )
if /i "%choice%"=="32" ( set "history=OptimizationCenterPG1;!history!" && call:RecallAi )
if /i "%choice%"=="33" ( set "history=OptimizationCenterPG1;!history!" && call:CopilotAi )
if /i "%choice%"=="34" ( set "history=OptimizationCenterPG1;!history!" && Call:WidgetUninstall )
if /i "%choice%"=="C" ( set "history=OptimizationCenterPG1;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=OptimizationCenterPG1;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=OptimizationCenterPG1;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=OptimizationCenterPG1;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack 
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="R" goto OptimizationCenterPG1
if /i "%choice%"=="к" goto OptimizationCenterPG1

if /i "%choice%"=="N" ( set "history=OptimizationCenterPG1;!history!" && goto OptimizationCenterPG2 )
if /i "%choice%"=="т" ( set "history=OptimizationCenterPG1;!history!" && goto OptimizationCenterPG2 )
REM if /i "%choice%"=="NoInput" goto WrongInput
call:WrongInput
goto OptimizationCenterPG1


:OptimizationCenterPG2
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":OptimizationCenterPG2" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=OptimizationCenterPG2
cls
call:Optimization-checker
:If_First_call_false2
TITLE Оптимизация и настройка - ASX Hub
echo.
echo                                                                     %COL%[90m[%COL%[96m2 %COL%[90m/ 2%COL%[90m]
echo.
echo          %COL%[36mОптимизация и настройка
echo          %COL%[97m-----------------------%COL%[37m
echo           1 %COL%[36m[%COL%[37m %WSND% %COL%[36m]%COL%[37m Системные звуки windows
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                   %COL%[36m[ B - Назад ]         %COL%[91m[ X - Главное меню ]         %COL%[36m[ N - Слудующая страница ]%COL%[90m
REM echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
set "choice="
set /p choice="%DEL%                                                                      >: "

if not defined choice cls && goto OptimizationCenterPG2
if /i "%choice%"=="1" ( set "history=OptimizationCenterPG2;!history!" && Call:WindowsSounds )

REM if /i "%choice%"=="N" goto OptimizationCenterPG2PG2
if /i "%choice%"=="C" ( set "history=OptimizationCenterPG2;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=OptimizationCenterPG2;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=OptimizationCenterPG2;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=OptimizationCenterPG2;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="R" goto OptimizationCenterPG2
if /i "%choice%"=="к" goto OptimizationCenterPG2
REM if /i "%choice%"=="NoInput" goto WrongInput
call:WrongInput
goto OptimizationCenterPG2

:ASXPowerPlan
echo [INFO ] %TIME% - Вызван ":ASXPowerPlan" >> "%ASX-Directory%\Files\Logs\%date%.txt" 
if "%ASXPW%" == "%COL%[91mВЫКЛ" (
    chcp 850 >nul 2>&1	
    powercfg -restoredefaultschemes
    chcp 65001 >nul 2>&1
    curl -g -L -# -o "%temp%\ASX-Power.pow" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/ASX.Hub-Power.pow" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] %TIME% - Ошибка при загрузке ASX-Hub-Power.pow >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto :PowerPlanError
    )	
    cls
    chcp 850 >nul 2>&1
    powercfg /d 44444444-4444-4444-4444-444444444449 >nul 2>&1 
    powercfg -import "%temp%\ASX-Power.pow" 44444444-4444-4444-4444-444444444449 >nul 2>&1 
    powercfg -SETACTIVE "44444444-4444-4444-4444-444444444449" >nul 2>&1 
    chcp 65001 >nul 2>&1
    powercfg /changename 44444444-4444-4444-4444-444444444449 "ASX-Hub-Power" "Оптимизировано для высокой частоты кадров и минимальной задержки." >nul 2>&1 
    del "%temp%\ASX-Power.pow" >nul 2>&1
    set "operation_name=Применение плана электропитания ASX Hub Power"
) else (
    powercfg -restoredefaultschemes >nul 2>&1
    set "operation_name=Восстановление настроек электропитания"
)

Call :YesNoBox "Удалить другие планы электропитания?" "ASX Hub"
if "%YesNo%"=="6" (
    powercfg /d 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
    powercfg /d 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
    powercfg /d a1841308-3541-4fab-bc81-f71556f20b4a >nul 2>&1
    powercfg /d a9758bf0-cfc6-439c-a392-7783990ff716 >nul 2>&1
)

REM Проверка активного плана электропитания
set "ASXPW=%COL%[92mВКЛ "
powercfg /GetActiveScheme | findstr /i "ASX" >nul 2>&1 || set "ASXPW=%COL%[91mВЫКЛ"

call:Complete_notice
goto GoBack

:PowerPlanError
echo [ERROR] %TIME% - Не удалось применить план электропитания ASX Hub Power >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo Не удалось применить план электропитания ASX Hub Power. Пожалуйста, проверьте подключение к интернету и попробуйте снова.
pause
goto GoBack

:DissableFSOandGameBar
echo [INFO ] %TIME% - Вызван ":DissableFSOandGameBar" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%FSOOF%" == "%COL%[92mВКЛ " (
    reg delete "HKCU\SOFTWARE\Microsoft\GameBar" /v "AllowAutoGameMode" /f >nul 2>&1
    reg delete "HKCU\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /f >nul 2>&1
    reg delete "HKCU\SOFTWARE\Microsoft\GameBar" /v "GamePanelStartupTipIndex" /f >nul 2>&1
    reg delete "HKCU\SOFTWARE\Microsoft\GameBar" /v "ShowStartupPanel" /f >nul 2>&1
    reg delete "HKCU\SOFTWARE\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\GameBar" /f >nul 2>&1
    reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /f >nul 2>&1
    reg delete "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "1" /f >nul 2>&1
    reg delete "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "0" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
    set "operation_name=Включение FSO и GameBar"
) else (
    reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "GamePanelStartupTipIndex" /t REG_DWORD /d "3" /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "ShowStartupPanel" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\GameBar" /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
    reg delete "HKCU\System\GameConfigStore" /v "Win32_AutoGameModeDefaultProfile" /f >nul 2>&1
    reg delete "HKCU\System\GameConfigStore" /v "Win32_GameModeRelatedProcesses" /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f >nul 2>&1
    reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
    set "operation_name=Выключение FSO и GameBar"
)

REM Проверка состояния FSO и GameBar и изменение переменной FSOOF
set "FSOOF=%COL%[92mВКЛ "
set "errorlevel_a=%errorlevel%"
reg query "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" | find "0x1" >nul 2>&1 && set "FSOOF=%COL%[91mВЫКЛ" >nul 2>&1
set errorlevel=%errorlevel_a%
call:Complete_notice
goto GoBack

:Spectre_Meldown_DownFall
echo [INFO ] %TIME% - Вызван ":Spectre_Meldown_DownFall" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%SMTSX%" == "%COL%[91mВЫКЛ" (
    Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "0" /f >nul 2>&1
    Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /f >nul 2>&1
    Reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /f >nul 2>&1
    set "operation_name=Включение настроек памяти Spectre, Meldown, DownFall"
) else (
    Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f >nul 2>&1
    Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "33554432" /f >nul 2>&1
    Reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f >nul 2>&1
    set "operation_name=Выключение настроек памяти Spectre, Meldown, DownFall"
) >nul 2>&1
REM Проверка состояния Spectre, Meldown, DownFall
set "SMTSX=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" | find "0x1" || set "SMTSX=%COL%[92mВКЛ " >nul 2>&1
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:NvidiaPanelOptimization
echo [INFO ] %TIME% - Вызван ":NvidiaPanelOptimization" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%NVPIN%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data\ParameterFunction" /v NvidiaPanelOptimization /f
	rmdir /S /Q "%ASX-Directory%\Files\Resources\nvidiaProfileInspector\"
	curl -g -L -# -o "%ASX-Directory%\Files\Downloads\nvidiaProfileInspector.zip" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Resources/NvidiaProfileInspector/nvidiaProfileInspector.zip"
    chcp 850 >nul 2>&1
    powershell -NoProfile Expand-Archive '"%ASX-Directory%\Files\Downloads\nvidiaProfileInspector.zip"' -DestinationPath '"%ASX-Directory%\Files\Resources\nvidiaProfileInspector\"'
	chcp 65001 >nul 2>&1
    del /F /Q "%ASX-Directory%\Files\Downloads\nvidiaProfileInspector.zip"
	curl -g -L -# -o "%ASX-Directory%\Files\Resources\nvidiaProfileInspector\ASX_Profile.nip" "https://raw.githubusercontent.com/ALFiX01/ASX-Hub/refs/heads/main/Files/Resources/NvidiaProfileInspector/ASX_Profile.nip"
    "%ASX-Directory%\Files\Resources\nvidiaProfileInspector\nvidiaProfileInspector.exe" "%ASX-Directory%\Files\Resources\nvidiaProfileInspector\ASX_Profile.nip"
    set "operation_name=Включение оптимизации настроек Nvidia"
) >nul 2>&1 else (
	rem https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip
	reg delete "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data\ParameterFunction" /v NvidiaPanelOptimization /f
	rmdir /S /Q "%ASX-Directory%\Files\Resources\nvidiaProfileInspector\"
	curl -g -L -# -o "%ASX-Directory%\Files\Downloads\nvidiaProfileInspector.zip" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Resources/NvidiaProfileInspector/nvidiaProfileInspector.zip"
	chcp 850 >nul 2>&1
    powershell -NoProfile Expand-Archive '"%ASX-Directory%\Files\Downloads\nvidiaProfileInspector.zip"' -DestinationPath '"%ASX-Directory%\Files\Resources\nvidiaProfileInspector\"'
	chcp 65001 >nul 2>&1
    del /F /Q "%ASX-Directory%\Files\Downloads\nvidiaProfileInspector.zip"
	curl -g -L -# -o "%ASX-Directory%\Files\Resources\nvidiaProfileInspector\Base_Profile.nip" "https://raw.githubusercontent.com/ALFiX01/ASX-Hub/refs/heads/main/Files/Resources/NvidiaProfileInspector/Base_Profile.nip"
	REM "%ASX-Directory%\Files\Resources\nvidiaProfileInspector\nvidiaProfileInspector.exe" Base_Profile.nip
    "%ASX-Directory%\Files\Resources\nvidiaProfileInspector\nvidiaProfileInspector.exe" "%ASX-Directory%\Files\Resources\nvidiaProfileInspector\Base_Profile.nip"
    set "operation_name=Выключение оптимизации настроек Nvidia"
) >nul 2>&1
REM Проверка состояния NVPIN
set "NVPIN=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
reg query "%SaveData%\ParameterFunction" /v "NvidiaPanelOptimization" >nul 2>&1 && set "NVPIN=%COL%[92mВКЛ "
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:Warning_Irreversible
cls
echo [INFO ] %TIME% - Вызван ":Warning_Irreversible" >> "%ASX-Directory%\Files\Logs\%date%.txt"
title Предупреждение - ASX Hub
echo.
echo.
echo.
echo.
echo                                                                         %COL%[91m_
echo                                                                        / \
echo                                                                       /   \
echo                                                                      /     \
echo                                                                     /       \
echo                                                                    /         \
echo                                                                   /           \
echo                                                                  /             \
echo                                                                 /      ___      \
echo                                                                /      ^|   ^|      \
echo                                                               /       ^|   ^|       \
echo                                                              /        ^|   ^|        \
echo                                                             /         ^|   ^|         \
echo                                                            /          ^|   ^|          \
echo                                                           /           ^|   ^|           \
echo                                                          /            ^|   ^|            \
echo                                                         /             ^|___^|             \
echo                                                        /                                 \
echo                                                       /                                   \
echo                                                      /                 ___                 \
echo                                                     /                 ^|___^|                 \
echo                                                    /                                         \
echo                                                   /___________________________________________\
echo.
echo.
echo.
echo.
echo             Внимание: %COL%[37mВыбранная вами функция приведет к необратимым изменениям, которые невозможно отменить с помощью ASX Hub.
echo.
echo             Настоятельно рекомендуем тщательно обдумать ваше решение перед использованием этой функции.%COL%[90m
echo.
echo.
echo.
echo                                        Введите %COL%[36m^<OK^>%COL%[90m чтобы продолжить или введите %COL%[36m^<B^>%COL%[90m чтобы вернуться назад
echo.
set "choice="
set /p choice="%DEL%                                                                     >: "

if not defined choice cls && goto Warning_Irreversible
if /i "%choice%"=="OK" ( goto %Warning_Irreversible_goto% )
if /i "%choice%"=="ок" ( goto %Warning_Irreversible_goto% )
if /i "%choice%"=="back" ( goto GoBack )
if /i "%choice%"=="B" ( goto GoBack )
if /i "%choice%"=="и" ( goto GoBack )
goto Warning_Irreversible

:HDCP
cls
TITLE Предупреждение - ASX Hub
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                       %COL%[91m_       __                 _            
echo                                                      ^| ^|     / /___ __________  ^(_^)___  ____ _
echo                                                      ^| ^| /^| / / __ `/ ___/ __ \/ / __ \/ __ `/
echo                                                      ^| ^|/ ^|/ / /_/ / /  / / / / / / / / /_/ / 
echo                                                      ^|__/^|__/\__,_/_/  /_/ /_/_/_/ /_/\__, /  
echo                                                                                      /____/
echo                                 %COL%[97m-----------------------------------------------------------------------------------%COL%[90m
echo.
echo                                 Отключение HDCP может повлиять на работу стриминговых сервисов и онлайн-кинотеатров
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
pause >nul 2>&1
GOTO :EOF

echo [INFO ] %TIME% - Вызван ":HDCP" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%HDCP%" == "%COL%[92mВКЛ " (
	reg add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /v "RMHdcpKeyglobZero" /t REG_DWORD /d 1 /f >nul 2>&1
    set "operation_name=Выключение HDCP"
) else (
	reg add "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /v "RMHdcpKeyglobZero" /t REG_DWORD /d 0 /f >nul 2>&1
    set "operation_name=Включение HDCP"
)

REM Проверка HDCP (High-bandwidth Digital Content Protection) для Nvidia
set "HDCP=%COL%[91mВЫКЛ"
if "%GPU_Brand%"=="Nvidia" (
    set "errorlevel_a=%errorlevel%"
	reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /v "RMHdcpKeyglobZero" | find "0x1" >nul 2>&1 || set "HDCP=%COL%[92mВКЛ "
    set "errorlevel=%errorlevel_a%"
) else (
	set "HDCP=%COL%[90mБЛОК"
)
call:Complete_notice
goto GoBack

:DisablePowerThrottling
echo [INFO ] %TIME% - Вызван ":DisablePowerThrottling" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%PWTH%" == "%COL%[91mВЫКЛ" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 0 /f >nul 2>&1
    set "operation_name=Выключение Power Throttling"
) else (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f >nul 2>&1
    set "operation_name=Включение Power Throttling"
) >nul 2>&1

REM Проверка ограничения мощности процессора
set "PWTH=%COL%[92mВКЛ "
set "errorlevel_a=%errorlevel%"
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" | find "0x0" >nul 2>&1 || set "PWTH=%COL%[91mВЫКЛ"
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:DisableBackgroundPrograms
echo [INFO ] %TIME% - Вызван ":DisableBackgroundPrograms" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%DBGP%" == "%COL%[92mВКЛ " (
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\embeddedmode" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
    set "operation_name=Отключение работы UWP программ в фоне"
) else (
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\embeddedmode" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
    set "operation_name=Включение работы UWP программ в фоне"
)
REM Проверка отключения фоновых программ
set "DBGP=%COL%[92mВКЛ " >nul 2>&1
set "errorlevel_a=%errorlevel%"
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" | find "0x1" && set "DBGP=%COL%[91mВЫКЛ" >nul 2>&1
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:DisableAllNotifications
echo [INFO ] %TIME% - Вызван ":DisableAllNotifications" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%DANF%" == "%COL%[91mВЫКЛ" (
	reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /f >nul 2>&1
	set "operation_name=Включение всех уведомлений обратно"
) else (
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
	set "operation_name=Отключение всех уведомлений"
)
REM Проверка уведомлений
reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" >nul 2>&1
if %errorlevel% neq 0 (
	set "DANF=%COL%[91mВЫКЛ "
) else (
    set "errorlevel_a=%errorlevel%"
	reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" | find "0x0" >nul 2>&1 && set "DANF=%COL%[91mВЫКЛ"
    reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" | find "0x1" >nul 2>&1 && set "DANF=%COL%[92mВКЛ "
    set "errorlevel=%errorlevel_a%"
)
call:Complete_notice
goto GoBack

:DisableCortana
echo [INFO ] %TIME% - Вызван ":DisableCortana" >> "%ASX-Directory%\Files\Logs\%date%.txt"

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

REM Проверка отключения Cortana и изменение переменной DSCR
set "DSCR=%COL%[92mВКЛ "
set "errorlevel_a=%errorlevel%"
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" | find "0x0" >nul 2>&1 && set "DSCR=%COL%[91mВЫКЛ"
set "errorlevel=%errorlevel_a%"
set "operation_name=Отключение Cortana"
call:Complete_notice
goto GoBack

:CleanDevice
echo [INFO ] %TIME% - Вызван ":CleanDevice" >> "%ASX-Directory%\Files\Logs\%date%.txt"
reg add "%SaveData%\ParameterFunction" /v "CleanDevice" /f >nul 2>&1
md "%ASX-Directory%\Files\Utilites\DeviceClean" >nul 2>&1
curl -g -L -# -o "%ASX-Directory%\Files\Utilites\DeviceClean\DeviceClean-RunAdmin.exe" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/DeviceClean-RunAdmin.exe" >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        echo Ошибка: Не удалось скачать файл DeviceClean-RunAdmin.exe. Проверьте подключение к интернету и доступность URL.
		echo [ERROR] %TIME% - Ошибка при загрузке DeviceClean-RunAdmin.exe. >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto GoBack
    )	
start "" "%ASX-Directory%\Files\Utilites\DeviceClean\DeviceClean-RunAdmin.exe"
goto GoBack

:FastBoot
echo [INFO ] %TIME% - Вызван ":FastBoot" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%FSBT%" == "%COL%[91mВЫКЛ" (
	REG add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /V HiberbootEnabled /T REG_dWORD /D 1 /f >nul 2>&1
	set "operation_name=Включение быстрого запуска"
) >nul 2>&1 else (
	REG add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /V HiberbootEnabled /T REG_dWORD /D 0 /f >nul 2>&1
	set "operation_name=Выключение быстрого запуска"
) >nul 2>&1
REM Проверка состояния быстрого запуска
set "FSBT=%COL%[91mВЫКЛ" >nul 2>&1
set "errorlevel_a=%errorlevel%"
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" | find "0x0" || set "FSBT=%COL%[92mВКЛ " >nul 2>&1
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:Hibernation
echo [INFO ] %TIME% - Вызван ":Hibernation" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%HIBNT%" == "%COL%[91mВЫКЛ" (
	reg add "%SaveData%\ParameterFunction" /v "Hibernation" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v HibernateEnabled /t REG_DWORD /d 0 /f >nul 2>&1
	powercfg.exe /hibernate off
	set "operation_name=Включение гибернации"		
) >nul 2>&1 else (
	reg delete "%SaveData%\ParameterFunction" /v "Hibernation" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v HibernateEnabled /t REG_DWORD /d 1 /f >nul 2>&1
	powercfg.exe /hibernate on
	set "operation_name=Выключение гибернации"	
) >nul 2>&1
REM Проверка состояния гибернации
set "HIBNT=%COL%[92mВКЛ " >nul 2>&1
set "errorlevel_a=%errorlevel%"
reg query "%SaveData%\ParameterFunction" /v "Hibernation" >nul 2>&1 || set "HIBNT=%COL%[91mВЫКЛ" >nul 2>&1
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:Indexing
echo [INFO ] %TIME% - Вызван ":Indexing" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%INDK%" == "%COL%[91mВЫКЛ" (
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WSearch" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
    sc config "WSearch" start= auto
    net start "WSearch"
	set "operation_name=Включение индексации"		
) >nul 2>&1 else (
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WSearch" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
    sc config "WSearch" start= disabled
    net stop "WSearch"
	set "operation_name=Выключение индексации"	
) >nul 2>&1
REM Проверка состояния индексации
set "INDK=%COL%[92mВКЛ " >nul 2>&1
set "errorlevel_a=%errorlevel%"
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WSearch" /v "Start" | findstr /i "0x4" >nul 2>&1 && set "INDK=%COL%[91mВЫКЛ"
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:WindowsDefender
echo [INFO ] %TIME% - Вызван ":WindowsDefender" >> "%ASX-Directory%\Files\Logs\%date%.txt"

if "%WINDF%" == "%COL%[91mВЫКЛ" (
    REM ВКЛЮЧЕНИЕ WINDOWS DEFENDER
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Windows Defender" /f >nul 2>&1

    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdBoot" /v "Start" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter" /v "Start" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1

    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "0" /f >nul 2>&1

    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration" /v "Notification_Suppress" /t REG_DWORD /d "0" /f >nul 2>&1

    reg add "HKLM\SYSTEM\CurrentControlSet\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\wscsvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
    
    REM Восстановление контекстного меню
    reg add "HKCR\*\shellex\ContextMenuHandlers\EPP" /ve /t REG_SZ /d "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f >nul 2>&1
    reg add "HKCR\Directory\shellex\ContextMenuHandlers\EPP" /ve /t REG_SZ /d "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f >nul 2>&1
    reg add "HKCR\Drive\shellex\ContextMenuHandlers\EPP" /ve /t REG_SZ /d "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f >nul 2>&1
    
    reg delete "HKLM\SYSTEM\SOFTWARE\Microsoft\Wbem" /v "AmsiEnable" /f >nul 2>&1
    set "operation_name=Включение Windows Defender"
) else (
    REM ВЫКЛЮЧЕНИЕ WINDOWS DEFENDER
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d "1" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d "1" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdBoot" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
    reg delete "HKCR\*\shellex\ContextMenuHandlers\EPP" /f >nul 2>&1
    reg delete "HKCR\Directory\shellex\ContextMenuHandlers\EPP" /f >nul 2>&1
    reg delete "HKCR\Drive\shellex\ContextMenuHandlers\EPP" /f >nul 2>&1

    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1

    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration" /v "Notification_Suppress" /t REG_DWORD /d "1" /f >nul 2>&1

    reg add "HKLM\SYSTEM\CurrentControlSet\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\wscsvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1

    reg add "HKLM\SYSTEM\SOFTWARE\Microsoft\Wbem" /v "AmsiEnable" /t REG_DWORD /d "0" /f >nul 2>&1
    set "operation_name=Выключение Windows Defender"
)

REM Проверка состояния Windows Defender
set "WINDF=%COL%[91mВЫКЛ" >nul 2>&1
set "errorlevel_a=%errorlevel%"

:: Run PowerShell command to check Windows Defender status
for /f "tokens=*" %%a in ('powershell -command "Get-MpComputerStatus | Select-Object -ExpandProperty AMServiceEnabled"') do set "defenderStatus=%%a"
:: Check the status and display the result
if "%defenderStatus%"=="True" (
    echo [INFO ] %TIME% - defenderStatus: %defenderStatus% >> "%ASX-Directory%\Files\Logs\%date%.txt"
) else (
    echo [INFO ] %TIME% - defenderStatus: %defenderStatus% >> "%ASX-Directory%\Files\Logs\%date%.txt"
)
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" | find "0x0" || set "WINDF=%COL%[92mВКЛ " >nul 2>&1
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack


:OneDrive
echo [INFO ] %TIME% - Вызван ":OneDrive" >> "%ASX-Directory%\Files\Logs\%date%.txt"
TITLE OneDrive Uninstaller - ASX Hub
reg add "%SaveData%\ParameterFunction" /v "OneDrive" /f >nul 2>&1
cls
set x86="%SYSTEMROOT%\System32\OneDriveSetup.exe"
set x64="%SYSTEMROOT%\SysWOW64\OneDriveSetup.exe"

echo Закрытие процесса OneDrive.
echo.
taskkill /f /im OneDrive.exe >nul 2>&1
taskkill /f /im OneDriveSetup.exe >nul 2>&1
taskkill /f /im OneDriveStandaloneUpdater.exe >nul 2>&1
timeout /t 3 /nobreak >nul

echo Деинсталляция OneDrive.
echo.
if exist "%SystemRoot%\System32\OneDriveSetup.exe" "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall >nul 2>&1
if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall >nul 2>&1
timeout /t 5 /nobreak >nul

echo Удаление остатков OneDrive.
echo.
rd "%UserProfile%\OneDrive" /q /s >nul 2>&1
rd "%LocalAppData%\Microsoft\OneDrive" /q /s >nul 2>&1
rd "%ProgramData%\Microsoft OneDrive" /q /s >nul 2>&1
rd "%SystemDrive%\OneDriveTemp" /q /s >nul 2>&1

for /f "usebackq delims=" %%a in (`dir /b /a:d "!SystemDrive!\Users"`) do (
    if exist "!SystemDrive!\Users\%%a\AppData\Local\Microsoft\OneDrive" (
        rmdir /q /s "!SystemDrive!\Users\%%a\AppData\Local\Microsoft\OneDrive" >nul 2>&1
    )
    if exist "!SystemDrive!\Users\%%a\OneDrive" (
        rmdir /q /s "!SystemDrive!\Users\%%a\OneDrive" >nul 2>&1
    )
    if exist "!SystemDrive!\Users\%%a\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" (
        del /q /f "!SystemDrive!\Users\%%a\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" >nul 2>&1
    )
)

echo Запрет установки OneDrive.
echo.
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f >nul 2>&1

echo Удаление OneDrive с боковой панели Проводника.
echo.
reg delete "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >nul 2>&1
reg delete "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >nul 2>&1
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /d "0" /t REG_DWORD /f >nul 2>&1
reg add "HKCR\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /d "0" /t REG_DWORD /f >nul 2>&1

echo Удаление OneDrive из реестра.
echo.
reg delete "HKCU\Environment" /v "OneDrive" /f >nul 2>&1
reg delete "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v OneDrive /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\OneDrive" /f >nul 2>&1

echo Удаление остаточных следов из системы.
echo.
rd /s /q "%userprofile%\AppData\Local\Microsoft\OneDrive" >nul 2>&1
rd /s /q "%ProgramData%\Microsoft OneDrive" >nul 2>&1

echo Удаление задачи OneDrive.
echo.
for /f "tokens=1 delims=," %%x in ('schtasks /query /fo csv ^| find "OneDrive"') do schtasks /Delete /TN "%%x" /F >nul 2>&1

echo Удаление остаточных файлов OneDrive.
echo.
del /F /Q "%SystemRoot%\System32\OneDriveSetup.exe" >nul 2>&1
del /F /Q "%SystemRoot%\SysWOW64\OneDriveSetup.exe" >nul 2>&1
del /F /Q "%SystemRoot%\SysWOW64\OneDriveSettingSyncProvider.dll" >nul 2>&1
rd /s /q "%SystemDrive%\OneDriveTemp" >nul 2>&1
rd /s /q "%ProgramData%\Microsoft OneDrive" >nul 2>&1

echo Удаление OneDrive из реестра пользователей.
echo.
for /f "usebackq tokens=2 delims=\" %%a in (`reg query "HKEY_USERS" ^| findstr /r /x /c:"HKEY_USERS\\S-.*" /c:"HKEY_USERS\\AME_UserHive_[^_]*"`) do (
    reg query "HKU\%%a" | findstr /c:"Volatile Environment" /c:"AME_UserHive_" >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "usebackq delims=" %%b in (`reg query "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\BannerStore" 2^>nul ^| findstr /i /c:"OneDrive"`) do (
            reg delete "%%b" /f >nul 2>&1
        )
        for /f "usebackq delims=" %%b in (`reg query "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\Handlers" 2^>nul ^| findstr /i /c:"OneDrive"`) do (
            reg delete "%%b" /f >nul 2>&1
        )
        for /f "usebackq delims=" %%b in (`reg query "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths" 2^>nul ^| findstr /i /c:"OneDrive"`) do (
            reg delete "%%b" /f >nul 2>&1
        )
        for /f "usebackq delims=" %%b in (`reg query "HKU\%%a\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" 2^>nul ^| findstr /i /c:"OneDrive"`) do (
            reg delete "%%b" /f >nul 2>&1
        )
    )
)

echo Остановка и удаление служб OneDrive.
echo.
sc stop OneSyncSvc >nul 2>&1
sc delete OneSyncSvc >nul 2>&1
for /f "tokens=*" %%s in ('sc query ^| find "OneSyncSvc_"') do (
    for /f "tokens=1 delims=:" %%n in ("%%s") do (
        sc stop %%n >nul 2>&1
        sc delete %%n >nul 2>&1
    )
)

echo Завершено.
echo.
REM Проверка удаления OneDrive
set "ONDR=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
reg query "%SaveData%\ParameterFunction" /v "OneDrive" >nul 2>&1 && set "ONDR=%COL%[92mВКЛ "
set "errorlevel=%errorlevel_a%"
set "operation_name=Удаление OneDrive"
call:Complete_notice
goto GoBack

:OneDrive-test-version
echo [INFO ] %TIME% - Вызван ":OneDrive-test-version" >> "%ASX-Directory%\Files\Logs\%date%.txt"
TITLE OneDrive Uninstaller TEST VERSION - ASX Hub

:: ------------------Kill OneDrive process-------------------
echo --- Завершение процесса OneDrive
:: Check and terminate the running process "OneDrive.exe"
tasklist /fi "ImageName eq OneDrive.exe" /fo csv 2>NUL | find /i "OneDrive.exe">NUL && (
    echo OneDrive.exe запущен и будет завершен.
    taskkill /f /im OneDrive.exe >nul 2>&1
) || (
    echo Пропуск, OneDrive.exe не запущен.
)


:: ---------------Remove OneDrive from startup---------------
echo --- Удаление OneDrive из автозагрузки
:: Delete the registry value "OneDrive" from the key "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" 
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$keyName = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Run'; $valueName = 'OneDrive'; $hive = $keyName.Split('\')[0]; $path = "^""$($hive):$($keyName.Substring($hive.Length))"^""; Write-Host "^""Removing the registry value '$valueName' from '$path'."^""; if (-Not (Test-Path -LiteralPath $path)) { Write-Host 'Skipping, no action needed, registry key does not exist.'; Exit 0; }; $existingValueNames = (Get-ItemProperty -LiteralPath $path).PSObject.Properties.Name; if (-Not ($existingValueNames -Contains $valueName)) { Write-Host 'Skipping, no action needed, registry value does not exist.'; Exit 0; }; try { if ($valueName -ieq '(default)') { Write-Host 'Removing the default value.'; $(Get-Item -LiteralPath $path).OpenSubKey('', $true).DeleteValue(''); } else { Remove-ItemProperty -LiteralPath $path -Name $valueName -Force -ErrorAction Stop; }; Write-Host 'Successfully removed the registry value.'; } catch { Write-Error "^""Failed to remove the registry value: $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1


:: --------Remove OneDrive through official installer--------
echo --- Удаление OneDrive через официальный установщик
if exist "%SYSTEMROOT%\System32\OneDriveSetup.exe" (
    "%SYSTEMROOT%\System32\OneDriveSetup.exe" /uninstall >nul 2>&1
) else (
    if exist "%SYSTEMROOT%\SysWOW64\OneDriveSetup.exe" (
        "%SYSTEMROOT%\SysWOW64\OneDriveSetup.exe" /uninstall >nul 2>&1
    ) else (
        echo Не удалось удалить, установщик не найден. 1>&2
    )
)


:: -------Remove OneDrive user data and synced folders-------
echo --- Удаление пользовательских данных и синхронизированных папок OneDrive
:: Delete directory  : "%USERPROFILE%\OneDrive*"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""$($directoryGlob = '%USERPROFILE%\OneDrive*'; if (-Not $directoryGlob.EndsWith('\')) { $directoryGlob += '\' }; $directoryGlob )"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $deletedCount = 0; $failedCount = 0; $oneDriveUserFolderPattern = [System.Environment]::ExpandEnvironmentVariables('%USERPROFILE%\OneDrive') + '*'; while ($true) { <# Loop to control the execution of the subsequent code #>; try { $userShellFoldersRegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'; if (-not (Test-Path $userShellFoldersRegistryPath)) { Write-Output "^""Skipping verification: The registry path for user shell folders is missing: `"^""$userShellFoldersRegistryPath`"^"""^""; break; }; $userShellFoldersRegistryKeys = Get-ItemProperty -Path $userShellFoldersRegistryPath; $userShellFoldersEntries = @($userShellFoldersRegistryKeys.PSObject.Properties); if ($userShellFoldersEntries.Count -eq 0) { Write-Warning "^""Skipping verification: No entries found for user shell folders in the registry: `"^""$userShellFoldersRegistryPath`"^"""^""; break; }; Write-Output "^""Initiating verification: Checking if any of the ${userShellFoldersEntries.Count} user shell folders point to the OneDrive user folder pattern ($oneDriveUserFolderPattern)."^""; $userShellFoldersInOneDrive = @(); foreach ($registryEntry in $userShellFoldersEntries) { $userShellFolderName = $registryEntry.Name; $userShellFolderPath = $registryEntry.Value; if (!$userShellFolderPath) { Write-Output "^""Skipping: The user shell folder `"^""$userShellFolderName`"^"" does not have a defined path."^""; continue; }; $expandedUserShellFolderPath = [System.Environment]::ExpandEnvironmentVariables($userShellFolderPath); if(-not ($expandedUserShellFolderPath -like $oneDriveUserFolderPattern)) { continue; }; $userShellFoldersInOneDrive += [PSCustomObject]@{ Name = $userShellFolderName;  Path = $expandedUserShellFolderPath }; }; if ($userShellFoldersInOneDrive.Count -gt 0) { $warningMessage = 'To keep your computer running smoothly, OneDrive user folder will not be deleted.'; $warningMessage += "^""`nIt's being used by the OS as a user shell directory for the following folders:"^""; $userShellFoldersInOneDrive.ForEach( { $warningMessage += "^""`n- $($_.Name): $($_.Path)"^""; }); Write-Warning $warningMessage; exit 0; }; Write-Output "^""Successfully verified that none of the $($userShellFoldersEntries.Count) user shell folders point to the OneDrive user folder pattern."^""; break; } catch { Write-Warning "^""An error occurred during verification of user shell folders. Skipping prevent potential issues. Error: $($_.Exception.Message)"^""; exit 0; }; }; $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { try { if (Test-Path -Path $path -PathType Leaf) { Write-Warning "^""Retaining file `"^""$path`"^"" to safeguard your data."^""; continue; } elseif (Test-Path -Path $path -PathType Container) { if ((Get-ChildItem "^""$path"^"" -Recurse | Measure-Object).Count -gt 0) { Write-Warning "^""Preserving non-empty folder `"^""$path`"^"" to protect your files."^""; continue; }; }; } catch { Write-Warning "^""An error occurred while processing `"^""$path`"^"". Skipping to protect your data. Error: $($_.Exception.Message)"^""; continue; }; if (-not (Test-Path $path)) { <# Re-check existence as prior deletions might remove subsequent items (e.g., subdirectories). #>; Write-Host "^""Successfully deleted: $($path) (already deleted)."^""; $deletedCount++; continue; }; try { Remove-Item -Path $path -Force -Recurse -ErrorAction Stop; $deletedCount++; Write-Host "^""Successfully deleted: $($path)"^""; } catch { $failedCount++; Write-Warning "^""Unable to delete $($path): $_"^""; }; }; Write-Host "^""Successfully deleted $($deletedCount) items."^""; if ($failedCount -gt 0) { Write-Warning "^""Failed to delete $($failedCount) items."^""; }"
chcp 65001 >nul 2>&1


:: -------Remove OneDrive installation files and cache-------
echo --- Удаление установочных файлов и кэша OneDrive
:: Delete directory (with additional permissions) : "%LOCALAPPDATA%\Microsoft\OneDrive"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""$($directoryGlob = '%LOCALAPPDATA%\Microsoft\OneDrive'; if (-Not $directoryGlob.EndsWith('\')) { $directoryGlob += '\' }; $directoryGlob )"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; <# Not using `Get-Acl`/`Set-Acl` to avoid adjusting token privileges #>; $parentDirectory = [System.IO.Path]::GetDirectoryName($expandedPath); $fileName = [System.IO.Path]::GetFileName($expandedPath); if ($parentDirectory -like '*[*?]*') { throw "^""Unable to grant permissions to glob path parent directory: `"^""$parentDirectory`"^"", wildcards in parent directory are not supported by ``takeown`` and ``icacls``."^""; }; if (($fileName -ne '*') -and ($fileName -like '*[*?]*')) { throw "^""Unable to grant permissions to glob path file name: `"^""$fileName`"^"", wildcards in file name is not supported by ``takeown`` and ``icacls``."^""; }; Write-Host "^""Taking ownership of `"^""$expandedPath`"^""."^""; $cmdPath = $expandedPath; if ($cmdPath.EndsWith('\')) { $cmdPath += '\' <# Escape trailing backslash for correct handling in batch commands #>; }; $takeOwnershipCommand = "^""takeown /f `"^""$cmdPath`"^"" /a"^"" <# `icacls /setowner` does not succeed, so use `takeown` instead. #>; if (-not (Test-Path -Path "^""$expandedPath"^"" -PathType Leaf)) { $localizedYes = 'Y' <# Default 'Yes' flag (fallback) #>; try { $choiceOutput = cmd /c "^""choice <nul 2>nul"^""; if ($choiceOutput -and $choiceOutput.Length -ge 2) { $localizedYes = $choiceOutput[1]; } else { Write-Warning "^""Failed to determine localized 'Yes' character. Output: `"^""$choiceOutput`"^"""^""; }; } catch { Write-Warning "^""Failed to determine localized 'Yes' character. Error: $_"^""; }; $takeOwnershipCommand += "^"" /r /d $localizedYes"^""; }; $takeOwnershipOutput = cmd /c "^""$takeOwnershipCommand 2>&1"^"" <# `stderr` message is misleading, e.g. "^""ERROR: The system cannot find the file specified."^"" is not an error. #>; if ($LASTEXITCODE -eq 0) { Write-Host "^""Successfully took ownership of `"^""$expandedPath`"^"" (using ``$takeOwnershipCommand``)."^""; } else { Write-Host "^""Did not take ownership of `"^""$expandedPath`"^"" using ``$takeOwnershipCommand``, status code: $LASTEXITCODE, message: $takeOwnershipOutput."^""; <# Do not write as error or warning, because this can be due to missing path, it's handled in next command. #>; <# `takeown` exits with status code `1`, making it hard to handle missing path here. #>; }; Write-Host "^""Granting permissions for `"^""$expandedPath`"^""."^""; $adminSid = New-Object System.Security.Principal.SecurityIdentifier 'S-1-5-32-544'; $adminAccount = $adminSid.Translate([System.Security.Principal.NTAccount]); $adminAccountName = $adminAccount.Value; $grantPermissionsCommand = "^""icacls `"^""$cmdPath`"^"" /grant `"^""$($adminAccountName):F`"^"" /t"^""; $icaclsOutput = cmd /c "^""$grantPermissionsCommand"^""; if ($LASTEXITCODE -eq 3) { Write-Host "^""Skipping, no items available for deletion according to: ``$grantPermissionsCommand``."^""; exit 0; } elseif ($LASTEXITCODE -ne 0) { Write-Host "^""Take ownership message:`n$takeOwnershipOutput"^""; Write-Host "^""Grant permissions:`n$icaclsOutput"^""; Write-Warning "^""Failed to assign permissions for `"^""$expandedPath`"^"" using ``$grantPermissionsCommand``, status code: $LASTEXITCODE."^""; } else { $fileStats = $icaclsOutput | ForEach-Object { $_ -match '\d+' | Out-Null; $matches[0] } | Where-Object { $_ -ne $null } | ForEach-Object { [int]$_ }; if ($fileStats.Count -gt 0 -and ($fileStats | ForEach-Object { $_ -eq 0 } | Where-Object { $_ -eq $false }).Count -eq 0) { Write-Host "^""Skipping, no items available for deletion according to: ``$grantPermissionsCommand``."^""; exit 0; } else { Write-Host "^""Successfully granted permissions for `"^""$expandedPath`"^"" (using ``$grantPermissionsCommand``)."^""; }; }; $deletedCount = 0; $failedCount = 0; $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (-not (Test-Path $path)) { <# Re-check existence as prior deletions might remove subsequent items (e.g., subdirectories). #>; Write-Host "^""Successfully deleted: $($path) (already deleted)."^""; $deletedCount++; continue; }; try { Remove-Item -Path $path -Force -Recurse -ErrorAction Stop; $deletedCount++; Write-Host "^""Successfully deleted: $($path)"^""; } catch { $failedCount++; Write-Warning "^""Unable to delete $($path): $_"^""; }; }; Write-Host "^""Successfully deleted $($deletedCount) items."^""; if ($failedCount -gt 0) { Write-Warning "^""Failed to delete $($failedCount) items."^""; }"
:: Delete directory  : "%PROGRAMDATA%\Microsoft OneDrive"
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""$($directoryGlob = '%PROGRAMDATA%\Microsoft OneDrive'; if (-Not $directoryGlob.EndsWith('\')) { $directoryGlob += '\' }; $directoryGlob )"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $deletedCount = 0; $failedCount = 0; $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (-not (Test-Path $path)) { <# Re-check existence as prior deletions might remove subsequent items (e.g., subdirectories). #>; Write-Host "^""Successfully deleted: $($path) (already deleted)."^""; $deletedCount++; continue; }; try { Remove-Item -Path $path -Force -Recurse -ErrorAction Stop; $deletedCount++; Write-Host "^""Successfully deleted: $($path)"^""; } catch { $failedCount++; Write-Warning "^""Unable to delete $($path): $_"^""; }; }; Write-Host "^""Successfully deleted $($deletedCount) items."^""; if ($failedCount -gt 0) { Write-Warning "^""Failed to delete $($failedCount) items."^""; }"
:: Delete directory  : "%SYSTEMDRIVE%\OneDriveTemp"
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""$($directoryGlob = '%SYSTEMDRIVE%\OneDriveTemp'; if (-Not $directoryGlob.EndsWith('\')) { $directoryGlob += '\' }; $directoryGlob )"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $deletedCount = 0; $failedCount = 0; $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (-not (Test-Path $path)) { <# Re-check existence as prior deletions might remove subsequent items (e.g., subdirectories). #>; Write-Host "^""Successfully deleted: $($path) (already deleted)."^""; $deletedCount++; continue; }; try { Remove-Item -Path $path -Force -Recurse -ErrorAction Stop; $deletedCount++; Write-Host "^""Successfully deleted: $($path)"^""; } catch { $failedCount++; Write-Warning "^""Unable to delete $($path): $_"^""; }; }; Write-Host "^""Successfully deleted $($deletedCount) items."^""; if ($failedCount -gt 0) { Write-Warning "^""Failed to delete $($failedCount) items."^""; }"
chcp 65001 >nul 2>&1


:: ----------------Remove OneDrive shortcuts-----------------
echo --- Удаление ярлыков OneDrive
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$shortcuts = @(; @{ Revert = $True;  Path = "^""$env:APPDATA\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"^""; }; @{ Revert = $False; Path = "^""$env:USERPROFILE\Links\OneDrive.lnk"^""; }; @{ Revert = $False; Path = "^""$env:SYSTEMROOT\ServiceProfiles\LocalService\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"^""; }; @{ Revert = $False; Path = "^""$env:SYSTEMROOT\ServiceProfiles\NetworkService\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"^""; }; ); foreach ($shortcut in $shortcuts) { if (-Not (Test-Path $shortcut.Path)) { Write-Host "^""Skipping, shortcut does not exist: `"^""$($shortcut.Path)`"^""."^""; continue; }; try { Remove-Item -Path $shortcut.Path -Force -ErrorAction Stop; Write-Output "^""Successfully removed shortcut: `"^""$($shortcut.Path)`"^""."^""; } catch { Write-Error "^""Encountered an issue while attempting to remove shortcut at: `"^""$($shortcut.Path)`"^""."^""; }; }"
PowerShell -ExecutionPolicy Unrestricted -Command "Set-Location "^""HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace"^""; Get-ChildItem | ForEach-Object {Get-ItemProperty $_.pspath} | ForEach-Object { $leftnavNodeName = $_."^""(default)"^""; if (($leftnavNodeName -eq "^""OneDrive"^"") -Or ($leftnavNodeName -eq "^""OneDrive - Personal"^"")) { if (Test-Path $_.pspath) { Write-Host "^""Deleting $($_.pspath)."^""; Remove-Item $_.pspath; }; }; }"
chcp 65001 >nul 2>&1


:: ------------------Disable OneDrive usage------------------
echo --- Отключение использования OneDrive
chcp 850 >nul 2>&1
:: Set the registry value: "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive!DisableFileSyncNGSC"
PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive'; $data = '1'; reg add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive' /v 'DisableFileSyncNGSC' /t 'REG_DWORD' /d "^""$data"^"" /f"
:: Set the registry value: "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive!DisableFileSync"
PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive'; $data = '1'; reg add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive' /v 'DisableFileSync' /t 'REG_DWORD' /d "^""$data"^"" /f"
chcp 65001 >nul 2>&1


:: ---------Disable automatic OneDrive installation----------
echo --- Отключение автоматической установки OneDrive
:: Delete the registry value "OneDriveSetup" from the key "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" 
:: This operation will not run on Windows versions earlier than Windows10-1909.This operation will not run on Windows versions later than Windows10-1909.
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$versionName = 'Windows10-1909'; $buildNumber = switch ($versionName) { 'Windows11-FirstRelease' { '10.0.22000' }; 'Windows11-22H2' { '10.0.22621' }; 'Windows11-21H2' { '10.0.22000' }; 'Windows10-22H2' { '10.0.19045' }; 'Windows10-21H2' { '10.0.19044' }; 'Windows10-20H2' { '10.0.19042' }; 'Windows10-1909' { '10.0.18363' }; 'Windows10-1607' { '10.0.14393' }; default { throw "^""Internal privacy$([char]0x002E)error: No build for minimum Windows '$versionName'"^""; }; }; $minVersion = [System.Version]::Parse($buildNumber); $ver = [Environment]::OSVersion.Version; $verNoPatch = [System.Version]::new($ver.Major, $ver.Minor, $ver.Build); if ($verNoPatch -lt $minVersion) { Write-Output "^""Skipping: Windows ($verNoPatch) is below minimum $minVersion ($versionName)"^""; Exit 0; }$versionName = 'Windows10-1909'; $buildNumber = switch ($versionName) { 'Windows11-21H2' { '10.0.22000' }; 'Windows10-MostRecent' { '10.0.19045' }; 'Windows10-22H2' { '10.0.19045' }; 'Windows10-1909' { '10.0.18363' }; 'Windows10-1903' { '10.0.18362' }; default { throw "^""Internal privacy$([char]0x002E)error: No build for maximum Windows '$versionName'"^""; }; }; $maxVersion=[System.Version]::Parse($buildNumber); $ver = [Environment]::OSVersion.Version; $verNoPatch = [System.Version]::new($ver.Major, $ver.Minor, $ver.Build); if ($verNoPatch -gt $maxVersion) { Write-Output "^""Skipping: Windows ($verNoPatch) is above maximum $maxVersion ($versionName)"^""; Exit 0; }; $keyName = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Run'; $valueName = 'OneDriveSetup'; $hive = $keyName.Split('\')[0]; $path = "^""$($hive):$($keyName.Substring($hive.Length))"^""; Write-Host "^""Removing the registry value '$valueName' from '$path'."^""; if (-Not (Test-Path -LiteralPath $path)) { Write-Host 'Skipping, no action needed, registry key does not exist.'; Exit 0; }; $existingValueNames = (Get-ItemProperty -LiteralPath $path).PSObject.Properties.Name; if (-Not ($existingValueNames -Contains $valueName)) { Write-Host 'Skipping, no action needed, registry value does not exist.'; Exit 0; }; try { if ($valueName -ieq '(default)') { Write-Host 'Removing the default value.'; $(Get-Item -LiteralPath $path).OpenSubKey('', $true).DeleteValue(''); } else { Remove-ItemProperty -LiteralPath $path -Name $valueName -Force -ErrorAction Stop; }; Write-Host 'Successfully removed the registry value.'; } catch { Write-Error "^""Failed to remove the registry value: $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1


:: --------Remove OneDrive folder from File Explorer---------
echo --- Удаление папки OneDrive из проводника
chcp 850 >nul 2>&1
:: Set the registry value: "HKCU\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}!System.IsPinnedToNameSpaceTree"
PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKCU\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}'; $data = '0'; reg add 'HKCU\Software\Classes\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' /v 'System.IsPinnedToNameSpaceTree' /t 'REG_DWORD' /d "^""$data"^"" /f"
:: Set the registry value: "HKCU\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}!System.IsPinnedToNameSpaceTree"
PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKCU\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}'; $data = '0'; reg add 'HKCU\Software\Classes\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}' /v 'System.IsPinnedToNameSpaceTree' /t 'REG_DWORD' /d "^""$data"^"" /f"
chcp 65001 >nul 2>&1

:: -------------Disable OneDrive scheduled tasks-------------
echo --- Отключение запланированных задач OneDrive
chcp 850 >nul 2>&1
:: Disable scheduled task(s): `\OneDrive Reporting Task-*`
PowerShell -ExecutionPolicy Unrestricted -Command "$taskPathPattern='\'; $taskNamePattern='OneDrive Reporting Task-*'; Write-Output "^""Disabling tasks matching pattern `"^""$taskNamePattern`"^""."^""; $tasks = @(Get-ScheduledTask -TaskPath $taskPathPattern -TaskName $taskNamePattern -ErrorAction Ignore); if (-Not $tasks) { Write-Output "^""Skipping, no tasks matching pattern `"^""$taskNamePattern`"^"" found, no action needed."^""; exit 0; }; $operationFailed = $false; foreach ($task in $tasks) { $taskName = $task.TaskName; if ($task.State -eq [Microsoft.PowerShell.Cmdletization.GeneratedTypes.ScheduledTask.StateEnum]::Disabled) { Write-Output "^""Skipping, task `"^""$taskName`"^"" is already disabled, no action needed."^""; continue; }; try { $task | Disable-ScheduledTask -ErrorAction Stop | Out-Null; Write-Output "^""Successfully disabled task `"^""$taskName`"^""."^""; } catch { Write-Error "^""Failed to disable task `"^""$taskName`"^"": $($_.Exception.Message)"^""; $operationFailed = $true; }; }; if ($operationFailed) { Write-Output 'Failed to disable some tasks. Check error messages above.'; exit 1; }"
:: Disable scheduled task(s): `\OneDrive Standalone Update Task-*`
PowerShell -ExecutionPolicy Unrestricted -Command "$taskPathPattern='\'; $taskNamePattern='OneDrive Standalone Update Task-*'; Write-Output "^""Disabling tasks matching pattern `"^""$taskNamePattern`"^""."^""; $tasks = @(Get-ScheduledTask -TaskPath $taskPathPattern -TaskName $taskNamePattern -ErrorAction Ignore); if (-Not $tasks) { Write-Output "^""Skipping, no tasks matching pattern `"^""$taskNamePattern`"^"" found, no action needed."^""; exit 0; }; $operationFailed = $false; foreach ($task in $tasks) { $taskName = $task.TaskName; if ($task.State -eq [Microsoft.PowerShell.Cmdletization.GeneratedTypes.ScheduledTask.StateEnum]::Disabled) { Write-Output "^""Skipping, task `"^""$taskName`"^"" is already disabled, no action needed."^""; continue; }; try { $task | Disable-ScheduledTask -ErrorAction Stop | Out-Null; Write-Output "^""Successfully disabled task `"^""$taskName`"^""."^""; } catch { Write-Error "^""Failed to disable task `"^""$taskName`"^"": $($_.Exception.Message)"^""; $operationFailed = $true; }; }; if ($operationFailed) { Write-Output 'Failed to disable some tasks. Check error messages above.'; exit 1; }"
:: Disable scheduled task(s): `\OneDrive Per-Machine Standalone Update`
PowerShell -ExecutionPolicy Unrestricted -Command "$taskPathPattern='\'; $taskNamePattern='OneDrive Per-Machine Standalone Update'; Write-Output "^""Disabling tasks matching pattern `"^""$taskNamePattern`"^""."^""; $tasks = @(Get-ScheduledTask -TaskPath $taskPathPattern -TaskName $taskNamePattern -ErrorAction Ignore); if (-Not $tasks) { Write-Output "^""Skipping, no tasks matching pattern `"^""$taskNamePattern`"^"" found, no action needed."^""; exit 0; }; $operationFailed = $false; foreach ($task in $tasks) { $taskName = $task.TaskName; if ($task.State -eq [Microsoft.PowerShell.Cmdletization.GeneratedTypes.ScheduledTask.StateEnum]::Disabled) { Write-Output "^""Skipping, task `"^""$taskName`"^"" is already disabled, no action needed."^""; continue; }; try { $task | Disable-ScheduledTask -ErrorAction Stop | Out-Null; Write-Output "^""Successfully disabled task `"^""$taskName`"^""."^""; } catch { Write-Error "^""Failed to disable task `"^""$taskName`"^"": $($_.Exception.Message)"^""; $operationFailed = $true; }; }; if ($operationFailed) { Write-Output 'Failed to disable some tasks. Check error messages above.'; exit 1; }"
chcp 65001 >nul 2>&1


:: -----------Clear OneDrive environment variable------------
echo --- Очистка переменных среды OneDrive
chcp 850 >nul 2>&1
:: Delete the registry value "OneDrive" from the key "HKCU\Environment" 
PowerShell -ExecutionPolicy Unrestricted -Command "$keyName = 'HKCU\Environment'; $valueName = 'OneDrive'; $hive = $keyName.Split('\')[0]; $path = "^""$($hive):$($keyName.Substring($hive.Length))"^""; Write-Host "^""Removing the registry value '$valueName' from '$path'."^""; if (-Not (Test-Path -LiteralPath $path)) { Write-Host 'Skipping, no action needed, registry key does not exist.'; Exit 0; }; $existingValueNames = (Get-ItemProperty -LiteralPath $path).PSObject.Properties.Name; if (-Not ($existingValueNames -Contains $valueName)) { Write-Host 'Skipping, no action needed, registry value does not exist.'; Exit 0; }; try { if ($valueName -ieq '(default)') { Write-Host 'Removing the default value.'; $(Get-Item -LiteralPath $path).OpenSubKey('', $true).DeleteValue(''); } else { Remove-ItemProperty -LiteralPath $path -Name $valueName -Force -ErrorAction Stop; }; Write-Host 'Successfully removed the registry value.'; } catch { Write-Error "^""Failed to remove the registry value: $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

echo Завершено.
echo.
REM Проверка удаления OneDrive
set "ONDR=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
reg query "%SaveData%\ParameterFunction" /v "OneDrive" >nul 2>&1 && set "ONDR=%COL%[92mВКЛ "
set "errorlevel=%errorlevel_a%"
set "operation_name=Удаление OneDrive"
call:Complete_notice
goto GoBack

:DisableWallpapercompression
echo [INFO ] %TIME% - Вызван ":DisableWallpapercompression" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%DWLC%" == "%COL%[92mВКЛ " (
    reg add "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /t REG_DWORD /d 256 /f >nul 2>&1
    set "operation_name=Отключение сжатия обоев"
) else (
    REM reg delete "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /f >nul 2>&1
    reg add "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" /t REG_DWORD /d 100 /f >nul 2>&1
    set "operation_name=Включение сжатия обоев"
)
REM Проверка сжатия обоев рабочего стола
set "DWLC=%COL%[92mВКЛ " >nul 2>&1
set "errorlevel_a=%errorlevel%"
reg query "HKCU\Control Panel\Desktop" /v "JPEGImportQuality" | find "0x100" && set "DWLC=%COL%[91mВЫКЛ" >nul 2>&1
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:DisableStickyKeys
    echo [INFO ] %TIME% - Вызван ":DisableStickyKeys" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%DSKN%" == "%COL%[92mВКЛ " (
    reg add "HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Control Panel\Accessibility\SoundSentry" /v "Flags" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "DelayBeforeAcceptance" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatRate" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatDelay" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f >nul 2>&1
    reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f >nul 2>&1
    set "operation_name=Отключение залипания клавиш"
) >nul 2>&1 else (
    reg add "HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "510" /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Control Panel\Accessibility\SoundSentry" /v "Flags" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "DelayBeforeAcceptance" /t REG_SZ /d "1000" /f >nul 2>&1
    reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatRate" /t REG_SZ /d "500" /f >nul 2>&1
    reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatDelay" /t REG_SZ /d "1000" /f >nul 2>&1
    reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "126" /f >nul 2>&1
    reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "62" /f >nul 2>&1
	set "operation_name=Возвращение залипаний клавиш"	
) >nul 2>&1
REM Проверка отключения залипания клавиш
set "DSKN=%COL%[92mВКЛ " >nul 2>&1
set "errorlevel_a=%errorlevel%"
reg query "HKEY_CURRENT_USER\Control Panel\Accessibility\StickyKeys" /v "Flags" | find "506" && set "DSKN=%COL%[91mВЫКЛ" >nul 2>&1
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:MouseAcceleration
    rem Повышенная точность установки указателя мыши
    echo [INFO ] %TIME% - Вызван ":MouseAcceleration" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%MOAC%" == "%COL%[92mВКЛ " (
    reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
    reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1
    set "operation_name=Отключение повышенной точности установки указателя мыши"
) >nul 2>&1 else (
    reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 1 /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 6 /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 10 /f >nul 2>&1
	set "operation_name=Возвращение повышенной точности установки указателя мыши"	
) >nul 2>&1
REM Проверка повышенной точности установки указателя мыши
set "errorlevel_a=%errorlevel%"
for /f "tokens=3" %%A in ('reg query "HKCU\Control Panel\Mouse" /v MouseSpeed 2^>nul') do (
    if "%%A"=="0" (
        set "MOAC=%COL%[91mВЫКЛ"
    ) else (
        set "MOAC=%COL%[92mВКЛ "
    )
)
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:HideCreativeCloudFiles
echo [INFO ] %TIME% - Вызван ":HideCreativeCloudFiles" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%HCCF%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_CLASSES_ROOT\CLSID\{0E270DAA-1BE6-48F2-AC49-12C0502DD12A}"  /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "HKEY_CLASSES_ROOT\CLSID\{0E270DAA-1BE6-48F2-AC49-FA88F404D493}"  /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f >nul 2>&1	
	set "operation_name=Скрытие Creative Cloud Files из проводника"		
) >nul 2>&1 else (
reg add "HKEY_CLASSES_ROOT\CLSID\{0E270DAA-1BE6-48F2-AC49-12C0502DD12A}"  /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "1" /f >nul 2>&1
	set "operation_name=Возвращение Creative Cloud Files в проводник"	
) >nul 2>&1
REM Проверка видимости файлов Creative Cloud в проводнике
set "HCCF=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
reg query "HKEY_CLASSES_ROOT\CLSID\{0E270DAA-1BE6-48F2-AC49-12C0502DD12A}" /v "System.IsPinnedToNameSpaceTree" | find "0x0" >nul 2>&1 || (
	reg query "HKEY_CLASSES_ROOT\CLSID\{0E270DAA-1BE6-48F2-AC49-FA88F404D493}" /v "System.IsPinnedToNameSpaceTree" | find "0x0" >nul 2>&1 || set "HCCF=%COL%[92mВКЛ "
)
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:RemoveIconsFromThisComputer
rem удаление иконок из проводника
echo [INFO ] %TIME% - Вызван ":RemoveIconsFromThisComputer" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%THPC%" == "%COL%[91mВЫКЛ" (
    		REM ; 3d objects...
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f >nul 2>&1
    		REM ; Desktop...
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f >nul 2>&1
    		REM ; Downloads...
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" /f >nul 2>&1
    		REM ; Documents...
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" /f >nul 2>&1
    		REM ; Music...
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f >nul 2>&1
    		REM ; Images...
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f >nul 2>&1
    		REM ; Video...
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f >nul 2>&1
	set "operation_name=Удаление иконок (Документы, Музыка и т.д.) из Этот компьютер"		
) >nul 2>&1 else (
    		REM ; Desktop...
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f >nul 2>&1
    		REM ; Downloads...
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" /f >nul 2>&1
    		REM ; Documents...
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" /f >nul 2>&1
    		REM ; Music...
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" /f >nul 2>&1
    		REM ; Images...
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" /f >nul 2>&1
    		REM ; Video...
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" /f >nul 2>&1
	set "operation_name=Возвращение иконок в Этот компьютер"	
) >nul 2>&1
call:Complete_notice
goto GoBack

:RemoveEdge
echo [INFO ] %TIME% - Вызван ":RemoveEdge" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%REDG%" == "%COL%[90mН/Д " (
	REM Предоставьте администраторам полный контроль над папкой Microsoft Edge.
	icacls "%ProgramFiles(x86)%\Microsoft\Edge" /t /c /q /grant administrators:F

	REM Станьте владельцем папки Microsoft Edge
	takeown /f "%ProgramFiles(x86)%\Microsoft\Edge" /r /d y

	REM Завершить процессы Microsoft Edge
	taskkill /f /im msedge.exe

	REM Удалите Microsoft Edge с помощью инструмента установки.
	if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application" (
		for /d %%I in ("%ProgramFiles(x86)%\Microsoft\Edge\Application\*") do (
			if exist "%%I\Installer\setup.exe" (
				"%%I\Installer\setup.exe" --uninstall --force-uninstall --system-level
			)
		)
	)

	REM Удалить папки Microsoft Edge
	if exist "%ProgramFiles(x86)%\Microsoft\Edge" (
		rmdir /s /q "%ProgramFiles(x86)%\Microsoft\Edge"
	)
	reg add "%SaveData%\ParameterFunction" /v RemoveEdge /f >nul 2>&1

    set "operation_name=Удаление Edge и всего, что с ним связанно"
) else (
	chcp 850 >nul 2>&1
	powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Данная функция уже активирована. Деактивация невозможна', 'ASX Hub', 'OK', [System.Windows.Forms.MessageBoxIcon]::Information);}" >nul 2>&1
	chcp 65001 >nul 2>&1
    goto GoBack
)
REM Проверка удаления Microsoft Edge
set "REDG=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
reg query "%SaveData%\ParameterFunction" /v "RemoveEdge" >nul 2>&1 && set "REDG=%COL%[92mВКЛ "
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:SecurityCenterNotifications
echo [INFO ] %TIME% - Вызван ":SecurityCenterNotifications" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%WDNT%" == "%COL%[91mВЫКЛ" (
    reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /f >nul 2>&1
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" /f >nul 2>&1
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v "DisableNotifications" /f >nul 2>&1
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" /v "DisableNotifications" /f >nul 2>&1
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" /v "DisableNotifications" /f >nul 2>&1
    set "operation_name=Возвращение назойливых уведомлений о безопасности от центра уведомлений"
) >nul 2>&1 else (
    reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /F /V "Enabled" /T REG_DWORD /d 0 >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /F /V "Enabled" /T REG_DWORD /d 0 >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /F /V "DisableNotifications" /T REG_DWORD /d 1 >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /F /V "Enabled" /T REG_DWORD /d 0 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" /F /V "DisableNotifications" /T REG_DWORD /d 1 >nul 2>&1
	set "operation_name=Отключение назойливых уведомлений о безопасности от центра уведомлений"
) >nul 2>&1
REM Проверка отключения уведомлений Windows Defender
set "WDNT=%COL%[92mВКЛ "
set "errorlevel_a=%errorlevel%"
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" | findstr /i "0x0" >nul 2>&1 && set "WDNT=%COL%[91mВЫКЛ"
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:AppStartNotify
echo [INFO ] %TIME% - Вызван ":AppStartNotify" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%APSN%" == "%COL%[91mВЫКЛ" (
    REM ВКЛЮЧЕНИЕ
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Security" /F /V "DisableSecuritySettingsCheck" /T REG_DWORD /d 0 >nul 2>&1
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v LowRiskFileTypes /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /F /V "1806" /T REG_DWORD /d 0 >nul 2>&1
	set "operation_name=Включение предупреждений при запуске любых exe"
) >nul 2>&1 else (
    REM ОТКЛЮЧЕНИЕ
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Security" /F /V "DisableSecuritySettingsCheck" /T REG_DWORD /d 1 >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Associations" /v LowRiskFileTypes /t REG_SZ /d ".exe;.bat;.cmd;.reg;.vbs;.msi;.msp;.com;.ps1;.ps2;.cpl" /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Zones\3" /F /V "1806" /T REG_DWORD /d 0 >nul 2>&1
 set "operation_name=Отключение предупреждений при запуске любых exe"	
) >nul 2>&1
REM Проверка отключения уведомлений о запуске приложений
set "APSN=%COL%[92mВКЛ "
set "errorlevel_a=%errorlevel%"
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Internet Explorer\Security" /v "DisableSecuritySettingsCheck" | findstr /i "0x1" >nul 2>&1 && set "APSN=%COL%[91mВЫКЛ"
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:PrioritizeGamingTasks
echo [INFO ] %TIME% - Вызван ":PrioritizeGamingTasks" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%PGMT%" == "%COL%[91mВЫКЛ" (
    REM ВКЛЮЧЕНИЕ Приоритета
    Rem reg add "%SaveData%\ParameterFunction" /F /V "PrioritizeGamingTask" /T REG_SZ /d 0 >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /F /V "Priority" /T REG_DWORD /d 6 >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /F /V "Scheduling Category" /T REG_SZ /d "High" >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /F /V "GPU Priority" /T REG_DWORD /d 8 >nul 2>&1
	set "operation_name=Включение приоритизации игровых задач"
) >nul 2>&1 else (
    REM ОТКЛЮЧЕНИЕ Приоритета
    Rem reg delete "%SaveData%\ParameterFunction" /v "PrioritizeGamingTask" /f >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /F /V "Priority" /T REG_DWORD /d 2 >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /F /V "Scheduling Category" /T REG_SZ /d "Medium" >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /F /V "GPU Priority" /T REG_DWORD /d 8 >nul 2>&1
    set "operation_name=Отключение приоритизации игровых задач"	
) >nul 2>&1
REM Проверка приоритета игровых процессов
set "PGMT=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" | find "0x2" >nul 2>&1 || set "PGMT=%COL%[92mВКЛ "
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:UAC
echo [INFO ] %TIME% - Вызван ":UAC" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%UACS%" == "%COL%[91mВЫКЛ" ( 
    REM ВКЛЮЧЕНИЕ
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "ConsentPromptBehaviorAdmin" /T REG_DWORD /d 5 >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "ConsentPromptBehaviorUser" /T REG_DWORD /d 3 >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "EnableInstallerDetection" /T REG_DWORD /d 1 >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "EnableLUA" /T REG_DWORD /d 1 >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "EnableVirtualization" /T REG_DWORD /d 1 >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "PromptOnSecureDesktop" /T REG_DWORD /d 1 >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "ValidateAdminCodeSignatures" /T REG_DWORD /d 0 >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "FilterAdministratorToken" /T REG_DWORD /d 0 >nul 2>&1
    set "operation_name=Включение UAC"
) >nul 2>&1 else (
	REM ОТКЛЮЧЕНИЕ
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "ConsentPromptBehaviorAdmin" /T REG_DWORD /d 0 >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "ConsentPromptBehaviorUser" /T REG_DWORD /d 3 >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "EnableInstallerDetection" /T REG_DWORD /d 1 >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "EnableLUA" /T REG_DWORD /d 1 >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "EnableVirtualization" /T REG_DWORD /d 1 >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "PromptOnSecureDesktop" /T REG_DWORD /d 0 >nul 2>&1
 	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "ValidateAdminCodeSignatures" /T REG_DWORD /d 0 >nul 2>&1       
 	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /F /V "FilterAdministratorToken" /T REG_DWORD /d 0 >nul 2>&1   
	set "operation_name=Отключение UAC"
) >nul 2>&1
REM Проверка состояния UAC (Контроль учетных записей пользователей)
set "UACS=%COL%[92mВКЛ "
set "errorlevel_a=%errorlevel%"
for /f "tokens=3" %%A in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" 2^>nul') do (
	if "%%A"=="0x0" set "UACS=%COL%[91mВЫКЛ"
)
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:HwSchMode
echo [INFO ] %TIME% - Вызван ":HwSchMode" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%SchM%" == "%COL%[91mВЫКЛ" (
    REM ВКЛЮЧЕНИЕ
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /F /V "HwSchMode" /T REG_DWORD /d 2 >nul 2>&1
	set "operation_name=Включение Планирования графического процессора с аппаратным ускорением"
) >nul 2>&1 else (
    REM ОТКЛЮЧЕНИЕ
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /F /V "HwSchMode" /T REG_DWORD /d 1 >nul 2>&1
    set "operation_name=Отключение Планирования графического процессора с аппаратным ускорением"	
) >nul 2>&1
REM Проверка режима аппаратного планирования GPU
set "SchM=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" | find "0x1" >nul 2>&1 || set "SchM=%COL%[92mВКЛ "
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:TIIP
echo [INFO ] %TIME% - Вызван ":TIIP" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%TIIP%" == "%COL%[90mН/Д " (
    reg add "%SaveData%\ParameterFunction" /v "TIIP" /f >nul 2>&1
    REM ВЫКЛЮЧЕНИЕ
    netsh interface teredo set state disabled
    netsh interface isatap set state disabled
    netsh int ipv6 isatap set state disabled
    netsh int ipv6 6to4 set state disabled
    netsh interface IPV6 set global randomizeidentifier=disabled
    netsh interface IPV6 set privacy state=disabled
	set "operation_name=Выключение Teredo, ISATAP и IPv6"
) >nul 2>&1 else (
    reg del "%SaveData%\ParameterFunction" /v "TIIP" /f >nul 2>&1
    REM ВКЛЮЧЕНИЕ
    netsh interface teredo set state enabled
    netsh interface isatap set state enabled
    netsh int ipv6 isatap set state enabled
    netsh int ipv6 6to4 set state enabled
    netsh interface IPV6 set global randomizeidentifier=enabled
    netsh interface IPV6 set privacy state=enabled
    set "operation_name=Включение Teredo, ISATAP и IPv6"	
) >nul 2>&1
REM Проверка отключения Teredo, ISATAP и IPv6
set "TIIP=%COL%[92mВКЛ "
set "errorlevel_a=%errorlevel%"
reg query "%SaveData%\ParameterFunction" /v "TIIP" >nul 2>&1 && set "TIIP=%COL%[91mВЫКЛ"
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:MSRT_in_WindowsUpdate
echo [INFO ] %TIME% - Вызван ":MSRT_in_WindowsUpdate" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%MSRT%" == "%COL%[91mВЫКЛ" (
    REM ВЫКЛЮЧЕНИЕ
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d 1 /f >nul 2>&1
    set "operation_name=Отключение MSRT в Windows Update"
) else (
    REM ВКЛЮЧЕНИЕ
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /f >nul 2>&1
    set "operation_name=Включение MSRT в Windows Update"
)
REM Проверка отключения определений MSRT (Malicious Software Removal Tool)
set "MSRT=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
reg query "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" | findstr /i "0x1" >nul 2>&1 && set "MSRT=%COL%[92mВКЛ "
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:DisableSleepingMode
echo [INFO ] %TIME% - Вызван ":DisableSleepingMode" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%SLMD%" == "%COL%[91mВЫКЛ" (
    REM ВЫКЛЮЧЕНИЕ
    powercfg /change standby-timeout-ac 0
    powercfg /change standby-timeout-dc 0
    powercfg /change hibernate-timeout-ac 0
    powercfg /change hibernate-timeout-dc 0
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f >nul 2>&1
    set "operation_name=Отключение спящего режима"
) else (
    REM ВКЛЮЧЕНИЕ
    powercfg /change standby-timeout-ac 30
    powercfg /change standby-timeout-dc 15
    powercfg /change hibernate-timeout-ac 180
    powercfg /change hibernate-timeout-dc 60
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 1 /f >nul 2>&1
    set "operation_name=Включение спящего режима"
)
REM Проверка режима сна (Sleep Mode)
set "SLMD=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled | findstr /i "0x0" >nul 2>&1 && set "SLMD=%COL%[92mВКЛ "
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:ClipboardHistory
echo [INFO ] %TIME% - Вызван ":ClipboardHistory" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%ECHR%" == "%COL%[91mВЫКЛ" (
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Clipboard" /v "EnableClipboardHistory" /t REG_DWORD /d 1 /f >nul 2>&1
    set "operation_name=Включение Журнала буфера обмена"
) else (
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Clipboard" /v "EnableClipboardHistory" /t REG_DWORD /d 0 /f >nul 2>&1
    set "operation_name=Отключение Журнала буфера обмена"
)
REM Проверка Изоляции ядра
set "ECHR=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
reg query "HKEY_CURRENT_USER\Software\Microsoft\Clipboard" /v "EnableClipboardHistory" | find "0x1" && set "ECHR=%COL%[92mВКЛ " >nul 2>&1
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:CoreIsolation
echo [INFO ] %TIME% - Вызван ":CoreIsolation" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%CRIS%" == "%COL%[91mВЫКЛ" (
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
    set "operation_name=Включение изоляции ядра"
) else (
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
    set "operation_name=Отключение изоляции ядра"
)
REM Проверка Журнала буфера обмена
set "CRIS=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" | find "0x1" && set "CRIS=%COL%[92mВКЛ " >nul 2>&1
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:AutoUpdateMaps
echo [INFO ] %TIME% - Вызван ":AutoUpdateMaps" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%AUMS%" == "%COL%[92mВКЛ " (
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\Maps" /v "AutoUpdateEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    set "operation_name=Отключение автообновления карт"
) else (
    reg delete "HKEY_LOCAL_MACHINE\SYSTEM\Maps" /v "AutoUpdateEnabled" /f >nul 2>&1
    set "operation_name=Включение автообновления карт"
)
REM Проверка автообновления карт
set "AUMS=%COL%[92mВКЛ "
set "errorlevel_a=%errorlevel%"
reg query "HKEY_LOCAL_MACHINE\SYSTEM\Maps" /v "AutoUpdateEnabled" | findstr /i "0x0" >nul 2>&1 && set "AUMS=%COL%[91mВЫКЛ"
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:AutoStoreApps
echo [INFO ] %TIME% - Вызван ":AutoStoreApps" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%AUSA%" == "%COL%[92mВКЛ " (
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore" /v "AutoDownload" /t REG_DWORD /d 2 /f >nul 2>&1
    set "operation_name=Отключение автообновления приложений магазина"
) else (
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore" /v "AutoDownload" /f >nul 2>&1
    set "operation_name=Включение автообновления приложений магазина"
)
REM Проверка автообновления приложений магазина
set "AUSA=%COL%[92mВКЛ "
set "errorlevel_a=%errorlevel%"
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\WindowsStore" /v "AutoDownload" | findstr /i "0x2" >nul 2>&1 && set "AUSA=%COL%[91mВЫКЛ"
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:BackgroundTaskEdgeBrowser
echo [INFO ] %TIME% - Вызван ":BackgroundTaskEdgeBrowser" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%BTEB%" == "%COL%[92mВКЛ " (
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "StartupBoostEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
    set "operation_name=Отключение фоновой работы браузера Microsoft Edge"
) else (
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "StartupBoostEnabled" /f >nul 2>&1
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" /f >nul 2>&1
    set "operation_name=Включение фоновой работы браузера Microsoft Edge"
)
REM Проверка ускорения Microsoft Edge и фоновой работы браузера
set "BTEB=%COL%[92mВКЛ "
set "errorlevel_a=%errorlevel%"
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "BackgroundModeEnabled" | findstr /i "0x0" >nul 2>&1 && set "BTEB=%COL%[91mВЫКЛ"
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:RecallAi
echo [INFO ] %TIME% - Вызван ":RecallAi" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%RECL%" == "%COL%[92mВКЛ " (
    dism /Online /Enable-Feature /FeatureName:Recall /All
    set "operation_name=Включение Recall"
) else (
    dism /Online /Disable-Feature /FeatureName:Recall /Remove
    set "operation_name=Удаление Recall"
)
REM Проверка ускорения Microsoft Edge и фоновой работы браузера
set "errorlevel_a=%errorlevel%"
dism /Online /Get-FeatureInfo /FeatureName:Recall >nul 2>&1 && ( set "RECL=%COL%[91mВЫКЛ" ) || ( set "RECL=%COL%[92mВКЛ " )
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:CopilotAi
echo [INFO ] %TIME% - Вызван ":CopilotAi" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%CPLT%" == "%COL%[92mВКЛ " (
    :: Убираем политики «выключено» (ставим 0 или удаляем ключи)
    reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v DisableAIDataAnalysis /t REG_DWORD /d 0 /f >nul 2>&1

    :: Восстанавливаем автозапуск и кнопку
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v AutoOpenCopilotLargeScreens /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCopilotButton /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\Shell\Copilot\BingChat" /v IsUserEligible /t REG_DWORD /d 1 /f >nul 2>&1

    :: Включаем боковую панель в Edge по умолчанию (ставим 1)
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v HubsSidebarEnabled /t REG_DWORD /d 1 /f >nul 2>&1
    set "operation_name=Включение Copilot"
) else (
    :: Ставим политики «выключено»
    reg add "HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 1 /f >nul 2>&1
    reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v DisableAIDataAnalysis /t REG_DWORD /d 1 /f >nul 2>&1

    :: Отключаем автозапуск и кнопку
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v AutoOpenCopilotLargeScreens /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCopilotButton /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\Shell\Copilot\BingChat" /v IsUserEligible /t REG_DWORD /d 0 /f >nul 2>&1

    :: Отключаем боковую панель в Edge (при наличии)
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v HubsSidebarEnabled /t REG_DWORD /d 0 /f >nul 2>&1
    set "operation_name=Удаление Copilot"
)
REM Проверка ускорения Microsoft Edge и фоновой работы браузера
set "CPLT=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
REM Copilot
reg query "HKCU\Software\Microsoft\Windows\Shell\Copilot\BingChat" /v "IsUserEligible" | findstr /i "0x0" >nul 2>&1 && set "CPLT=%COL%[92mВКЛ "
reg query "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v "HubsSidebarEnabled" | findstr /i "0x0" >nul 2>&1 && set "CPLT=%COL%[92mВКЛ "
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:WidgetUninstall
echo [INFO ] %TIME% - Вызван ":WidgetUninstall" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%WTUL%" == "%COL%[91mВЫКЛ" (

:: --------------Remove "Widgets" from taskbar---------------
    chcp 850 >nul 2>&1
    PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; $data =  '0'; reg add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' /v 'TaskbarDa' /t 'REG_DWORD' /d "^""$data"^"" /f" >nul 2>&1
    PowerShell -ExecutionPolicy Unrestricted -Command "$message = 'This script will not take effect until you restart explorer.exe. You can restart explorer.exe by restarting your computer or by running following on command prompt: `taskkill /f /im explorer.exe & start explorer`.'; $warn =  $false; if ($warn) { Write-Warning "^""$message"^""; } else { Write-Host "^""Note: "^"" -ForegroundColor Blue -NoNewLine; Write-Output "^""$message"^""; }" >nul 2>&1
    chcp 65001 >nul 2>&1
    :: --Remove "Windows Web Experience Pack" (breaks Widgets)---
    chcp 850 >nul 2>&1
    PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'MicrosoftWindows.Client.WebExperience' | Remove-AppxPackage"
    PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
    chcp 65001 >nul 2>&1

    rem Удаление DesktopPackageMetadata
    powershell -Command "Get-AppxPackage *DesktopPackageMetadata* | Remove-AppxPackage" >nul 2>&1

    rem Удаление среды выполнения, предназначенной для работы с виджетами (widgets)
    powershell -Command "Get-AppxPackage *Microsoft.WidgetsPlatformRuntime* | Remove-AppxPackage" >nul 2>&1

    rem Удаление WidgetServicePackage
    powershell -Command "Get-AppxPackage *WidgetServicePackage* | Remove-AppxPackage" >nul 2>&1

    chcp 65001 >nul 2>&1
    reg add "%SaveData%\ParameterFunction" /v "WidgetUninstall" /f >nul 2>&1

    reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t "REG_DWORD" /d "0" /f >nul 2>&1

    rem Деактивация приложение Microsoft Windows Client Web Experience
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy" /f >nul 2>&1

    rem Отключение виджетов на панели задач
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\NewsAndInterests\AllowNewsAndInterests" /v "value" /t REG_DWORD /d 0 /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d 0 /f >nul 2>&1

    REM Переменная для хранения пути к папке с Widgets.dll
    set "widgets_path="

:: Перебираем все папки внутри C:\Program Files\WindowsApps\
for /d %%d in ("%ProgramFiles%\WindowsApps\*") do (
    :: Проверяем, есть ли в текущей папке файл Widgets.dll
    if exist "%%d\Widgets.dll" (
        set "widgets_path=%%d"
        :: Выводим путь к папке с Widgets.dll
        echo [INFO ] %TIME% - Файл Widgets.dll найден в папке: !widgets_path! >> "%ASX-Directory%\Files\Logs\%date%.txt"
        :: Take ownership of the folder
        takeown /f "!widgets_path!" /r /d y >nul 2>&1
        icacls "!widgets_path!" /grant %username%:F /t >nul 2>&1
        :: Удаляем папку
        rmdir /s /q "!widgets_path!" >nul 2>&1
        :: Проверяем, удалена ли папка
        if exist "!widgets_path!" (
            echo [ERROR] %TIME% - Папка !widgets_path! не была удалена. >> "%ASX-Directory%\Files\Logs\%date%.txt"
        ) else (
            echo [INFO ] %TIME% - Папка !widgets_path! успешно удалена. >> "%ASX-Directory%\Files\Logs\%date%.txt"
        )
    )
)

    set "operation_name=Удаление виджетов"
) else (
    set "operation_name=Виджеты Windows уже деактивированы в системе")
REM Проверка установки виджетов Windows - WebExperience
set "WTUL=%COL%[91mВЫКЛ" >nul 2>&1
set "errorlevel_a=%errorlevel%"
reg query "%SaveData%\ParameterFunction" /v "WidgetUninstall" >nul 2>&1 && set "WTUL=%COL%[92mВКЛ " >nul 2>&1
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:WindowsSounds
echo [INFO ] %TIME% - Вызван ":WindowsSounds" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%WSND%" == "%COL%[92mВКЛ " (
    reg add "HKCU\AppEvents\Schemes" /ve /d ".None" /f >nul
    reg add "HKCU\Control Panel\Sound" /v "Beep" /d "no" /f >nul
    reg add "HKCU\Control Panel\Sound" /v "ExtendedSounds" /d "no" /f >nul
    reg add "HKCU\Control Panel\Sound" /v "EnableSystemSounds" /t REG_DWORD /d 0 /f >nul
    reg add "HKCU\AppEvents\EventLabels\WindowsLogon" /v "ExcludeFromCPL" /t REG_DWORD /d 1 /f >nul
    set "operation_name=Отключение системных звуков Windows"
) else (
    reg add "HKCU\AppEvents\Schemes" /ve /d ".Default" /f >nul
    reg add "HKCU\Control Panel\Sound" /v "Beep" /d "yes" /f >nul
    reg add "HKCU\Control Panel\Sound" /v "ExtendedSounds" /d "yes" /f >nul
    reg add "HKCU\Control Panel\Sound" /v "EnableSystemSounds" /t REG_DWORD /d 1 /f >nul
    reg add "HKCU\AppEvents\EventLabels\WindowsLogon" /v "ExcludeFromCPL" /t REG_DWORD /d 0 /f >nul
    set "operation_name=Включение системных звуков Windows"
)
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe >nul
REM Проверка системных звуков Windows
set "WSND=%COL%[91mВЫКЛ"
set "errorlevel_a=%errorlevel%"
reg query "HKCU\Control Panel\Sound" /v "EnableSystemSounds" 2>nul | find "0x1" >nul
if !errorlevel! == 0 ( set "WSND=%COL%[92mВКЛ " )
set "errorlevel=%errorlevel_a%"
call:Complete_notice
goto GoBack

:FixProblemPanel
cls
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":FixProblemPanel" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=FixProblemPanel
set choice=NoInput
TITLE Исправление проблем - ASX Hub
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo          %COL%[36mВозможные проблемы 
echo          %COL%[97m------------------
echo          %COL%[36m[%COL%[37m 1 %COL%[36m]%COL%[37m Медленно открываются программы или игры ^(Только для HDD дисков^)
echo          %COL%[36m[%COL%[37m 2 %COL%[36m]%COL%[37m Не запускается GTA V RAGE MP            
echo          %COL%[36m[%COL%[37m 3 %COL%[36m]%COL%[37m Не работает Bluetooth
echo          %COL%[36m[%COL%[37m 4 %COL%[36m]%COL%[37m Не работает VPN
echo          %COL%[36m[%COL%[37m 5 %COL%[36m]%COL%[37m Не работает буфер WIN + V
echo          %COL%[36m[%COL%[37m 6 %COL%[36m]%COL%[37m Не работает принтер
echo          %COL%[36m[%COL%[37m 7 %COL%[36m]%COL%[37m Не работают уведомления
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
set /p choice="%DEL%                                                                      >: "
if /i "%choice%"=="1" ( set "history=FixProblemPanel;!history!" && goto SlowStartSoftGame )
if /i "%choice%"=="2" ( set "history=FixProblemPanel;!history!" && goto GTAVRAGEMP )
if /i "%choice%"=="3" ( set "history=FixProblemPanel;!history!" && goto Bluetooth )
if /i "%choice%"=="4" ( set "history=FixProblemPanel;!history!" && goto NoVPN )
if /i "%choice%"=="5" ( set "history=FixProblemPanel;!history!" && goto WinV )
if /i "%choice%"=="6" ( set "history=FixProblemPanel;!history!" && goto Printer )
if /i "%choice%"=="7" ( set "history=FixProblemPanel;!history!" && goto NoNotifi )

if /i "%choice%"=="C" ( set "history=FixProblemPanel;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=FixProblemPanel;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" (set "history=FixProblemPanel;!history!" && goto MainMenu )
if /i "%choice%"=="ч" (set "history=FixProblemPanel;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="R" goto FixProblemPanel
if /i "%choice%"=="к" goto FixProblemPanel
if /i "%choice%"=="NoInput" goto WrongInput
call:WrongInput
goto FixProblemPanel


:SlowStartSoftGame
reg add HKLM\SYSTEM\CurrentControlSet\Services\sysmain /v Start /t REG_DWORD /d 2 >nul
set "operation_name=Попытка исправить медленное открываются программ и игр"
call:Complete_notice
goto GoBack

:GTAVRAGEMP     
reg add HKLM\SYSTEM\CurrentControlSet\services\mssmbios /v Start /t REG_DWORD /d 1 /f >nul 2>&1
set "operation_name=Попытка исправить GTA V RAGE MP"
call:Complete_notice
goto GoBack

:Bluetooth 
reg add HKLM\SYSTEM\CurrentControlSet\Services\BTAGService /v Start /t REG_DWORD /d 3 >nul
reg add HKLM\SYSTEM\CurrentControlSet\Services\BthAvctpSvc /v Start /t REG_DWORD /d 3 >nul
reg add HKLM\SYSTEM\CurrentControlSet\Services\NcbService /v Start /t REG_DWORD /d 3 >nul
reg add HKLM\SYSTEM\CurrentControlSet\Services\DevicesFlowUserSvc /v Start /t REG_DWORD /d 3 >nul
reg add HKLM\SYSTEM\CurrentControlSet\Services\DevicePickerUserSvc /v Start /t REG_DWORD /d 3 >nul
reg add HKLM\SYSTEM\CurrentControlSet\Services\ConsentUxUserSvc /v Start /t REG_DWORD /d 3 >nul
reg add HKLM\SYSTEM\CurrentControlSet\Services\bthserv /v Start /t REG_DWORD /d 3 >nul

set "operation_name=Попытка исправить не работающий Bluetooth"
call:Complete_notice
goto GoBack

:NoVPN
reg add HKLM\SYSTEM\CurrentControlSet\Services\upnphost /v Start /t REG_DWORD /d 3 >nul

set "operation_name=Попытка исправить не работающий VPN"
call:Complete_notice
goto GoBack

:WINV
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\FSE" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\EFS" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
for /f %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "cbdhsvc" ^| find /i "cbdhsvc"') do (reg add "%%i" /v "Start" /t reg_dword /d 2 /f)  >nul 2>&1
sc start EFS
sc config EFS start=demand
set "operation_name=Попытка исправить не работающий буфер WIN + V" 
call:Complete_notice
goto GoBack

:Printer    
reg add HKLM\SYSTEM\CurrentControlSet\Services\PrintNotify /v Start /t REG_DWORD /d 3 >nul
reg add HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation /v Start /t REG_DWORD /d 2 >nul
reg add HKLM\SYSTEM\CurrentControlSet\Services\FDResPub /v Start /t REG_DWORD /d 3 >nul
reg add HKLM\SYSTEM\CurrentControlSet\Services\lmhosts /v Start /t REG_DWORD /d 3 >nul
reg add HKLM\SYSTEM\CurrentControlSet\Services\Spooler /v Start /t REG_DWORD /d 2 >nul
reg add HKLM\SYSTEM\CurrentControlSet\Services\PrintWorkflowUserSvc /v Start /t REG_DWORD /d 2 >nul
set "operation_name=Попытка исправить не работающий принтер"
call:Complete_notice
goto GoBack

:NoNotifi
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK" /f >nul
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK" /f >nul
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" /v "NOC_GLOBAL_SETTING_TOASTS_ENABLED" /f >nul
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings" /f >nul
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer" /f >nul
reg delete "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /f >nul
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer" /f >nul
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /f >nul
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v "ToastEnabled" /f >nul
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /f >nul
reg delete "HKCU\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoToastApplicationNotification" /f >nul
reg add "HKCU\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /f >nul
reg delete "HKCU\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /v "NoTileApplicationNotification" /f >nul
reg add "HKCU\Software\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" /f >nul
set "operation_name=Попытка исправить не работающие уведомления"
call:Complete_notice
goto GoBack


:Privacy-checker
set LOGFILE="%ASX-Directory%\Files\Logs\%date%.txt"

echo [INFO ] %TIME% - Вызван "Privacy-checker" >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo [INFO ] %TIME% - Начало проверки настроек конфиденциальности >> "%ASX-Directory%\Files\Logs\%date%.txt"

REM Проверка значений
for %%i in (ADOFF DOMAC SPYMD ASSC) do ( set "%%i=%COL%[91mВЫКЛ")
for %%i in (CWINT DATAS) do ( set "%%i=%COL%[90mН/Д ")
for %%i in (ADOFF SYWND TELEN NVTEL APPDA STATU INPAD LOGUS LOCOF FEEDB SPECH MONSY EXPRT WINLO DLEGT) do ( set "%%i=%COL%[92mВКЛ ")


( 
REM Рекламный идентификатор и реклама
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" | find "0x0" >nul 2>&1 && set "ADOFF=%COL%[91mВЫКЛ"

REM Все типы синхронизаций Windows
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" | find "0x0" >nul 2>&1 && set "SYWND=%COL%[91mВЫКЛ"

REM Все виды телеметрий Windows
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Diagtrack-Listener" /v "Start" | find "0x0" >nul 2>&1 && set "TELEN=%COL%[91mВЫКЛ"

REM Телеметрия NVIDIA
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer" /v "Start" | find "0x4" >nul 2>&1 && set "NVTEL=%COL%[91mВЫКЛ"

REM Телеметрия Edge
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Edge" /v "DiagnosticData" | find "0x0" >nul 2>&1 && set "DLEGT=%COL%[91mВЫКЛ"

REM Сбор данных через события планировщика
reg query "%SaveData%\ParameterFunction" /v "SchedulerEventData" && set "DATAS=%COL%[92mВКЛ "

REM Сбор данных об установленных приложениях
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" | find "0x1" >nul 2>&1 && set "APPDA=%COL%[91mВЫКЛ"

REM Сбор статистики использования приложений
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" | find "0x0" >nul 2>&1 && set "STATU=%COL%[91mВЫКЛ"

REM Сбор и отправка данных рукописного ввода
reg query "HKEY_CURRENT_USER\Software\Microsoft\Input\TIPC" /v "Enabled" | find "0x0" >nul 2>&1 && set "INPAD=%COL%[91mВЫКЛ"

REM Cетевой доступ к доменам сбора данных
reg query "%SaveData%\ParameterFunction" /v "DataDomains" && set "DOMAC=%COL%[92mВКЛ "

REM Ведение записи поведения пользователя
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" | find "0x1" >nul 2>&1 && set "LOGUS=%COL%[91mВЫКЛ"

REM Определение местоположения пользователя
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" | find "0x1" >nul 2>&1 && set "LOCOF=%COL%[91mВЫКЛ"

REM Проверка обращения через Обратную связь
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" | find "0x1" >nul 2>&1 && set "FEEDB=%COL%[91mВЫКЛ"

REM Скрытое фоновое обновление синтеза речи
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Speech" /v "AllowSpeechModelUpdate" | find "0x0" >nul 2>&1 && set "SPECH=%COL%[91mВЫКЛ"

REM Скрытый мониторинг системы
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CDPUserSvc" /v "Start" | find "0x4" >nul 2>&1 && set "MONSY=%COL%[91mВЫКЛ"
	
REM Удалённые эксперименты над ПК
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v "AllowExperimentation" | find "0x0" >nul 2>&1 && set "EXPRT=%COL%[91mВЫКЛ"

REM Проверка синхронизации настроек Windows
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /v "DisableApplicationSettingSync" >nul 2>&1 || set "ASSC=%COL%[92mВКЛ "

REM Отключение и выпиливание шпионских модулей Microsoft
::reg query "%SaveData%\ParameterFunction" /v "MicrosoftSpyModules" && set "SPYMD=%COL%[92mВКЛ "
reg query "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" && set "SPYMD=%COL%[92mВКЛ "

REM «Журналирования» Событий Windows
reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\diagnosticshub.standardcollector.service" /v "Start" | find "0x4" >nul 2>&1 && set "WINLO=%COL%[91mВЫКЛ"
cls
REM APPTR
reg query "%SaveData%\ParameterFunction" /v "AppsTrack" || set "APPTR=%COL%[91mВЫКЛ"
reg query "%SaveData%\ParameterFunction" /v "Disablelogging" && set "APPTR=%COL%[92mВКЛ "
) >nul 2>&1

REM Отслеживание запуска программ
reg query "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" /v "SensorPermissionState" | find "0x0" >nul 2>&1 || set "DLOS=%COL%[92mВКЛ "
goto :eof

:Privacy
call:Privacy-checker
REM Nvidia телеметрия
cls
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":Privacy" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=Privacy
set choice=NoInput
TITLE Конфиденциальность - ASX Hub
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo          %COL%[36mТЕЛЕМЕТРИЯ
echo          %COL%[97m----------
echo           1 %COL%[36m[%COL%[37m %ADOFF% %COL%[36m]%COL%[37m Рекламный идентификатор и реклама
echo           2 %COL%[36m[%COL%[37m %SYWND% %COL%[36m]%COL%[37m Все типы синхронизаций Windows
echo           3 %COL%[36m[%COL%[37m %TELEN% %COL%[36m]%COL%[37m Все виды телеметрий Windows
echo           4 %COL%[36m[%COL%[37m %NVTEL% %COL%[36m]%COL%[37m Телеметрия NVIDIA
echo           5 %COL%[36m[%COL%[37m %NVTEL% %COL%[36m]%COL%[37m Отключить и удалить телеметрию Nvidia
echo           6 %COL%[36m[%COL%[37m %DLEGT% %COL%[36m]%COL%[37m Телеметрия Edge
echo           7 %COL%[36m[%COL%[37m %DATAS% %COL%[36m]%COL%[37m Сбор данных через события планировщика
echo           8 %COL%[36m[%COL%[37m %APPDA% %COL%[36m]%COL%[37m Сбор данных об установленных приложениях
echo           9 %COL%[36m[%COL%[37m %STATU% %COL%[36m]%COL%[37m Сбор статистики использования приложений
echo          10 %COL%[36m[%COL%[37m %INPAD% %COL%[36m]%COL%[37m Сбор и отправка данных рукописного ввода
echo          11 %COL%[36m[%COL%[37m %DOMAC% %COL%[36m]%COL%[37m Отключение сетевого доступа к доменам сбора данных
echo          12 %COL%[36m[%COL%[37m %LOGUS% %COL%[36m]%COL%[37m Ведение записи поведения пользователя
echo          13 %COL%[36m[%COL%[37m %LOCOF% %COL%[36m]%COL%[37m Определение местоположения пользователя
echo          14 %COL%[36m[%COL%[37m %FEEDB% %COL%[36m]%COL%[37m Проверка обращения через Обратную связь
echo          15 %COL%[36m[%COL%[37m %SPECH% %COL%[36m]%COL%[37m Скрытое фоновое обновление синтеза речи
echo          16 %COL%[36m[%COL%[37m %MONSY% %COL%[36m]%COL%[37m Скрытый мониторинг системы %COL%[90m^(Не будут работать: Виртуальные рабочие столы, приложение 'Ваш телефон' и Ночной свет^)%COL%[37m
echo          17 %COL%[36m[%COL%[37m %EXPRT% %COL%[36m]%COL%[37m Удалённые эксперименты над ПК
echo          18 %COL%[36m[%COL%[37m %SPYMD% %COL%[36m]%COL%[37m Шпионские модули Microsoft
echo          19 %COL%[36m[%COL%[37m %WINLO% %COL%[36m]%COL%[37m «Журналирования» Событий Windows
echo          20 %COL%[36m[%COL%[37m %CWINT% %COL%[36m]%COL%[37m Очистить временные файлы Windows
echo          21 %COL%[36m[%COL%[37m %APPTR% %COL%[36m]%COL%[37m Отслеживание запуска программ
echo.
echo.
echo.
echo          %COL%[36mДРУГОЕ
echo          %COL%[97m------
echo          22 %COL%[36m[%COL%[37m %APPTR% %COL%[36m]%COL%[37m Cинхронизация настроек и приложений
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
REM echo                              %COL%[36m[ B - Назад ]         %COL%[91m[ X - Главное меню ]         %COL%[36m[ N - Слудующая страница ]
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
set /p choice="%DEL%                                                                      >: "
if /i "%choice%"=="1" ( set "history=Privacy;!history!" && Call:WinAd )
if /i "%choice%"=="2" ( set "history=Privacy;!history!" && Call:WindowsSync )
if /i "%choice%"=="3" ( set "history=Privacy;!history!" && Call:WindowsTelemetry )
if /i "%choice%"=="4" ( set "history=Privacy;!history!" && Call:NVIDIATelemetry )
if /i "%choice%"=="5" ( set "history=Privacy;!history!" && Call:Uninstall_NVTelemetry )

if /i "%choice%"=="6" ( set "history=Privacy;!history!" && Call:EdgeTelemetry )

if /i "%choice%"=="7" ( set "history=Privacy;!history!" && Call:SchedulerEventData )
if /i "%choice%"=="8" ( set "history=Privacy;!history!" && Call:InstalledAppData )
if /i "%choice%"=="9" ( set "history=Privacy;!history!" && Call:AppUsageStats )
if /i "%choice%"=="10" ( set "history=Privacy;!history!" && Call:HandwritingData )
if /i "%choice%"=="11" ( set "history=Privacy;!history!" && Call:DataDomains )
if /i "%choice%"=="12" ( set "history=Privacy;!history!" && Call:UserBehaviorLogging )
if /i "%choice%"=="13" ( set "history=Privacy;!history!" && Call:LocationTracking )
if /i "%choice%"=="14" ( set "history=Privacy;!history!" && Call:FeedbackCheck )
if /i "%choice%"=="15" ( set "history=Privacy;!history!" && Call:BackgroundSpeechSynthesis )
if /i "%choice%"=="16" ( set "history=Privacy;!history!" && Call:SystemMonitoring )
if /i "%choice%"=="17" ( set "history=Privacy;!history!" && Call:RemotePCexperiments )
if /i "%choice%"=="18" ( set "history=Privacy;!history!" && Call:MicrosoftSpyModules )
if /i "%choice%"=="19" ( set "history=Privacy;!history!" && Call:WindowsEventLogging )
if /i "%choice%"=="20" ( set "history=Privacy;!history!" && Call:Clear_Windows_TempFile )
if /i "%choice%"=="21" ( set "history=Privacy;!history!" && Call:App_start_Tracking )

if /i "%choice%"=="22" ( set "history=Privacy;!history!" && Call:AppSettingsSync )

if /i "%choice%"=="C" ( set "history=Privacy;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=Privacy;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=Privacy;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=Privacy;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="NoInput" goto WrongInput
call:WrongInput
goto Privacy

:WinAd
echo [INFO ] %TIME% - Вызван ":WinAd" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%ADOFF%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth" /v "AllowAdvertising" /t REG_DWORD /d 1 /f >nul 2>&1
	set "operation_name=Включение рекламного идентификатора и рекламы"
) >nul 2>&1 else (
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Bluetooth" /v "AllowAdvertising" /t REG_DWORD /d 0 /f >nul 2>&1
	set "operation_name=Выключение рекламного идентификатора и рекламы"
) >nul 2>&1
call:Complete_notice
goto GoBack

:WindowsSync
echo [INFO ] %TIME% - Вызван ":WindowsSync" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%SYWND%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
	set "operation_name=Включение всех типов синхронизаций Windows"
) >nul 2>&1 else (
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Accessibility" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\BrowserSettings" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Credentials" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Personalization" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Windows" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
	set "operation_name=Отключение всех типов синхронизаций Windows"
) >nul 2>&1
call:Complete_notice
goto GoBack

:WindowsTelemetry
echo [INFO ] %TIME% - Вызван ":WindowsTelemetry" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%TELEN%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Diagtrack-Listener" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t REG_DWORD /d 3 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
	schtasks /change /tn "Microsoft\Office\Office ClickToRun Service Monitor" /enable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetry\AgentFallBack2016" /enable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetry\AgentFallBack2016" /enable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetry\OfficeTelemetryAgentLogOn2016" /enable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentFallBack2016" /enable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentLogOn2016" /enable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentFallBack" /enable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentLogOn" /enable
	schtasks /change /tn "Microsoft\Office\Office 15 Subscription Heartbeat" /enable
	set "operation_name=Включение всех видов телеметрий Windows"
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\WMI\Autologger\Diagtrack-Listener" /v "Start" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments" /v "SaveZoneInformation" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DiagTrack" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	schtasks /change /tn "Microsoft\Office\Office ClickToRun Service Monitor" /disable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetry\AgentFallBack2016" /disable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetry\AgentFallBack2016" /disable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetry\OfficeTelemetryAgentLogOn2016" /disable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentFallBack2016" /disable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentLogOn2016" /disable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentFallBack" /disable
	schtasks /change /tn "Microsoft\Office\OfficeTelemetryAgentLogOn" /disable
	schtasks /change /tn "Microsoft\Office\Office 15 Subscription Heartbeat" /disable
	set "operation_name=Отключение всех видов телеметрий Windows"
) >nul 2>&1
call:Complete_notice
goto GoBack

:NVIDIATelemetry
echo [INFO ] %TIME% - Вызван ":NVIDIATelemetry" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%NVTEL%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
	schtasks /change /tn NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /enable
	schtasks /change /tn NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /enable
	schtasks /change /tn NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /enable
	net start NvTelemetryContainer
	sc config NvTelemetryContainer start= enabled
	sc start NvTelemetryContainer	
	set "operation_name=Включение Телеметрии NVIDIA"
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NvTelemetryContainer" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1	
	schtasks /change /tn NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /disable
	schtasks /change /tn NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /disable
	schtasks /change /tn NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /disable
	net stop NvTelemetryContainer
	sc config NvTelemetryContainer start= disabled
	sc stop NvTelemetryContainer
	set "operation_name=Отключение Телеметрии NVIDIA"
) >nul 2>&1
call:Complete_notice
goto GoBack

:SchedulerEventData
echo [INFO ] %TIME% - Вызван ":SchedulerEventData" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%DATAS%" == "%COL%[91mВЫКЛ" (
 	reg add "%SaveData%\ParameterFunction" /F /V "SchedulerEventData" /T REG_SZ /d 0 >nul 2>&1		
	schtasks /change /tn "Microsoft\Windows\Maintenance\WinSAT" /enable
	schtasks /change /tn "Microsoft\Windows\Autochk\Proxy" /enable
	schtasks /change /tn "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /enable
	schtasks /change /tn "Microsoft\Windows\Application Experience\ProgramDataUpdater" /enable
	schtasks /change /tn "Microsoft\Windows\Application Experience\StartupAppTask" /enable
	schtasks /change /tn "Microsoft\Windows\PI\Sqm-Tasks" /enable
	schtasks /change /tn "Microsoft\Windows\NetTrace\GatherNetworkInfo" /enable
	schtasks /change /tn "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /enable
	schtasks /change /tn "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /enable
	schtasks /change /tn "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /enable
	schtasks /change /tn "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" /enable
	schtasks /change /tn "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /enable
	set "operation_name=Включение сбора данных через события планировщика"
) >nul 2>&1 else (
	reg delete "%SaveData%\ParameterFunction" /v "SchedulerEventData" /f >nul 2>&1
	schtasks /change /tn "Microsoft\Windows\Maintenance\WinSAT" /disable
	schtasks /change /tn "Microsoft\Windows\Autochk\Proxy" /disable
	schtasks /change /tn "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /disable
	schtasks /change /tn "Microsoft\Windows\Application Experience\ProgramDataUpdater" /disable
	schtasks /change /tn "Microsoft\Windows\Application Experience\StartupAppTask" /disable
	schtasks /change /tn "Microsoft\Windows\PI\Sqm-Tasks" /disable
	schtasks /change /tn "Microsoft\Windows\NetTrace\GatherNetworkInfo" /disable
	schtasks /change /tn "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /disable
	schtasks /change /tn "Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask" /disable
	schtasks /change /tn "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip" /disable
	schtasks /change /tn "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticResolver" /disable
	schtasks /change /tn "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /disable
	set "operation_name=Отключение сбора данных через события планировщика"
) >nul 2>&1
call:Complete_notice
goto GoBack

:InstalledAppData
echo [INFO ] %TIME% - Вызван ":InstalledAppData" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%APPDA%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d 0 /f >nul 2>&1
	set "operation_name=Включение сбора данных об установленных приложенияхs"
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableInventory" /t REG_DWORD /d 1 /f >nul 2>&1
	set "operation_name=Отключение сбора данных об установленных приложениях"
) >nul 2>&1
call:Complete_notice
goto GoBack

:AppUsageStats
echo [INFO ] %TIME% - Вызван ":AppUsageStats" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%STATU%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d 1 /f >nul 2>&1
	set "operation_name=Включение сбора статистики использования приложений"
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "AITEnable" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /t REG_DWORD /d 0 /f >nul 2>&1
	set "operation_name=Отключение сбора статистики использования приложений"
) >nul 2>&1
call:Complete_notice
goto GoBack

:HandwritingData
echo [INFO ] %TIME% - Вызван ":HandwritingData" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%INPAD%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
	set "operation_name=Включение сбора и отправки данных рукописного ввода"
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\TabletPC" /v "PreventHandwritingDataSharing" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports" /v "PreventHandwritingErrorReports" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Input\TIPC" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
	set "operation_name=Отключение сбора и отправки данных рукописного ввода"
) >nul 2>&1
call:Complete_notice
goto GoBack

:DataDomains
echo [INFO ] %TIME% - Вызван ":DataDomains" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%DOMAC%" == "%COL%[91mВЫКЛ" (
	reg add "%SaveData%\ParameterFunction" /v "DataDomains" /t Reg_SZ /f >nul 2>&1		
	curl -g -L -# -o "%ASX-Directory%\Files\Resources\host.txt" "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Other/hosts.txt" >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        echo Ошибка: Не удалось скачать файл host.txt. Проверьте подключение к интернету и доступность URL.
		echo [ERROR] %TIME% - Ошибка при загрузке host.txt >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto GoBack
    )	
	start "" "%ASX-Directory%\Files\Resources\host.txt"
	start "" "%Windir%\System32\drivers\etc\hosts"
	if not exist "%ASX-Directory%\Files\Restore" mkdir "%ASX-Directory%\Files\Restore"
	copy "%Windir%\System32\drivers\etc\hosts" "%ASX-Directory%\Files\Restore\hosts_backup" /Y
	set "operation_name=Включение сетевого доступа к доменам сбора данных"
) else (
    chcp 850 >nul 2>&1
    powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Данная функция уже активирована. Диактивация невозможна', 'ASX Hub', 'OK', [System.Windows.Forms.MessageBoxIcon]::information);}"  >nul 2>&1
    chcp 65001 >nul 2>&1
) >nul 2>&1
call:Complete_notice
goto GoBack

:UserBehaviorLogging
echo [INFO ] %TIME% - Вызван ":UserBehaviorLogging" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%LOGUS%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreenCamera" /t REG_DWORD /d 0 /f >nul 2>&1	
	set "operation_name=Включение ведения записи поведения пользователя"
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /v "DisableUAR" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreenCamera" /t REG_DWORD /d 1 /f >nul 2>&1	
	set "operation_name=Отключение ведения записи поведения пользователя"
) >nul 2>&1
call:Complete_notice
goto GoBack

:LocationTracking
echo [INFO ] %TIME% - Вызван ":LocationTracking" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%LOCOF%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /t REG_DWORD /d 0 /f >nul 2>&1	
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableWindowsLocationProvider" /t REG_DWORD /d 0 /f >nul 2>&1	
	set "operation_name=Включение определения местоположения пользователя"
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 1 /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocationScripting" /t REG_DWORD /d 1 /f >nul 2>&1	
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableWindowsLocationProvider" /t REG_DWORD /d 1 /f >nul 2>&1	
	set "operation_name=Отключение определения местоположения пользователя"
) >nul 2>&1
call:Complete_notice
goto GoBack

:FeedbackCheck
echo [INFO ] %TIME% - Вызван ":FeedbackCheck" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%FEEDB%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d 0 /f >nul 2>&1	
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 0 /f >nul 2>&1		
	set "operation_name=Включение проверки обращений через Обратную связь"
) >nul 2>&1 else (
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Siuf\Rules" /v "NumberOfSIUFInPeriod" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Siuf\Rules" /v "PeriodInNanoSeconds" /t REG_DWORD /d 0 /f >nul 2>&1	
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f >nul 2>&1			
	set "operation_name=Отключение проверки обращений через Обратную связь"
) >nul 2>&1
call:Complete_notice
goto GoBack

:BackgroundSpeechSynthesis
echo [INFO ] %TIME% - Вызван ":BackgroundSpeechSynthesis" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%SPECH%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Speech" /v "AllowSpeechModelUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
	set "operation_name=Включение скрытого фонового обновления синтеза речи"
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Speech" /v "AllowSpeechModelUpdate" /t REG_DWORD /d 0 /f >nul 2>&1
	set "operation_name=Отключение скрытого фонового обновления синтеза речи"
) >nul 2>&1
call:Complete_notice
goto GoBack

:SystemMonitoring
echo [INFO ] %TIME% - Вызван ":SystemMonitoring" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%MONSY%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CDPUserSvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1	
	set "operation_name=Включение скрытого мониторинга системы"
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\CDPUserSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1		
	set "operation_name=Отключение скрытого мониторинга системы"
) >nul 2>&1
call:Complete_notice
goto GoBack

:RemotePCexperiments
echo [INFO ] %TIME% - Вызван ":RemotePCexperiments" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%EXPRT%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v "AllowExperimentation" /t REG_DWORD /d 1 /f >nul 2>&1
	set "operation_name=Включение удалённых экспериментов над ПК"
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\System" /v "AllowExperimentation" /t REG_DWORD /d 0 /f >nul 2>&1
	set "operation_name=Отключение удалённых экспериментов над ПК"
) >nul 2>&1
call:Complete_notice
goto GoBack

:MicrosoftSpyModules
echo [INFO ] %TIME% - Вызван ":MicrosoftSpyModules" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%SPYMD%" == "%COL%[90mН/Д " (		
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /f >nul 2>&1	
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /f >nul 2>&1	
	set "operation_name=Отключение и выпиливание шпионских модулей Microsoft"
) else if "%SPYMD%" == "%COL%[92mВКЛ " (
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\DiagTrack" /f >nul 2>&1	
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /f >nul 2>&1	
	set "operation_name=Отключение и выпиливание шпионских модулей Microsoft"
) else (
    chcp 850 >nul 2>&1
    powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Данная функция уже активирована. Диактивация невозможна', 'ASX Hub', 'OK', [System.Windows.Forms.MessageBoxIcon]::information);}"  >nul 2>&1
    chcp 65001 >nul 2>&1
) >nul 2>&1
goto GoBack

:WindowsEventLogging
echo [INFO ] %TIME% - Вызван ":WindowsEventLogging" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%WINLO%" == "%COL%[91mВЫКЛ" (
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\diagnosticshub.standardcollector.service" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1	
	set "operation_name=Включение «журналирования» Событий Windows"
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\diagnosticshub.standardcollector.service" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1		
	set "operation_name=Отключение «журналирования» Событий Windows"
) >nul 2>&1
call:Complete_notice
goto GoBack

:Clear_Windows_TempFile
echo [INFO ] %TIME% - Вызван ":Clear_Windows_TempFile" >> "%ASX-Directory%\Files\Logs\%date%.txt"
del /f /q %localappdata%\Temp\* >nul 2>&1
rd /s /q "%WINDIR%\Temp" >nul 2>&1
rd /s /q "%TEMP%" >nul 2>&1

md "%WinDir%\Temp" >nul 2>&1
md "%localappdata%\Temp" >nul 2>&1
md "%Temp%" >nul 2>&1
set "operation_name=Очистка временных файлов в Windows"
call:Complete_notice
goto GoBack

:App_start_Tracking
echo [INFO ] %TIME% - Вызван ":App_start_Tracking" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%APPTR%" == "%COL%[91mВЫКЛ" (
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /d 1 /t REG_DWORD /f >nul 2>&1
	reg add "%SaveData%\ParameterFunction" /v "AppsTrack" /f >nul 2>&1
	set "operation_name=Включение отслеживания приложений"		
) >nul 2>&1 else (
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Start_TrackProgs" /d 0 /t REG_DWORD /f >nul 2>&1
	reg delete "%SaveData%\ParameterFunction" /v "AppsTrack" /f >nul 2>&1
	set "operation_name=Выключение отслеживания приложений"
) >nul 2>&1
call:Complete_notice
goto GoBack

:AppSettingsSync
echo [INFO ] %TIME% - Вызван ":AppSettingsSync" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%ASSC%" == "%COL%[91mВЫКЛ" (
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableApplicationSettingSync" /T REG_DWORD /d 0 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableWebBrowserSettingSync" /T REG_DWORD /d 0 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableDesktopThemeSettingSync" /T REG_DWORD /d 0 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableSettingSync" /T REG_DWORD /d 0 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableSyncOnPaidNetwork" /T REG_DWORD /d 0 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableWindowsSettingSync" /T REG_DWORD /d 0 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableCredentialsSettingSync" /T REG_DWORD /d 0 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisablePersonalizationSettingSync" /T REG_DWORD /d 0 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableStartLayoutSettingSync" /T REG_DWORD /d 0 >nul 2>&1
	set "operation_name=Включение синхронизации настроек и приложений"
) >nul 2>&1 else (
    REM Disables synchronization of application settings, app sync settings, web browser settings, desktop theme settings, and all settings in Windows.
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableApplicationSettingSync" /T REG_DWORD /d 2 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableWebBrowserSettingSync" /T REG_DWORD /d 2 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableDesktopThemeSettingSync" /T REG_DWORD /d 2 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableSettingSync" /T REG_DWORD /d 2 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableSyncOnPaidNetwork" /T REG_DWORD /d 1 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableWindowsSettingSync" /T REG_DWORD /d 2 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableCredentialsSettingSync" /T REG_DWORD /d 2 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisablePersonalizationSettingSync" /T REG_DWORD /d 2 >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync" /F /V "DisableStartLayoutSettingSync" /T REG_DWORD /d 2 >nul 2>&1 
	set "operation_name=Выключение синхронизации настроек и приложений"	
) >nul 2>&1
call:Complete_notice
goto GoBack


:WinCustomization-checker
echo [INFO ] %TIME% - Вызван ":WinCustomization-checker" >> "%ASX-Directory%\Files\Logs\%date%.txt"
for %%i in (BLEX SFE NetworkExplorer IconArrow GrayHilight ) do (set "%%i=%COL%[92mВКЛ ") >nul 2>&1
for %%i in (THPC OldContMenuWindows galleryExplorer HomeExplorer DSWE MSRT ) do (set "%%i=%COL%[91mВЫКЛ") >nul 2>&1
REM Показать расширения файлов
for /f "tokens=3" %%A in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" 2^>nul') do @if "%%A"=="0x0" (set "SFE=%COL%[92mВКЛ ") else (set "SFE=%COL%[91mВЫКЛ")

(
REM Размытый фон проводника
reg query "%SaveData%\ParameterFunction" /v "AcrylicExplorer" || set "BLEX=%COL%[91mВЫКЛ"

rem WinVersion
reg query "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" || set "OldContMenuWindows=%COL%[91mВЫКЛ"
reg query "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" && set "OldContMenuWindows=%COL%[92mВКЛ "

REM Проверка отключения Windows Spotlight на экране приветствия
reg query "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsSpotlightWindowsWelcomeExperience" | findstr /i "0x1" >nul 2>&1 && set "DSWE=%COL%[92mВКЛ "

REM Удалить иконки (Документы, Музыка, Изображения и т.д.) из окна Этот компьютер;
for /f "tokens=1,2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" ') do @if "%%A%%B"=="HKEY_LOCAL_MACHINE\SOFTWARE" (set "THPC=%COL%[92mВКЛ ") else (set "THPC=%COL%[91mВЫКЛ")

REM Проверка отключения определений MSRT (Malicious Software Removal Tool)
reg query "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" | findstr /i "0x1" >nul 2>&1 && set "MSRT=%COL%[92mВКЛ "

REM Тема
for %%i in (THEME ) do (set "%%i=светлую")
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" 2^>nul ^| find /i "1"') do (
  set "THEME=темную") >nul 2>&1

for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" ^| find /i "1"') do ( set "THEME=темную")

for /f "tokens=3" %%A in ('reg query "HKEY_CURRENT_USER\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /v "System.IsPinnedToNameSpaceTree" ') do @if "%%A"=="0x1" (set "galleryExplorer=%COL%[92mВКЛ ") else (set "galleryExplorer=%COL%[91mВЫКЛ")

REM Главная в проводнике
for /f "tokens=3" %%A in ('reg query "HKEY_CURRENT_USER\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /v "System.IsPinnedToNameSpaceTree" ') do @if "%%A"=="0x1" (set "HomeExplorer=%COL%[92mВКЛ ") else (set "HomeExplorer=%COL%[91mВЫКЛ")

REM Сеть в проводнике
for /f "tokens=3" %%A in ('reg query "HKEY_CURRENT_USER\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /v "System.IsPinnedToNameSpaceTree" ') do @if "%%A"=="0x1" (set "NetworkExplorer=%COL%[92mВКЛ ") else (set "NetworkExplorer=%COL%[91mВЫКЛ")

REM Корзина в проводнике
set "RecycleBinExplorer=%COL%[91mВЫКЛ"
for /f "tokens=3" %%A in ('reg query "HKEY_CURRENT_USER\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" /v "System.IsPinnedToNameSpaceTree" 2^>nul') do (
    if "%%A"=="0x1" (
        set "RecycleBinExplorer=%COL%[92mВКЛ "
    )
)

REM День Недели на панели задач
for /f "tokens=3" %%A in ('reg query "HKEY_CURRENT_USER\Control Panel\International" /v sShortDate ') do @(if "%%A"=="ddd-dd.MM.yyyy" (set "TaskBarDate=%COL%[92mВКЛ ") else (set "TaskBarDate=%COL%[91mВЫКЛ"))

REM Серый цвет для выделения
for /f "tokens=2*" %%a in ('reg query "HKCU\Control Panel\Colors" /v "Hilight" ^| find /i "0 120 215"') do ( set "GrayHilight=%COL%[91mВЫКЛ")

REM Стрелки на ярлыках
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29  && set "IconArrow=%COL%[91mВЫКЛ"
) >nul 2>&1

reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "RenameNameTemplate" >nul 2>&1
if %errorlevel% equ 0 (
    set "FolderNameTemplate=%COL%[92mВКЛ "
) else (
    set "FolderNameTemplate=%COL%[91mВЫКЛ"
)

for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "RenameNameTemplate" 2^>nul') do (
    set "FolderNameTemplateName=%%b"
)

if "%FolderNameTemplate%" == "%COL%[91mВЫКЛ" (
    set "FolderNameTemplateName= "
) else (
    set "FolderNameTemplateName=- %FolderNameTemplateName%"
)

goto :eof

:WinCustomization
call:WinCustomization-checker
cls
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":WinCustomization" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=WinCustomization
set choice=NoInput
TITLE Кастомизация windows - ASX Hub
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo          %COL%[36mКАСТОМИЗАЦИЯ
echo          %COL%[97m------------%COL%[37m
echo            1 %COL%[36m[%COL%[37m %BLEX% %COL%[36m]%COL%[37m Размытый фон проводника
echo            2 %COL%[36m[%COL%[37m %SFE% %COL%[36m]%COL%[37m Показывать расширения файлов
echo            3 %COL%[36m[%COL%[90m Н/Д  %COL%[36m]%COL%[37m Установить %COL%[36m%THEME% %COL%[37mтему для всех программ
echo            4 %COL%[36m[%COL%[37m %THPC% %COL%[36m]%COL%[37m Убрать иконки ^(Документы, Музыка и т.д.^) из Этот компьютер
if "%WinVer%"=="Windows 11" (
echo            5 %COL%[36m[%COL%[37m %OldContMenuWindows% %COL%[36m]%COL%[37m Старое контекстное меню из Windows 10	
) else (
echo            5 %COL%[36m[%COL%[37m %COL%[91mБЛОК %COL%[36m]%COL%[37m Старое контекстное меню из Windows 10  %COL%[91m^(Не доступно на вашем пк^)%COL%[90m
)
echo            6 %COL%[36m[%COL%[37m %galleryExplorer% %COL%[36m]%COL%[37m Пункт %COL%[36mГалерея %COL%[37mв проводнике
echo            7 %COL%[36m[%COL%[37m %HomeExplorer% %COL%[36m]%COL%[37m Пункт %COL%[36mГлавная %COL%[37mв проводнике
echo            8 %COL%[36m[%COL%[37m %RecycleBinExplorer% %COL%[36m]%COL%[37m Пункт %COL%[36mКорзина %COL%[37mв проводнике
echo            9 %COL%[36m[%COL%[37m %NetworkExplorer% %COL%[36m]%COL%[37m Пункт %COL%[36mСеть %COL%[37mв проводнике
echo           10 %COL%[36m[%COL%[37m %TaskBarDate% %COL%[36m]%COL%[37m Показать день недели на панели задач
echo           11 %COL%[36m[%COL%[37m %IconArrow% %COL%[36m]%COL%[37m Стрелки на ярлыках
echo           12 %COL%[36m[%COL%[37m %DSWE% %COL%[36m]%COL%[37m Отключить экран приветствия Windows
echo           13 %COL%[36m[%COL%[37m %MSRT% %COL%[36m]%COL%[37m Исключить средство удаления вредоносных программ из обновлений Windows
echo           14 %COL%[36m[%COL%[37m %FolderNameTemplate% %COL%[36m]%COL%[37m Нестандартное имя для новой папки %FolderNameTemplateName%
echo           15 %COL%[36m[%COL%[37m %GrayHilight% %COL%[36m]%COL%[37m Серый цвет выделеной области
echo.
echo.
echo          %COL%[36mПУНКТЫ
echo          %COL%[97m------%COL%[37m
echo          %COL%[36m[%COL%[37m CS %COL%[36m]%COL%[37m Меню выбора кастомного курсора мыши
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
REM echo                              %COL%[36m[ B - Назад ]         %COL%[91m[ X - Главное меню ]         %COL%[36m[ N - Слудующая страница ]
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
set /p choice="%DEL%                                                                      >: "
if /i "%choice%"=="1" ( set "history=WinCustomization;!history!" && Call:EplorerBlur )
if /i "%choice%"=="2" ( set "history=WinCustomization;!history!" && Call:ShowFileExtensions )
if /i "%choice%"=="3" ( set "history=WinCustomization;!history!" && Call:ThemeTweaks )
if /i "%choice%"=="4" ( set "history=WinCustomization;!history!" && Call:RemoveIconsFromThisComputer )
if "%WinVer%"=="Windows 11" (
	if /i "%choice%"=="5" ( set "history=WinCustomization;!history!" && call:OldContextMenu )
)
if /i "%choice%"=="6" ( set "history=WinCustomization;!history!" && call:GalleryExplorer )
if /i "%choice%"=="7" ( set "history=WinCustomization;!history!" && call:HomeExplorer )
if /i "%choice%"=="8" ( set "history=WinCustomization;!history!" && call:RecycleBinExplorer )
if /i "%choice%"=="9" ( set "history=WinCustomization;!history!" && call:NetworkExplorer )
if /i "%choice%"=="10" ( set "history=WinCustomization;!history!" && call:TaskBarDate )
if /i "%choice%"=="11" ( set "history=WinCustomization;!history!" && call:IconArrowOnShortcut )
if /i "%choice%"=="12" ( set "history=WinCustomization;!history!" && Call:DisableWelcomeExperience )
if /i "%choice%"=="13" ( set "history=WinCustomization;!history!" && Call:MSRT_in_WindowsUpdate )
if /i "%choice%"=="14" ( set "history=WinCustomization;!history!" && call:FolderNameTemplateMenu )
if /i "%choice%"=="15" ( set "history=WinCustomization;!history!" && call:GrayHilightToggle )

if /i "%choice%"=="Cs" ( set "history=WinCustomization;!history!" && goto Cursor_menu )
if /i "%choice%"=="сы" ( set "history=WinCustomization;!history!" && goto Cursor_menu )

if /i "%choice%"=="C" ( set "history=WinCustomization;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=WinCustomization;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=WinCustomization;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=WinCustomization;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="NoInput" goto WrongInput
call:WrongInput
goto WinCustomization


:Cursor_menu
cls
for %%i in (C_VS15 C_VS20 ) do (set "%%i=%COL%[37m") >nul 2>&1

for /f "tokens=2*" %%a in ('reg query "HKCU\Control Panel\Cursors" /ve 2^>nul') do set "default_value=%%b"
if "%default_value%"=="VS Cursor 15.0" set "C_VS20=%COL%[36m[%COL%[37m %COL%[92mАКТИВЕН %COL%[36m] %COL%[37m"

for /f "tokens=2*" %%a in ('reg query "HKCU\Control Panel\Cursors" /ve 2^>nul') do set "default_value=%%b"
if "%default_value%"=="VS Cursor 20.0" set "C_VS20=%COL%[36m[%COL%[37m %COL%[92mАКТИВЕН %COL%[36m] %COL%[37m"

TITLE Панель кастомных курсоров - ASX Hub
echo [INFO ] %TIME% - Открыта панель ":Cursor_menu" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set "choice="
mode con: cols=146 lines=45 >nul 2>&1
set PageName=Cursor_menu

echo.
echo.
echo.
echo                                     %COL%[90m::::::::   :::     ::: :::::::::    ::::::::   ::::::::    :::::::::   :::::::: 
echo                                   :+:    :+:  :+:    :+:  :+:    :+:  :+:    :+:  :+:    :+:  :+:    :+:  :+:    :+: 
echo                                  +:+         +:+    +:+  +:+    +:+  +:+         +:+    +:+  +:+    +:+  +:+         
echo                                 +#+         +#+    +:+  +#++:++#:   +#++:++#++  +#+    +:+  +#++:++#:   +#++:++#++   
echo                                +#+         +#+    +#+  +#+    +#+        +#+   +#+    +#+  +#+    +#+         +#+    
echo                               #+#    #+#  #+#    #+#  #+#    #+#  #+#    #+#  #+#    #+#  #+#    #+#  #+#    #+#     
echo                              ########    ########    ###    ###   ########    ########   ###    ###   ########       
echo.
echo.
echo.
echo.
echo.
echo           %COL%[36mКУРСОРЫ
echo           %COL%[97m-------%COL%[37m
echo           %COL%[96m 1 %COL%[37m VS Cursor 15.0 %C_VS15% %COL%[90m ^[C1 - предпросмотр^] %COL%[37m
echo.
echo           %COL%[96m 2. %COL%[37m VS Cursor 20.0 %C_VS20% %COL%[90m ^[C2 - предпросмотр^] %COL%[37m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                         %COL%[90m[ D - Вернуть стандартный курсор ]
echo.
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[37m
echo.
set /p choice="%DEL%                                                                      >: "
if /i "%choice%"=="1" ( set "history=Cursor_menu;!history!" && goto Cursor-VS_15 )
if /i "%choice%"=="c1" ( start https://github.com/ALFiX01/ASX-Hub/blob/main/Files/Resources/Windows_Customization/Cursors/VS_15/Preview.png?raw=true )
if /i "%choice%"=="2" ( set "history=Cursor_menu;!history!" && goto Cursor-VS_20 )
if /i "%choice%"=="c2" ( start https://github.com/ALFiX01/ASX-Hub/blob/main/Files/Resources/Windows_Customization/Cursors/VS_20/Preview.png?raw=true )

if /i "%choice%"=="4" ( set "history=Cursor_menu;!history!" && goto Cursor-win11 )

if /i "%choice%"=="D" ( set "history=Cursor_menu;!history!" && goto Cursor-Default )
if /i "%choice%"=="в" ( set "history=Cursor_menu;!history!" && goto Cursor-Default )

if /i "%choice%"=="C" ( set "history=Cursor_menu;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=Cursor_menu;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=Cursor_menu;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=Cursor_menu;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="NoInput" goto WrongInput
goto Cursor_menu

:Cursor-VS_15
cls
echo [INFO ] %TIME% - Вызван ":Cursor-VS_15" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if not exist "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15" (
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\VS_15.zip" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Resources/Windows_Customization/Cursors/VS_15/VS_15.zip" >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        echo Ошибка: Не удалось скачать файл VS_15.zip. Проверьте подключение к интернету и доступность URL.
		echo [ERROR] %TIME% - Ошибка при загрузке VS_15.zip >> "%ASX-Directory%\Files\Logs\%date%.txt"
        pause
        goto GoBack
    )
    chcp 850 >nul 2>&1
    powershell -NoProfile Expand-Archive '"%ASX-Directory%\Files\Downloads\VS_15.zip"' -DestinationPath '"%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15"' >nul 2>&1	
    chcp 65001 >nul 2>&1
)
echo  %COL%[90m
:: Название схемы и папка
set "CUR_DIR=%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15"
set "SCHEME_NAME=VS Cursor 15.0"

:: Путь к системной папке курсоров
set "DEST_DIR=%SystemRoot%\Cursors\%SCHEME_NAME%"

:: Создать папку назначения (если её нет)
if not exist "%DEST_DIR%" (
    mkdir "%DEST_DIR%"
)

:: Копировать файлы курсоров
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\pointer.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\help.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\work.ani" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\busy.ani" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\cross.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\text.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\hand.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\unavailable.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\vert.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\horz.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\dgn1.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\dgn2.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\move.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\alternate.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\link.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\pin.cur" "%DEST_DIR%" >nul 2>&1
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_15\person.cur" "%DEST_DIR%" >nul 2>&1
cls

:: Импортировать схему курсоров в реестр
reg add "HKCU\Control Panel\Cursors\Schemes" /v "%SCHEME_NAME%" /d "%DEST_DIR%\pointer.cur,%DEST_DIR%\help.cur,%DEST_DIR%\work.ani,%DEST_DIR%\busy.ani,%DEST_DIR%\cross.cur,%DEST_DIR%\text.cur,%DEST_DIR%\hand.cur,%DEST_DIR%\unavailable.cur,%DEST_DIR%\vert.cur,%DEST_DIR%\horz.cur,%DEST_DIR%\dgn1.cur,%DEST_DIR%\dgn2.cur,%DEST_DIR%\move.cur,%DEST_DIR%\alternate.cur,%DEST_DIR%\link.cur,%DEST_DIR%\pin.cur,%DEST_DIR%\person.cur" /f >nul 2>&1

echo.
echo %COL%[37m Установка завершена. Выберите курсор "%SCHEME_NAME%" в настройках указателя мыши. %COL%[90m
echo.
start /wait %Windir%\System32\main.cpl

set "operation_name=Установка курсора %SCHEME_NAME%"
set "errorlevel=0"
call:Complete_notice
goto GoBack

:Cursor-VS_20
cls
echo [INFO ] %TIME% - Вызван ":Cursor-VS_20" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if not exist "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20" (
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\VS_20.zip" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Resources/Windows_Customization/Cursors/VS_20/VS_20.zip" >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        echo Ошибка: Не удалось скачать файл VS_20.zip. Проверьте подключение к интернету и доступность URL.
		echo [ERROR] %TIME% - Ошибка при загрузке VS_20.zip >> "%ASX-Directory%\Files\Logs\%date%.txt"
        pause
        goto GoBack
    )
    chcp 850 >nul 2>&1
    powershell -NoProfile Expand-Archive '"%ASX-Directory%\Files\Downloads\VS_20.zip"' -DestinationPath '"%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20"' >nul 2>&1	
    chcp 65001 >nul 2>&1
)
echo  %COL%[90m
:: Название схемы и папка
set "CUR_DIR=%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20"
set "SCHEME_NAME=VS Cursor 20.0"

:: Путь к системной папке курсоров
set "DEST_DIR=%SystemRoot%\Cursors\%SCHEME_NAME%"

:: Создать папку назначения (если её нет)
if not exist "%DEST_DIR%" (
    mkdir "%DEST_DIR%"
)

:: Копировать файлы курсоров
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\pointer.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\help.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\work.ani" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\busy.ani" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\cross.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\text.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\hand.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\unavailable.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\vert.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\horz.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\dgn1.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\dgn2.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\move.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\alternate.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\link.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\pin.cur" "%DEST_DIR%"
    copy /Y "%ASX-Directory%\Files\Resources\Windows_Customization\Cursors\VS_20\person.cur" "%DEST_DIR%"
cls

:: Импортировать схему курсоров в реестр
reg add "HKCU\Control Panel\Cursors\Schemes" /v "%SCHEME_NAME%" /d "%DEST_DIR%\pointer.cur,%DEST_DIR%\help.cur,%DEST_DIR%\work.ani,%DEST_DIR%\busy.ani,%DEST_DIR%\cross.cur,%DEST_DIR%\text.cur,%DEST_DIR%\hand.cur,%DEST_DIR%\unavailable.cur,%DEST_DIR%\vert.cur,%DEST_DIR%\horz.cur,%DEST_DIR%\dgn1.cur,%DEST_DIR%\dgn2.cur,%DEST_DIR%\move.cur,%DEST_DIR%\alternate.cur,%DEST_DIR%\link.cur,%DEST_DIR%\pin.cur,%DEST_DIR%\person.cur" /f >nul 2>&1
echo.
echo  %COL%[37m Установка завершена. Выберите курсор "%SCHEME_NAME%" в настройках указателя мыши. %COL%[90m
echo.
start /wait %Windir%\System32\main.cpl

set "operation_name=Установка курсора %SCHEME_NAME%"
set "errorlevel=0"
call:Complete_notice
goto GoBack

:Cursor-Default
cls
echo [INFO ] %TIME% - Вызван ":Cursor-Default" >> "%ASX-Directory%\Files\Logs\%date%.txt"
:: Импортировать схему курсоров в реестр
echo.
echo  %COL%[37m Выберите СХЕМА "По умолчанию (системная)" в настройках указателя мыши. %COL%[90m
echo.
start /wait %Windir%\System32\main.cpl

set "operation_name=Установка курсора Default"
set "errorlevel=0"
call:Complete_notice
goto GoBack

:DisableWelcomeExperience
echo [INFO ] %TIME% - Вызван ":DisableWelcomeExperience" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%DSWE%" == "%COL%[91mВЫКЛ" (
    reg add "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsSpotlightWindowsWelcomeExperience" /t REG_DWORD /d 1 /f >nul 2>&1
    set "operation_name=Отключение экрана приветствия Windows"
) else (
    reg delete "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsSpotlightWindowsWelcomeExperience" /f >nul 2>&1
    set "operation_name=Возвращение экрана приветствия Windows"
)
call:Complete_notice
goto GoBack

:EplorerBlur
echo [INFO ] %TIME% - Вызван ":EplorerBlur" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%BLEX%" == "%COL%[91mВЫКЛ" (
REM ВКЛЮЧЕНИЕ
    curl -g -L -# -o "%ASX-Directory%\Files\Resources\AcrylicExplorer.zip" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/AcrylicExplorer.zip" >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        echo Ошибка: Не удалось скачать файл AcrylicExplorer.zip. Проверьте подключение к интернету и доступность URL.
	    echo [ERROR] %TIME% - Ошибка при загрузке AcrylicExplorer.zip >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto GoBack
    )	
    chcp 850 >nul 2>&1 
    powershell -NoProfile Expand-Archive '"%ASX-Directory%\Files\Resources\AcrylicExplorer.zip"' -DestinationPath '"%ASX-Directory%\Files\Resources\AcrylicExplorer"'
    chcp 65001 >nul 2>&1
    del "%ASX-Directory%\Files\Resources\AcrylicExplorer.zip" /Q
    regsvr32 "%ASX-Directory%\Files\Resources\AcrylicExplorer\ExplorerBlurMica.dll"

    reg add "%SaveData%\ParameterFunction" /F /V "AcrylicExplorer" /T REG_SZ /d 0 >nul 2>&1
    set "operation_name=Включение размытого фона проводника"
) >nul 2>&1 else (
    REM ОТКЛЮЧЕНИЕ
    regsvr32 /u "%ASX-Directory%\Files\Resources\AcrylicExplorer\ExplorerBlurMica.dll"
    taskkill /f /im explorer.exe & explorer.exe

    timeout /t 2 >nul 2>&1

    del /f /s /q "%ASX-Directory%\Files\Resources\AcrylicExplorer\*.*" >nul 2>&1
    rd /s /q "%ASX-Directory%\Files\Resources\AcrylicExplorer" >nul 2>&1

    reg delete "%SaveData%\ParameterFunction" /v "AcrylicExplorer" /f >nul 2>&1
    set "operation_name=Отключение размытого фона проводника"
) >nul 2>&1
call:Complete_notice
goto GoBack

:ShowFileExtensions
echo [INFO ] %TIME% - Вызван ":ShowFileExtensions" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%SFE%" == "%COL%[91mВЫКЛ" (
	reg add "%SaveData%\ParameterFunction" /v "ShowFileExtensions" /t Reg_SZ /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t Reg_DWORD /d "0" /f >nul 2>&1
set "operation_name=Включение отображения расширений файлов"
) else (
	reg delete "%SaveData%\ParameterFunction" /v "ShowFileExtensions" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t Reg_DWORD /d "1" /f >nul 2>&1
set "operation_name=Выключение отображения расширений файлов"
) >nul 2>&1
call:Complete_notice
goto GoBack

:ThemeTweaks
echo [INFO ] %TIME% - Вызван ":ThemeTweaks" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%THEME%" == "светлую" (
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "1" /f >nul 2>&1
	reg add "%SaveData%\ParameterFunction" /v "ThemeTweaks" /t Reg_SZ /f >nul 2>&1	
    set "operation_name=Включение светлой темы для приложений"
) else (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f >nul 2>&1
	reg add "%SaveData%\ParameterFunction" /v "ThemeTweaks" /t Reg_SZ /f >nul 2>&1	
    set "operation_name=Включение темной темы для приложений"
) >nul 2>&1
call:Complete_notice
goto GoBack

:GalleryExplorer
echo [INFO ] %TIME% - Вызван ":GalleryExplorer" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%galleryExplorer%" == "%COL%[91mВЫКЛ" (	
        REM ; Show Gallery on Navigation Pane for current user
        reg add "HKCU\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "1" /f >nul 2>&1
        REM ; Add `Show Gallery` option to File Explorer folder options, with default set to enabled
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "CheckedValue" /t REG_DWORD /d "1" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "DefaultValue" /t REG_DWORD /d "1" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "HKeyRoot" /t REG_DWORD /d "2147483649" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "Id" /t REG_DWORD /d "13" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "RegPath" /t REG_SZ /d "Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "Text" /t REG_SZ /d "Show Gallery" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "Type" /t REG_SZ /d "checkbox" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "UncheckedValue" /t REG_DWORD /d "0" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "ValueName" /t REG_SZ /d "System.IsPinnedToNameSpaceTree" /f >nul 2>&1
        set "operation_name=Включение Галерея в проводнике"
) >nul 2>&1 else (
        REM ; Hide Gallery on Navigation Pane for current user
        reg add "HKCU\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f >nul 2>&1
        REM ; Add `Show Gallery` option to File Explorer folder options, with default set to disabled
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "CheckedValue" /t REG_DWORD /d "1" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "DefaultValue" /t REG_DWORD /d "0" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "HKeyRoot" /t REG_DWORD /d "2147483649" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "Id" /t REG_DWORD /d "13" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "RegPath" /t REG_SZ /d "Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "Text" /t REG_SZ /d "Show Gallery" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "Type" /t REG_SZ /d "checkbox" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "UncheckedValue" /t REG_DWORD /d "0" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowGallery" /v "ValueName" /t REG_SZ /d "System.IsPinnedToNameSpaceTree" /f >nul 2>&1
        set "operation_name=Выключение Галерея в проводнике"
) >nul 2>&1
call:Complete_notice
goto GoBack

:HomeExplorer
echo [INFO ] %TIME% - Вызван ":HomeExplorer" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%HomeExplorer%" == "%COL%[91mВЫКЛ" (	
        REM ; Show Home on Navigation Pane for current user
        reg add "HKCU\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /ve /t REG_SZ /d "CLSID_MSGraphHomeFolder" /f >nul 2>&1
        reg add "HKCU\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "1" /f >nul 2>&1
        REM ; Add `Show Home` option to File Explorer folder options, with default set to enabled
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "CheckedValue" /t REG_DWORD /d "1" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "DefaultValue" /t REG_DWORD /d "1" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "HKeyRoot" /t REG_DWORD /d "2147483649" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "Id" /t REG_DWORD /d "13" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "RegPath" /t REG_SZ /d "Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "Text" /t REG_SZ /d "Show Home" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "Type" /t REG_SZ /d "checkbox" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "UncheckedValue" /t REG_DWORD /d "0" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "ValueName" /t REG_SZ /d "System.IsPinnedToNameSpaceTree" /f >nul 2>&1
        set "operation_name=Включение Главная в проводнике"
) >nul 2>&1 else (
        REM ; Hide Home on Navigation Pane for current user
        reg add "HKCU\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /ve /t REG_SZ /d "CLSID_MSGraphHomeFolder" /f >nul 2>&1
        reg add "HKCU\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "0" /f >nul 2>&1
        REM ; Add `Show Home` option to File Explorer folder options, with default set to disabled
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "CheckedValue" /t REG_DWORD /d "1" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "DefaultValue" /t REG_DWORD /d "0" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "HKeyRoot" /t REG_DWORD /d "2147483649" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "Id" /t REG_DWORD /d "13" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "RegPath" /t REG_SZ /d "Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "Text" /t REG_SZ /d "Show Home" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "Type" /t REG_SZ /d "checkbox" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "UncheckedValue" /t REG_DWORD /d "0" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\NavPane\ShowHome" /v "ValueName" /t REG_SZ /d "System.IsPinnedToNameSpaceTree" /f >nul 2>&1
        set "operation_name=Выключение Главная в проводнике"
) >nul 2>&1
call:Complete_notice
goto GoBack

:RecycleBinExplorer
echo [INFO ] %TIME% - Вызван ":RecycleBinExplorer" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%RecycleBinExplorer%" == "%COL%[91mВЫКЛ" (
    REM Показываем Корзину на панели навигации для текущего пользователя
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /f >nul 2>&1
    reg add "HKEY_CURRENT_USER\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" /v "System.IsPinnedToNameSpaceTree" /t REG_DWORD /d "1" /f >nul 2>&1
    set "operation_name=Включение Корзина в проводнике"
) >nul 2>&1 else (
    REM Удаляем Корзину из левой панели проводника через реестр (адаптация из .reg)
    reg delete "HKEY_CURRENT_USER\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" /f >nul 2>&1
    set "operation_name=Выключение Корзина в проводнике"
) >nul 2>&1
call:Complete_notice
goto GoBack

:NetworkExplorer
echo [INFO ] %TIME% - Вызван ":NetworkExplorer" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%NetworkExplorer%" == "%COL%[91mВЫКЛ" (	
		reg add "HKEY_CURRENT_USER\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /v "System.IsPinnedToNameSpaceTree" /t Reg_DWORD /d "1" /f >nul 2>&1
         set "operation_name=Включение Сеть в проводнике"
) >nul 2>&1 else (
		reg add "HKEY_CURRENT_USER\Software\Classes\CLSID\{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}" /v "System.IsPinnedToNameSpaceTree" /t Reg_DWORD /d "0" /f >nul 2>&1
         set "operation_name=Выключение Сеть в проводнике"
) >nul 2>&1
call:Complete_notice
goto GoBack

:TaskBarDate
echo [INFO ] %TIME% - Вызван ":TaskBarDate" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%TaskBarDate%" == "%COL%[91mВЫКЛ" (	
		reg add "HKEY_CURRENT_USER\Control Panel\International" /v "sShortDate" /t Reg_SZ /d "ddd-dd.MM.yyyy" /f >nul 2>&1
        set "operation_name=Включение показа дня недели на панели задач"
        taskkill /f /im explorer.exe & explorer.exe
) >nul 2>&1 else (
		reg add "HKEY_CURRENT_USER\Control Panel\International" /v "sShortDate" /t Reg_SZ /d "dd.MM.yyyy" /f >nul 2>&1
        set "operation_name=Выключение показа дня недели на панели задач"
        taskkill /f /im explorer.exe & explorer.exe
) >nul 2>&1
call:Complete_notice
goto GoBack

:IconArrowOnShortcut
echo [INFO ] %TIME% - Вызван ":IconArrowOnShortcut" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if "%IconArrow%" == "%COL%[91mВЫКЛ" (	
        reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /f
        taskkill /f /im explorer.exe
        start explorer.exe
        set "operation_name=Вкючение стрелок на ярлыках"
) >nul 2>&1 else (
        REM curl -sSL https://git.io/blankfavicon16x16 -o %ASX-Directory%\Files\Resources\favicon.ico
        REG add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" /v 29 /t REG_SZ /d "" /f
        taskkill /f /im explorer.exe
        start explorer.exe
        set "operation_name=Выкючение стрелок на ярлыках"
) >nul 2>&1
call:Complete_notice
goto GoBack

:FolderNameTemplateMenu
if "%FolderNameTemplate%" == "%COL%[91mВЫКЛ" (
    echo [INFO ] %TIME% - Вызван ":FolderNameTemplateMenu" >> "%ASX-Directory%\Files\Logs\%date%.txt"
    cls
    TITLE Смена названия новых папок - ASX Hub
    echo.
    echo.
    echo.
    echo.
    echo.
    echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
    echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
    echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
    echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
    echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
    echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
    echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
    echo.
    echo                              Нажатие клавиш B или И не вернет вас назад, а может привести к нарушению работы скрипта
    echo.
    echo.
    set /p "FolderNameTemplateEnter=%DEL%                                                Введите шаблон для названия новых папок >: "
    echo [INFO ] %TIME% - Установка названия для новых папок: %FolderNameTemplateEnter% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /v "RenameNameTemplate" /t REG_SZ /d "%FolderNameTemplateEnter%" /f >nul 2>&1
    set "operation_name=Установка нестандартного названия для новых папок"
) else (
    echo [INFO ] %TIME% - Установка названия для новых папок на стандартное >> "%ASX-Directory%\Files\Logs\%date%.txt"
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates" /f >nul 2>&1
    set "operation_name=Сброс названий новых папок на стандартные"
)
call:Complete_notice
goto GoBack

:GrayHilightToggle
if "%GrayHilight%" == "%COL%[91mВЫКЛ" (
    echo [INFO ] %TIME% - Изменение цвета выделения на серый >> "%ASX-Directory%\Files\Logs\%date%.txt"
    reg add "HKCU\Control Panel\Colors" /v "Hilight" /t REG_SZ /d "95 95 95" /f >nul 2>&1
    reg add "HKCU\Control Panel\Colors" /v "HotTrackingColor" /t REG_SZ /d "80 80 80" /f >nul 2>&1
    set "operation_name=Изменение цвета выделеной области. Нужна перезагрузка"
) >nul 2>&1 else (
    echo [INFO ] %TIME% - Изменение цвета выделения на стандартный >> "%ASX-Directory%\Files\Logs\%date%.txt"
    reg add "HKCU\Control Panel\Colors" /v "Hilight" /t REG_SZ /d "0 120 215" /f >nul 2>&1
    reg add "HKCU\Control Panel\Colors" /v "HotTrackingColor" /t REG_SZ /d "0 102 204" /f >nul 2>&1
    set "operation_name=Изменение цвета выделеной области. Нужна перезагрузка"
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services
REM call:Privacy-checker
cls
chcp 65001 >nul 2>&1
REM Reset status variables (optional, but good practice)
for %%s in (PcaSvc Wecsvc WbioSrvc stisvc WSearch MapsBroker SensorService vmickvpexchange XblAuthManager Spooler DPS SysMain wisvc Fax RemoteRegistry PhoneSvc TabletInputService WpcMonSvc DoSvc WalletService MixedRealityOpenXRSvc) do (
    set "Serv_%%s=%COL%[91mН/Д"
)

for %%R in (Serv_Location Serv_UserActivities ) do (
    set "%%R=%COL%[92mВКЛ "
)

set "output_file=%ASX-Directory%\Files\Logs\Output-Services-%date%.txt"
reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services > %output_file%
for /f %%i in ('type %output_file% ^| find /c /v ""') do set "line_count=%%i"

for /f %%i in ('sc query ^| find "STATE" ^| find /c "RUNNING"') do set Services_count=%%i

rem Проверяем службы и их состояние
set "ServicesList=PcaSvc Wecsvc WbioSrvc stisvc WSearch MapsBroker SensorService vmickvpexchange XblAuthManager Spooler DPS SysMain wisvc Fax RemoteRegistry PhoneSvc TabletInputService WpcMonSvc DoSvc WalletService MixedRealityOpenXRSvc UsoSvc"
for %%s in (%ServicesList%) do (
    sc query %%s >nul 2>&1
    if errorlevel 1 (
        set "Serv_%%s=%COL%[90mН/Д "
    ) else (
        for /f "tokens=4" %%a in ('sc query %%s ^| findstr "STATE"') do (
            if /i "%%a"=="RUNNING" (
                set "Serv_%%s=%COL%[92mВКЛ "
            ) else (
                set "Serv_%%s=%COL%[91mВЫКЛ"
            )
        )
    )
)

	REM Служба отслеживания местоположения
    for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v "Value" 2^>nul') do (
    	if "%%A"=="Deny" set "Serv_Location=%COL%[91mВЫКЛ"
    )

    REM Проверка состояния UAC (Контроль учетных записей пользователей)
    for /f "tokens=3" %%A in ('reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities1" 2^>nul') do (
    	if "%%A"=="0x1" set "Serv_UserActivities=%COL%[91mВЫКЛ"
    )


echo [INFO ] %TIME% - Открыта панель ":Services" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=Services
set choice=NoInput
TITLE Службы - ASX Hub
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo          %COL%[36mСЛУЖБЫ WINDOWS ^(%Services_count%\~%line_count%^)
echo          %COL%[97m------------------------%COL%[37m
echo           1 %COL%[36m[%COL%[37m %Serv_PcaSvc% %COL%[36m]%COL%[37m Служба помощника по совместимости программ ^(%COL%[36mPcaSvc %COL%[37m^)
echo           2 %COL%[36m[%COL%[37m %Serv_Wecsvc% %COL%[36m]%COL%[37m Служба сборщика событий Windows ^(%COL%[36mWecsvc %COL%[37m^)
echo           3 %COL%[36m[%COL%[37m %Serv_WbioSrvc% %COL%[36m]%COL%[37m Биометрическая служба Windows ^(%COL%[36mWbioSrvc %COL%[37m^)
echo           4 %COL%[36m[%COL%[37m %Serv_WSearch% %COL%[36m]%COL%[37m Windows Search ^(%COL%[36mWSearch %COL%[37m^)
echo           5 %COL%[36m[%COL%[37m %Serv_MapsBroker% %COL%[36m]%COL%[37m Диспетчер скачанных карт ^(%COL%[36mMapsBroker %COL%[37m^)
echo           6 %COL%[36m[%COL%[37m %Serv_SensorService% %COL%[36m]%COL%[37m Службы датчиков ^(%COL%[36mSensorService, SensorDataService, SensrSvc %COL%[37m^)
echo           7 %COL%[36m[%COL%[37m %Serv_vmickvpexchange% %COL%[36m]%COL%[37m Службы Hyper-V ^(%COL%[36mvmickvpexchange, vmicshutdown, vmicheartbeat, и тд. %COL%[37m^)
echo           8 %COL%[36m[%COL%[37m %Serv_XblAuthManager% %COL%[36m]%COL%[37m Службы Xbox ^(%COL%[36mXblGameSave, XboxNetApiSvc, XblAuthManager и тд. %COL%[37m^)
echo           9 %COL%[36m[%COL%[37m %Serv_Spooler% %COL%[36m]%COL%[37m Служба печати ^(%COL%[36mSpooler - Если нет принтера - выключайте %COL%[37m^)
echo          10 %COL%[36m[%COL%[37m %Serv_stisvc% %COL%[36m]%COL%[37m Служба загрузки изображений Windows ^(%COL%[36mstisvc - Если нет сканера - выключайте %COL%[37m^)
echo          11 %COL%[36m[%COL%[37m %Serv_DPS% %COL%[36m]%COL%[37m Службы диагностики ^(%COL%[36mDiagTrack, DPS, WdiServiceHost и тд. %COL%[37m^)
echo          12 %COL%[36m[%COL%[37m %Serv_SysMain% %COL%[36m]%COL%[37m SysMain ^(%COL%[36mSuperfetch - Если у вас SSD - выключайте %COL%[37m^)
echo          13 %COL%[36m[%COL%[37m %Serv_wisvc% %COL%[36m]%COL%[37m Служба предварительной оценки Windows ^(%COL%[36mwisvc - Компоненты Insider Preview %COL%[37m^)
echo          14 %COL%[36m[%COL%[37m %Serv_Fax% %COL%[36m]%COL%[37m Факс ^(%COL%[36mFax - Если нет факс-модема - выключайте %COL%[37m^)
echo          15 %COL%[36m[%COL%[37m %Serv_RemoteRegistry% %COL%[36m]%COL%[37m Удаленный реестр ^(%COL%[36mRemoteRegistry - Обычно не нужен %COL%[37m^)
echo          16 %COL%[36m[%COL%[37m %Serv_PhoneSvc% %COL%[36m]%COL%[37m Телефонная служба ^(%COL%[36mPhoneSvc - Если не используете модем/телефонию %COL%[37m^)
echo          17 %COL%[36m[%COL%[37m %Serv_TabletInputService% %COL%[36m]%COL%[37m Служба сенсорной клавиатуры и панели рукописного ввода ^(%COL%[36mTabletInputService %COL%[37m^)
echo          18 %COL%[36m[%COL%[37m %Serv_WpcMonSvc% %COL%[36m]%COL%[37m Служба родительского контроля ^(%COL%[36mWpcMonSvc - Если не используется %COL%[37m^)
echo          19 %COL%[36m[%COL%[37m %Serv_DoSvc% %COL%[36m]%COL%[37m Оптимизация доставки ^(%COL%[36mDoSvc - P2P обновления Windows %COL%[37m^)
echo          20 %COL%[36m[%COL%[37m %Serv_WalletService% %COL%[36m]%COL%[37m Служба кошелька ^(%COL%[36mWalletService - Для некоторых приложений Store%COL%[37m^)
echo          21 %COL%[36m[%COL%[37m %Serv_MixedRealityOpenXRSvc% %COL%[36m]%COL%[37m Служба Windows Mixed Reality OpenXR ^(%COL%[36mMixedRealityOpenXRSvc - Для некоторых приложений Store %COL%[37m^)
echo          22 %COL%[36m[%COL%[37m %Serv_UsoSvc% %COL%[36m]%COL%[37m Службы обновления Windows ^(%COL%[36mwuauserv, WaaSMedicSvc, UsoSvc, DoSvc%COL%[37m^)
echo          23 %COL%[36m[%COL%[37m %Serv_Location% %COL%[36m]%COL%[37m Служба отслеживания местоположения ^(%COL%[36mlfsvc %COL%[37m^)
echo          23 %COL%[36m[%COL%[37m %Serv_UserActivities% %COL%[36m]%COL%[37m Запись хронологии действий в Windows ^(%COL%[36mlfsvc %COL%[37m^)
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
REM echo                                           %COL%[90mВведите %COL%[36m[ RS ]%COL%[90m для автоматической настройки всех служб Windows
echo.
echo.
REM echo                              %COL%[36m[ B - Назад ]         %COL%[91m[ X - Главное меню ]         %COL%[36m[ N - Слудующая страница ]
echo                        %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m       %COL%[36m[ SL - Список служб ]%COL%[90m       %COL%[36m[ RS - Авто настройка ]%COL%[90m
echo.
set /p choice="%DEL%                                                                       >: "
if /i "%choice%"=="1" ( set "history=Services;!history!" && Call:Services_PcaSvc )
if /i "%choice%"=="2" ( set "history=Services;!history!" && Call:Services_Wecsvc )
if /i "%choice%"=="3" ( set "history=Services;!history!" && Call:Services_WbioSrvc )
if /i "%choice%"=="4" ( set "history=Services;!history!" && Call:Services_WSearch )
if /i "%choice%"=="5" ( set "history=Services;!history!" && Call:Services_MapsBroker )
if /i "%choice%"=="6" ( set "history=Services;!history!" && Call:Services_SensorService )
if /i "%choice%"=="7" ( set "history=Services;!history!" && Call:Services_Hyper-V )
if /i "%choice%"=="8" ( set "history=Services;!history!" && Call:Services_XblGameSave )
if /i "%choice%"=="9" ( set "history=Services;!history!" && Call:Services_Printer )
if /i "%choice%"=="10" ( set "history=Services;!history!" && Call:Services_stisvc )
if /i "%choice%"=="11" ( set "history=Services;!history!" && Call:Services_Diagnost )
if /i "%choice%"=="12" ( set "history=Services;!history!" && Call:Services_SysMain )
if /i "%choice%"=="13" ( set "history=Services;!history!" && Call:Services_wisvc )
if /i "%choice%"=="14" ( set "history=Services;!history!" && Call:Services_Fax )
if /i "%choice%"=="15" ( set "history=Services;!history!" && Call:Services_RemoteRegistry )
if /i "%choice%"=="16" ( set "history=Services;!history!" && Call:Services_PhoneSvc )
if /i "%choice%"=="17" ( set "history=Services;!history!" && Call:Services_TabletInputService )
if /i "%choice%"=="18" ( set "history=Services;!history!" && Call:Services_WpcMonSvc )
if /i "%choice%"=="19" ( set "history=Services;!history!" && Call:Services_DoSvc )
if /i "%choice%"=="20" ( set "history=Services;!history!" && Call:Services_WalletService )
if /i "%choice%"=="21" ( set "history=Services;!history!" && Call:Services_MixedRealityOpenXRSvc )
if /i "%choice%"=="22" ( set "Warning_NotRecommended_Call=Services_WinUpdate" && set "history_Warning_NotRecommended_goto=Services" && set "history=Services;!history!" && Call:Warning_NotRecommended)
if /i "%choice%"=="23" ( set "history=Services;!history!" && Call:Services_Location )
if /i "%choice%"=="24" ( set "history=Services;!history!" && Call:Services_UserActivities )

if /i "%choice%"=="RS" ( set "history=Services;!history!" && Call:Recommeded_Services_Turn )
if /i "%choice%"=="кы" ( set "history=Services;!history!" && Call:Recommeded_Services_Turn )
if /i "%choice%"=="SL" ( set "history=Services;!history!" && Call:Services_List )
if /i "%choice%"=="ыд" ( set "history=Services;!history!" && Call:Services_List )
if /i "%choice%"=="C" ( set "history=Services;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=Services;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=Services;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=Services;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="NoInput" goto WrongInput
call:WrongInput
goto Services

:Warning_NotRecommended
cls
echo [INFO ] %TIME% - Вызван ":Warning_NotRecommended" >> "%ASX-Directory%\Files\Logs\%date%.txt"
title Предупреждение - ASX Hub
echo.
echo.
echo.
echo.
echo                                                                         %COL%[91m_
echo                                                                        / \
echo                                                                       /   \
echo                                                                      /     \
echo                                                                     /       \
echo                                                                    /         \
echo                                                                   /           \
echo                                                                  /             \
echo                                                                 /      ___      \
echo                                                                /      ^|   ^|      \
echo                                                               /       ^|   ^|       \
echo                                                              /        ^|   ^|        \
echo                                                             /         ^|   ^|         \
echo                                                            /          ^|   ^|          \
echo                                                           /           ^|   ^|           \
echo                                                          /            ^|   ^|            \
echo                                                         /             ^|___^|             \
echo                                                        /                                 \
echo                                                       /                                   \
echo                                                      /                 ___                 \
echo                                                     /                 ^|___^|                 \
echo                                                    /                                         \
echo                                                   /___________________________________________\
echo.
echo.
echo.
echo.
echo                                Внимание: %COL%[37mВыбранный вами твик не рекомендуется к применению разработчиками ASX Hub.
echo.
echo                                       Пожалуйста, тщательно обдумайте своё решение перед активацией твика.%COL%[90m
echo.
echo.
echo.
echo                                               Введите %COL%[36m^<OK^>%COL%[90m для продолжения или %COL%[36m^<B^>%COL%[90m для возврата назад.
echo.
set "choice="
set /p choice="%DEL%                                                                     >: "

if not defined choice cls && goto Warning_NotRecommended
if /i "%choice%"=="OK" ( goto %Warning_NotRecommended_Call% )
if /i "%choice%"=="ок" ( goto %Warning_NotRecommended_Call% )
if /i "%choice%"=="back" ( goto GoBack )
if /i "%choice%"=="B" ( goto GoBack )
if /i "%choice%"=="и" ( goto GoBack )
goto Warning_NotRecommended

:Services_PcaSvc
if "%Serv_PcaSvc%" == "%COL%[91mВЫКЛ" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\PcaSvc" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
		net start PcaSvc
	set "operation_name=Включение службы PcaSvc"
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\PcaSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
		net stop PcaSvc
	set "operation_name=Выключение службы PcaSvc"	
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services_Wecsvc
if "%Serv_Wecsvc%" == "%COL%[91mВЫКЛ" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Wecsvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
		net start Wecsvc
	set "operation_name=Включение службы Wecsvc"
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Wecsvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
		net stop Wecsvc
	set "operation_name=Выключение службы Wecsvc"
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services_WbioSrvc
if "%Serv_WbioSrvc%" == "%COL%[91mВЫКЛ" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\WbioSrvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1
		net start WbioSrvc	
	set "operation_name=Включение службы WbioSrvc"
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\WbioSrvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
		net stop WbioSrvc
	set "operation_name=Выключение службы WbioSrvc"	
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services_stisvc
if "%Serv_stisvc%" == "%COL%[91mВЫКЛ" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\stisvc" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
		net start stisvc
	set "operation_name=Включение службы stisvc"
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\stisvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
		net stop stisvc
	set "operation_name=Выключение службы stisvc"	
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services_WSearch
if "%Serv_WSearch%" == "%COL%[91mВЫКЛ" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\WSearch" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
		net start WSearch	
	set "operation_name=Включение службы WSearch"
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\WSearch" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
		net stop WSearch
	set "operation_name=Выключение службы WSearch"	
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services_MapsBroker
if "%Serv_MapsBroker%" == "%COL%[91mВЫКЛ" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\MapsBroker" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	net start MapsBroker	
	set "operation_name=Включение службы MapsBroker"	
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\MapsBroker" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
		net stop MapsBroker
	set "operation_name=Выключение службы MapsBroker"	
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services_SensorService
REM SensorService, SensorDataService, SensrSvc
if "%Serv_SensorService%" == "%COL%[91mВЫКЛ" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SensorService" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SensorDataService" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SensrSvc" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
		net start SensorService
		net start SensorDataService
		net start SensrSvc
	set "operation_name=Включение служб SensorService, SensorDataService, SensrSvc"		
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SensorService" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SensorDataService" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SensrSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
		net stop SensorService
		net stop SensorDataService
		net stop SensrSvc
	set "operation_name=Выключение служб SensorService, SensorDataService, SensrSvc"	
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services_Hyper-V
REM vmickvpexchange, vmicshutdown, vmicheartbeat, vmictimesync, vmicrdv, vmicguestinterface, vmicvmsession, vmicvss
if "%Serv_Hyper-V%" == "%COL%[91mВЫКЛ" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmickvpexchange" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicshutdown" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicheartbeat" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmictimesync" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicrdv" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicguestinterface" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicvmsession" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicvss" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
		net start vmickvpexchange
		net start vmicshutdown
		net start vmicheartbeat
		net start vmictimesync
		net start vmicrdv
		net start vmicguestinterface
		net start vmicvmsession
		net start vmicvss
	set "operation_name=Включение служб vmickvpexchange, vmicshutdown, vmicheartbeat, vmictimesync, vmicrdv, vmicguestinterface, vmicvmsession, vmicvss"		
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmickvpexchange" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicshutdown" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicheartbeat" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmictimesync" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicrdv" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicguestinterface" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicvmsession" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicvss" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1	
		net stop vmickvpexchange
		net stop vmicshutdown
		net stop vmicheartbeat
		net stop vmictimesync
		net stop vmicrdv
		net stop vmicguestinterface
		net stop vmicvmsession
		net stop vmicvss
	set "operation_name=Выключение служб vmickvpexchange, vmicshutdown, vmicheartbeat, vmictimesync, vmicrdv, vmicguestinterface, vmicvmsession, vmicvss"	
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services_XblGameSave
REM XblGameSave, XboxNetApiSvc, XboxGipSvc, XblAuthManager
if "%Serv_XblGameSave%" == "%COL%[91mВЫКЛ" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblGameSave" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxNetApiSvc" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxGipSvc" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblAuthManager" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
		net start XblGameSave
		net start XboxNetApiSvc
		net start XboxGipSvc
		net start XblAuthManager
	set "operation_name=Включение служб XblGameSave, XboxNetApiSvc, XboxGipSvc, XblAuthManager"		
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblGameSave" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxNetApiSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxGipSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblAuthManager" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
		net stop XblGameSave
		net stop XboxNetApiSvc
		net stop XboxGipSvc
		net stop XblAuthManager
	set "operation_name=Выключение служб XblGameSave, XboxNetApiSvc, XboxGipSvc, XblAuthManager"	
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services_Printer
REM Spooler, PrintNotify
if "%Serv_Printer%" == "%COL%[91mВЫКЛ" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Spooler" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\PrintNotify" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
		net start Spooler
		net start PrintNotify
	set "operation_name=Включение служб Spooler, PrintNotify"
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Spooler" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\PrintNotify" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
		net stop Spooler
		net stop PrintNotify
	set "operation_name=Выключение служб Spooler, PrintNotify"
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services_SysMain
REM SysMain
if "%Serv_SysMain%" == "%COL%[91mВЫКЛ" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
		net start SysMain
	set "operation_name=Включение службы SysMain"
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
		net stop SysMain
	set "operation_name=Выключение службы SysMain"
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services_wisvc
REM wisvc
if "%Serv_wisvc%" == "%COL%[91mВЫКЛ" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\wisvc" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1
		net start wisvc
	set "operation_name=Включение службы wisvc"
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\wisvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
		net stop wisvc
	set "operation_name=Выключение службы wisvc"
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services_Diagnost
REM DiagTrack, dmwappushservice, diagsvc, DPS, diagnosticshub.standardcollector.service, WdiServiceHost, WdiSystemHost
if "%Serv_DPS%" == "%COL%[91mВЫКЛ" (
        sc config "DiagTrack" start= auto
		    net start DiagTrack
        sc config "dmwappushservice" start= auto
		    net start dmwappushservice
        sc config "diagsvc" start= auto
		    net start diagsvc
        sc config "DPS" start= auto
		    net start DPS
                reg add HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DiagLog /v Start /t reg_dword /d 1 /f >nul 2>&1
                reg add HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\WdiContextLog /v Start /t reg_dword /d 1 /f >nul 2>&1
        sc config "diagnosticshub.standardcollector.service" start= auto
		    net start diagnosticshub.standardcollector.service
        sc config "WdiServiceHost" start= auto
		    net start WdiServiceHost
        sc config "WdiSystemHost" start= auto
		    net start WdiSystemHost
	set "operation_name=Включение служб DiagTrack, dmwappushservice, diagsvc, DPS и тд."		
) >nul 2>&1 else (
		net stop DiagTrack
            sc config "DiagTrack" start= disabled
		net stop dmwappushservice
            sc config "dmwappushservice" start= disabled
		net stop diagsvc
            sc config "diagsvc" start= disabled
        net stop DPS
            sc config "DPS" start= disabled
                reg add HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DiagLog /v Start /t reg_dword /d 0 /f >nul 2>&1
                reg add HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\WdiContextLog /v Start /t reg_dword /d 0 /f >nul 2>&1
		net stop diagnosticshub.standardcollector.service
            sc config "diagnosticshub.standardcollector.service" start= disabled
		net stop WdiServiceHost
            sc config "WdiServiceHost" start= disabled
		net stop WdiSystemHost
            sc config "WdiSystemHost" start= disabled
	set "operation_name=Выключение служб DiagTrack, dmwappushservice, diagsvc, DPS и тд."	
) >nul 2>&1
call:Complete_notice
goto GoBack

:Services_Fax
if "%Serv_Fax%" == "%COL%[91mВЫКЛ" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Fax" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1 REM Включаем как Manual (3)
    net start Fax >nul 2>&1
    set "operation_name=Включение службы Fax"
) else (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Fax" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1 REM Выключаем (4)
    net stop Fax >nul 2>&1
    set "operation_name=Выключение службы Fax"
)
call:Complete_notice
goto GoBack

:Services_RemoteRegistry
if "%Serv_RemoteRegistry%" == "%COL%[91mВЫКЛ" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\RemoteRegistry" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1 REM Включаем как Manual (3)
    net start RemoteRegistry >nul 2>&1
    set "operation_name=Включение службы RemoteRegistry"
) else (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\RemoteRegistry" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1 REM Выключаем (4)
    net stop RemoteRegistry >nul 2>&1
    set "operation_name=Выключение службы RemoteRegistry"
)
call:Complete_notice
goto GoBack

:Services_PhoneSvc
if "%Serv_PhoneSvc%" == "%COL%[91mВЫКЛ" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\PhoneSvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1 REM Включаем как Manual (3)
    net start PhoneSvc >nul 2>&1
    set "operation_name=Включение службы PhoneSvc"
) else (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\PhoneSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1 REM Выключаем (4)
    net stop PhoneSvc >nul 2>&1
    set "operation_name=Выключение службы PhoneSvc"
)
call:Complete_notice
goto GoBack

:Services_TabletInputService
if "%Serv_TabletInputService%" == "%COL%[91mВЫКЛ" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\TabletInputService" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1 REM Включаем как Automatic (2)
    net start TabletInputService >nul 2>&1
    set "operation_name=Включение службы TabletInputService"
) else (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\TabletInputService" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1 REM Выключаем (4)
    net stop TabletInputService >nul 2>&1
    set "operation_name=Выключение службы TabletInputService"
)
call:Complete_notice
goto GoBack

:Services_WpcMonSvc
if "%Serv_WpcMonSvc%" == "%COL%[91mВЫКЛ" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WpcMonSvc" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1 REM Включаем как Automatic (2)
    net start WpcMonSvc >nul 2>&1
    set "operation_name=Включение службы WpcMonSvc"
) else (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WpcMonSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1 REM Выключаем (4)
    net stop WpcMonSvc >nul 2>&1
    set "operation_name=Выключение службы WpcMonSvc"
)
call:Complete_notice
goto GoBack

:Services_DoSvc
REM DoSvc - Delivery Optimization
if "%Serv_DoSvc%" == "%COL%[91mВЫКЛ" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v "Start" /t REG_DWORD /d 2 /f >nul 2>&1 REM Включаем как Automatic (2)
    net start DoSvc >nul 2>&1
    set "operation_name=Включение службы DoSvc (Оптимизация доставки)"
) else (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1 REM Выключаем (4)
    net stop DoSvc >nul 2>&1
    set "operation_name=Выключение службы DoSvc (Оптимизация доставки)"
)
call:Complete_notice
goto GoBack

:Services_WalletService
REM WalletService
if "%Serv_WalletService%" == "%COL%[91mВЫКЛ" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WalletService" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1 REM Включаем как Manual (3)
    net start WalletService >nul 2>&1
    set "operation_name=Включение службы WalletService"
) else (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WalletService" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1 REM Выключаем (4)
    net stop WalletService >nul 2>&1
    set "operation_name=Выключение службы WalletService"
)
call:Complete_notice
goto GoBack

:Services_MixedRealityOpenXRSvc
REM MixedRealityOpenXRSvc
if "%Serv_MixedRealityOpenXRSvc%" == "%COL%[91mВЫКЛ" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\MixedRealityOpenXRSvc" /v "Start" /t REG_DWORD /d 3 /f >nul 2>&1 REM Включаем как Manual (3)
    net start MixedRealityOpenXRSvc >nul 2>&1
    set "operation_name=Включение службы MixedRealityOpenXRSvc"
) else (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\MixedRealityOpenXRSvc" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1 REM Выключаем (4)
    net stop MixedRealityOpenXRSvc >nul 2>&1
    set "operation_name=Выключение службы MixedRealityOpenXRSvc"
)
call:Complete_notice
goto GoBack

:Services_WinUpdate
REM wuauserv, WaaSMedicSvc, UsoSvc, DoSvc
if "%Serv_UsoSvc%" == "%COL%[91mВЫКЛ" (
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UsoSvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
    REM reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\BITS" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DoSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1

    net start wuauserv
    net start UsoSvc
    net start WaaSMedicSvc
    net start BITS
    net start DoSvc
    schtasks /change /TN "Microsoft\Windows\WindowsUpdate\DoNotConnectToWindowsUpdateInternetLocations" /ENABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\WindowsUpdate\SetDisableUXWUAccess" /ENABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\WindowsUpdate\ExcludeWUDriversInQualityUpdate" /ENABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\WindowsUpdate\AU\NoAutoUpdate" /ENABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan Static Task" /ENABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\UpdateOrchestrator\Start Oobe Expedite Work" /ENABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /ENABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker" /ENABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\UpdateOrchestrator\UpdateModelTask" /ENABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\WaaSMedic\PerformRemediation" /ENABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\WindowsUpdate\Scheduled Start" /ENABLE >nul 2>&1

    chcp 850 >nul 2>&1
    powershell -command "Get-ScheduledTask -TaskPath '\Microsoft\Windows\InstallService\*' | Enable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\UpdateOrchestrator\*' | Enable-ScheduledTask; Get-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\*' | Enable-ScheduledTask;"
    chcp 65001 >nul 2>&1

    set "operation_name=Включение служб mwuauserv, WaaSMedicSvc, UsoSvc, DoSvc"
) else (
    net stop wuauserv
    net stop UsoSvc
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\wuauserv" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\UsoSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
    REM  reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\BITS" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\DoSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1

    schtasks /change /TN "Microsoft\Windows\WindowsUpdate\DoNotConnectToWindowsUpdateInternetLocations" /DISABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\WindowsUpdate\SetDisableUXWUAccess" /DISABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\WindowsUpdate\ExcludeWUDriversInQualityUpdate" /DISABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\WindowsUpdate\AU\NoAutoUpdate" /DISABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan Static Task" /DISABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\UpdateOrchestrator\Start Oobe Expedite Work" /DISABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /DISABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\UpdateOrchestrator\USO_UxBroker" /DISABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\UpdateOrchestrator\UpdateModelTask" /DISABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\WaaSMedic\PerformRemediation" /DISABLE >nul 2>&1
    schtasks /change /TN "Microsoft\Windows\WindowsUpdate\Scheduled Start" /DISABLE >nul 2>&1
    
    chcp 850 >nul 2>&1
    powershell -command "Get-ScheduledTask -TaskPath '\Microsoft\Windows\WindowsUpdate\' | Disable-ScheduledTask"
    chcp 65001 >nul 2>&1

    rd /s /q "%windir%\SoftwareDistribution"
    md "%windir%\SoftwareDistribution"
    set "operation_name=Выключение служб mwuauserv, WaaSMedicSvc, UsoSvc, DoSvc"
)
call:Complete_notice
goto GoBack

:Services_Location
REM lfsvc
if "%Serv_Location%" == "%COL%[91mВЫКЛ" (
    reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v "Value" /f >nul 2>&1
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" /v "Status" /f >nul 2>&1
    set "operation_name=Включение cлужбы отслеживания местоположения"
) else (
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" /v "Value" /t REG_SZ /d "Deny" /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration" /v "Status" /t REG_DWORD /d "0" /f >nul 2>&1
    set "operation_name=Выключение службы отслеживания местоположения"
)
call:Complete_notice
goto GoBack

:Services_UserActivities
REM lfsvc
if "%Serv_Location%" == "%COL%[91mВЫКЛ" (
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /f >nul 2>&1
    set "operation_name=Включение функции записи хронологии действий в Windows"
) else (
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d "0" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d "0" /f >nul 2>&1
    set "operation_name=Выключение функции записи хронологии действий в Windows"
)
call:Complete_notice
goto GoBack

:Recommeded_Services_Turn
REM 2 — Автоматически
REM 3 — Вручную
REM 4 — Отключена

reg add "HKLM\SYSTEM\CurrentControlSet\Services\ALG" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AppIDSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Appinfo" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AppMgmt" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AppReadiness" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AssignedAccessManagerSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AppXSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AudioEndpointBuilder" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Audiosrv" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\AxInstSV" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BFE" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BITS" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BrokerInfrastructure" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BTAGService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BDESVC" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\camsvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CDPSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\ClipSVC" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\COMSysApp" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CoreMessagingRegistrar" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\cphs" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\cplspcon" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CryptSvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DcomLaunch" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DeviceAssociationService" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DeviceInstall" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DevQueryBroker" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dhcp" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\diagnosticshub.standardcollector.service" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\diagsvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dmwappushservice" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1

reg add "HKLM\SYSTEM\CurrentControlSet\Services\diagtrack" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DispBrokerDesktopSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DisplayEnhancementService" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DmEnrollmentSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DoSvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\dot3svc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DPS" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DsmSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DsSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Eaphost" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\EFS" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\EventLog" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\EventSystem" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\fdPHost" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FDResPub" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FontCache" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FontCache3.0.0.0" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\FrameServer" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\gpsvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\GraphicsPerfSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\hidserv" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\IKEEXT" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\InstallService" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\iphlpsvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\IpxlatCfgSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\KAPSService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\KeyIso" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\KNDBWM" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\KtmRm" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LicenseManager" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lmhosts" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\lfsvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LSM" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LxpSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mpssvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\MSDTC" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NcbService" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NcdAutoSetup" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Netman" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\netprofm" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetSetupSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetTcpPortSharing" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NgcCtnrSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NgcSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NlaSvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nsi" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\p2pimsvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\p2psvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PcaSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PerfHost" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\pla" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PlugPlay" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PNRPAutoReg" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PNRPsvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Power" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PrintNotify" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\ProfSvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\QWAVE" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RasMan" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RpcEptMapper" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RpcSs" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\RmSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SamSs" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Schedule" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\seclogon" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SENS" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SensorDataService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SensorService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SensrSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\ShellHWDetection" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SNMPTRAP" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\sppsvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SSDPSRV" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SstpSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\StateRepository" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Steam Client Service" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\stisvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\StorSvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\svsvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\swprv" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SystemEventsBroker" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1

for /f %%I in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services" /k /f "SgrmBroker" ^| find /i "SgrmBroker"') do (
    reg add "%%I" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
)
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Themes" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TimeBrokerSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TokenBroker" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrkWks" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\upnphost" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\UserManager" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\UsoSvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1

reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmickvpexchange" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicshutdown" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicheartbeat" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmictimesync" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicrdv" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicguestinterface" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicvmsession" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\vmicvss" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1	

reg add "HKLM\SYSTEM\CurrentControlSet\Services\VaultSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\vds" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\VSS" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\W32Time" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WarpJITSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Wcmsvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdiServiceHost" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdiSystemHost" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Wecsvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WEPHOSTSVC" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WFDSConMgrSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WiaRpc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WinHttpAutoProxySvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Winmgmt" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WlanSvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1

reg add "HKLM\SYSTEM\CurrentControlSet\Services\wlidsvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1

reg add "HKLM\SYSTEM\CurrentControlSet\Services\WManSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\wmiApSrv" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WSearch" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblAuthManager" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XblGameSave" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxGipSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\XboxNetApiSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\xTendSoftAPService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\xTendUtilityService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BcastDVRUserService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\BluetoothUserService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CaptureService" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\cbdhsvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CDPUserSvc" /v "Start" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\ConsentUxUserSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CredentialEnrollmentManagerUserSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DeviceAssociationBrokerSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DevicePickerUserSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\DevicesFlowUserSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\OneSyncSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PimIndexMaintenanceSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PrintWorkflowUserSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\UdkUserSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\UnistoreSvc" /v "Start" /t REG_DWORD /d "3" /f >nul 2>&1
set "operation_name=Авто настройка"	
call:Complete_notice
goto GoBack

:Services_List


IF NOT EXIST "%ASX-Directory%\Files\Resources\ASX_ServiceManager" (
    md "%ASX-Directory%\Files\Resources\ASX_ServiceManager" >nul 2>&1
)

curl -g -L -# -o "%ASX-Directory%\Files\Resources\ASX_ServiceManager\ASX_ServiceManager.exe" "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Utilities/ASX_ServiceManager/ASX_ServiceManager.exe" >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        set "ASX_ERROR_TEMPLATE_TEXT=         Не удалось скачать файл ASX_ServiceManager.exe"
        call:ASX_ERROR_TEMPLATE
        goto GoBack
    ) Else (
        start "" "%ASX-Directory%\Files\Resources\ASX_ServiceManager\ASX_ServiceManager.exe"
    )
goto GoBack

:WebResources
if "%WiFi%"=="Off" (	
cls
TITLE Предупреждение - ASX Hub
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                       %COL%[91m_       __                 _            
echo                                                      ^| ^|     / /___ __________  ^(_^)___  ____ _
echo                                                      ^| ^| /^| / / __ `/ ___/ __ \/ / __ \/ __ `/
echo                                                      ^| ^|/ ^|/ / /_/ / /  / / / / / / / / /_/ / 
echo                                                      ^|__/^|__/\__,_/_/  /_/ /_/_/_/ /_/\__, /  
echo                                                                                      /____/
echo                                           %COL%[97m---------------------------------------------------------------%COL%[90m
echo.
echo                                           Веб-ресурсы недоступна из-за отсутствия подключения к интернету
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
pause >nul 2>&1
goto GoBack )

cls
chcp 65001 >nul 2>&1
set PageName=WebResources
set choice=NoInput
echo [INFO ] %TIME% - Открыта панель ":WebResources" >> "%ASX-Directory%\Files\Logs\%date%.txt"
TITLE Веб-ресурсы - ASX Hub
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########%COL%[37m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                          %COL%[36m[ %COL%[37m1 %COL%[36m] %COL%[37mВеб-сайты                         %COL%[36m[ %COL%[37m2 %COL%[36m] %COL%[37mВеб-Расширения
echo.
echo                                          %COL%[36m[ %COL%[37m3 %COL%[36m] %COL%[37mСочетания клавиш                  %COL%[36m[ %COL%[37m4 %COL%[36m] %COL%[37mDiscord
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
%SYSTEMROOT%\System32\choice.exe /c:1234CсXчBи /n /m "%DEL%                                                                      >: " 
set choice=%errorlevel%
if "%choice%"=="1" ( Start https://alfix-inc.yonote.ru/share/c09b6731-f1e2-4fe4-a924-f420ecef3972 )
if "%choice%"=="2" ( Start https://alfix-inc.yonote.ru/share/8e24ecd0-aadb-4a1e-83f4-b66d76710d2c )
if "%choice%"=="3" ( Start https://alfix-inc.yonote.ru/share/bf2a0a30-f29e-4dc0-a9ef-52b034503497 )
if "%choice%"=="4" ( Start https://discord.gg/MreKhdN2Ns )

if "%choice%"=="5" ( set "history=WebResources;!history!" && goto ASX_CMD )
if "%choice%"=="6" ( set "history=WebResources;!history!" && goto ASX_CMD )

if "%choice%"=="7" goto MainMenu
if "%choice%"=="8" goto MainMenu

if "%choice%"=="9" goto GoBack
if "%choice%"=="10" goto GoBack
goto WebResources

:Exp_tweaks
REM for %%i in (ADOFF DOMAC ) do (set "%%i=%COL%[91mВЫКЛ") >nul 2>&1
REM for %%i in (DLNVT CWINT DATAS SPYMD ) do (set "%%i=%COL%[90mН/Д ") >nul 2>&1
for %%i in (C_W11 ) do (set "%%i=%COL%[92mВКЛ ") >nul 2>&1

TITLE Экспериментальные твики - ASX Hub
echo [INFO ] %TIME% - Открыта панель ":Exp_tweaks" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set "choice="
mode con: cols=146 lines=45 >nul 2>&1
set PageName=Exp_tweaks

echo.
echo.
echo.
echo                                        %COL%[90m::::::::::: :::       ::: ::::::::::     :::     :::    ::: ::::::::
echo                                           :+:     :+:       :+: :+:          :+: :+:   :+:   :+: :+:    :+:
echo                                          +:+     +:+       +:+ +:+         +:+   +:+  +:+  +:+  +:+
echo                                         +#+     +#+  +:+  +#+ +#++:++#   +#++:++#++: +#++:++   +#++:++#++
echo                                        +#+     +#+ +#+#+ +#+ +#+        +#+     +#+ +#+  +#+         +#+
echo                                       #+#      #+#+# #+#+#  #+#        #+#     #+# #+#   #+# #+#    #+#
echo                                      ###       ###   ###   ########## ###     ### ###    ### ########
echo.
echo.
echo.
echo.
echo.
echo           %COL%[36mЭкспериментальные твики
echo           %COL%[97m-----------------------%COL%[37m
echo            1 %COL%[36m[%COL%[37m %COL%[36m]%COL%[37m Создать Резервную копию драйверов
echo.
echo            2 %COL%[36m[%COL%[37m %COL%[36m]%COL%[37m Новый метод полного удаления OneDrive
echo.
echo            3 %COL%[36m[%COL%[37m %COL%[36m]%COL%[37m Поиск интересов
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
set /p choice="%DEL%                                                                      >: "
if /i "%choice%"=="1" ( set "history=Exp_tweaks;!history!" && goto Driver_copy )
if /i "%choice%"=="2" ( set "history=Exp_tweaks;!history!" && goto OneDrive-test-version )
if /i "%choice%"=="3" ( set "history=Exp_tweaks;!history!" && goto AnalyzeBrowserHistory )

if /i "%choice%"=="C" ( set "history=Exp_tweaks;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=Exp_tweaks;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=Exp_tweaks;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=Exp_tweaks;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="NoInput" goto WrongInput
goto Exp_tweaks

:AnalyzeBrowserHistory
cls
:: Загрузка BrowsingHistoryView.exe, если отсутствует
if not exist "%ASX-Directory%\Files\Resources\BrowsingHistory" (
    md "%ASX-Directory%\Files\Resources\BrowsingHistory" >nul 2>&1
)
if not exist "%ASX-Directory%\Files\Resources\BrowsingHistory\BrowsingHistoryView.exe" (
    echo  %COL%[37mСкачиваю необходимый компонент...
    curl -g -L -s -o "%ASX-Directory%\Files\Resources\BrowsingHistory\BrowsingHistoryView.exe" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Resources/BrowsingHistoryView.exe"
    if errorlevel 1 (
        echo  ERROR Не удалось скачать необходимый компонент
    )
)
echo  %COL%[37mЭкспортирую данные...
"%ASX-Directory%\Files\Resources\BrowsingHistory\BrowsingHistoryView.exe" /scomma "%ASX-Directory%\Files\Resources\BrowsingHistory\BrowserHistory.txt"

timeout /t 2 >nul

set "file=%ASX-Directory%\Files\Resources\BrowsingHistory\BrowserHistory.txt"

REM Прокачанные категории и ключевые слова
set "Categories=Movies Games Tweaker Social Shopping News Work Education"
set "Movies=movie film cinema netflix hulu kino youtube vod disney amazonprime hbo kinopoisk ivi okko сериал фильм кино мультфильм трейлер animation anime amedia lostfilm"
set "Games=pubg csgo rust fortnite minecraft steam epic roblox dota lol valorant cyberpunk genshin overwatch warzone игровой гейминг геймер игра playstation xbox nintendo blizzard riot ubisoft battlenet origin gog"
set "Tweaker=msconfig regedit sysinternals processhacker autoruns overclock tuning tweak sdi snappy latencymon reshade radeon msi afterburner nvidia driver booster оптимизация настройка производительность разгон утилита tweakui process explorer"
set "Social=facebook instagram twitter tiktok telegram discord whatsapp vkontakte odnoklassniki соцсеть чат мессенджер reddit snapchat linkedin messenger skype zoom teams"
set "Shopping=aliexpress ozon wildberries amazon ebay lamoda sbermarket яндексмаркет маркет покупка магазин shopping купон скидка promo"
set "News=bbc cnn reuters lenta gazeta news новости издание журнал times bloomberg forbes meduza"
set "Work=office outlook teams slack jira trello notion monday github gitlab bitbucket zoom meet work работа проект task задача"
set "Education=edx coursera stepik udemy skillbox geekbrains университет школа лекция учеба обучение learn study курс курс лекции"

REM Очистка старых данных
reg delete "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data\User_Interests_test" /f >nul 2>&1
echo  Запускаю продвинутый анализ...
echo.

setlocal enabledelayedexpansion
set "interestIndex=1"

REM Считаем общее количество строк для нормализации уверенности
for /f %%A in ('find /c /v "" "%file%"') do set "totalLines=%%A"

REM Для каждой категории считаем количество уникальных совпавших ключевых слов и общий счет
for %%C in (%Categories%) do (
    set "categoryName=%%C"
    set "keywords=!%%C!"
    set "keywordCount=0"
    set "uniqueHits="
    set "totalHits=0"

    for %%W in (!keywords!) do (
        findstr /i /c:"%%W" "%file%" >nul 2>&1
        if !errorlevel! equ 0 (
            echo !uniqueHits! | findstr /i /c:"%%W;" >nul 2>&1 || (
                set /a keywordCount+=1
                set "uniqueHits=!uniqueHits!%%W;"
            )
            REM Считаем общее количество вхождений ключа
            for /f %%H in ('findstr /i /c:"%%W" "%file%" ^| find /c /v ""') do (
                set /a totalHits+=%%H
            )
        )
    )

    REM Динамический порог: если найдено хотя бы 3 уникальных ключа или более 10 общих совпадений
    if !keywordCount! geq 5 (
        set "confidence=!keywordCount! уникальных, !totalHits! совпадений"
        reg add "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data\User_Interests_test" /v User_Interests!interestIndex! /t REG_SZ /d !categoryName! /f >nul
        if !errorlevel! equ 0 (
            echo  %COL%[92mОбнаружен интерес к категории !categoryName! ^(Уверенность: !confidence!^) %COL%[37m
            set /a interestIndex+=1
        ) else (
            echo  %COL%[91mОшибка записи категории !categoryName! в реестр %COL%[37m
        )
    )
)

echo.
echo  Завершено
echo.
echo.
echo  %COL%[90mДля продолжения нажмите любую клавишу на клавиатуре
echo.
pause >nul
goto Exp_tweaks

:Driver_copy
echo [INFO ] %TIME% - Вызван ":Driver_copy" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set "choice=NoInput"
cls
echo.
echo Выберите действие:
echo 1. Создать резервную копию драйверов
echo 2. Восстановить драйверы из резервной копии
echo.
set /p choice="Введите номер действия: "

if /I "%choice%"=="1" goto CreateBackup
if /I "%choice%"=="2" goto RestoreBackup
if /I "%choice%"=="B" goto GoBack
if /I "%choice%"=="и" goto GoBack
goto Driver_copy

:CreateBackup
set "backupdir=%ASX-Directory%\Files\Restore\Drivers\%date%"

echo  Создание директории для резервной копии драйверов...
mkdir "%backupdir%"

echo  Экспорт драйверов...
dism /online /export-driver /destination:"%backupdir%"

echo  Резервная копия драйверов создана в %backupdir%!
start "" "%backupdir%"
pause
goto Driver_copy


:RestoreBackup
echo  Выберите папку с резервной копией драйверов:
set "backuproot=%ASX-Directory%\Files\Restore\Drivers"
dir /ad /b "%backuproot%"
echo.
set /p backupdate=" Введите дату резервной копии (в формате, показанном выше): "
set "restoredir=%backuproot%\%backupdate%"

if not exist "%restoredir%" (
    echo  Папка с резервной копией драйверов не найдена.
    pause
    goto Driver_copy
)

echo  Восстановление драйверов из %restoredir%...
dism /online /Add-Driver /Driver:"%restoredir%" /Recurse

echo  Драйверы восстановлены из %restoredir%!
pause
goto Driver_copy


:: Панель программ
:AppPanel
ping -n 1 google.ru >nul 2>&1
IF %ERRORLEVEL% EQU 1 (
 	set "WiFi=Off"	
 ) else (
 	set "WiFi=On"		
)

cls
echo [INFO ] %TIME% - Открыта панель ":AppPanel" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=AppPanel
set choice=NoInput
set SLOADStats=0
REM set "fileList=Start.exe"
TITLE Программы - ASX Hub
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                           %COL%[92m___
echo                                          %COL%[92m^|   ^|                                                     %COL%[91m______
echo                                          %COL%[92m^|   ^|                                              %COL%[91m______^|______^|_____
echo                                          %COL%[92m^|   ^|                                             %COL%[91m^|___________________^|
echo                                        %COL%[92m__^|   ^|__
echo                                        %COL%[92m\       /                                           %COL%[91m^|  ^|             ^|  ^|
echo                                         %COL%[92m\     /                                            %COL%[91m^|  ^|    ^|   ^|    ^|  ^|
echo                                          %COL%[92m\   /                                             %COL%[91m^|  ^|    ^|   ^|    ^|  ^|
echo                                           %COL%[92m\_/                                              %COL%[91m^|  ^|    ^|   ^|    ^|  ^|
echo                                                                                            %COL%[91m^|  ^|    ^|   ^|    ^|  ^|
echo                                %COL%[92m^|  ^|                 ^|  ^|                                   %COL%[91m^|  ^|             ^|  ^|
echo                                %COL%[92m^|  ^|_________________^|  ^|                                   %COL%[91m^|  ^|_____________^|  ^| 
echo                                %COL%[92m^|_______________________^|                                   %COL%[91m^|___________________^|                                
echo.
echo                                        %COL%[92mУстановка %COL%[37m                                                %COL%[91m Удаление%COL%[37m
echo                                _________________________                                   _____________________
echo.
echo                                 %COL%[92m[%COL%[37m 1 %COL%[92m] %COL%[37mОсновные %COL%[37m                                             %COL%[91m[%COL%[37m 3 %COL%[91m] %COL%[37mВручную %COL%[37m
echo                                 %COL%[92m[%COL%[37m 2 %COL%[92m] %COL%[37mРекомендованные %COL%[37m                                      %COL%[91m[%COL%[37m 4 %COL%[91m] %COL%[37mАвтоматически %COL%[37m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                        %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]       %COL%[90m[ F - Папка загрузок ]
echo.
echo.
REM set /p choice="%DEL%                                                                      >: "
%SYSTEMROOT%\System32\choice.exe /c:1234FаXчCсBи /n /m "%DEL%                                                                      >: " 
set choice=%errorlevel%
if "%choice%"=="1" ( set "history=AppPanel;!history!" && goto AppInstall_PG1 )
if "%choice%"=="2" ( set "history=AppPanel;!history!" && goto AppInstall_Recommendations )
if "%choice%"=="3" ( set "history=AppPanel;!history!" && goto AppUninstall )
if "%choice%"=="4" ( set "history=AppPanel;!history!" && goto DeleteMicrosoftApps_Warn )
if "%choice%"=="5" ( set "history=AppPanel;!history!" && goto DwFolder )
if "%choice%"=="6" ( set "history=AppPanel;!history!" && goto DwFolder )
if "%choice%"=="7" ( set "history=AppPanel;!history!" && goto MainMenu )
if "%choice%"=="8" ( set "history=AppPanel;!history!" && goto MainMenu )
if "%choice%"=="9" ( set "history=AppPanel;!history!" && goto ASX_CMD )
if "%choice%"=="10" ( set "history=AppPanel;!history!" && goto ASX_CMD )
if "%choice%"=="11" goto GoBack
if "%choice%"=="12" goto GoBack
call:WrongInput
goto AppPanel


:: Открывает папку загрузок ASX
:DwFolder
start "" "%ASX-Directory%\Files\Downloads"
goto GoBack

:DeleteMicrosoftApps_Warn
rem chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":DeleteMicrosoftApps_Warn" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=DeleteMicrosoftApps_Warn

TITLE Предупреждение перед автоматическим удалением лишних приложений Microsoft - ASX Hub
cls
echo.
echo.
echo.
echo                                                                         %COL%[91m_
echo                                                                        / \
echo                                                                       /   \
echo                                                                      /     \
echo                                                                     /       \
echo                                                                    /         \
echo                                                                   /           \
echo                                                                  /             \
echo                                                                 /      ___      \
echo                                                                /      ^|   ^|      \
echo                                                               /       ^|   ^|       \
echo                                                              /        ^|   ^|        \
echo                                                             /         ^|   ^|         \
echo                                                            /          ^|   ^|          \
echo                                                           /           ^|   ^|           \
echo                                                          /            ^|   ^|            \
echo                                                         /             ^|___^|             \
echo                                                        /                                 \
echo                                                       /                                   \
echo                                                      /                 ___                 \
echo                                                     /                 ^|___^|                 \
echo                                                    /                                         \
echo                                                   /___________________________________________\
echo.
echo.
echo.
echo.
echo                                       %COL%[37mДля запуска автоматического удаления программ необходимо подтверждение.
echo.
echo                        %COL%[96mБудут удалены:%COL%[90m
echo                        3DBuilder, Bing, BingFinance, BingSports, BingWeather, OneConnect, Paint, StickyNotes, SoundRecorder, 
echo                        MixedRealityPortal, 3DViewer, Feedback, Messaging, MicrosoftOfficeHub, OneNote, People, Skype,
echo                        Solitaire Collection, Photos, Phone, Maps, FeedbackHub и SoundRecorder.
echo.
echo.
echo.
echo.
set /p choice="%DEL%                                      Введите %COL%[96m"ОК"%COL%[90m чтобы продолжить или нажмите %COL%[96m"B"%COL%[90m, чтобы вернуться назад %COL%[37m>%COL%[96m "
if /i "%choice%"=="OK" mode con: cols=146 lines=45 >nul 2>&1 & call:DeleteMicrosoftApps
if /i "%choice%"=="ОК" mode con: cols=146 lines=45 >nul 2>&1 & call:DeleteMicrosoftApps
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
goto DeleteMicrosoftApps_Warn

:DeleteMicrosoftApps
echo [INFO ] %TIME% - Вызван "DeleteMicrosoftApps" >> "%ASX-Directory%\Files\Logs\%date%.txt"
if not exist "%ASX-Directory%\Files\Resources\Scripts" md "%ASX-Directory%\Files\Resources\Scripts" >nul 2>&1
curl -L -o "%ASX-Directory%\Files\Resources\Scripts\Delete_MicrosoftOffice.ps1" "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Scripts/Delete_MicrosoftOffice.ps1" >nul 2>&1
cls
TITLE Автоматическое удаление лишних приложений Microsoft - ASX Hub
echo.
echo  Идет процесс удаления лишних программ от Microsoft

:: -----------------Remove "MSN Weather" app-----------------
echo --- Remove "MSN Weather" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.BingWeather' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.BingWeather_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1
chcp 65001 >nul 2>&1

:: -----------------Remove "MSN Sports" app------------------
echo --- Remove "MSN Sports" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.BingSports' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.BingSports_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: ---------------Remove "Microsoft News" app----------------
echo --- Remove "Microsoft News" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.BingNews' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.BingNews_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: ------------------Remove "MSN Money" app------------------
echo --- Remove "MSN Money" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.BingFinance' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.BingFinance_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: --------------Remove insecure "Print 3D" app--------------
echo --- Remove insecure "Print 3D" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.Print3D' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Print3D_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""%SYSTEMROOT%\SystemApps\Windows.Print3D_cw5n1h2txyewy\*"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $renamedCount   = 0; $skippedCount   = 0; $failedCount    = 0; Add-Type -TypeDefinition "^""using System;`r`nusing System.Runtime.InteropServices;`r`npublic class Privileges {`r`n    [DllImport(`"^""advapi32.dll`"^"", ExactSpelling = true, SetLastError = true)]`r`n    internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,`r`n        ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);`r`n    [DllImport(`"^""advapi32.dll`"^"", ExactSpelling = true, SetLastError = true)]`r`n    internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);`r`n    [DllImport(`"^""advapi32.dll`"^"", SetLastError = true)]`r`n    internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);`r`n    [StructLayout(LayoutKind.Sequential, Pack = 1)]`r`n    internal struct TokPriv1Luid {`r`n        public int Count;`r`n        public long Luid;`r`n        public int Attr;`r`n    }`r`n    internal const int SE_PRIVILEGE_ENABLED = 0x00000002;`r`n    internal const int TOKEN_QUERY = 0x00000008;`r`n    internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;`r`n    public static bool AddPrivilege(string privilege) {`r`n        try {`r`n            bool retVal;`r`n            TokPriv1Luid tp;`r`n            IntPtr hproc = GetCurrentProcess();`r`n            IntPtr htok = IntPtr.Zero;`r`n            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);`r`n            tp.Count = 1;`r`n            tp.Luid = 0;`r`n            tp.Attr = SE_PRIVILEGE_ENABLED;`r`n            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);`r`n            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);`r`n            return retVal;`r`n        } catch (Exception ex) {`r`n            throw new Exception(`"^""Failed to adjust token privileges`"^"", ex);`r`n        }`r`n    }`r`n    public static bool RemovePrivilege(string privilege) {`r`n        try {`r`n            bool retVal;`r`n            TokPriv1Luid tp;`r`n            IntPtr hproc = GetCurrentProcess();`r`n            IntPtr htok = IntPtr.Zero;`r`n            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);`r`n            tp.Count = 1;`r`n            tp.Luid = 0;`r`n            tp.Attr = 0;  // This line is changed to revoke the privilege`r`n            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);`r`n            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);`r`n            return retVal;`r`n        } catch (Exception ex) {`r`n            throw new Exception(`"^""Failed to adjust token privileges`"^"", ex);`r`n        }`r`n    }`r`n    [DllImport(`"^""kernel32.dll`"^"", CharSet = CharSet.Auto)]`r`n    public static extern IntPtr GetCurrentProcess();`r`n}"^""; [Privileges]::AddPrivilege('SeRestorePrivilege') | Out-Null; [Privileges]::AddPrivilege('SeTakeOwnershipPrivilege') | Out-Null; $adminSid = New-Object System.Security.Principal.SecurityIdentifier 'S-1-5-32-544'; $adminAccount = $adminSid.Translate([System.Security.Principal.NTAccount]); $adminFullControlAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule( $adminAccount, [System.Security.AccessControl.FileSystemRights]::FullControl, [System.Security.AccessControl.AccessControlType]::Allow ); $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (Test-Path -Path $path -PathType Container) { Write-Host "^""Skipping folder (not its contents): `"^""$path`"^""."^""; $skippedCount++; continue; }; if($revert -eq $true) { if (-not $path.EndsWith('.OLD')) { Write-Host "^""Skipping non-backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; } else { if ($path.EndsWith('.OLD')) { Write-Host "^""Skipping backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; }; $originalFilePath = $path; Write-Host "^""Processing file: `"^""$originalFilePath`"^""."^""; if (-Not (Test-Path $originalFilePath)) { Write-Host "^""Skipping, file `"^""$originalFilePath`"^"" not found."^""; $skippedCount++; exit 0; }; $originalAcl = Get-Acl -Path "^""$originalFilePath"^""; $accessGranted = $false; try { $acl = Get-Acl -Path "^""$originalFilePath"^""; $acl.SetOwner($adminAccount) <# Take Ownership (because file is owned by TrustedInstaller) #>; $acl.AddAccessRule($adminFullControlAccessRule) <# Grant rights to be able to move the file #>; Set-Acl -Path $originalFilePath -AclObject $acl -ErrorAction Stop; $accessGranted = $true; } catch { Write-Warning "^""Failed to grant access to `"^""$originalFilePath`"^"": $($_.Exception.Message)"^""; }; if ($revert -eq $true) { $newFilePath = $originalFilePath.Substring(0, $originalFilePath.Length - 4); } else { $newFilePath = "^""$($originalFilePath).OLD"^""; }; try { Move-Item -LiteralPath "^""$($originalFilePath)"^"" -Destination "^""$newFilePath"^"" -Force -ErrorAction Stop; Write-Host "^""Successfully processed `"^""$originalFilePath`"^""."^""; $renamedCount++; if ($accessGranted) { try { Set-Acl -Path $newFilePath -AclObject $originalAcl -ErrorAction Stop; } catch { Write-Warning "^""Failed to restore access on `"^""$newFilePath`"^"": $($_.Exception.Message)"^""; }; }; } catch { Write-Error "^""Failed to rename `"^""$originalFilePath`"^"" to `"^""$newFilePath`"^"": $($_.Exception.Message)"^""; $failedCount++; if ($accessGranted) { try { Set-Acl -Path $originalFilePath -AclObject $originalAcl -ErrorAction Stop; } catch { Write-Warning "^""Failed to restore access on `"^""$originalFilePath`"^"": $($_.Exception.Message)"^""; }; }; }; }; if (($renamedCount -gt 0) -or ($skippedCount -gt 0)) { Write-Host "^""Successfully processed $renamedCount items and skipped $skippedCount items."^""; }; if ($failedCount -gt 0) { Write-Warning "^""Failed to process $($failedCount) items."^""; }; [Privileges]::RemovePrivilege('SeRestorePrivilege') | Out-Null; [Privileges]::RemovePrivilege('SeTakeOwnershipPrivilege') | Out-Null"
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""%SYSTEMROOT%\$(("^""Windows.Print3D"^"" -Split '\.')[-1])\*"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $renamedCount   = 0; $skippedCount   = 0; $failedCount    = 0; Add-Type -TypeDefinition "^""using System;`r`nusing System.Runtime.InteropServices;`r`npublic class Privileges {`r`n    [DllImport(`"^""advapi32.dll`"^"", ExactSpelling = true, SetLastError = true)]`r`n    internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,`r`n        ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);`r`n    [DllImport(`"^""advapi32.dll`"^"", ExactSpelling = true, SetLastError = true)]`r`n    internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);`r`n    [DllImport(`"^""advapi32.dll`"^"", SetLastError = true)]`r`n    internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);`r`n    [StructLayout(LayoutKind.Sequential, Pack = 1)]`r`n    internal struct TokPriv1Luid {`r`n        public int Count;`r`n        public long Luid;`r`n        public int Attr;`r`n    }`r`n    internal const int SE_PRIVILEGE_ENABLED = 0x00000002;`r`n    internal const int TOKEN_QUERY = 0x00000008;`r`n    internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;`r`n    public static bool AddPrivilege(string privilege) {`r`n        try {`r`n            bool retVal;`r`n            TokPriv1Luid tp;`r`n            IntPtr hproc = GetCurrentProcess();`r`n            IntPtr htok = IntPtr.Zero;`r`n            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);`r`n            tp.Count = 1;`r`n            tp.Luid = 0;`r`n            tp.Attr = SE_PRIVILEGE_ENABLED;`r`n            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);`r`n            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);`r`n            return retVal;`r`n        } catch (Exception ex) {`r`n            throw new Exception(`"^""Failed to adjust token privileges`"^"", ex);`r`n        }`r`n    }`r`n    public static bool RemovePrivilege(string privilege) {`r`n        try {`r`n            bool retVal;`r`n            TokPriv1Luid tp;`r`n            IntPtr hproc = GetCurrentProcess();`r`n            IntPtr htok = IntPtr.Zero;`r`n            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);`r`n            tp.Count = 1;`r`n            tp.Luid = 0;`r`n            tp.Attr = 0;  // This line is changed to revoke the privilege`r`n            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);`r`n            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);`r`n            return retVal;`r`n        } catch (Exception ex) {`r`n            throw new Exception(`"^""Failed to adjust token privileges`"^"", ex);`r`n        }`r`n    }`r`n    [DllImport(`"^""kernel32.dll`"^"", CharSet = CharSet.Auto)]`r`n    public static extern IntPtr GetCurrentProcess();`r`n}"^""; [Privileges]::AddPrivilege('SeRestorePrivilege') | Out-Null; [Privileges]::AddPrivilege('SeTakeOwnershipPrivilege') | Out-Null; $adminSid = New-Object System.Security.Principal.SecurityIdentifier 'S-1-5-32-544'; $adminAccount = $adminSid.Translate([System.Security.Principal.NTAccount]); $adminFullControlAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule( $adminAccount, [System.Security.AccessControl.FileSystemRights]::FullControl, [System.Security.AccessControl.AccessControlType]::Allow ); $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (Test-Path -Path $path -PathType Container) { Write-Host "^""Skipping folder (not its contents): `"^""$path`"^""."^""; $skippedCount++; continue; }; if($revert -eq $true) { if (-not $path.EndsWith('.OLD')) { Write-Host "^""Skipping non-backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; } else { if ($path.EndsWith('.OLD')) { Write-Host "^""Skipping backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; }; $originalFilePath = $path; Write-Host "^""Processing file: `"^""$originalFilePath`"^""."^""; if (-Not (Test-Path $originalFilePath)) { Write-Host "^""Skipping, file `"^""$originalFilePath`"^"" not found."^""; $skippedCount++; exit 0; }; $originalAcl = Get-Acl -Path "^""$originalFilePath"^""; $accessGranted = $false; try { $acl = Get-Acl -Path "^""$originalFilePath"^""; $acl.SetOwner($adminAccount) <# Take Ownership (because file is owned by TrustedInstaller) #>; $acl.AddAccessRule($adminFullControlAccessRule) <# Grant rights to be able to move the file #>; Set-Acl -Path $originalFilePath -AclObject $acl -ErrorAction Stop; $accessGranted = $true; } catch { Write-Warning "^""Failed to grant access to `"^""$originalFilePath`"^"": $($_.Exception.Message)"^""; }; if ($revert -eq $true) { $newFilePath = $originalFilePath.Substring(0, $originalFilePath.Length - 4); } else { $newFilePath = "^""$($originalFilePath).OLD"^""; }; try { Move-Item -LiteralPath "^""$($originalFilePath)"^"" -Destination "^""$newFilePath"^"" -Force -ErrorAction Stop; Write-Host "^""Successfully processed `"^""$originalFilePath`"^""."^""; $renamedCount++; if ($accessGranted) { try { Set-Acl -Path $newFilePath -AclObject $originalAcl -ErrorAction Stop; } catch { Write-Warning "^""Failed to restore access on `"^""$newFilePath`"^"": $($_.Exception.Message)"^""; }; }; } catch { Write-Error "^""Failed to rename `"^""$originalFilePath`"^"" to `"^""$newFilePath`"^"": $($_.Exception.Message)"^""; $failedCount++; if ($accessGranted) { try { Set-Acl -Path $originalFilePath -AclObject $originalAcl -ErrorAction Stop; } catch { Write-Warning "^""Failed to restore access on `"^""$originalFilePath`"^"": $($_.Exception.Message)"^""; }; }; }; }; if (($renamedCount -gt 0) -or ($skippedCount -gt 0)) { Write-Host "^""Successfully processed $renamedCount items and skipped $skippedCount items."^""; }; if ($failedCount -gt 0) { Write-Warning "^""Failed to process $($failedCount) items."^""; }; [Privileges]::RemovePrivilege('SeRestorePrivilege') | Out-Null; [Privileges]::RemovePrivilege('SeTakeOwnershipPrivilege') | Out-Null"
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""%SYSTEMDRIVE%\Program Files\WindowsApps\Windows.Print3D_*_cw5n1h2txyewy\*"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $renamedCount   = 0; $skippedCount   = 0; $failedCount    = 0; Add-Type -TypeDefinition "^""using System;`r`nusing System.Runtime.InteropServices;`r`npublic class Privileges {`r`n    [DllImport(`"^""advapi32.dll`"^"", ExactSpelling = true, SetLastError = true)]`r`n    internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,`r`n        ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);`r`n    [DllImport(`"^""advapi32.dll`"^"", ExactSpelling = true, SetLastError = true)]`r`n    internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);`r`n    [DllImport(`"^""advapi32.dll`"^"", SetLastError = true)]`r`n    internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);`r`n    [StructLayout(LayoutKind.Sequential, Pack = 1)]`r`n    internal struct TokPriv1Luid {`r`n        public int Count;`r`n        public long Luid;`r`n        public int Attr;`r`n    }`r`n    internal const int SE_PRIVILEGE_ENABLED = 0x00000002;`r`n    internal const int TOKEN_QUERY = 0x00000008;`r`n    internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;`r`n    public static bool AddPrivilege(string privilege) {`r`n        try {`r`n            bool retVal;`r`n            TokPriv1Luid tp;`r`n            IntPtr hproc = GetCurrentProcess();`r`n            IntPtr htok = IntPtr.Zero;`r`n            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);`r`n            tp.Count = 1;`r`n            tp.Luid = 0;`r`n            tp.Attr = SE_PRIVILEGE_ENABLED;`r`n            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);`r`n            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);`r`n            return retVal;`r`n        } catch (Exception ex) {`r`n            throw new Exception(`"^""Failed to adjust token privileges`"^"", ex);`r`n        }`r`n    }`r`n    public static bool RemovePrivilege(string privilege) {`r`n        try {`r`n            bool retVal;`r`n            TokPriv1Luid tp;`r`n            IntPtr hproc = GetCurrentProcess();`r`n            IntPtr htok = IntPtr.Zero;`r`n            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);`r`n            tp.Count = 1;`r`n            tp.Luid = 0;`r`n            tp.Attr = 0;  // This line is changed to revoke the privilege`r`n            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);`r`n            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);`r`n            return retVal;`r`n        } catch (Exception ex) {`r`n            throw new Exception(`"^""Failed to adjust token privileges`"^"", ex);`r`n        }`r`n    }`r`n    [DllImport(`"^""kernel32.dll`"^"", CharSet = CharSet.Auto)]`r`n    public static extern IntPtr GetCurrentProcess();`r`n}"^""; [Privileges]::AddPrivilege('SeRestorePrivilege') | Out-Null; [Privileges]::AddPrivilege('SeTakeOwnershipPrivilege') | Out-Null; $adminSid = New-Object System.Security.Principal.SecurityIdentifier 'S-1-5-32-544'; $adminAccount = $adminSid.Translate([System.Security.Principal.NTAccount]); $adminFullControlAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule( $adminAccount, [System.Security.AccessControl.FileSystemRights]::FullControl, [System.Security.AccessControl.AccessControlType]::Allow ); $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (Test-Path -Path $path -PathType Container) { Write-Host "^""Skipping folder (not its contents): `"^""$path`"^""."^""; $skippedCount++; continue; }; if($revert -eq $true) { if (-not $path.EndsWith('.OLD')) { Write-Host "^""Skipping non-backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; } else { if ($path.EndsWith('.OLD')) { Write-Host "^""Skipping backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; }; $originalFilePath = $path; Write-Host "^""Processing file: `"^""$originalFilePath`"^""."^""; if (-Not (Test-Path $originalFilePath)) { Write-Host "^""Skipping, file `"^""$originalFilePath`"^"" not found."^""; $skippedCount++; exit 0; }; $originalAcl = Get-Acl -Path "^""$originalFilePath"^""; $accessGranted = $false; try { $acl = Get-Acl -Path "^""$originalFilePath"^""; $acl.SetOwner($adminAccount) <# Take Ownership (because file is owned by TrustedInstaller) #>; $acl.AddAccessRule($adminFullControlAccessRule) <# Grant rights to be able to move the file #>; Set-Acl -Path $originalFilePath -AclObject $acl -ErrorAction Stop; $accessGranted = $true; } catch { Write-Warning "^""Failed to grant access to `"^""$originalFilePath`"^"": $($_.Exception.Message)"^""; }; if ($revert -eq $true) { $newFilePath = $originalFilePath.Substring(0, $originalFilePath.Length - 4); } else { $newFilePath = "^""$($originalFilePath).OLD"^""; }; try { Move-Item -LiteralPath "^""$($originalFilePath)"^"" -Destination "^""$newFilePath"^"" -Force -ErrorAction Stop; Write-Host "^""Successfully processed `"^""$originalFilePath`"^""."^""; $renamedCount++; if ($accessGranted) { try { Set-Acl -Path $newFilePath -AclObject $originalAcl -ErrorAction Stop; } catch { Write-Warning "^""Failed to restore access on `"^""$newFilePath`"^"": $($_.Exception.Message)"^""; }; }; } catch { Write-Error "^""Failed to rename `"^""$originalFilePath`"^"" to `"^""$newFilePath`"^"": $($_.Exception.Message)"^""; $failedCount++; if ($accessGranted) { try { Set-Acl -Path $originalFilePath -AclObject $originalAcl -ErrorAction Stop; } catch { Write-Warning "^""Failed to restore access on `"^""$originalFilePath`"^"": $($_.Exception.Message)"^""; }; }; }; }; if (($renamedCount -gt 0) -or ($skippedCount -gt 0)) { Write-Host "^""Successfully processed $renamedCount items and skipped $skippedCount items."^""; }; if ($failedCount -gt 0) { Write-Warning "^""Failed to process $($failedCount) items."^""; }; [Privileges]::RemovePrivilege('SeRestorePrivilege') | Out-Null; [Privileges]::RemovePrivilege('SeTakeOwnershipPrivilege') | Out-Null"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\$CURRENT_USER_SID\Windows.Print3D_cw5n1h2txyewy'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; $userSid = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([Security.Principal.SecurityIdentifier]).Value; $registryPath = $registryPath.Replace('$CURRENT_USER_SID', $userSid); if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Windows.Print3D' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Windows.Print3D_cw5n1h2txyewy'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\$CURRENT_USER_SID\Windows.Print3D_cw5n1h2txyewy'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; $userSid = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([Security.Principal.SecurityIdentifier]).Value; $registryPath = $registryPath.Replace('$CURRENT_USER_SID', $userSid); Write-Host "^""Removing registry key at `"^""$registryPath`"^""."^""; if (-not (Test-Path -LiteralPath $registryPath)) { Write-Host "^""Skipping, no action needed, registry key `"^""$registryPath`"^"" does not exist."^""; exit 0; }; try { Remove-Item -LiteralPath $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully removed the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to remove the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""%LOCALAPPDATA%\Packages\Windows.Print3D_cw5n1h2txyewy\*"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $renamedCount   = 0; $skippedCount   = 0; $failedCount    = 0; $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (Test-Path -Path $path -PathType Container) { Write-Host "^""Skipping folder (not its contents): `"^""$path`"^""."^""; $skippedCount++; continue; }; if($revert -eq $true) { if (-not $path.EndsWith('.OLD')) { Write-Host "^""Skipping non-backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; } else { if ($path.EndsWith('.OLD')) { Write-Host "^""Skipping backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; }; $originalFilePath = $path; Write-Host "^""Processing file: `"^""$originalFilePath`"^""."^""; if (-Not (Test-Path $originalFilePath)) { Write-Host "^""Skipping, file `"^""$originalFilePath`"^"" not found."^""; $skippedCount++; exit 0; }; if ($revert -eq $true) { $newFilePath = $originalFilePath.Substring(0, $originalFilePath.Length - 4); } else { $newFilePath = "^""$($originalFilePath).OLD"^""; }; try { Move-Item -LiteralPath "^""$($originalFilePath)"^"" -Destination "^""$newFilePath"^"" -Force -ErrorAction Stop; Write-Host "^""Successfully processed `"^""$originalFilePath`"^""."^""; $renamedCount++; } catch { Write-Error "^""Failed to rename `"^""$originalFilePath`"^"" to `"^""$newFilePath`"^"": $($_.Exception.Message)"^""; $failedCount++; }; }; if (($renamedCount -gt 0) -or ($skippedCount -gt 0)) { Write-Host "^""Successfully processed $renamedCount items and skipped $skippedCount items."^""; }; if ($failedCount -gt 0) { Write-Warning "^""Failed to process $($failedCount) items."^""; }"
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""%PROGRAMDATA%\Microsoft\Windows\AppRepository\Packages\Windows.Print3D_*_cw5n1h2txyewy\*"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $renamedCount   = 0; $skippedCount   = 0; $failedCount    = 0; Add-Type -TypeDefinition "^""using System;`r`nusing System.Runtime.InteropServices;`r`npublic class Privileges {`r`n    [DllImport(`"^""advapi32.dll`"^"", ExactSpelling = true, SetLastError = true)]`r`n    internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall,`r`n        ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr relen);`r`n    [DllImport(`"^""advapi32.dll`"^"", ExactSpelling = true, SetLastError = true)]`r`n    internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);`r`n    [DllImport(`"^""advapi32.dll`"^"", SetLastError = true)]`r`n    internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);`r`n    [StructLayout(LayoutKind.Sequential, Pack = 1)]`r`n    internal struct TokPriv1Luid {`r`n        public int Count;`r`n        public long Luid;`r`n        public int Attr;`r`n    }`r`n    internal const int SE_PRIVILEGE_ENABLED = 0x00000002;`r`n    internal const int TOKEN_QUERY = 0x00000008;`r`n    internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;`r`n    public static bool AddPrivilege(string privilege) {`r`n        try {`r`n            bool retVal;`r`n            TokPriv1Luid tp;`r`n            IntPtr hproc = GetCurrentProcess();`r`n            IntPtr htok = IntPtr.Zero;`r`n            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);`r`n            tp.Count = 1;`r`n            tp.Luid = 0;`r`n            tp.Attr = SE_PRIVILEGE_ENABLED;`r`n            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);`r`n            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);`r`n            return retVal;`r`n        } catch (Exception ex) {`r`n            throw new Exception(`"^""Failed to adjust token privileges`"^"", ex);`r`n        }`r`n    }`r`n    public static bool RemovePrivilege(string privilege) {`r`n        try {`r`n            bool retVal;`r`n            TokPriv1Luid tp;`r`n            IntPtr hproc = GetCurrentProcess();`r`n            IntPtr htok = IntPtr.Zero;`r`n            retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);`r`n            tp.Count = 1;`r`n            tp.Luid = 0;`r`n            tp.Attr = 0;  // This line is changed to revoke the privilege`r`n            retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);`r`n            retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);`r`n            return retVal;`r`n        } catch (Exception ex) {`r`n            throw new Exception(`"^""Failed to adjust token privileges`"^"", ex);`r`n        }`r`n    }`r`n    [DllImport(`"^""kernel32.dll`"^"", CharSet = CharSet.Auto)]`r`n    public static extern IntPtr GetCurrentProcess();`r`n}"^""; [Privileges]::AddPrivilege('SeRestorePrivilege') | Out-Null; [Privileges]::AddPrivilege('SeTakeOwnershipPrivilege') | Out-Null; $adminSid = New-Object System.Security.Principal.SecurityIdentifier 'S-1-5-32-544'; $adminAccount = $adminSid.Translate([System.Security.Principal.NTAccount]); $adminFullControlAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule( $adminAccount, [System.Security.AccessControl.FileSystemRights]::FullControl, [System.Security.AccessControl.AccessControlType]::Allow ); $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (Test-Path -Path $path -PathType Container) { Write-Host "^""Skipping folder (not its contents): `"^""$path`"^""."^""; $skippedCount++; continue; }; if($revert -eq $true) { if (-not $path.EndsWith('.OLD')) { Write-Host "^""Skipping non-backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; } else { if ($path.EndsWith('.OLD')) { Write-Host "^""Skipping backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; }; $originalFilePath = $path; Write-Host "^""Processing file: `"^""$originalFilePath`"^""."^""; if (-Not (Test-Path $originalFilePath)) { Write-Host "^""Skipping, file `"^""$originalFilePath`"^"" not found."^""; $skippedCount++; exit 0; }; $originalAcl = Get-Acl -Path "^""$originalFilePath"^""; $accessGranted = $false; try { $acl = Get-Acl -Path "^""$originalFilePath"^""; $acl.SetOwner($adminAccount) <# Take Ownership (because file is owned by TrustedInstaller) #>; $acl.AddAccessRule($adminFullControlAccessRule) <# Grant rights to be able to move the file #>; Set-Acl -Path $originalFilePath -AclObject $acl -ErrorAction Stop; $accessGranted = $true; } catch { Write-Warning "^""Failed to grant access to `"^""$originalFilePath`"^"": $($_.Exception.Message)"^""; }; if ($revert -eq $true) { $newFilePath = $originalFilePath.Substring(0, $originalFilePath.Length - 4); } else { $newFilePath = "^""$($originalFilePath).OLD"^""; }; try { Move-Item -LiteralPath "^""$($originalFilePath)"^"" -Destination "^""$newFilePath"^"" -Force -ErrorAction Stop; Write-Host "^""Successfully processed `"^""$originalFilePath`"^""."^""; $renamedCount++; if ($accessGranted) { try { Set-Acl -Path $newFilePath -AclObject $originalAcl -ErrorAction Stop; } catch { Write-Warning "^""Failed to restore access on `"^""$newFilePath`"^"": $($_.Exception.Message)"^""; }; }; } catch { Write-Error "^""Failed to rename `"^""$originalFilePath`"^"" to `"^""$newFilePath`"^"": $($_.Exception.Message)"^""; $failedCount++; if ($accessGranted) { try { Set-Acl -Path $originalFilePath -AclObject $originalAcl -ErrorAction Stop; } catch { Write-Warning "^""Failed to restore access on `"^""$originalFilePath`"^"": $($_.Exception.Message)"^""; }; }; }; }; if (($renamedCount -gt 0) -or ($skippedCount -gt 0)) { Write-Host "^""Successfully processed $renamedCount items and skipped $skippedCount items."^""; }; if ($failedCount -gt 0) { Write-Warning "^""Failed to process $($failedCount) items."^""; }; [Privileges]::RemovePrivilege('SeRestorePrivilege') | Out-Null; [Privileges]::RemovePrivilege('SeTakeOwnershipPrivilege') | Out-Null"
chcp 65001 >nul 2>&1

:: ------------Remove "Microsoft 3D Builder" app-------------
echo --- Remove "Microsoft 3D Builder" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.3DBuilder' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.3DBuilder_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: ------------------Remove "3D Viewer" app------------------
echo --- Remove "3D Viewer" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.Microsoft3DViewer' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Microsoft3DViewer_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: -----------Remove "Microsoft 365 (Office)" app------------
echo --- Remove "Microsoft 365 (Office)" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.MicrosoftOfficeHub' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: -------------------Remove "OneNote" app-------------------
echo --- Remove "OneNote" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.Office.OneNote' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Office.OneNote_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: --------------------Remove "Sway" app---------------------
echo --- Remove "Sway" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.Office.Sway' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Office.Sway_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: ---------------Remove "Phone Companion" app---------------
echo --- Remove "Phone Companion" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.WindowsPhone' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.WindowsPhone_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: ---------------Remove "Microsoft Phone" app---------------
echo --- Remove "Microsoft Phone" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.CommsPhone' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.CommsPhone_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: -----------------Remove "Phone Link" app------------------
echo --- Remove "Phone Link" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.YourPhone' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.YourPhone_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: --------------------Remove "Call" app---------------------
echo --- Remove "Call" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\$CURRENT_USER_SID\Microsoft.Windows.CallingShellApp_cw5n1h2txyewy'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; $userSid = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([Security.Principal.SecurityIdentifier]).Value; $registryPath = $registryPath.Replace('$CURRENT_USER_SID', $userSid); if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.Windows.CallingShellApp' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Windows.CallingShellApp_cw5n1h2txyewy'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\$CURRENT_USER_SID\Microsoft.Windows.CallingShellApp_cw5n1h2txyewy'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; $userSid = (New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([Security.Principal.SecurityIdentifier]).Value; $registryPath = $registryPath.Replace('$CURRENT_USER_SID', $userSid); Write-Host "^""Removing registry key at `"^""$registryPath`"^""."^""; if (-not (Test-Path -LiteralPath $registryPath)) { Write-Host "^""Skipping, no action needed, registry key `"^""$registryPath`"^"" does not exist."^""; exit 0; }; try { Remove-Item -LiteralPath $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully removed the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to remove the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: -------------------Remove "Cortana" app-------------------
echo --- Remove "Cortana" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.549981C3F5F10' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.549981C3F5F10_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: -Remove "Get Help" app (breaks built-in troubleshooting)--
echo --- Remove "Get Help" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.GetHelp' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.GetHelp_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: ---------------Remove "Microsoft Tips" app----------------
echo --- Remove "Microsoft Tips" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.Getstarted' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Getstarted_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: -------------Remove "Microsoft Messaging" app-------------
echo --- Remove "Microsoft Messaging" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.Messaging' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Messaging_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: ------------Remove "Mixed Reality Portal" app-------------
echo --- Remove "Mixed Reality Portal" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.MixedReality.Portal' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MixedReality.Portal_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: ----------------Remove "Feedback Hub" app-----------------
echo --- Remove "Feedback Hub" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.WindowsFeedbackHub' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: ----------------Remove "Windows Maps" app-----------------
echo --- Remove "Windows Maps" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.WindowsMaps' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.WindowsMaps_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: --------------Remove "Microsoft People" app---------------
echo --- Remove "Microsoft People" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.People' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.People_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: ----------------Remove "Microsoft Pay" app----------------
echo --- Remove "Microsoft Pay" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.Wallet' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Wallet_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: ----------------Remove "Mobile Plans" app-----------------
echo --- Remove "Mobile Plans" app
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.OneConnect' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.OneConnect_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: -------Remove "Microsoft Solitaire Collection" app--------
echo --- Remove "Microsoft Solitaire Collection" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.MicrosoftSolitaireCollection' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: -----------Remove "Microsoft Sticky Notes" app------------
echo --- Remove "Microsoft Sticky Notes" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.MicrosoftStickyNotes' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: --------------Remove "Mail and Calendar" app--------------
echo --- Remove "Mail and Calendar" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'microsoft.windowscommunicationsapps' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\microsoft.windowscommunicationsapps_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: -----------Remove "Windows Sound Recorder" app------------
echo --- Remove "Windows Sound Recorder" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.WindowsSoundRecorder' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

:: --Remove "Microsoft To Do: Lists, Tasks & Reminders" app--
echo --- Remove "Microsoft To Do: Lists, Tasks ^& Reminders" app
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "Get-AppxPackage 'Microsoft.Todos' | Remove-AppxPackage"
PowerShell -ExecutionPolicy Unrestricted -Command "$keyPath='HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\Microsoft.Todos_8wekyb3d8bbwe'; $registryHive = $keyPath.Split('\')[0]; $registryPath = "^""$($registryHive):$($keyPath.Substring($registryHive.Length))"^""; if (Test-Path $registryPath) { Write-Host "^""Skipping, no action needed, registry path `"^""$registryPath`"^"" already exists."^""; exit 0; }; try { New-Item -Path $registryPath -Force -ErrorAction Stop | Out-Null; Write-Host "^""Successfully created the registry key at path `"^""$registryPath`"^""."^""; } catch { Write-Error "^""Failed to create the registry key at path `"^""$registryPath`"^"": $($_.Exception.Message)"^""; }"
chcp 65001 >nul 2>&1

echo  Процесс удаления лишних программ от Microsoft Завершён. Переход назад будет выполнен автоматически через 5 секунд.
timeout /t 5 /nobreak > NUL
goto AppPanel


REM =====================================================================================================================================================================================

:AppInstall_Recommendations
if "%WiFi%"=="Off" (
    call:NotWiFiConnection
    goto GoBack
)

cls

echo [INFO ] %TIME% - Открыта панель ":AppInstall_Recommendations" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=AppInstall_Recommendations
set choice=NoInput

rem Считаем количество записей автозагрузки в реестре
set StartUpAppcount=0

REM Считаем только значения, а не заголовки
for /f "tokens=*" %%A in ('reg query "HKLM\Software\Microsoft\Windows\CurrentVersion\Run"') do set /a StartUpAppcount+=1
for /f "tokens=*" %%A in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"') do set /a StartUpAppcount+=1

rem Считаем количество записей в папке автозагрузки
for /f "tokens=*" %%A in ('dir /b "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup"') do set /a StartUpAppcount+=1
for /f "tokens=*" %%A in ('dir /b "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Startup"') do set /a StartUpAppcount+=1

REM Сброс значений для переменных
set NvidiaAppInstalled=No
set NVBroadcastInstalled=No
set AMDAdrenalinInstalled=No
set SteamInstalled=No
set DiscordInstalled=No
set UninstallToolInstalled=No
set AutorunsInstalled=No
set qBittorrentInstalled=No
set WindowsActivated=Yes

REM --- Проверка активации Windows ---
rem slmgr /xpr выводит информацию о статусе активации
rem Ищем строку "активирована на постоянной основе" (может отличаться в разных версиях/переводах)
rem Используем findstr /V "фраза" для поиска строк, которые НЕ содержат фразу
rem Если найдена хоть одна строка БЕЗ фразы, ERRORLEVEL будет 0, значит не активирована на постоянной основе
cscript //Nologo %windir%\system32\slmgr.vbs /dli 2>nul | findstr /I "имеет лицензию" >nul
if %ERRORLEVEL%==0 (
    set WindowsActivated=Yes
    echo %COL%[90m[ INFO  ]%COL%[37m %TIME% - Обнаружено: Windows активирована любой тип. >> "%ASX-Directory%\Files\Logs\%date%.txt"
) else (
    echo %COL%[90m[ INFO  ]%COL%[37m %TIME% - Обнаружено: Windows не активирована. >> "%ASX-Directory%\Files\Logs\%date%.txt"
)

REM Проверка NVIDIA App (поиск по ключевым словам)
for /F "tokens=*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Приложение NVIDIA" ^| findstr /I "DisplayName"') do (
    set NvidiaAppInstalled=Yes
)

REM Проверка NVIDIA Broadcast (поиск по ключевым словам)
for /F "tokens=*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "NVIDIA Broadcast" ^| findstr /I "DisplayName"') do (
    set NVBroadcastInstalled=Yes
)

REM Проверка AMD Adrenalin Edition
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\AMD Software" >nul 2>&1
if %ERRORLEVEL%==0 (
    set AMDAdrenalinInstalled=Yes
)

REM Проверка Steam (поиск по ключевым словам)
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Steam" >nul 2>&1
if %ERRORLEVEL%==0 (
    set SteamInstalled=Yes
)

REM Проверка Discord
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\Discord" >nul 2>&1
if %ERRORLEVEL%==0 (
    set DiscordInstalled=Yes
)

REM Проверка Uninstall Tool (поиск по ключевым словам)
for /F "tokens=*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Uninstall Tool" ^| findstr /I "DisplayName"') do (
    set UninstallToolInstalled=Yes
)

REM Проверка Autoruns
if exist "%ASX-Directory%\Files\Utilites\Autoruns\Autoruns.exe" (
    set AutorunsInstalled=Yes
)

REM Проверка qBittorrent
reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\qBittorrent" >nul 2>&1
if %ERRORLEVEL%==0 (
    set qBittorrentInstalled=Yes
)

REM Определяем тип видеокарты и вендора
set "gpu_type=Unknown"
set "gpu_vendor=Unknown"

REM --- Определение интересов пользователя ---
set "interest_count=0"
if "%SteamInstalled%"=="Yes" (
    set /a interest_count+=1
    set "interest!interest_count!=GAME"
)
if "%DiscordInstalled%"=="Yes" (
    set /a interest_count+=1
    set "interest!interest_count!=COMMUNICATION"
)
if %StartUpAppcount% GEQ 8 (
    set /a interest_count+=1
    set "interest!interest_count!=TWEAK"
)

REM Сохранение интересов в реестре
reg add "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data\User_Interests" /f >nul 2>&1
for /L %%i in (1,1,3) do (
    if defined interest%%i (
        reg add "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data\User_Interests" /v "User_Interests%%i" /t REG_SZ /d "!interest%%i!" /f >nul 2>&1
    ) else (
        reg delete "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data\User_Interests" /v "User_Interests%%i" /f >nul 2>&1
    )
)

TITLE Рекомендации по установке - ASX Hub
echo.
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########%COL%[37m
echo.
echo                             %COL%[90m Данная панель находится в разработке и может быть не полностью готова к использованию%COL%[37m
echo.
echo.
set choiceCounter=1

REM Рекомендации программ в зависимости от типа GPU
if "%GPU_Brand%"=="Nvidia" (
    if "%NvidiaAppInstalled%"=="No" (
        echo                      %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mNVIDIA App
        set NvidiaAppChoice=%choiceCounter%
        set /A choiceCounter+=1
    )
    if "%NVBroadcastInstalled%"=="No" (
        echo                      %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mNVIDIA Broadcast
        set NVBroadcastChoice=%choiceCounter%
        set /A choiceCounter+=1
    )
) else if "%gpu_type%"=="AMD" (
    if "%AMDAdrenalinInstalled%"=="No" (
        echo                      %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mAMD Adrenalin Edition
        set AMDAdrenalinChoice=%choiceCounter%
        set /A choiceCounter+=1
    )
)
if %StartUpAppcount% GEQ 8 (
    if "%AutorunsInstalled%"=="No" (
        echo                      %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mAutoruns
        set AutorunsChoice=%choiceCounter%
        set /A choiceCounter+=1
    )
)

REM Общие рекомендации
if "%WindowsActivated%"=="No" (
    echo                      %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mWin Digital activation
    set WinActivatedChoice=%choiceCounter%
    set /A choiceCounter+=1
)
if "%SteamInstalled%"=="No" (
    echo                      %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mSteam
    set SteamChoice=%choiceCounter%
    set /A choiceCounter+=1
)
if "%DiscordInstalled%"=="No" (
    echo                      %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mDiscord
    set DiscordChoice=%choiceCounter%
    set /A choiceCounter+=1
)
if "%UninstallToolInstalled%"=="No" (
    echo                      %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mUninstall Tool
    set UninstallToolChoice=%choiceCounter%
    set /A choiceCounter+=1
)
if "%qBittorrentInstalled%"=="No" (
    echo                      %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mqBittorrent
    set qBittorrentChoice=%choiceCounter%
    set /A choiceCounter+=1
)

REM Заполнение оставшихся строк для сохранения разметки
for /L %%i in (%choiceCounter%,1,6) do (
    echo.
)

echo.
echo.
echo.
echo.
echo.
echo.

if %choiceCounter% equ 1 (
    echo                                                   %COL%[90mРекомендации по установке программ отсутствуют%COL%[37m
)
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
set /p choice="%DEL%                                                                      >: "

REM Реакция на выбор пользователя
if "%WindowsActivated%"=="No" (
    if /i "%choice%"=="%WinActivatedChoice%" (
        set "history=AppInstall_Recommendations;!history!" && goto WinDigActivation
    )
)
if /i "%choice%"=="%NvidiaAppChoice%" (
    set "history=AppInstall_Recommendations;!history!" && goto Nvidia-App
)
if /i "%choice%"=="%NVBroadcastChoice%" (
    set "history=AppInstall_Recommendations;!history!" && goto NVIDIA-Broadcast
)
if /i "%choice%"=="%AMDAdrenalinChoice%" (
    set "history=AppInstall_Recommendations;!history!" && goto AMDAdrenalin
)
if /i "%choice%"=="%SteamChoice%" (
    set "history=AppInstall_Recommendations;!history!" && goto Steam
)
if /i "%choice%"=="%DiscordChoice%" (
    set "history=AppInstall_Recommendations;!history!" && goto Discord
)
if /i "%choice%"=="%UninstallToolChoice%" (
    set "history=AppInstall_Recommendations;!history!" && goto UninstallTool
)
if /i "%choice%"=="%AutorunsChoice%" (
    set "history=AppInstall_Recommendations;!history!" && goto Autoruns
)
if /i "%choice%"=="%qBittorrentChoice%" (
    set "history=AppInstall_Recommendations;!history!" && goto qBittorrent
)

REM Переходы в главное меню и назад
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="ч" goto MainMenu

goto AppInstall_Recommendations



:AppInstall_PG1
if "%WiFi%"=="Off" (	
    call:NotWiFiConnection
    goto GoBack
)

cls
set "SLOAD=%COL%[92mВКЛ "
reg query "%SaveData%\ParameterFunction" /v "SequentialDownload" >nul 2>&1 || set "SLOAD=%COL%[91mВЫКЛ" >nul 2>&1

if "%SLOADStats%" GEQ "1" ( set "SLOADStatsColor=%COL%[36m" ) else (
	set "SLOADStatsColor=%COL%[90m"
)

echo [INFO ] %TIME% - Открыта панель ":AppInstall_PG1" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=AppInstall_PG1
set "FileName="
TITLE Установка программ - ASX Hub
REM A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 2%COL%[90m]
echo.
echo              %COL%[36mВЕБ-БРАУЗЕРЫ                                   МУЛЬТИМЕДИА                                ГРАФИЧЕСКИЕ РЕДАКТОРЫ
echo              %COL%[97m------------                                   -----------                                ---------------------
echo              %COL%[36m[%COL%[37m A1  %COL%[36m]%COL%[37m Edge                                   %COL%[36m[%COL%[37m B1  %COL%[36m]%COL%[37m Яндекс музыка                      %COL%[36m[%COL%[37m C1  %COL%[36m]%COL%[37m Paint.net
echo              %COL%[36m[%COL%[37m A2  %COL%[36m]%COL%[37m Chrome                                 %COL%[36m[%COL%[37m B2  %COL%[36m]%COL%[37m iTunes                             %COL%[36m[%COL%[37m C2  %COL%[36m]%COL%[37m Photoshop
echo              %COL%[36m[%COL%[37m A3  %COL%[36m]%COL%[37m Firefox                                %COL%[36m[%COL%[37m B3  %COL%[36m]%COL%[37m Zona                               %COL%[36m[%COL%[37m C3  %COL%[36m]%COL%[37m Topaz Gigapixel
echo              %COL%[36m[%COL%[37m A4  %COL%[36m]%COL%[37m Opera                                  %COL%[36m[%COL%[37m B4  %COL%[36m]%COL%[37m Spotify                            %COL%[36m[%COL%[37m C4  %COL%[36m]%COL%[37m Upscayl
echo              %COL%[36m[%COL%[37m A5  %COL%[36m]%COL%[37m Yandex                                                                            %COL%[36m[%COL%[37m C5  %COL%[36m]%COL%[37m Movavi Video Editor
echo.
echo.
echo              %COL%[36mУТИЛИТЫ ДЛЯ ЖЕЛЕЗА                             ИГРОВЫЕ ЛАУНЧЕРЫ                           ОПТИМИЗАЦИЯ И НАСТРОЙКА
echo              %COL%[97m------------------                             ----------------                           -----------------------
echo              %COL%[36m[%COL%[37m D1  %COL%[36m]%COL%[37m NVIDIA App                             %COL%[36m[%COL%[37m E1  %COL%[36m]%COL%[37m Steam                              %COL%[36m[%COL%[37m F1  %COL%[36m]%COL%[37m WinTweaker
echo              %COL%[36m[%COL%[37m D2  %COL%[36m]%COL%[37m NVIDIA Broadcast                       %COL%[36m[%COL%[37m E2  %COL%[36m]%COL%[37m Epic Games                         %COL%[36m[%COL%[37m F2  %COL%[36m]%COL%[37m QuickCpu
echo              %COL%[36m[%COL%[37m D3  %COL%[36m]%COL%[37m AMD Adrenalin                          %COL%[36m[%COL%[37m E3  %COL%[36m]%COL%[37m Origin                             %COL%[36m[%COL%[37m F3  %COL%[36m]%COL%[37m Auslogics Boost Speed
echo              %COL%[36m[%COL%[37m D4  %COL%[36m]%COL%[37m ThunderMaster                          %COL%[36m[%COL%[37m E4  %COL%[36m]%COL%[37m Uplay                              %COL%[36m[%COL%[37m F4  %COL%[36m]%COL%[37m Dism++
echo              %COL%[36m[%COL%[37m D5  %COL%[36m]%COL%[37m Logitech Ghub                          %COL%[36m[%COL%[37m E5  %COL%[36m]%COL%[37m Battle.net                         %COL%[36m[%COL%[37m F5  %COL%[36m]%COL%[37m Ccleaner
echo              %COL%[36m[%COL%[37m D6  %COL%[36m]%COL%[37m HyperX NGENUITY                        %COL%[36m[%COL%[37m E6  %COL%[36m]%COL%[37m Riot Client                        %COL%[36m[%COL%[37m F6  %COL%[36m]%COL%[37m Autoruns
echo              %COL%[36m[%COL%[37m D7  %COL%[36m]%COL%[37m RSQ Keyrox                             %COL%[36m[%COL%[37m E7  %COL%[36m]%COL%[37m Xbox
echo              %COL%[36m[%COL%[37m D8  %COL%[36m]%COL%[37m Razer Synapse
echo              %COL%[36m[%COL%[37m D9  %COL%[36m]%COL%[37m Apple Devices
echo.
echo.
echo              %COL%[36mБИБЛИОТЕКИ И ПО                                Windows                                    МЕССЕНДЖЕРЫ
echo              %COL%[97m---------------                                -------                                    -----------
echo              %COL%[36m[%COL%[37m G1  %COL%[36m]%COL%[37m Visual C++                             %COL%[36m[%COL%[37m H1  %COL%[36m]%COL%[37m KMS auto                           %COL%[36m[%COL%[37m I1  %COL%[36m]%COL%[37m Discord
echo              %COL%[36m[%COL%[37m G2  %COL%[36m]%COL%[37m DirectX                                %COL%[36m[%COL%[37m H2  %COL%[36m]%COL%[37m Win Digital Activation             %COL%[36m[%COL%[37m I2  %COL%[36m]%COL%[37m Telegram
echo              %COL%[36m[%COL%[37m G3  %COL%[36m]%COL%[37m Microsoft Office                       %COL%[36m[%COL%[37m H3  %COL%[36m]%COL%[37m Media Creation Tool
echo              %COL%[36m[%COL%[37m G4  %COL%[36m]%COL%[37m Creative Cloud                         %COL%[36m[%COL%[37m H4  %COL%[36m]%COL%[37m Microsoft PowerToys
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
if "%SLOAD%" == "%COL%[92mВКЛ " ( 
echo.
echo               %COL%[36m[ B - Назад ]         %COL%[91m[ X - Главное меню ]         %COL%[36m[ N - Слудующая страница ]%COL%[90m         %COL%[36m[ L - Послед. загрузка %SLOAD% %COL%[36m]%COL%[37m
echo                                                                                                     %COL%[90m[ Выбрано %SLOADStatsColor%%SLOADStats% %COL%[90m] [ S - Начать  ]%COL%[90m
) else (
echo.	
echo               %COL%[36m[ B - Назад ]         %COL%[91m[ X - Главное меню ]         %COL%[36m[ N - Слудующая страница ]%COL%[90m         %COL%[36m[ L - Послед. загрузка %SLOAD% %COL%[36m]%COL%[90m
echo.
)
set "choice="
set /p choice="%DEL%                                                                      >: "

if not defined choice cls && goto AppInstall_PG1

REM A - GROUP
if /i "%choice%"=="A1" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=MicrosoftEdgeSetup.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Edge
        echo [INFO ] %TIME% - Вызвано Edge для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A2" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=ChromeSetup.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Chrome
        echo [INFO ] %TIME% - Вызвано Chrome для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A3" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Firefox.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:FireFox
        echo [INFO ] %TIME% - Вызвано FireFox для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A4" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Opera.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Opera
        echo [INFO ] %TIME% - Вызвано Opera для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A5" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Yandex.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Yandex_Browser
        echo [INFO ] %TIME% - Вызвано Yandex_Browser для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

REM B - GROUP
if /i "%choice%"=="B1" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Yandex Music не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Yandex_Music
        echo [INFO ] %TIME% - Вызвано Yandex_Music для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="B2" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=iTunes не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:iTunes
        echo [INFO ] %TIME% - Вызвано iTunes для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="B3" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=ZonaSetup64.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Zona
        echo [INFO ] %TIME% - Вызвано Zona для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="B4" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Spotify не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - Spotify не поддерживает последовательную установку >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Spotify
        echo [INFO ] %TIME% - Вызвано Spotify для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

REM C - GROUP
if /i "%choice%"=="C1" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=paintnet.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:PaintNet
        echo [INFO ] %TIME% - Вызвано PaintNet для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="C2" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=PHOTOSHOP не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        start https://drive.google.com/file/d/1pD97cXSNbxErvVGVEcaESYmfpHkDsai1/view?usp=sharing
        echo [INFO ] %TIME% - Открыта ссылка на PHOTOSHOP >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="C3" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Topaz Gigapixel AI не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:TopazGigapixelAI
		echo [INFO ] %TIME% - Вызвано TopazGigapixelAI для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="C4" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Upscayl.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Upscayl
		echo [INFO ] %TIME% - Вызвано Upscayl для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"		
    )
)

if /i "%choice%"=="C5" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Movavi_Video_Editor.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:MovaviVideoEditor
		echo [INFO ] %TIME% - Вызвано MovaviVideoEditor для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"			
    )
)

REM D - GROUP
if /i "%choice%"=="D1" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=NVIDIA_app.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Nvidia_App
        echo [INFO ] %TIME% - Вызвано NvidiaApp для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    )
)

if /i "%choice%"=="D2" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=NVIDIA_Broadcast.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:NVIDIA-Broadcast
        echo [INFO ] %TIME% - Вызвано NVIDIA_Broadcast для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    )
)

if /i "%choice%"=="D3" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=AMD-Adrenalin-edition.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:AMD-Adrenalin-edition
        echo [INFO ] %TIME% - Вызвано AMD-Adrenalin-edition для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="D4" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Setup_ThunderMaster.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:ThunderMaster
        echo [INFO ] %TIME% - Вызвано ThunderMaster для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    )
)

if /i "%choice%"=="D5" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=LogitechGhub.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:LogitechGhub
        echo [INFO ] %TIME% - Вызвано LogitechGhub для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    )
)

if /i "%choice%"=="D6" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=HyperX NGENUITY не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:HyperXNGENUITY
        echo [INFO ] %TIME% - Вызвано HyperXNGENUITY для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    )
)

if /i "%choice%"=="D7" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=RSQKeyroxSetup.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:RSQKeyrox
        echo [INFO ] %TIME% - Вызвано RSQKeyrox для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    )
)

if /i "%choice%"=="D8" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=RazerSynapseInstaller.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:RazerSynapse
        echo [INFO ] %TIME% - Вызвано RazerSynapse для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    )
)

if /i "%choice%"=="D9" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Apple Devices не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:AppleDevices
        echo [INFO ] %TIME% - Вызвано AppleDevices для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    )
)

REM E - GROUP
if /i "%choice%"=="E1" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=SteamSetup.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Steam
        echo [INFO ] %TIME% - Вызвано Steam для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    )
)

if /i "%choice%"=="E2" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Epic.Games.msi"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:EGS
        echo [INFO ] %TIME% - Вызвано EGS для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    )
)

if /i "%choice%"=="E3" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=EAapp.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:EAapp
        echo [INFO ] %TIME% - Вызвано EAapp для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    )
)

if /i "%choice%"=="E4" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=UbisoftConnectInstaller.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:UbisConnect
        echo [INFO ] %TIME% - Вызвано UbisConnect для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    )
)

if /i "%choice%"=="E5" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=BattleNet.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:BattleNet
        echo [INFO ] %TIME% - Вызвано BattleNet для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    )
)

if /i "%choice%"=="E6" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=ValorantSetup.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:RiotClient
        echo [INFO ] %TIME% - Вызвано RiotClient для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="E7" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Xbox не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Xbox
        echo [INFO ] %TIME% - Вызвано Xbox для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

REM F - GROUP
if /i "%choice%"=="F1" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Win.Tweaker.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:WinTweaker
        echo [INFO ] %TIME% - Вызвано WinTweaker для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="F2" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=QuickCpuSetup.msi"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:QuickCpu
        echo [INFO ] %TIME% - Вызвано QuickCpu для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="F3" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Auslogics.BoostSpeed.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:AuslogicsBoostSpeed
        echo [INFO ] %TIME% - Вызвано AuslogicsBoostSpeed для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="F4" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Dism не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:dism
        echo [INFO ] %TIME% - Вызвано dism для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="F5" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=CCleaner.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Ccleaner
        echo [INFO ] %TIME% - Вызвано Ccleaner для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="F6" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Autoruns не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Autoruns
        echo [INFO ] %TIME% - Вызвано Autoruns для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

REM G - GROUP
if /i "%choice%"=="G1" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=VC_redist.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:VisualC
        echo [INFO ] %TIME% - Вызвано VisualC для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="G2" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=DirectX.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:DirectX
        echo [INFO ] %TIME% - Вызвано DirectX для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="G3" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Microsoft Office не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:MicrosoftOffice
        echo [INFO ] %TIME% - Вызвано MicrosoftOffice для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="G4" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=CreativeCloud.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:CreativeCloud
        echo [INFO ] %TIME% - Вызвано CreativeCloud для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

REM H - GROUP
if /i "%choice%"=="H1" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=AutoKMS не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:AutoKMS
        echo [INFO ] %TIME% - Вызвано AutoKMS для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="H2" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=WinDigitalActivation.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:WinDigActivation
        echo [INFO ] %TIME% - Вызвано WinDigActivation для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="H3" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=MediaCreationTool не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:MediaCreationTool
        echo [INFO ] %TIME% - Вызвано MediaCreationTool для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="H4" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=PowerToys не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:PowerToys
        echo [INFO ] %TIME% - Вызвано PowerToys для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

REM I - GROUP
if /i "%choice%"=="I1" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=DiscordSetup.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Discord
        echo [INFO ] %TIME% - Вызвано Discord для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="I2" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Telegram.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG1;!history!"
        call:Telegram
        echo [INFO ] %TIME% - Вызвано Telegram для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="L" ( set "history=AppInstall_PG1;!history!" && call:SequentialDownload )
if /i "%choice%"=="д" ( set "history=AppInstall_PG1;!history!" && call:SequentialDownload )
if /i "%choice%"=="S" ( set "history=AppInstall_PG1;!history!" && call:SequentialDownloadStart )
if /i "%choice%"=="ы" ( set "history=AppInstall_PG1;!history!" && call:SequentialDownloadStart )

if /i "%choice%"=="List" ( cls
for %%a in (%fileList%) do (
     echo  %%a
	)
	pause
)

if /i "%choice%"=="C" ( set "history=AppInstall_PG1;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=AppInstall_PG1;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=AppInstall_PG1;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=AppInstall_PG1;!history!" && goto MainMenu )
if /i "%choice%"=="F" goto DwFolder
if /i "%choice%"=="а" goto DwFolder
if /i "%choice%"=="R" ( set "history=AppInstall_PG1;!history!" && goto AppInstall_PG1 )
if /i "%choice%"=="к" ( set "history=AppInstall_PG1;!history!" && goto AppInstall_PG1 )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="N" ( set "history=AppInstall_PG1;!history!" && goto AppInstall_PG2 )
if /i "%choice%"=="т" ( set "history=AppInstall_PG1;!history!" && goto AppInstall_PG2 )
if /i "%choice%"=="NoInput" goto WrongInput
REM call:WrongInput
goto AppInstall_PG1

rem Sequential download setup
:SequentialDownload
if "%SLOAD%" == "%COL%[91mВЫКЛ" (
    reg add "%SaveData%\ParameterFunction" /v "SequentialDownload" /f >nul 2>&1
    set "ListfileName="
    set "fileList="
    set "SLOADStats=0"
    echo [INFO ] %TIME% - Инициализация последовательной загрузки ^(выключено^) >> "%ASX-Directory%\Files\Logs\%date%.txt"
) else (
    reg delete "%SaveData%\ParameterFunction" /v "SequentialDownload" /f >nul 2>&1
    echo [INFO ] %TIME% - Инициализация последовательной загрузки ^(включено^) >> "%ASX-Directory%\Files\Logs\%date%.txt"
)
goto GoBack

rem Start sequential download
:SequentialDownloadStart
if "%SLOAD%" == "%COL%[91mВЫКЛ" (
    goto GoBack
) else (
    set "FileDownloadCount=0"
    for %%a in (%fileList%) do (
        set /a FileDownloadCount+=1 >nul 2>&1
        Title ^[%FileDownloadCount%^] Загрузка файла: %%a
        echo [INFO ] %TIME% - Начало загрузки %%a >> "%ASX-Directory%\Files\Logs\%date%.txt"
        curl -g -L -o "%ASX-Directory%\Files\Downloads\%%a" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%%a" >nul 2>&1
        if errorlevel 1 (
            echo [ERROR] %TIME% - Сбой загрузки для %%a >> "%ASX-Directory%\Files\Logs\%date%.txt"
        ) else (
            echo [INFO ] %TIME% - Успешная загрузка %%a >> "%ASX-Directory%\Files\Logs\%date%.txt"
        )
    )
    if "%FileDownloadCount%"=="0" (
        set "INFO_TEXT=Ничего не было загружено"
        echo [INFO ] %TIME% - Ничего не было загружено >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "INFO_TEXT=Последовательная загрузка завершена. Далее будут запущены установочники"
        if "%SLOADStats%" neq "0" (
            set /a SLOADStats-=1 >nul 2>&1
        )
        echo [INFO ] %TIME% - Последовательная загрузка завершена >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
    call:info_msg

for %%a in (%fileList%) do (
     Title Запуск файла: %%a
    echo [INFO ] %TIME% - Начало установки %%a >> "%ASX-Directory%\Files\Logs\%date%.txt"
      start /wait "" "%ASX-Directory%\Files\Downloads\%%a"
     if errorlevel 1 (
         echo [ERROR] %TIME% - Сбой установки для %%a >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
          echo [INFO ] %TIME% - Установка завершена для %%a >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
      REM del "%ASX-Directory%\Files\Downloads\%%a" /Q
)
    rem Clear the installation queue and reset the counter
    set "fileList="
    set "SLOADStats=0"
    echo [INFO ] %TIME% - Очередь установки и счетчик сброшены >> "%ASX-Directory%\Files\Logs\%date%.txt"
    Title Завершено
)
goto GoBack




:AppInstall_PG2
cls
chcp 65001 >nul 2>&1

for %%i in (SLOAD ) do (set "%%i=%COL%[92mВКЛ ") >nul 2>&1
reg query "%SaveData%\ParameterFunction" /v "SequentialDownload" >nul 2>&1 || set "SLOAD=%COL%[91mВЫКЛ" >nul 2>&1

if "%SLOADStats%" GEQ "1" ( set "SLOADStatsColor=%COL%[36m" ) else (
	set "SLOADStatsColor=%COL%[90m"
)

echo [INFO ] %TIME% - Открыта панель ":AppInstall_PG2" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=AppInstall_PG2
set "FileName="
TITLE Установка программ - ASX Hub
REM TITLE !history!
echo.
echo                                                                     %COL%[90m[%COL%[96m2 %COL%[90m/ 2%COL%[90m]
echo.
echo              %COL%[36mИНСТРУМЕНТЫ                                    УПРАВЛЕНИЕ СИСТ. РЕСУРСАМИ                     ИНСТРУМЕНТЫ РАЗРАБОТКИ
echo              %COL%[97m-----------                                    --------------------------                     ----------------------
echo              %COL%[36m[%COL%[37m A1  %COL%[36m]%COL%[37m WinRAR                                 %COL%[36m[%COL%[37m B1  %COL%[36m]%COL%[37m Uninstall Tool                         %COL%[36m[%COL%[37m C1  %COL%[36m]%COL%[37m VS Code
echo              %COL%[36m[%COL%[37m A2  %COL%[36m]%COL%[37m qBittorrent                            %COL%[36m[%COL%[37m B2  %COL%[36m]%COL%[37m Driver Booster                         %COL%[36m[%COL%[37m C2  %COL%[36m]%COL%[37m Visual Studio
echo              %COL%[36m[%COL%[37m A3  %COL%[36m]%COL%[37m TeamViewer                             %COL%[36m[%COL%[37m B3  %COL%[36m]%COL%[37m Unlocker                               %COL%[36m[%COL%[37m C3  %COL%[36m]%COL%[37m GitHub Desktop
echo              %COL%[36m[%COL%[37m A4  %COL%[36m]%COL%[37m Flow-Launcher                          %COL%[36m[%COL%[37m B4  %COL%[36m]%COL%[37m FreeMove                               %COL%[36m[%COL%[37m C4  %COL%[36m]%COL%[37m Notepad++
echo              %COL%[36m[%COL%[37m A5  %COL%[36m]%COL%[37m Rufus                                  %COL%[36m[%COL%[37m B5  %COL%[36m]%COL%[37m MemReduct                              %COL%[36m[%COL%[37m C5  %COL%[36m]%COL%[37m Pycharm
echo              %COL%[36m[%COL%[37m A6  %COL%[36m]%COL%[37m Flashr                                 %COL%[36m[%COL%[37m B6  %COL%[36m]%COL%[37m EaseUS
echo              %COL%[36m[%COL%[37m A7  %COL%[36m]%COL%[37m MiniBin                                %COL%[36m[%COL%[37m B7  %COL%[36m]%COL%[37m AIDA64
echo              %COL%[36m[%COL%[37m A8  %COL%[36m]%COL%[37m DfControl                              %COL%[36m[%COL%[37m B8  %COL%[36m]%COL%[37m CPU-Z
echo              %COL%[36m[%COL%[37m A9  %COL%[36m]%COL%[37m Driver Store Explorer                  %COL%[36m[%COL%[37m B9  %COL%[36m]%COL%[37m MSI Afterburner
echo              %COL%[36m[%COL%[37m A10 %COL%[36m]%COL%[37m Display Driver Uninstaller                          
echo              %COL%[36m[%COL%[37m A11 %COL%[36m]%COL%[37m VibranceGUI                         
echo              %COL%[36m[%COL%[37m A12 %COL%[36m]%COL%[37m Everything                         
echo              %COL%[36m[%COL%[37m A13 %COL%[36m]%COL%[37m ShutUp10                         
echo              %COL%[36m[%COL%[37m A14 %COL%[36m]%COL%[37m Windows Update MiniTool    
echo.
echo.
echo              %COL%[36mАУДИО
echo              %COL%[97m-----
echo              %COL%[36m[%COL%[37m D1  %COL%[36m]%COL%[37m Sound Lock
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
if "%SLOAD%" == "%COL%[92mВКЛ " ( 
echo.
echo               %COL%[36m[ B - Назад ]         %COL%[91m[ X - Главное меню ]         %COL%[36m[ N - Слудующая страница ]%COL%[90m         %COL%[36m[ L - Послед. загрузка %SLOAD% %COL%[36m]%COL%[37m
echo                                                                                                     %COL%[90m[ Выбрано %SLOADStatsColor%%SLOADStats% %COL%[90m] [ S - Начать  ]%COL%[90m
) else (
echo.	
echo               %COL%[36m[ B - Назад ]         %COL%[91m[ X - Главное меню ]         %COL%[36m[ N - Слудующая страница ]%COL%[90m         %COL%[36m[ L - Послед. загрузка %SLOAD% %COL%[36m]%COL%[90m
echo.
)
set "choice="
set /p choice="%DEL%                                                                      >: "

if not defined choice cls && goto AppInstall_PG2

REM A - GROUP
if /i "%choice%"=="A1" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=WinRAR.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:WinRAR
        echo [INFO ] %TIME% - Вызвано WinRAR для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A2" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=qbittorrent.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:qbittorrent
        echo [INFO ] %TIME% - Вызвано qbittorrent для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A3" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=TeamViewer.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:TeamViewer
        echo [INFO ] %TIME% - Вызвано TeamViewer для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A4" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Flow-Launcher-Setup.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:Flow-Launcher
        echo [INFO ] %TIME% - Вызвано Flow-Launcher для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A5" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Rufus.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:Rufus
        echo [INFO ] %TIME% - Вызвано Rufus для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A6" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Flashr не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:Flashr
        echo [INFO ] %TIME% - Вызвано Flashr для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A7" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=MiniBin.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:MiniBin
        echo [INFO ] %TIME% - Вызвано MiniBin для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A8" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=dfControl.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:DfControl
        echo [INFO ] %TIME% - Вызвано DfControl для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A9" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Driver Store Explorer не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:DriverStoreExplorer
        echo [INFO ] %TIME% - Вызвано DriverStoreExplorer для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A10" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Display Driver Uninstaller не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:DisplayDriverUninstaller
        echo [INFO ] %TIME% - Вызвано DisplayDriverUninstaller для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A11" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=VibranceGUI не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:VibranceGUI
        echo [INFO ] %TIME% - Вызвано VibranceGUI для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A12" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Everything не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:Everything
        echo [INFO ] %TIME% - Вызвано Everything для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A13" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=ShutUp10 не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:ShutUp10
        echo [INFO ] %TIME% - Вызвано ShutUp10 для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="A14" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Windows Update MiniTool не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:Wumt
        echo [INFO ] %TIME% - Вызвано Wumt для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

REM B - GROUP
if /i "%choice%"=="B1" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Uninstall Tool не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:UninstallTool
        echo [INFO ] %TIME% - Вызвано UninstallTool для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="B2" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Driver.Booster.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:DriverBooster
        echo [INFO ] %TIME% - Вызвано DriverBooster для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="B3" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Unlocker.msi"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:Unlocker
        echo [INFO ] %TIME% - Вызвано Unlocker для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="B4" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=FreeMove.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:FreeMove
        echo [INFO ] %TIME% - Вызвано FreeMove для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="B5" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=memreduct.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:MemReduct
        echo [INFO ] %TIME% - Вызвано MemReduct для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="B6" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=EaseUS.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:EaseUS
        echo [INFO ] %TIME% - Вызвано EaseUS для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="B7" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=AIDA64.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:AIDA64
        echo [INFO ] %TIME% - Вызвано AIDA64 для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="B8" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=cpu-z.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:CPU-Z
        echo [INFO ] %TIME% - Вызвано CPU-Z для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="B9" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=MSIAfterburnerSetup.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:MSI_Afterburner
        echo [INFO ] %TIME% - Вызвано MSI_Afterburner для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

REM C - GROUP
if /i "%choice%"=="C1" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=VSCode.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:VScode
        echo [INFO ] %TIME% - Вызвано VScode для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="C2" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=VisualStudioSetup.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:VS
        echo [INFO ] %TIME% - Вызвано VS для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="C3" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=GitHubDesktop.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:GitHubDesktop
        echo [INFO ] %TIME% - Вызвано GitHubDesktop для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="C4" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=npp.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:NotepadPP
        echo [INFO ] %TIME% - Вызвано NotepadPP для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="C5" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "ListfileName=Pycharm.exe"
        set "fileList=!fileList! !ListfileName!"
        set /a SLOADStats+=1 >nul 2>&1
        echo [INFO ] %TIME% - %ListfileName% добавлен в список загрузок >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:Pycharm
        echo [INFO ] %TIME% - Вызвано Pycharm для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

REM D - GROUP
if /i "%choice%"=="D1" (
    if "%SLOAD%" == "%COL%[92mВКЛ " (
        set "INFO_TEXT=Sound Lock не поддерживает последовательную установку"
        call:info_msg
        echo [INFO ] %TIME% - %INFO_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    ) else (
        set "history=AppInstall_PG2;!history!"
        call:SoundLock
        echo [INFO ] %TIME% - Вызвано SoundLock для установки >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if /i "%choice%"=="L" ( set "history=AppInstall_PG2;!history!" && call:SequentialDownload )
if /i "%choice%"=="д" ( set "history=AppInstall_PG2;!history!" && call:SequentialDownload )
if /i "%choice%"=="S" ( set "history=AppInstall_PG2;!history!" && call:SequentialDownloadStart )
if /i "%choice%"=="ы" ( set "history=AppInstall_PG2;!history!" && call:SequentialDownloadStart )

if /i "%choice%"=="List" ( cls
for %%a in (%fileList%) do (
     echo  %%a
	)
	pause
)

if /i "%choice%"=="C" ( set "history=AppInstall_PG1;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=AppInstall_PG1;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=AppInstall_PG1;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=AppInstall_PG1;!history!" && goto MainMenu )
if /i "%choice%"=="F" goto DwFolder
if /i "%choice%"=="а" goto DwFolder
if /i "%choice%"=="R" ( set "history=AppInstall_PG1;!history!" && goto AppInstall_PG2 )
if /i "%choice%"=="к" ( set "history=AppInstall_PG1;!history!" && goto AppInstall_PG2 )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="N" ( set "history=AppInstall_PG2;!history!" && goto AppInstall_PG1 )
if /i "%choice%"=="т" ( set "history=AppInstall_PG2;!history!" && goto AppInstall_PG1 )
if /i "%choice%"=="NoInput" goto WrongInput
REM if /i "%choice%"=="N" (set "PG=AppRecommendedPG3") & goto AppRecommendedPG3
goto AppInstall_PG2



:: Код проверки файлов
:FileChecker
set "FileSize=0"
REM set "file=%ASX-Directory%\Files\Downloads\%FileName%"
set "Check_FilePatch=%FilePatch%"
set "Check_FileName=%FileName%"

for %%I in ("%Check_FilePatch%") do set FileSize=%%~zI

if not exist "%Check_FilePatch%" ( 
    echo     %COL%[91m   └ Ошибка: Не удалось провести проверку файла%COL%[37m
    echo [ERROR] %TIME% - Не удалось провести проверку файла - %Check_FileName% не найден >> "%ASX-Directory%\Files\Logs\%date%.txt"
    echo.
    echo.
    echo.
    echo.
    echo                                                %COL%[90mДля продолжения нажмите любую клавишу на клавиатуре
    pause >nul 2>&1
    goto GoBack
)

if not defined FileSize (
    echo     %COL%[91m   └ Ошибка: Не удалось провести проверку файла%COL%[37m
    echo [ERROR] %TIME% - Не удалось провести проверку файла %Check_FileName% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    echo.
    del /Q "%Check_FilePatch%"
    echo.
    echo.
    echo.
    echo                                                %COL%[90mДля продолжения нажмите любую клавишу на клавиатуре
    pause >nul 2>&1
    goto GoBack
)
if %FileSize% LSS 100 (
    echo     %COL%[91m   └ Ошибка: Файл не прошел проверку. Возможно, он поврежден %COL%[37m
    echo [ERROR] %TIME% - Файл %Check_FileName% поврежден или URL не доступен ^(Size %FileSize%^) >> "%ASX-Directory%\Files\Logs\%date%.txt"
    echo.
    del /Q "%Check_FilePatch%"
    echo.
    echo.
    echo.
    echo                                                %COL%[90mДля продолжения нажмите любую клавишу на клавиатуре
    pause >nul 2>&1
    goto GoBack
)
goto :eof

:: Начало установочных файлов
:Edge
call :ASX_Hub_Downloads_Title 
set "FileName=MicrosoftEdgeSetup.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Chrome
call :ASX_Hub_Downloads_Title 
set "FileName=ChromeSetup.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:FireFox
call :ASX_Hub_Downloads_Title 
set "FileName=Firefox.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Opera
call :ASX_Hub_Downloads_Title
set "FileName=Opera.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Yandex_Browser
call :ASX_Hub_Downloads_Title
set "FileName=Yandex.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Yandex_Music
call :ASX_Hub_Downloads_Title
set "FileName=YandexMusic.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:iTunes
call :ASX_Hub_Downloads_Title
set "FileName=iTunesInstaller.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Zona
call :ASX_Hub_Downloads_Title
set "FileName=ZonaSetup.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Spotify
call :ASX_Hub_Downloads_Title
set "FileName=SpotifyInstaller.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:PaintNet
cls
call :ASX_Hub_Downloads_Title
set "FileName=paintnet.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:TopazGigapixelAI
call :ASX_Hub_Downloads_Title 
set "FileName=TopazGigapixelAI.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
	reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "forceLogin" /t REG_SZ /d "false" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "ia0" /t REG_SZ /d "aWk=" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "lastLoggedInUserName" /t REG_SZ /d "any name" /f >nul 2>&1	
	reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "userPw" /t REG_SZ /d "any password" /f >nul 2>&1	
	start "" "%FilePatch%"
) ELSE (
	cd "%ASX-Directory%\Files"
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
	curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск процесса инициализации %COL%[37m
    title Настройка файлов [0/2]
	reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "forceLogin" /t REG_SZ /d "false" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "ia0" /t REG_SZ /d "aWk=" /f >nul 2>&1
	reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "lastLoggedInUserName" /t REG_SZ /d "any name" /f >nul 2>&1	
	reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "userPw" /t REG_SZ /d "any password" /f >nul 2>&1
    title Настройка файлов [1/2]
  	echo 127.0.0.1 topazlabs.com >> "%ASX-Directory%\Windows\System32\drivers\etc\hosts"
  	echo 127.0.0.1 et.topazlabs.com >> "%ASX-Directory%\Windows\System32\drivers\etc\hosts"
  	echo 127.0.0.1 104.22.33.115 >> "%ASX-Directory%\Windows\System32\drivers\etc\hosts"
  	echo 127.0.0.1 172.67.37.186 >> "%ASX-Directory%\Windows\System32\drivers\etc\hosts"
    title Настройка файлов [2/2] 
    echo  %COL%[36mНастройка завершена, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul   	   
	start "" "%FilePatch%"
)
goto GoBack

:Upscayl 
call :ASX_Hub_Downloads_Title
set "FileName=Upscayl.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:MovaviVideoEditor
call :ASX_Hub_Downloads_Title
set "FileName=Movavi_Video_Editor.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Nvidia-App
call :ASX_Hub_Downloads_Title
set "FileName=NVIDIA_app.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%ASX-Directory%\Files\Downloads\%FileName%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:NVIDIA-Broadcast
call :ASX_Hub_Downloads_Title
set "FileName=NVIDIA_Broadcast.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:AMD-Adrenalin-edition
call :ASX_Hub_Downloads_Title
set "FileName=AMD-Adrenalin-edition.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:ThunderMaster
call :ASX_Hub_Downloads_Title
set "FileName=Setup_ThunderMaster.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:LogitechGhub
call :ASX_Hub_Downloads_Title
set "FileName=LogitechGhub.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:HyperXNGENUITY
call :ASX_Hub_Downloads_Title
set "FileName=HyperX_NGENUITY.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:RSQKeyrox
call :ASX_Hub_Downloads_Title
set "FileName=RSQKeyroxSetup.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:RazerSynapse
call :ASX_Hub_Downloads_Title
set "FileName=RazerSynapseInstaller.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:AppleDevices
call :ASX_Hub_Downloads_Title
set "FileName=AppleDevicesInstaller.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Steam
call :ASX_Hub_Downloads_Title
set "FileName=SteamSetup.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:EGS
call :ASX_Hub_Downloads_Title
set "FileName=Epic.Games.msi"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:EAapp
call :ASX_Hub_Downloads_Title
set "FileName=EAapp.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:UbisConnect
call :ASX_Hub_Downloads_Title
set "FileName=UbisoftConnectInstaller.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:BattleNet
call :ASX_Hub_Downloads_Title
set "FileName=BattleNet.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:RiotClient
call :ASX_Hub_Downloads_Title
set "FileName=ValorantSetup.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Xbox
call :ASX_Hub_Downloads_Title
set "FileName=XboxInstaller.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:WinTweaker
call :ASX_Hub_Downloads_Title
set "FileName=Win.Tweaker.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск программы %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:QuickCpu
call :ASX_Hub_Downloads_Title
set "FileName=QuickCpuSetup.msi"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:AuslogicsBoostSpeed
call :ASX_Hub_Downloads_Title
set "FileName=Auslogics.BoostSpeed.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Dism
call :ASX_Hub_Downloads_Title 
set "FileName=Dism++x64.exe"
set "FileNameZip=Dism++.zip"
set "FilePatch=%ASX-Directory%\Files\Downloads\Dism++\%FileName%"
set "FilePatchZip=%ASX-Directory%\Files\Downloads\%FileNameZip%"
set "FilePatchZipDestination=%ASX-Directory%\Files\Downloads\Dism++"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileNameZip%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileNameZip%" >nul 2>&1
	title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, Настройка файлов %COL%[37m
    title Настройка файлов [0/1]
	chcp 850 >nul 2>&1 
    powershell -NoProfile Expand-Archive '"%FilePatchZip%"' -DestinationPath '"%FilePatchZipDestination%"' >nul 2>&1
	chcp 65001 >nul 2>&1
	title Настройка файлов [1/1]
	echo     %COL%[36m   └ Настройка завершена, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m     └ Файл прошел проверку, запуск программы %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatchZip%"
)
goto GoBack

:Ccleaner
call :ASX_Hub_Downloads_Title 
set "FileName=CCleaner.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:PowerToys
call :ASX_Hub_Downloads_Title 
set "FileName=PowerToysSetup.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:WinRaR
call :ASX_Hub_Downloads_Title 
set "FileName=winrar-x64-701ru.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
    timeout 4 /nobreak >nul
    title Активация продукта [1/1]
    echo     %COL%[36m     └ Установщик запущен, Активация продукта %COL%[37m
    curl -g -L -# -o "%ProgramFiles%\WinRAR\rarreg.key" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/rarreg.key" >nul 2>&1
    start "" "%ProgramFiles%\WinRAR\WinRAR.exe"
)
goto GoBack

:7z
call :ASX_Hub_Downloads_Title 
set "FileName=7z.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Discord
call :ASX_Hub_Downloads_Title
set "FileName=DiscordSetup.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Telegram
call :ASX_Hub_Downloads_Title 
set "FileName=Telegram.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:UninstallTool
call :ASX_Hub_Downloads_Title 
set "FileName=UninstallTool.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:DriverBooster
call :ASX_Hub_Downloads_Title 
set "FileName=Driver.Booster.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Unlocker
call :ASX_Hub_Downloads_Title 
set "FileName=Unlocker.msi"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" "%FilePatch%"
)
goto GoBack

:FreeMove
call :ASX_Hub_Downloads_Title 
set "FileName=FreeMove.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, cоздание ярлыка на рабочем столе %COL%[37m
    chcp 850 >nul 2>&1
    powershell "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\%FileName%.lnk'); $Shortcut.TargetPath = '%FilePatch%'; $Shortcut.Save()"
    chcp 65001 >nul 2>&1
    echo     %COL%[36m     └ Ярлык создан, запуск программы%COL%[37m
    timeout 1 /nobreak >nul
    start "" "%FilePatch%"
)
goto GoBack

:MemReduct
call :ASX_Hub_Downloads_Title 
set "FileName=memreduct.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:EaseUS
call :ASX_Hub_Downloads_Title 
set "FileName=EaseUS.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:AIDA64
call :ASX_Hub_Downloads_Title 
set "FileName=AIDA64.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:CPU-Z
call :ASX_Hub_Downloads_Title 
set "FileName=cpu-z.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:MSI_Afterburner
call :ASX_Hub_Downloads_Title 
set "FileName=MSIAfterburnerSetup.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:VScode
call :ASX_Hub_Downloads_Title 
set "FileName=VSCode.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:VS
call :ASX_Hub_Downloads_Title 
set "FileName=VisualStudioSetup.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:GitHubDesktop
call :ASX_Hub_Downloads_Title
set "FileName=GitHubDesktop.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:NotepadPP
call :ASX_Hub_Downloads_Title 
set "FileName=npp.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Pycharm
call :ASX_Hub_Downloads_Title 
set "FileName=Pycharm.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:SoundLock
call :ASX_Hub_Downloads_Title 
set "FileName=Sound_Lock_Setup.msi"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:AutoKMS
call :ASX_Hub_Downloads_Title 
set "FileName=KMSAuto++.exe"
set "FileNameZip=KMSAuto.zip"
set "FilePatch=%ASX-Directory%\Files\Resources\KMSAuto\%FileName%"
set "FilePatchZip=%ASX-Directory%\Files\Downloads\%FileNameZip%"
set "FilePatchZipDestination=%ASX-Directory%\Files\Resources\KMSAuto"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
	title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileNameZip% %COL%[37m    
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\KMSAuto.zip" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/KMSAuto.zip" >nul 2>&1
	title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, Настройка файлов %COL%[37m
    title Настройка файлов [0/1]
	chcp 850 >nul 2>&1 
	powershell -NoProfile Expand-Archive '"%FilePatchZip%"' -DestinationPath '"%FilePatchZipDestination%"'
	chcp 65001 >nul 2>&1
	title Настройка файлов [1/1]
	echo     %COL%[36m   └ Настройка завершена, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m     └ Файл прошел проверку, запуск программы %COL%[37m
    timeout 1 /nobreak >nul    
	start "" /wait "%FilePatch%"
    del /Q "%FilePatchZip%"
)
goto GoBack

:WinDigActivation
call :ASX_Hub_Downloads_Title 
set "FileName=WinDigitalActivation.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск программы %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:qbittorrent
call :ASX_Hub_Downloads_Title 
set "FileName=qbittorrent.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:TeamViewer
call :ASX_Hub_Downloads_Title 
set "FileName=TeamViewer.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Flow-Launcher
call :ASX_Hub_Downloads_Title 
set "FileName=Flow-Launcher-Setup.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Rufus
call :ASX_Hub_Downloads_Title 
set "FileName=Rufus.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск программы %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Flashr
call :ASX_Hub_Downloads_Title 
set "FileName=Flashr.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск программы %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:MiniBin
call :ASX_Hub_Downloads_Title
set "FileName=MiniBin.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%ASX-Directory%\Files\Downloads\%FileName%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    md "%ASX-Directory%\Files\Resources\MiniBin_icon" >nul 2>&1	
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    curl -g -L -# -o "%ASX-Directory%\Files\Resources\MiniBin_icon\full.ico" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/full.ico" >nul 2>&1
	curl -g -L -# -o "%ASX-Directory%\Files\Resources\MiniBin_icon\75.ico" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/75.ico" >nul 2>&1
	curl -g -L -# -o "%ASX-Directory%\Files\Resources\MiniBin_icon\50.ico" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/50.ico" >nul 2>&1
    curl -g -L -# -o "%ASX-Directory%\Files\Resources\MiniBin_icon\25.ico" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/25.ico" >nul 2>&1
    curl -g -L -# -o "%ASX-Directory%\Files\Resources\MiniBin_icon\empty.ico" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/empty.ico" >nul 2>&1    
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
	start /wait "" "%ASX-Directory%\Files\Downloads\%FileName%"
    start "" "%ASX-Directory%\Files\Resources\MiniBin_icon"
	del /Q "%ASX-Directory%\Files\Downloads\%FileName%"
)
goto GoBack

:dfControl
call :ASX_Hub_Downloads_Title 
set "FileName=dfControl.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск программы %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack


:DriverStoreExplorer
call :ASX_Hub_Downloads_Title 
set "FileName=Rapr.exe"
set "FileNameZip=DriverStoreExplorer.zip"
set "FilePatch=%ASX-Directory%\Files\Utilites\DriverStoreExplorer\%FileName%"
set "FilePatchZip=%ASX-Directory%\Files\Downloads\%FileNameZip%"
set "FilePatchZipDestination=%ASX-Directory%\Files\Utilites\DriverStoreExplorer"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
	title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileNameZip% %COL%[37m    
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\DriverStoreExplorer.zip" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/DriverStoreExplorer.zip" >nul 2>&1
	title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, Настройка файлов %COL%[37m
    title Настройка файлов [0/1]
	chcp 850 >nul 2>&1 
	powershell -NoProfile Expand-Archive '"%FilePatchZip%"' -DestinationPath '"%FilePatchZipDestination%"'
	chcp 65001 >nul 2>&1
	title Настройка файлов [1/1]
	echo     %COL%[36m   └ Настройка завершена, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m     └ Файл прошел проверку, запуск программы %COL%[37m
    timeout 1 /nobreak >nul
	start "" "%FilePatch%"
    del /Q "%FilePatchZip%"
)
goto GoBack

:Autoruns
call :ASX_Hub_Downloads_Title 
set "FileName=Autoruns.exe"
set "FilePatch=%ASX-Directory%\Files\Utilites\Autoruns\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m 
    md "%ASX-Directory%\Files\Utilites\Autoruns" >nul 2>&1
    curl -g -L -# -o "%ASX-Directory%\Files\Utilites\Autoruns\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, cоздание ярлыка на рабочем столе %COL%[37m
    chcp 850 >nul 2>&1
    powershell "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\%FileName%.lnk'); $Shortcut.TargetPath = '%FilePatch%'; $Shortcut.Save()"
    chcp 65001 >nul 2>&1
    echo     %COL%[36m     └ Ярлык создан, запуск программы%COL%[37m
    timeout 1 /nobreak >nul
    start "" "%FilePatch%"
)
goto GoBack

:DisplayDriverUninstaller
call :ASX_Hub_Downloads_Title 
set "FileName=DDU_setup.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:VibranceGUI
call :ASX_Hub_Downloads_Title 
set "FileName=VibranceGUI.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск программы %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:Everything
call :ASX_Hub_Downloads_Title 
set "FileName=EverythingSetup.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:ShutUp10
call :ASX_Hub_Downloads_Title 
set "FileName=ShutUp10.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск программы %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
)
goto GoBack

:Wumt
call :ASX_Hub_Downloads_Title 
set "FileName=wumt.exe"
set "FilePatch=%ASX-Directory%\Files\Utilites\WindowsUpdate-MiniTool\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    md "%ASX-Directory%\Files\Utilites\WindowsUpdate-MiniTool" >nul 2>&1
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Utilites\WindowsUpdate-MiniTool\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, cоздание ярлыка на рабочем столе %COL%[37m
    chcp 850 >nul 2>&1
    powershell "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\%FileName%.lnk'); $Shortcut.TargetPath = '%FilePatch%'; $Shortcut.Save()"
    chcp 65001 >nul 2>&1
    echo     %COL%[36m     └ Ярлык создан, запуск программы%COL%[37m
    start "" "%FilePatch%"
)
goto GoBack

:VisualC
call :ASX_Hub_Downloads_Title 
set "FileName=VC_redist.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:DirectX
call :ASX_Hub_Downloads_Title 
set "FileName=DirectX.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:MicrosoftOffice
call :ASX_Hub_Downloads_Title 
set "FileName=Office Installer.exe"
set "FileNameZip=Office.zip"
set "FilePatch=%ASX-Directory%\Files\Downloads\Office\%FileName%"
set "FilePatchZip=%ASX-Directory%\Files\Downloads\%FileNameZip%"
set "FilePatchZipDestination=%ASX-Directory%\Files\Downloads\Office"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileNameZip% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
	title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileNameZip% %COL%[37m    
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileNameZip%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileNameZip%" >nul 2>&1
	title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, Настройка файлов %COL%[37m
    title Настройка файлов [0/1]
	chcp 850 >nul 2>&1 
	powershell -NoProfile Expand-Archive '"%FilePatchZip%"' -DestinationPath '"%FilePatchZipDestination%"'
	chcp 65001 >nul 2>&1
	title Настройка файлов [1/1]
	echo     %COL%[36m   └ Настройка завершена, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m     └ Файл прошел проверку, запуск программы %COL%[37m
    timeout 1 /nobreak >nul
    start "" "%FilePatch%"
    del /Q "%FilePatchZip%"
)
goto GoBack

:CreativeCloud
call :ASX_Hub_Downloads_Title 
set "FileName=CreativeCloud.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack

:MediaCreationTool
call :ASX_Hub_Downloads_Title 
set "FileName=MediaCreationTool_Win11_23H2.exe"
set "FilePatch=%ASX-Directory%\Files\Downloads\%FileName%"
IF EXIST "%FilePatch%" (
	echo %COL%[36m Запуск %FileName% %COL%[37m
    start "" "%FilePatch%"
) ELSE (
    title Скачивание файлов [0/1]
    echo     %COL%[36m Запущено скачивание %FileName% %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\%FileName%" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/%FileName%" >nul 2>&1
    title Скачивание файлов [1/1]
    echo     %COL%[36m └ Скачивание завершено, проверка файла %COL%[37m
    title Проверка файлов [0/1]
    call:FileChecker
    title Проверка файлов [1/1]
    echo     %COL%[36m   └ Файл прошел проверку, запуск установщика %COL%[37m
    timeout 1 /nobreak >nul
    start "" /wait "%FilePatch%"
    del /Q "%FilePatch%"
)
goto GoBack
:: Конец установочных файлов


:AppUninstall
cls
call :ASX_Hub_Downloads_Title 
IF EXIST "%ASX-Directory%\Files\Utilites\PyDebloatX\PyDebloatX.exe" (
    start "" "%ASX-Directory%\Files\Utilites\PyDebloatX\PyDebloatX.exe"
) ELSE (
    title Скачивание нелбходимых файлов [0/1]
	md "%ASX-Directory%\Files\Utilites\PyDebloatX" >nul 2>&1
    curl -g -L -# -o "%ASX-Directory%\Files\Utilites\PyDebloatX\PyDebloatX.exe" "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Utilities/PyDebloatX/PyDebloatX.exe" >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        TITLE Ошибка: Не удалось скачать файл PyDebloatX.exe. Проверьте подключение к интернету и доступность URL.
        goto GoBack
    )
    title Скачивание нелбходимых файлов [1/1]
	start "" "%ASX-Directory%\Files\Utilites\PyDebloatX\PyDebloatX.exe"
)
goto GoBack


:Uninstall_NVTelemetry
::Удаление задач телеметрии NVIDIA
if exist "%ProgramFiles%\NVIDIA Corporation\Installer2\InstallerCore\NVI2.DLL" (
rundll32 "%PROGRAMFILES%\NVIDIA Corporation\Installer2\InstallerCore\NVI2.DLL",UninstallPackage NvTelemetryContainer
rundll32 "%PROGRAMFILES%\NVIDIA Corporation\Installer2\InstallerCore\NVI2.DLL",UninstallPackage NvTelemetry

::Удаление файлов остаточной телеметрии NVIDIA
del /s %SystemRoot%\System32\DriverStore\FileRepository\NvTelemetry*.dll
rmdir /s /q "%ProgramFiles(x86)%\NVIDIA Corporation\NvTelemetry" 2>nul
rmdir /s /q "%ProgramFiles%\NVIDIA Corporation\NvTelemetry" 2>nul

::Отключите службу Nvidia Telemetry Container	
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$serviceName = 'NvTelemetryContainer'; Write-Host "^""Disabling service: `"^""$serviceName`"^""."^""; <# -- 1. Skip if service does not exist #>; $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue; if(!$service) {; Write-Host "^""Service `"^""$serviceName`"^"" could not be not found, no need to disable it."^""; Exit 0; }; <# -- 2. Stop if running #>; if ($service.Status -eq [System.ServiceProcess.ServiceControllerStatus]::Running) {; Write-Host "^""`"^""$serviceName`"^"" is running, stopping it."^""; try {; Stop-Service -Name "^""$serviceName"^"" -Force -ErrorAction Stop; Write-Host "^""Stopped `"^""$serviceName`"^"" successfully."^""; } catch {; Write-Warning "^""Could not stop `"^""$serviceName`"^"", it will be stopped after reboot: $_"^""; }; } else {; Write-Host "^""`"^""$serviceName`"^"" is not running, no need to stop."^""; }; <# -- 3. Skip if already disabled #>; $startupType = $service.StartType <# Does not work before .NET 4.6.1 #>; if(!$startupType) {; $startupType = (Get-WmiObject -Query "^""Select StartMode From Win32_Service Where Name='$serviceName'"^"" -ErrorAction Ignore).StartMode; if(!$startupType) {; $startupType = (Get-WmiObject -Class Win32_Service -Property StartMode -Filter "^""Name='$serviceName'"^"" -ErrorAction Ignore).StartMode; }; }; if($startupType -eq 'Disabled') {; Write-Host "^""$serviceName is already disabled, no further action is needed"^""; }; <# -- 4. Disable service #>; try {; Set-Service -Name "^""$serviceName"^"" -StartupType Disabled -Confirm:$false -ErrorAction Stop; Write-Host "^""Disabled `"^""$serviceName`"^"" successfully."^""; } catch {; Write-Error "^""Could not disable `"^""$serviceName`"^"": $_"^""; }" >nul 2>&1
chcp 65001 >nul 2>&1

::Отключите службы телеметрии NVIDIA
schtasks /change /TN NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /DISABLE
schtasks /change /TN NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /DISABLE
schtasks /change /TN NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8} /DISABLE
)

:: ----------Disable "NVIDIA Telemetry Report" task----------
echo --- Disable "NVIDIA Telemetry Report" task
:: Disable scheduled task(s): `\NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}`
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$taskPathPattern='\'; $taskNamePattern='NvTmRep_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}'; Write-Output "^""Disabling tasks matching pattern `"^""$taskNamePattern`"^""."^""; $tasks = @(Get-ScheduledTask -TaskPath $taskPathPattern -TaskName $taskNamePattern -ErrorAction Ignore); if (-Not $tasks) { Write-Output "^""Skipping, no tasks matching pattern `"^""$taskNamePattern`"^"" found, no action needed."^""; exit 0; }; $operationFailed = $false; foreach ($task in $tasks) { $taskName = $task.TaskName; if ($task.State -eq [Microsoft.PowerShell.Cmdletization.GeneratedTypes.ScheduledTask.StateEnum]::Disabled) { Write-Output "^""Skipping, task `"^""$taskName`"^"" is already disabled, no action needed."^""; continue; }; try { $task | Disable-ScheduledTask -ErrorAction Stop | Out-Null; Write-Output "^""Successfully disabled task `"^""$taskName`"^""."^""; } catch { Write-Error "^""Failed to disable task `"^""$taskName`"^"": $($_.Exception.Message)"^""; $operationFailed = $true; }; }; if ($operationFailed) { Write-Output 'Failed to disable some tasks. Check error messages above.'; exit 1; }"
chcp 65001 >nul 2>&1

:: -----Disable "NVIDIA Telemetry Report on Logon" task------
echo --- Disable "NVIDIA Telemetry Report on Logon" task
:: Disable scheduled task(s): `\NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}`
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$taskPathPattern='\'; $taskNamePattern='NvTmRepOnLogon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}'; Write-Output "^""Disabling tasks matching pattern `"^""$taskNamePattern`"^""."^""; $tasks = @(Get-ScheduledTask -TaskPath $taskPathPattern -TaskName $taskNamePattern -ErrorAction Ignore); if (-Not $tasks) { Write-Output "^""Skipping, no tasks matching pattern `"^""$taskNamePattern`"^"" found, no action needed."^""; exit 0; }; $operationFailed = $false; foreach ($task in $tasks) { $taskName = $task.TaskName; if ($task.State -eq [Microsoft.PowerShell.Cmdletization.GeneratedTypes.ScheduledTask.StateEnum]::Disabled) { Write-Output "^""Skipping, task `"^""$taskName`"^"" is already disabled, no action needed."^""; continue; }; try { $task | Disable-ScheduledTask -ErrorAction Stop | Out-Null; Write-Output "^""Successfully disabled task `"^""$taskName`"^""."^""; } catch { Write-Error "^""Failed to disable task `"^""$taskName`"^"": $($_.Exception.Message)"^""; $operationFailed = $true; }; }; if ($operationFailed) { Write-Output 'Failed to disable some tasks. Check error messages above.'; exit 1; }"
chcp 65001 >nul 2>&1

:: ---------Disable "NVIDIA telemetry monitor" task----------
echo --- Disable "NVIDIA telemetry monitor" task
:: Disable scheduled task(s): `\NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}`
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$taskPathPattern='\'; $taskNamePattern='NvTmMon_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}'; Write-Output "^""Disabling tasks matching pattern `"^""$taskNamePattern`"^""."^""; $tasks = @(Get-ScheduledTask -TaskPath $taskPathPattern -TaskName $taskNamePattern -ErrorAction Ignore); if (-Not $tasks) { Write-Output "^""Skipping, no tasks matching pattern `"^""$taskNamePattern`"^"" found, no action needed."^""; exit 0; }; $operationFailed = $false; foreach ($task in $tasks) { $taskName = $task.TaskName; if ($task.State -eq [Microsoft.PowerShell.Cmdletization.GeneratedTypes.ScheduledTask.StateEnum]::Disabled) { Write-Output "^""Skipping, task `"^""$taskName`"^"" is already disabled, no action needed."^""; continue; }; try { $task | Disable-ScheduledTask -ErrorAction Stop | Out-Null; Write-Output "^""Successfully disabled task `"^""$taskName`"^""."^""; } catch { Write-Error "^""Failed to disable task `"^""$taskName`"^"": $($_.Exception.Message)"^""; $operationFailed = $true; }; }; if ($operationFailed) { Write-Output 'Failed to disable some tasks. Check error messages above.'; exit 1; }"
chcp 65001 >nul 2>&1

:: -------------Remove Nvidia telemetry packages-------------
echo --- Remove Nvidia telemetry packages
if exist "%ProgramFiles%\NVIDIA Corporation\Installer2\InstallerCore\NVI2.DLL" (
    rundll32 "%PROGRAMFILES%\NVIDIA Corporation\Installer2\InstallerCore\NVI2.DLL",UninstallPackage NvTelemetryContainer
    rundll32 "%PROGRAMFILES%\NVIDIA Corporation\Installer2\InstallerCore\NVI2.DLL",UninstallPackage NvTelemetry
)

:: ------------Remove Nvidia telemetry components------------
echo --- Remove Nvidia telemetry components
:: Soft delete files matching pattern: "%PROGRAMFILES(X86)%\NVIDIA Corporation\NvTelemetry\*"  
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""%PROGRAMFILES(X86)%\NVIDIA Corporation\NvTelemetry\*"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $renamedCount   = 0; $skippedCount   = 0; $failedCount    = 0; $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (Test-Path -Path $path -PathType Container) { Write-Host "^""Skipping folder (not its contents): `"^""$path`"^""."^""; $skippedCount++; continue; }; if($revert -eq $true) { if (-not $path.EndsWith('.OLD')) { Write-Host "^""Skipping non-backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; } else { if ($path.EndsWith('.OLD')) { Write-Host "^""Skipping backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; }; $originalFilePath = $path; Write-Host "^""Processing file: `"^""$originalFilePath`"^""."^""; if (-Not (Test-Path $originalFilePath)) { Write-Host "^""Skipping, file `"^""$originalFilePath`"^"" not found."^""; $skippedCount++; exit 0; }; if ($revert -eq $true) { $newFilePath = $originalFilePath.Substring(0, $originalFilePath.Length - 4); } else { $newFilePath = "^""$($originalFilePath).OLD"^""; }; try { Move-Item -LiteralPath "^""$($originalFilePath)"^"" -Destination "^""$newFilePath"^"" -Force -ErrorAction Stop; Write-Host "^""Successfully processed `"^""$originalFilePath`"^""."^""; $renamedCount++; } catch { Write-Error "^""Failed to rename `"^""$originalFilePath`"^"" to `"^""$newFilePath`"^"": $($_.Exception.Message)"^""; $failedCount++; }; }; if (($renamedCount -gt 0) -or ($skippedCount -gt 0)) { Write-Host "^""Successfully processed $renamedCount items and skipped $skippedCount items."^""; }; if ($failedCount -gt 0) { Write-Warning "^""Failed to process $($failedCount) items."^""; }"
:: Soft delete files matching pattern: "%PROGRAMFILES%\NVIDIA Corporation\NvTelemetry\*"  
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""%PROGRAMFILES%\NVIDIA Corporation\NvTelemetry\*"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $renamedCount   = 0; $skippedCount   = 0; $failedCount    = 0; $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (Test-Path -Path $path -PathType Container) { Write-Host "^""Skipping folder (not its contents): `"^""$path`"^""."^""; $skippedCount++; continue; }; if($revert -eq $true) { if (-not $path.EndsWith('.OLD')) { Write-Host "^""Skipping non-backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; } else { if ($path.EndsWith('.OLD')) { Write-Host "^""Skipping backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; }; $originalFilePath = $path; Write-Host "^""Processing file: `"^""$originalFilePath`"^""."^""; if (-Not (Test-Path $originalFilePath)) { Write-Host "^""Skipping, file `"^""$originalFilePath`"^"" not found."^""; $skippedCount++; exit 0; }; if ($revert -eq $true) { $newFilePath = $originalFilePath.Substring(0, $originalFilePath.Length - 4); } else { $newFilePath = "^""$($originalFilePath).OLD"^""; }; try { Move-Item -LiteralPath "^""$($originalFilePath)"^"" -Destination "^""$newFilePath"^"" -Force -ErrorAction Stop; Write-Host "^""Successfully processed `"^""$originalFilePath`"^""."^""; $renamedCount++; } catch { Write-Error "^""Failed to rename `"^""$originalFilePath`"^"" to `"^""$newFilePath`"^"": $($_.Exception.Message)"^""; $failedCount++; }; }; if (($renamedCount -gt 0) -or ($skippedCount -gt 0)) { Write-Host "^""Successfully processed $renamedCount items and skipped $skippedCount items."^""; }; if ($failedCount -gt 0) { Write-Warning "^""Failed to process $($failedCount) items."^""; }"
chcp 65001 >nul 2>&1

:: -------------Disable Nvidia telemetry drivers-------------
echo --- Disable Nvidia telemetry drivers
:: Soft delete files matching pattern: "%SYSTEMROOT%\System32\DriverStore\FileRepository\NvTelemetry*.dll"  
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$pathGlobPattern = "^""%SYSTEMROOT%\System32\DriverStore\FileRepository\NvTelemetry*.dll"^""; $expandedPath = [System.Environment]::ExpandEnvironmentVariables($pathGlobPattern); Write-Host "^""Searching for items matching pattern: `"^""$($expandedPath)`"^""."^""; $renamedCount   = 0; $skippedCount   = 0; $failedCount    = 0; $foundAbsolutePaths = @(); Write-Host 'Iterating files and directories recursively.'; try { $foundAbsolutePaths += @(; Get-ChildItem -Path $expandedPath -Force -Recurse -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; try { $foundAbsolutePaths += @(; Get-Item -Path $expandedPath -ErrorAction Stop | Select-Object -ExpandProperty FullName; ); } catch [System.Management.Automation.ItemNotFoundException] { <# Swallow, do not run `Test-Path` before, it's unreliable for globs requiring extra permissions #>; }; $foundAbsolutePaths = $foundAbsolutePaths | Select-Object -Unique | Sort-Object -Property { $_.Length } -Descending; if (!$foundAbsolutePaths) { Write-Host 'Skipping, no items available.'; exit 0; }; Write-Host "^""Initiating processing of $($foundAbsolutePaths.Count) items from `"^""$expandedPath`"^""."^""; foreach ($path in $foundAbsolutePaths) { if (Test-Path -Path $path -PathType Container) { Write-Host "^""Skipping folder (not its contents): `"^""$path`"^""."^""; $skippedCount++; continue; }; if($revert -eq $true) { if (-not $path.EndsWith('.OLD')) { Write-Host "^""Skipping non-backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; } else { if ($path.EndsWith('.OLD')) { Write-Host "^""Skipping backup file: `"^""$path`"^""."^""; $skippedCount++; continue; }; }; $originalFilePath = $path; Write-Host "^""Processing file: `"^""$originalFilePath`"^""."^""; if (-Not (Test-Path $originalFilePath)) { Write-Host "^""Skipping, file `"^""$originalFilePath`"^"" not found."^""; $skippedCount++; exit 0; }; if ($revert -eq $true) { $newFilePath = $originalFilePath.Substring(0, $originalFilePath.Length - 4); } else { $newFilePath = "^""$($originalFilePath).OLD"^""; }; try { Move-Item -LiteralPath "^""$($originalFilePath)"^"" -Destination "^""$newFilePath"^"" -Force -ErrorAction Stop; Write-Host "^""Successfully processed `"^""$originalFilePath`"^""."^""; $renamedCount++; } catch { Write-Error "^""Failed to rename `"^""$originalFilePath`"^"" to `"^""$newFilePath`"^"": $($_.Exception.Message)"^""; $failedCount++; }; }; if (($renamedCount -gt 0) -or ($skippedCount -gt 0)) { Write-Host "^""Successfully processed $renamedCount items and skipped $skippedCount items."^""; }; if ($failedCount -gt 0) { Write-Warning "^""Failed to process $($failedCount) items."^""; }"
chcp 65001 >nul 2>&1

:: --------Disable participation in Nvidia telemetry---------
echo --- Disable participation in Nvidia telemetry
:: Set the registry value: "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client!OptInOrOutPreference"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client'; $data =  '0'; reg add 'HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client' /v 'OptInOrOutPreference' /t 'REG_DWORD' /d "^""$data"^"" /f"
:: Set the registry value: "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS!EnableRID44231"
PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS'; $data =  '0'; reg add 'HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS' /v 'EnableRID44231' /t 'REG_DWORD' /d "^""$data"^"" /f"
:: Set the registry value: "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS!EnableRID64640"
PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS'; $data =  '0'; reg add 'HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS' /v 'EnableRID64640' /t 'REG_DWORD' /d "^""$data"^"" /f"
:: Set the registry value: "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS!EnableRID66610"
PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS'; $data =  '0'; reg add 'HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS' /v 'EnableRID66610' /t 'REG_DWORD' /d "^""$data"^"" /f"
:: Set the registry value: "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\Startup!SendTelemetryData"
PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\Startup'; $data =  '0'; reg add 'HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\Startup' /v 'SendTelemetryData' /t 'REG_DWORD' /d "^""$data"^"" /f"
chcp 65001 >nul 2>&1

:: -------Disable "Nvidia Telemetry Container" service-------
echo --- Disable "Nvidia Telemetry Container" service
:: Disable service(s): `NvTelemetryContainer`
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$serviceName = 'NvTelemetryContainer'; Write-Host "^""Disabling service: `"^""$serviceName`"^""."^""; <# -- 1. Skip if service does not exist #>; $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue; if(!$service) { Write-Host "^""Service `"^""$serviceName`"^"" could not be not found, no need to disable it."^""; Exit 0; }; <# -- 2. Stop if running #>; if ($service.Status -eq [System.ServiceProcess.ServiceControllerStatus]::Running) { Write-Host "^""`"^""$serviceName`"^"" is running, stopping it."^""; try { Stop-Service -Name "^""$serviceName"^"" -Force -ErrorAction Stop; Write-Host "^""Stopped `"^""$serviceName`"^"" successfully."^""; } catch { Write-Warning "^""Could not stop `"^""$serviceName`"^"", it will be stopped after reboot: $_"^""; }; } else { Write-Host "^""`"^""$serviceName`"^"" is not running, no need to stop."^""; }; <# -- 3. Skip if already disabled #>; $startupType = $service.StartType <# Does not work before .NET 4.6.1 #>; if (!$startupType) { $startupType = (Get-WmiObject -Query "^""Select StartMode From Win32_Service Where Name='$serviceName'"^"" -ErrorAction Ignore).StartMode; if(!$startupType) { $startupType = (Get-WmiObject -Class Win32_Service -Property StartMode -Filter "^""Name='$serviceName'"^"" -ErrorAction Ignore).StartMode; }; }; if ($startupType -eq 'Disabled') { Write-Host "^""$serviceName is already disabled, no further action is needed"^""; Exit 0; }; <# -- 4. Disable service #>; try { Set-Service -Name "^""$serviceName"^"" -StartupType Disabled -Confirm:$false -ErrorAction Stop; Write-Host "^""Disabled `"^""$serviceName`"^"" successfully."^""; } catch { Write-Error "^""Could not disable `"^""$serviceName`"^"": $_"^""; }"
chcp 65001 >nul 2>&1
set "operation_name=Удаление телеметрии Nvidia"
call:Complete_notice
goto GoBack


:EdgeTelemetry
if "%DLEGT%" == "%COL%[92mВКЛ " (
echo [INFO ] %TIME% - Выключении телеметрии edge >> "%ASX-Directory%\Files\Logs\%date%.txt"
cls
:: -----------Disable Edge diagnostic data sending-----------
echo --- Disable Edge diagnostic data sending
:: Set the registry value: "HKLM\SOFTWARE\Policies\Microsoft\Edge!DiagnosticData"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SOFTWARE\Policies\Microsoft\Edge'; $data =  '0'; reg add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'DiagnosticData' /t 'REG_DWORD' /d "^""$data"^"" /f"
:: Suggest restarting Edge for changes to take effect
PowerShell -ExecutionPolicy Unrestricted -Command "$message = 'For the changes to fully take effect, please restart Microsoft Edge.'; $warn =  $false; if ($warn) { Write-Warning "^""$message"^""; } else { Write-Host "^""Note: "^"" -ForegroundColor Blue -NoNewLine; Write-Output "^""$message"^""; }"
chcp 65001 >nul 2>&1

:: --------Disable outdated Edge metrics data sending--------
echo --- Disable outdated Edge metrics data sending
:: Set the registry value: "HKLM\SOFTWARE\Policies\Microsoft\Edge!MetricsReportingEnabled"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SOFTWARE\Policies\Microsoft\Edge'; $data =  '0'; reg add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'MetricsReportingEnabled' /t 'REG_DWORD' /d "^""$data"^"" /f"
:: Suggest restarting Edge for changes to take effect
PowerShell -ExecutionPolicy Unrestricted -Command "$message = 'For the changes to fully take effect, please restart Microsoft Edge.'; $warn =  $false; if ($warn) { Write-Warning "^""$message"^""; } else { Write-Host "^""Note: "^"" -ForegroundColor Blue -NoNewLine; Write-Output "^""$message"^""; }"
chcp 65001 >nul 2>&1

:: ------Disable outdated Edge site information sending------
echo --- Disable outdated Edge site information sending
:: Set the registry value: "HKLM\SOFTWARE\Policies\Microsoft\Edge!SendSiteInfoToImproveServices"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SOFTWARE\Policies\Microsoft\Edge'; $data =  '0'; reg add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'SendSiteInfoToImproveServices' /t 'REG_DWORD' /d "^""$data"^"" /f"
:: Suggest restarting Edge for changes to take effect
PowerShell -ExecutionPolicy Unrestricted -Command "$message = 'For the changes to fully take effect, please restart Microsoft Edge.'; $warn =  $false; if ($warn) { Write-Warning "^""$message"^""; } else { Write-Host "^""Note: "^"" -ForegroundColor Blue -NoNewLine; Write-Output "^""$message"^""; }"
chcp 65001 >nul 2>&1

:: ------------------Disable Edge Feedback-------------------
echo --- Disable Edge Feedback
:: Set the registry value: "HKLM\SOFTWARE\Policies\Microsoft\Edge!UserFeedbackAllowed"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "$registryPath = 'HKLM\SOFTWARE\Policies\Microsoft\Edge'; $data =  '0'; reg add 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'UserFeedbackAllowed' /t 'REG_DWORD' /d "^""$data"^"" /f"
:: Suggest restarting Edge for changes to take effect
PowerShell -ExecutionPolicy Unrestricted -Command "$message = 'For the changes to fully take effect, please restart Microsoft Edge.'; $warn =  $false; if ($warn) { Write-Warning "^""$message"^""; } else { Write-Host "^""Note: "^"" -ForegroundColor Blue -NoNewLine; Write-Output "^""$message"^""; }"
chcp 65001 >nul 2>&1
    set "operation_name=Выключении телеметрии edge"
) >nul 2>&1 else (
cls
echo [INFO ] %TIME% - Включении телеметрии edge >> "%ASX-Directory%\Files\Logs\%date%.txt"
:: ------Disable Edge diagnostic data sending (revert)-------
echo --- Disable Edge diagnostic data sending - revert
:: Delete the registry value "HKLM\SOFTWARE\Policies\Microsoft\Edge!DiagnosticData"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "reg delete 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'DiagnosticData' /f 2>$null"
:: Suggest restarting Edge for changes to take effect
PowerShell -ExecutionPolicy Unrestricted -Command "$message = 'For the changes to fully take effect, please restart Microsoft Edge.'; $warn =  $false; if ($warn) { Write-Warning "^""$message"^""; } else { Write-Host "^""Note: "^"" -ForegroundColor Blue -NoNewLine; Write-Output "^""$message"^""; }"
chcp 65001 >nul 2>&1

:: ---Disable outdated Edge metrics data sending (revert)----
echo --- Disable outdated Edge metrics data sending - revert
:: Delete the registry value "HKLM\SOFTWARE\Policies\Microsoft\Edge!MetricsReportingEnabled"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "reg delete 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'MetricsReportingEnabled' /f 2>$null"
:: Suggest restarting Edge for changes to take effect
PowerShell -ExecutionPolicy Unrestricted -Command "$message = 'For the changes to fully take effect, please restart Microsoft Edge.'; $warn =  $false; if ($warn) { Write-Warning "^""$message"^""; } else { Write-Host "^""Note: "^"" -ForegroundColor Blue -NoNewLine; Write-Output "^""$message"^""; }"
chcp 65001 >nul 2>&1

:: -Disable outdated Edge site information sending (revert)--
echo --- Disable outdated Edge site information sending - revert
:: Delete the registry value "HKLM\SOFTWARE\Policies\Microsoft\Edge!SendSiteInfoToImproveServices"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "reg delete 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'SendSiteInfoToImproveServices' /f 2>$null"
:: Suggest restarting Edge for changes to take effect
PowerShell -ExecutionPolicy Unrestricted -Command "$message = 'For the changes to fully take effect, please restart Microsoft Edge.'; $warn =  $false; if ($warn) { Write-Warning "^""$message"^""; } else { Write-Host "^""Note: "^"" -ForegroundColor Blue -NoNewLine; Write-Output "^""$message"^""; }"
chcp 65001 >nul 2>&1

:: --------------Disable Edge Feedback (revert)--------------
echo --- Disable Edge Feedback - revert
:: Delete the registry value "HKLM\SOFTWARE\Policies\Microsoft\Edge!UserFeedbackAllowed"
chcp 850 >nul 2>&1
PowerShell -ExecutionPolicy Unrestricted -Command "reg delete 'HKLM\SOFTWARE\Policies\Microsoft\Edge' /v 'UserFeedbackAllowed' /f 2>$null"
:: Suggest restarting Edge for changes to take effect
PowerShell -ExecutionPolicy Unrestricted -Command "$message = 'For the changes to fully take effect, please restart Microsoft Edge.'; $warn =  $false; if ($warn) { Write-Warning "^""$message"^""; } else { Write-Host "^""Note: "^"" -ForegroundColor Blue -NoNewLine; Write-Output "^""$message"^""; }"
chcp 65001 >nul 2>&1
	set "operation_name=Включении телеметрии edge"
) >nul 2>&1

call:Complete_notice
goto GoBack

:gameBooster
TITLE Ускоритель игр - ASX Hub
cls & echo Выберите местоположение игры, вы можете сделать это второй раз, чтобы отменить изменения.
set dialog="about:<input type=file id=FILE><script>FILE.click();new ActiveXObject
set dialog=%dialog%('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(FILE.value);
set dialog=%dialog%close();resizeTo(0,0);</script>"
for /f "tokens=* delims=" %%p in ('mshta.exe %dialog%') do set "file=%%p"
if "%file%"=="" goto :eof
for %%F in ("%file%") do reg query "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%file%" && (
	reg delete "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "%file%" /f >nul 2>&1
	reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%file%" /f >nul 2>&1
	reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%~nxF\PerfOptions" /v "CpuPriorityClass" /f >nul 2>&1
	cls
	echo Ускорение игры было отменено!
	Timeout 5 /nobreak>nul
	set "operation_name=Отмена ускорения игры"
) || (
	reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "%file%" /t Reg_SZ /d "GpuPreference=2;" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%file%" /t Reg_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f >nul 2>&1
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%~nxF\PerfOptions" /v "CpuPriorityClass" /t Reg_DWORD /d "3" /f >nul 2>&1
	set "operation_name=Неизвестно"
) >nul 2>&1
call:Complete_notice
goto GoBack


:ASX_Information
cls
chcp 65001 >nul 2>&1
set PageName=ASX_Information
set choice=NoInput
echo [INFO ] %TIME% - Открыта панель ":ASX_Information" >> "%ASX-Directory%\Files\Logs\%date%.txt"
TITLE Информация - ASX Hub
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########%COL%[37m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                               %COL%[36m[ %COL%[37m1 %COL%[36m] %COL%[37mОб ASX
echo.
echo                                                               %COL%[36m[ %COL%[37m2 %COL%[36m] %COL%[37mОбновление ASX
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
%SYSTEMROOT%\System32\choice.exe /c:12CсXчBи /n /m "%DEL%                                                                      >: " 
set choice=%errorlevel%
if "%choice%"=="1" ( set "history=ASX_Information;!history!" && goto ASX_Information_About )
if "%choice%"=="2" ( set "history=ASX_Information;!history!" && goto ASX_Information_UpdateCheck )
REM if "%choice%"=="3" ( set "history=ASX_Information;!history!" && goto ASX_Information_Developers )
if "%choice%"=="3" ( set "history=ASX_Information;!history!" && goto ASX_CMD )
if "%choice%"=="4" ( set "history=ASX_Information;!history!" && goto ASX_CMD )
if "%choice%"=="5" ( set "history=ASX_Information;!history!" && goto MainMenu )
if "%choice%"=="6" ( set "history=ASX_Information;!history!" && goto MainMenu )
if "%choice%"=="7" goto GoBack
if "%choice%"=="8" goto GoBack
goto ASX_Information

:ASX_Utilites
cls
echo [INFO ] %TIME% - Открыта панель ":ASX_Utilites" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=ASX_Utilites
set choice=NoInput

REM Проверка наличия файлов в указанной директории
IF EXIST "%ASX-Directory%\Files\Utilites\DriverStoreExplorer\Rapr.exe" (
    set ASX_Utilites_Download_mark=Yes
) ELSE (
    REM Проверка наличия файла Autoruns.exe в указанной директории
    IF EXIST "%ASX-Directory%\Files\Utilites\Autoruns\Autoruns.exe" (
        set ASX_Utilites_Download_mark=Yes
    ) ELSE (
        REM Проверка наличия файла VibranceGUI.exe в указанной директории
        IF EXIST "%ASX-Directory%\Files\Utilites\VibranceGUI\VibranceGUI.exe" (
            set ASX_Utilites_Download_mark=Yes
        ) ELSE (
            REM Проверка наличия файла ShutUp10.exe в указанной директории
            IF EXIST "%ASX-Directory%\Files\Utilites\ShutUp10\ShutUp10.exe" (
                set ASX_Utilites_Download_mark=Yes
            ) ELSE (
                REM Проверка наличия файла wumt.exe в указанной директории
                IF EXIST "%ASX-Directory%\Files\Utilites\Windows Update MiniTool\wumt.exe" (
                    set ASX_Utilites_Download_mark=Yes
                ) ELSE (
                    REM Проверка наличия файла PyDebloatX.exe в указанной директории
                    IF EXIST "%ASX-Directory%\Files\Utilites\PyDebloatX\PyDebloatX.exe" (
                        set ASX_Utilites_Download_mark=Yes
                    ) ELSE (
                        REM Установка переменной в случае отсутствия всех файлов
                        set ASX_Utilites_Download_mark=No
                    )
                )
            )
        )
    )
)

TITLE Утилиты - ASX Hub
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########%COL%[37m
echo.
echo.
echo.
if "%WinVer%"=="Windows 11" (
    REM --- Windows 11: пункт "Совместимость" не нужен ---
    echo                                                            %COL%[36mОптимизация и обслуживание:
    echo                                                            %COL%[37m---------------------------
    echo                                                            %COL%[36m[ %COL%[37m1  %COL%[36m] %COL%[37mОчистка мусора %COL%[90m^(PC Cleaner^)
    echo                                                            %COL%[36m[ %COL%[37m2  %COL%[36m] %COL%[37mСортировка файлов
    echo.
    echo.
    echo.
    echo                                                            %COL%[36mДиагностика и информация:
    echo                                                            %COL%[37m-------------------------
    echo                                                            %COL%[36m[ %COL%[37m3  %COL%[36m] %COL%[37mСистемная информация
    echo                                                            %COL%[36m[ %COL%[37m4  %COL%[36m] %COL%[37mПроизводительность ПК
    echo                                                            %COL%[36m[ %COL%[37m5  %COL%[36m] %COL%[37mБенчмарк перезагрузки ПК
    echo.
    echo.
    echo.
    echo                                                            %COL%[36mДополнительные Инструменты:
    echo                                                            %COL%[37m---------------------------
    echo                                                            %COL%[36m[ %COL%[37m6  %COL%[36m] %COL%[37mСоздание бэкапа %COL%[90m^(ASX Revert^)
    echo                                                            %COL%[36m[ %COL%[37m7  %COL%[36m] %COL%[37mУдаление WinDefender %COL%[90m^(PEGASUS^)
    echo                                                            %COL%[36m[ %COL%[37m8  %COL%[36m] %COL%[37mПросмотр и удаление драйверов %COL%[90m^(DriverFinder^)
    if "%ASX_Utilites_Download_mark%"=="Yes" (
        echo                                                            %COL%[36m[ %COL%[37m9  %COL%[36m] %COL%[37mСторонние утилиты
    )
    echo.
) else (
    REM --- Не Windows 11: включаем пункт "Совместимость ПК с Win11" ---
    echo                                                            %COL%[36mОптимизация и обслуживание:
    echo                                                            %COL%[37m---------------------------
    echo                                                            %COL%[36m[ %COL%[37m1  %COL%[36m] %COL%[37mОчистка мусора %COL%[90m^(PC Cleaner^)
    echo                                                            %COL%[36m[ %COL%[37m2  %COL%[36m] %COL%[37mСортировка файлов
    echo                                                            %COL%[36m[ %COL%[37m3  %COL%[36m] %COL%[37mСовместимость ПК с Win 11
    echo.
    echo.
    echo.
    echo                                                            %COL%[36mДиагностика и информация:
    echo                                                            %COL%[37m-------------------------
    echo                                                            %COL%[36m[ %COL%[37m4  %COL%[36m] %COL%[37mСистемная информация
    echo                                                            %COL%[36m[ %COL%[37m5  %COL%[36m] %COL%[37mПроизводительность ПК
    echo                                                            %COL%[36m[ %COL%[37m6  %COL%[36m] %COL%[37mБенчмарк перезагрузки ПК
    echo.
    echo.
    echo.
    echo                                                            %COL%[36mДополнительные Инструменты:
    echo                                                            %COL%[37m---------------------------
    echo                                                            %COL%[36m[ %COL%[37m7  %COL%[36m] %COL%[37mСоздание бэкапа %COL%[90m^(ASX Revert^)
    echo                                                            %COL%[36m[ %COL%[37m8  %COL%[36m] %COL%[37mУдаление WinDefender %COL%[90m^(PEGASUS^)
    echo                                                            %COL%[36m[ %COL%[37m9  %COL%[36m] %COL%[37mПросмотр и удаление драйверов %COL%[90m^(DriverFinder^)
    if "%ASX_Utilites_Download_mark%"=="Yes" (
        echo                                                            %COL%[36m[ %COL%[37m10 %COL%[36m] %COL%[37mСторонние утилиты
    )
)


echo.
echo.
echo.
echo.
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
set /p choice="%DEL%                                                                      >: "

REM ===== Обработка выбора пользователя =====
if "%WinVer%"=="Windows 11" (
    REM --- Windows 11 ---
    if /i "%choice%"=="1" (
        set "history=ASX_Utilites;!history!"
        call :ASX_cleaner_Warn
    ) else if /i "%choice%"=="2" (
        set "history=ASX_Utilites;!history!"
        call :ASX_sorter
    ) else if /i "%choice%"=="3" (
        set "history=ASX_Utilites;!history!"
        call :SystemInformation
    ) else if /i "%choice%"=="4" (
        set "history=ASX_Utilites;!history!"
        call :ASX_PC_PowerCheck
    ) else if /i "%choice%"=="5" (
        set "history=ASX_Utilites;!history!"
        call :ASX_Benchmark_Restart_Time
    ) else if /i "%choice%"=="6" (
        set "history=ASX_Utilites;!history!"
        call :Backup
    ) else if /i "%choice%"=="7" (
        set "history=ASX_Utilites;!history!"
        call :PEGASUS_Menu_Prepare
    ) else if /i "%choice%"=="8" (
        set "history=ASX_Utilites;!history!"
        call :DriverFinder_Menu
    ) else if /i "%choice%"=="9" (
        if "%ASX_Utilites_Download_mark%"=="Yes" (
            set "history=ASX_Utilites;!history!"
            call :ASX_Utilites_Download
        ) else (
            goto WrongInput
        )
    )
) else (
    REM --- Не Windows 11 ---
    if /i "%choice%"=="1" (
        set "history=ASX_Utilites;!history!"
        call :ASX_cleaner_Warn
    ) else if /i "%choice%"=="2" (
        set "history=ASX_Utilites;!history!"
        call :ASX_sorter
    ) else if /i "%choice%"=="3" (
        set "history=ASX_Utilites;!history!"
        call :Windows11_CompatibilityCheck
    ) else if /i "%choice%"=="4" (
        set "history=ASX_Utilites;!history!"
        call :SystemInformation
    ) else if /i "%choice%"=="5" (
        set "history=ASX_Utilites;!history!"
        call :ASX_PC_PowerCheck
    ) else if /i "%choice%"=="6" (
        set "history=ASX_Utilites;!history!"
        call :ASX_Benchmark_Restart_Time
    ) else if /i "%choice%"=="7" (
        set "history=ASX_Utilites;!history!"
        call :Backup
    ) else if /i "%choice%"=="8" (
        set "history=ASX_Utilites;!history!"
        call :PEGASUS_Menu_Prepare
    ) else if /i "%choice%"=="9" (
        set "history=ASX_Utilites;!history!"
        call :DriverFinder_Menu
    ) else if /i "%choice%"=="10" (
        if "%ASX_Utilites_Download_mark%"=="Yes" (
            set "history=ASX_Utilites;!history!"
            call :ASX_Utilites_Download
        ) else (
            goto WrongInput
        )
    )
)

if /i "%choice%"=="C" (
    set "history=ASX_Utilites;!history!"
    goto ASX_CMD
) else if /i "%choice%"=="с" (
    set "history=ASX_Utilites;!history!"
    goto ASX_CMD
) else if /i "%choice%"=="X" (
    set "history=ASX_Utilites;!history!"
    goto MainMenu
) else if /i "%choice%"=="ч" (
    set "history=ASX_Utilites;!history!"
    goto MainMenu
) else if /i "%choice%"=="B" (
    goto GoBack
) else if /i "%choice%"=="и" (
    goto GoBack
) else if /i "%choice%"=="NoInput" (
    goto WrongInput
) else (
    call :WrongInput
)
goto ASX_Utilites

:ASX_Utilites_Download
cls
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":ASX_Utilites_Download" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=ASX_Utilites_Download
set choice=NoInput

REM Проверка наличия файлов и установка переменных
set AutorunsMark=No
set DriverStoreExplorerMark=No
set VibranceGUIMark=No
set ShutUp10Mark=No
set WumtMark=No
set DeviceCleanMark=No

IF EXIST "%ASX-Directory%\Files\Utilites\Autoruns\Autoruns.exe" (
    set AutorunsMark=Yes
)
IF EXIST "%ASX-Directory%\Files\Utilites\DriverStoreExplorer\Rapr.exe" (
    set DriverStoreExplorerMark=Yes
)
IF EXIST "%ASX-Directory%\Files\Utilites\VibranceGUI\VibranceGUI.exe" (
    set VibranceGUIMark=Yes
)
IF EXIST "%ASX-Directory%\Files\Utilites\ShutUp10\ShutUp10.exe" (
    set ShutUp10Mark=Yes
)
IF EXIST "%ASX-Directory%\Files\Utilites\Windows Update MiniTool\wumt.exe" (
    set WumtMark=Yes
)
IF EXIST "%ASX-Directory%\Files\Utilites\DeviceClean\DeviceClean-RunAdmin.exe" (
    set DeviceCleanMark=Yes
)

TITLE Сторонние утилиты - ASX Hub
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: ::::::::: 
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+: 
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+  
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+   
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+  
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#   
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########%COL%[37m    
echo.
echo.
echo.
echo.

set /A choiceCounter=1

if "%AutorunsMark%" == "Yes" (
    echo                                                           %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mAutoruns
    set AutorunsChoice=%choiceCounter%
    set /A choiceCounter+=1
)

if "%DriverStoreExplorerMark%" == "Yes" (
    echo                                                           %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mDriver Store Explorer
    set DriverStoreExplorerChoice=%choiceCounter%
    set /A choiceCounter+=1
)

if "%VibranceGUIMark%" == "Yes" (
    echo                                                           %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mVibranceGUI
    set VibranceGUIChoice=%choiceCounter%
    set /A choiceCounter+=1
)

if "%ShutUp10Mark%" == "Yes" (
    echo                                                           %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mShutUp10
    set ShutUp10Choice=%choiceCounter%
    set /A choiceCounter+=1
)

if "%WumtMark%" == "Yes" (
    echo                                                           %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mWindows Update MiniTool
    set WumtChoice=%choiceCounter%
    set /A choiceCounter+=1
)

if "%DeviceCleanMark%" == "Yes" (
    echo                                                           %COL%[36m[ %COL%[37m%choiceCounter%  %COL%[36m] %COL%[37mDeviceClean
    set DeviceCleanChoice=%choiceCounter%
    set /A choiceCounter+=1
)

REM Filling the remaining lines with empty echoes to keep the layout consistent
for /L %%i in (%choiceCounter%,1,6) do (
    echo.
)

echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
set /p choice="%DEL%                                                                      >: "
if /i "%choice%"=="%AutorunsChoice%" ( start "" "%ASX-Directory%\Files\Utilites\Autoruns\Autoruns.exe")
if /i "%choice%"=="%DriverStoreExplorerChoice%" ( start "" "%ASX-Directory%\Files\Utilites\DriverStoreExplorer\Rapr.exe" )
if /i "%choice%"=="%VibranceGUIChoice%" ( start "" "%ASX-Directory%\Files\Utilites\VibranceGUI\VibranceGUI.exe" )
if /i "%choice%"=="%ShutUp10Choice%" ( start "" "%ASX-Directory%\Files\Utilites\ShutUp10\ShutUp10.exe" )
if /i "%choice%"=="%WumtChoice%" ( start "" "%ASX-Directory%\Files\Utilites\Windows Update MiniTool\wumt.exe" )
if /i "%choice%"=="%DeviceCleanChoice%" ( start "" "%ASX-Directory%\Files\Utilites\DeviceClean\DeviceClean-RunAdmin.exe" )
if /i "%choice%"=="C" ( set "history=ASX_Utilites_Download;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=ASX_Utilites_Download;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=ASX_Utilites_Download;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=ASX_Utilites_Download;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
goto ASX_Utilites_Download

:Windows11_CompatibilityCheck
cls
IF EXIST "%ASX-Directory%\Files\Resources\ASX_Win11CompChk\ASX_Win11CompChk.exe" (
	echo %COL%[36m Запуск %COL%[37m
    start "" "%ASX-Directory%\Files\Resources\ASX_Win11CompChk\ASX_Win11CompChk.exe"
) ELSE (
	title Скачивание файлов [0/1]
	echo %COL%[36m Скачивание ASX_Win11CompChk.exe %COL%[37m
	md "%ASX-Directory%\Files\Resources\ASX_Win11CompChk" >nul 2>&1
    curl -g -L -# -o "%ASX-Directory%\Files\Resources\ASX_Win11CompChk\ASX_Win11CompChk.exe" "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Utilities/ASX_Win11CompChk/ASX_Win11CompChk.exe" >nul 2>&1
	title Скачивание файлов [1/1]
	echo  %COL%[36mСкачивание завершено, запуск установщика %COL%[37m
	start "" "%ASX-Directory%\Files\Resources\ASX_Win11CompChk\ASX_Win11CompChk.exe"
)
goto GoBack

:DriverFinder_Menu
if exist "%ASX-Directory%\Files\Utilites\ASX_DriverFinder\DriverFinder.exe" (
    start "DriverFinder" "%ASX-Directory%\Files\Utilites\ASX_DriverFinder\DriverFinder.exe"
) else (
    title Загрузка отсутствующих компонентов...
    echo [INFO ] %TIME% - Загрузка отсутствующего компонента DriverFinder.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
	if not exist "%ASX-Directory%\Files\Utilites\ASX_DriverFinder" md "%ASX-Directory%\Files\Utilites\ASX_DriverFinder" >nul 2>&1
    curl -g -L -# -o "%ASX-Directory%\Files\Utilites\ASX_DriverFinder\DriverFinder.exe" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Utilities/ASX_DriverFinder/DriverFinder.exe" >nul 2>&1
    curl -g -L -# -o "%ASX-Directory%\Files\Utilites\ASX_DriverFinder\DriverFinder_FindService.exe" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Utilities/ASX_DriverFinder/DriverFinder_FindService.exe" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] %TIME% - Ошибка при загрузке компонента DriverFinder.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
        set /a "error_on_loading_1+=1"
        )
)
goto GoBack

:ASX_Information_About
cls
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":ASX_Information_About" >> "%ASX-Directory%\Files\Logs\%date%.txt"
TITLE Об ASX Hub - ASX Hub
set PageName=ASX_Information_About
set choice=NoInput
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########%COL%[37m
echo.
echo.
echo.
echo.
echo               %COL%[36mГлавное об ASX Hub
echo               %COL%[97m------------------%COL%[37m
echo               Разработчик: %COL%[36mALFiX Inc.%COL%[37m
echo.
echo               Описание: %COL%[36mASX Hub — это инструмент с открытым исходным кодом, созданный для оптимизации и автоматизации процесса
echo                         настройки вашего компьютера. Он упрощает установку и конфигурацию необходимых программ, повышая общую
echo                         производительность системы. %COL%[37m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
set /p choice="%DEL%                                                                      >: "
if /i "%choice%"=="C" ( set "history=ASX_Information_About;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=ASX_Information_About;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=ASX_Information_About;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=ASX_Information_About;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="P" ( set "history=ASX_Information_About;!history!" && goto PatchNotesOpen )
if /i "%choice%"=="з" ( set "history=ASX_Information_About;!history!" && goto PatchNotesOpen )
if /i "%choice%"=="NoInput" goto WrongInput
call:WrongInput
goto ASX_Information_About


:ASX_Information_UpdateCheck
cls
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":ASX_Information_UpdateCheck" >> "%ASX-Directory%\Files\Logs\%date%.txt"
TITLE Информация - ASX Hub
set PageName=ASX_Information_UpdateCheck
set choice=NoInput
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: ::::::::: 
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+  
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+  
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+  
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#  
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########%COL%[37m    

TITLE Проверка обновлений
echo [INFO ] %TIME% - Проверка обновлений >> "%ASX-Directory%\Files\Logs\%date%.txt"
set ErrorServerUpdate=No

:: Установка имени файла проверки версии
set "FileVerCheckName=ASX_Version"

:: Загрузка нового файла Updater.bat
if exist "%TEMP%\Updater.bat" del /s /q /f "%TEMP%\Updater.bat" >nul 2>&1
curl -s -o "%TEMP%\Updater.bat" "https://raw.githubusercontent.com/ALFiX01/ASX-Hub/main/Files/ASX/%FileVerCheckName%" 
if errorlevel 1 (
    echo [ERROR] %TIME% - Ошибка связи с сервером проверки обновлений >> "%ASX-Directory%\Files\Logs\%date%.txt"
    set ErrorServerUpdate=Yes
)

:: Выполнение загруженного файла Updater.bat
call "%TEMP%\Updater.bat" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] %TIME% - Ошибка при выполнении Updater.bat >> "%ASX-Directory%\Files\Logs\%date%.txt"
)



echo.
echo.
echo.
echo               %COL%[36mТекущая Версия
echo               %COL%[97m--------------%COL%[37m
echo               Версия: %COL%[36m%FullVersionNameCurrent% %COL%[37m
echo.
echo               Номер сборки: %COL%[36m%VersionNumberCurrent%%COL%[37m
echo.
echo               Дата выпуска: %COL%[36m%DateUpdate%%COL%[37m
echo.
echo               Тип выпуска: %COL%[36m%BranchCurrentVersion%%COL%[37m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.


TITLE Информация - ASX Hub
:: Проверка, изменилась ли версия
if "%ErrorServerUpdate%"=="Yes" (
    echo                                                 %COL%[90m^[ Ошибка связи с сервером проверки обновлений ^]%COL%[90m
    echo [ERROR] %TIME% - Ошибка при проверке обновлений >> "%ASX-Directory%\Files\Logs\%date%.txt"
) else (
    echo "%VersionNumberList%" | findstr /i "%VersionNumberCurrent%" >nul
    if errorlevel 1 (
        echo [INFO ] %TIME% - Доступно обновление v%UPDVER% >> "%ASX-Directory%\Files\Logs\%date%.txt"
        echo %FullVersionName% | findstr /i "beta" >nul
        if errorlevel 1 (
            echo                                                 %COL%[92m^[ U - Загрузить и установить более новую версию ^]%COL%[90m
        ) else (
            echo                                                 %COL%[92m^[ U - Загрузить и установить более новую версию ^]%COL%[90m
        )
    ) else (
        echo                                                   %COL%[90m^[ У вас установлена актуальная версия ASX Hub ^]%COL%[90m
    )
)

echo.
echo.
echo                                     %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m       %COL%[36m[ P - Описание обновления ]%COL%[90m
echo.
echo.
%SYSTEMROOT%\System32\choice.exe /c:UгPзCсXчBи /n /m "%DEL%                                                                      >: " 
set choice=%errorlevel%
if "%choice%"=="1" ( set "history=ASX_Information_UpdateCheck;!history!" && goto Update_screen )
if "%choice%"=="2" ( set "history=ASX_Information_UpdateCheck;!history!" && goto Update_screen )

if "%choice%"=="3" ( set "history=ASX_Information_UpdateCheck;!history!" && goto PatchNotesOpen )
if "%choice%"=="4" ( set "history=ASX_Information_UpdateCheck;!history!" && goto PatchNotesOpen )

if "%choice%"=="5" ( set "history=ASX_Information_UpdateCheck;!history!" && goto ASX_CMD )
if "%choice%"=="6" ( set "history=ASX_Information_UpdateCheck;!history!" && goto ASX_CMD )
if "%choice%"=="7" ( set "history=ASX_Information_UpdateCheck;!history!" && goto MainMenu )
if "%choice%"=="8" ( set "history=ASX_Information_UpdateCheck;!history!" && goto MainMenu )
if "%choice%"=="9" goto GoBack
if "%choice%"=="10" goto GoBack
goto ASX_Information_UpdateCheck

:ASX_settings
cls
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":ASX_settings" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=ASX_settings
set choice=NoInput
REM Проверка значений

for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "AutoControlDirectory" 2^>nul ^| find /i "AutoControlDirectory"') do set "AutoControlDirectory=%%b"
if "%AutoControlDirectory%"=="On" ( set "AutoControlDirectory=%COL%[92mВКЛ " ) else ( set "AutoControlDirectory=%COL%[91mВЫКЛ" )

for %%i in (AutoUpdateCheck ) do (set "%%i=%COL%[91mВЫКЛ") >nul 2>&1
reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "SkipUpdate"  >nul 2>&1 || set "AutoUpdateCheck=%COL%[92mВКЛ " >nul 2>&1

for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CheckUpdateOnWinStartUp" 2^>nul ^| find /i "CheckUpdateOnWinStartUp"') do set "CheckUpdateOnWinStartUp=%%b"

if "%CheckUpdateOnWinStartUp%"=="On" ( set "CheckUpdateOnWinStartUp_st=%COL%[92mВКЛ " ) else ( set "CheckUpdateOnWinStartUp_st=%COL%[91mВЫКЛ" )

TITLE Настройки - ASX Hub

echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: ::::::::: 
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+: 
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########%COL%[37m
echo.
echo.
echo.
echo.
echo.
echo                                                       %COL%[36mФункции:
echo                                                       %COL%[37m--------
echo                                                       %COL%[36m[ %COL%[37m1  %COL%[36m] %COL%[90m[ %AutoUpdateCheck% %COL%[90m] %COL%[37mАвто-проверка обновлений ASX
echo                                                       %COL%[36m[ %COL%[37m2  %COL%[36m] %COL%[90m[ %CheckUpdateOnWinStartUp_st% %COL%[90m] %COL%[37mАвто-обновление ASX при запуске ПК
echo                                                       %COL%[36m[ %COL%[37m3  %COL%[36m] %COL%[90m[ %AutoControlDirectory% %COL%[90m] %COL%[37mАвто-контроль директории ASX
echo.
echo.
echo.
echo                                                       %COL%[36mВозможности:
echo                                                       %COL%[37m------------
echo                                                       %COL%[36m[ %COL%[37m4  %COL%[36m] %COL%[37mПроверить дирректорию ASX
echo                                                       %COL%[36m[ %COL%[37m5  %COL%[36m] %COL%[37mПеренести ASX в другое место
echo                                                       %COL%[36m[ %COL%[37m6  %COL%[36m] %COL%[37mАктуализировать пути ярлыков
echo                                                       %COL%[36m[ %COL%[37m7  %COL%[36m] %COL%[37mУдалить ASX Hub
echo                                                       %COL%[36m[ %COL%[37m8  %COL%[36m] %COL%[37mИзменить Имя пользователя ASX
echo                                                       %COL%[36m[ %COL%[37m9  %COL%[36m] %COL%[37mДобавить ярлык ASX на рабочий стол
echo                                                       %COL%[36m[ %COL%[37m10 %COL%[36m] %COL%[37mОткрыть Центр восстановления ASX Revert
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.

set /p choice="%DEL%                                                                      >: " 

if /i "%choice%"=="1" ( set "history=ASX_settings;!history!" && call:AutoUpdateCheck )
if /i "%choice%"=="2" ( set "history=ASX_settings;!history!" && call:CheckUpdateOnWinStartUp_settings )
if /i "%choice%"=="3" ( set "history=ASX_settings;!history!" && call:AutoControlDirectory_config )
if /i "%choice%"=="4" ( set "history=ASX_settings;!history!" && call:Check_ASX_Directories )
if /i "%choice%"=="5" ( set "history=ASX_settings;!history!" && call:Transferring_ASX )
if /i "%choice%"=="6" ( set "history=ASX_settings;!history!" && call:UpdateShortcut )
if /i "%choice%"=="7" ( set "history=ASX_settings;!history!" && call:ASX_Uninstall )
if /i "%choice%"=="8" ( set "history=ASX_settings;!history!" && set "COLR1=%COL%[36m" && set "COLR2=%COL%[36m" && set "COLR3=%COL%[36m" && call:CustomUserName )
if /i "%choice%"=="9" ( set "history=ASX_settings;!history!" && call:CreateShortcutDesktop )
if /i "%choice%"=="10" ( set "history=ASX_settings;!history!" && goto RestoreHub )

if /i "%choice%"=="C" ( set "history=ASX_settings;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=ASX_settings;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=ASX_settings;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=ASX_settings;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="NoInput" goto WrongInput
call:WrongInput
goto ASX_settings

:AutoControlDirectory_config
if "%AutoControlDirectory%" == "%COL%[92mВКЛ " (
    echo [INFO ] %TIME% - Отключен Автоматический контроль директории ASX >> "%ASX-Directory%\Files\Logs\%date%.txt"	
	reg add "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Settings" /v "AutoControlDirectory" /t REG_SZ /d "Off" /f
    set "operation_name=Отключение автоматического контроля директории ASX"
) >nul 2>&1 else (
    echo [INFO ] %TIME% - Включен Автоматический контроль директории ASX >> "%ASX-Directory%\Files\Logs\%date%.txt"		
	reg add "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Settings" /v "AutoControlDirectory" /t REG_SZ /d "On" /f
    set "operation_name=Включение автоматического контроля директории ASX"
) >nul 2>&1
call:Complete_notice
goto GoBack

:AutoUpdateCheck
if "%AutoUpdateCheck%" == "%COL%[92mВКЛ " (
    echo [INFO ] %TIME% - Отключена автоматическая проверка обновлений ASX Hub >> "%ASX-Directory%\Files\Logs\%date%.txt"	
	reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "SkipUpdate" /f
    set "operation_name=Отключение авто обновлений ASX Hub"
) >nul 2>&1 else (
    echo [INFO ] %TIME% - Включена автоматическая проверка обновлений ASX Hub >> "%ASX-Directory%\Files\Logs\%date%.txt"		
	reg delete "HKCU\Software\ALFiX inc.\ASX\Settings" /v "SkipUpdate" /f
    set "operation_name=Включение авто обновлений ASX Hub"
) >nul 2>&1
call:Complete_notice
goto GoBack


:CheckUpdateOnWinStartUp_settings
if "%CheckUpdateOnWinStartUp_st%"=="%COL%[91mВЫКЛ" (
    curl -g -L -# -o "%ASX-Directory%\Files\ASX-Hub-Updater.exe" "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Updater/UpdateCheck_OnStartPC.exe" >nul 2>&1
    if errorlevel 0 (
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "ASX-Hub-Updater" /t REG_SZ /d "\"%ASX-Directory%\Files\ASX-Hub-Updater.exe\" --minimized" /f >nul 2>&1
        reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CheckUpdateOnWinStartUp" /t REG_SZ /d "On" /f >nul 2>&1
        set "operation_name=Включение авто обновления при запуске ПК"
    ) else (
        echo [ERROR] %TIME% - Ошибка при загрузке ASX-Hub-Updater.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)
if "%CheckUpdateOnWinStartUp_st%"=="%COL%[92mВКЛ " (
        reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "ASX-Hub-Updater" /f >nul 2>&1
        reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CheckUpdateOnWinStartUp" /t REG_SZ /d "Off" /f >nul 2>&1
        set "operation_name=Выключение авто обновления при запуске ПК"
)
call:Complete_notice
goto GoBack

:Check_ASX_Directories
echo [INFO ] %TIME% - Запущена проверка директории ASX >> "%ASX-Directory%\Files\Logs\%date%.txt"
for %%d in (
    "%ASX-Directory%\Files\Downloads"
    "%ASX-Directory%\Files\Resources"
    "%ASX-Directory%\Files\Restore"
    "%ASX-Directory%\Files\Logs"
) do (
    if not exist "%%~d" (
        mkdir "%%~d"
        echo [INFO ] %TIME% - Создана директория: %%~d >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)
echo %COL%[92mУспешно - Директории ASX проверены и обновлены%COL%[37m
set "operation_name=Проверка и обновление директорий ASX Hub"
call:Complete_notice
goto GoBack

:CreateShortcutDesktop
echo [INFO ] %TIME% - Создание ярлыка запуска ASX Hub на рабочем столе >> "%ASX-Directory%\Files\Logs\%date%.txt"
chcp 850 >nul 2>&1
powershell -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Desktop') + '\ASX Hub.lnk'); $s.TargetPath = '%ASX-Directory%\ASX Hub.exe'; $s.Save()"
if %errorlevel% equ 0 (
    echo [INFO ] %TIME% - Ярлык успешно создан на рабочем столе >> "%ASX-Directory%\Files\Logs\%date%.txt"
) else (
    echo [ERROR] %TIME% - Ошибка при создании ярлыка на рабочем столе >> "%ASX-Directory%\Files\Logs\%date%.txt"
)
chcp 65001 >nul 2>&1
set "operation_name=Создание ярлыка запуска ASX Hub на рабочем столе"
call:Complete_notice
goto GoBack

:UpdateShortcut
REM Актуализация ярлыков
chcp 850 >nul 2>&1
powershell -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%SystemDrive%\Windows\ASX Hub.lnk'); $s.TargetPath = '%ASX-Directory%\ASX Hub.exe'; $s.WorkingDirectory = '%ASX-Directory%'; $s.Save()"
powershell -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%SystemDrive%\Windows\ASX.lnk'); $s.TargetPath = '%ASX-Directory%\ASX Hub.exe'; $s.WorkingDirectory = '%ASX-Directory%'; $s.Save()"
powershell -Command "$s = (New-Object -ComObject WScript.Shell).CreateShortcut('%SystemDrive%\Windows\ASX-dir.lnk'); $s.TargetPath = '%ASX-Directory%'; $s.WorkingDirectory = '%ASX-Directory%'; $s.Save()"
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Произведена актуализация ярлыков >> "%ASX-Directory%\Files\Logs\%date%.txt"
set "operation_name=Актуализация ярлыков"
call:Complete_notice
goto GoBack

:Transferring_ASX
echo [INFO ] %TIME% - Открыта панель ":Transferring_ASX" >> "%ASX-Directory%\Files\Logs\%date%.txt"
:: Проверка наличия ключа CheckUpdateOnWinStartUp в реестре
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CheckUpdateOnWinStartUp" 2^>nul ^| find /i "CheckUpdateOnWinStartUp"') do set "CheckUpdateOnWinStartUp=%%b"

if not defined CheckUpdateOnWinStartUp (
    reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CheckUpdateOnWinStartUp" /t REG_SZ /d "On" /f >nul 2>&1
    set "CheckUpdateOnWinStartUp=On"
)
REM Перенос директории ASX
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" 2^>nul ^| find /i "Directory"') do set "ASX-Directory=%%b"
cls
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: ::::::::: 
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+: 
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+  
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+    
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+    
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#     
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
echo.
echo.
echo   %COL%[37mВведите новый путь для директории "ASX Hub".
echo   %COL%[90mСейчас директория находится в %ASX-Directory:~0,-4% %COL%[37m
echo.
echo   Пример: %COL%[96m%Systemdrive%\ProgramData %COL%[37m — если полный путь выглядит как %COL%[96m%Systemdrive%\ProgramData\ASX%COL%[37m.
echo   Чтобы указать только диск для размещения ASX Hub, введите %COL%[96mC:%COL%[37m.
echo   После переноса ASX Hub будет перезапущен автоматически.
echo.
echo.

set "suggestion_count=0"


REM Добавление системного диска, если папка ASX1 не существует
if not exist "%Systemdrive%\ASX" (
    if exist "%Systemdrive%\" (
        set /a "suggestion_count+=1"
        set "suggestion_!suggestion_count!=%Systemdrive%\ASX"
    )
)

REM Проверка доступного места на всех дисках от C до Z
for %%D in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist "%%D:\" (
        for /f "tokens=3" %%S in ('dir %%D: ^| find "bytes free"') do (
            REM Преобразование свободного места в гигабайты
            set /a "free_space=%%S / 1073741824"
            REM Проверка, что свободного места больше или равно 5 ГБ
            if !free_space! geq 5 (
                REM Проверка наличия Program Files на диске
                if exist "%%D:\Program Files" (
                    set /a "suggestion_count+=1"
                    set "suggestion_!suggestion_count!=%%D:\Program Files"
                )
            )
        ) >nul 2>&1
    )
)


REM Проверка и добавление пути AppData\Local
if exist "%userprofile%\AppData\Local" (
    set /a "suggestion_count+=1"
    set "suggestion_!suggestion_count!=%userprofile%\AppData\Local"
)

REM Проверка и добавление пути ProgramData
if exist "%Systemdrive%\ProgramData" (
    set /a "suggestion_count+=1"
    set "suggestion_!suggestion_count!=%Systemdrive%\ProgramData"
)

REM Вывод списка предложений
echo   Рекомендуемые места для переноса ASX Hub:
for /l %%i in (1,1,%suggestion_count%) do (
    echo   %%i. %COL%[96m!suggestion_%%i!%COL%[37m
)

echo.
set /p choice="%DEL%   Нажмите для продолжения >: " 
set "DialogText=Введите путь к папке в которою будет перемещена папка ASX Hub"
call:DialogPatchbox

set c1=!folder:~0,-1!
set c2=!folder:~1,-1!

if /i "%c2%" equ ":" (
  REM Update registry and move directory for root drive
  reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" /t REG_SZ /d "%c1%\ASX" /f >nul 2>&1
  md %c1%\ASX Hub >nul 2>&1
  robocopy "%ASX-Directory%" "%c1%\ASX" /E /MOVE >nul 2>&1
  rd "%ASX-Directory%" >nul 2>&1

  REM Update ASX directory variable
  for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" 2^>nul ^| find /i "Directory"') do set "ASX-Directory=%%b"
  echo [INFO ] %TIME% - Директория ASX перемещена на диск %c1%\ASX >> "%ASX-Directory%\Files\Logs\%date%.txt"

  REM Update uninstall registry entries
  reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "DisplayIcon" /t REG_SZ /d "%c1%\ASX\ASX Hub.exe" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "UninstallString" /t REG_SZ /d "%c1%\ASX\Uninst.exe" /f >nul 2>&1

  REM Setup auto-update if enabled
  if "%CheckUpdateOnWinStartUp%"=="On" (
      if not exist "%ASX-Directory%\Files\ASX-Hub-Updater.exe" (
          reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "ASX-Hub-Updater" /t REG_SZ /d "\"%c1%\ASX\Files\ASX-Hub-Updater.exe\"" /f >nul 2>&1
      )
  )

  start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'"
  exit
) else (
  REM Update registry and move directory for non-root path
  reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" /t REG_SZ /d "!folder!\ASX" /f >nul 2>&1
  robocopy "%ASX-Directory%" "!folder!\ASX" /E /MOVE >nul 2>&1
  rd "%ASX-Directory%" >nul 2>&1

  REM Update ASX directory variable
  for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" 2^>nul ^| find /i "Directory"') do set "ASX-Directory=%%b"
  echo [INFO ] %TIME% - Директория ASX перемещена в !folder!\ASX >> "%ASX-Directory%\Files\Logs\%date%.txt"

  REM Update uninstall registry entries
  reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "DisplayIcon" /t REG_SZ /d "!folder!\ASX\ASX Hub.exe" /f >nul 2>&1
  reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ASX Hub" /v "UninstallString" /t REG_SZ /d "!folder!\ASX\Uninst.exe" /f >nul 2>&1

  REM Setup auto-update if enabled
  if "%CheckUpdateOnWinStartUp%"=="On" (
      if not exist "%ASX-Directory%\Files\ASX-Hub-Updater.exe" (
          reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "ASX-Hub-Updater" /t REG_SZ /d "\"!folder!\ASX\Files\ASX-Hub-Updater.exe\"" /f >nul 2>&1
      )
  )

  start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'"
  exit
)

set "operation_name=Перенос директории ASX Hub"
call:Complete_notice
goto GoBack

:SystemInformation
:: Установка кодировки UTF-8 и активация виртуального терминала
chcp 65001 >nul 2>&1
reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
:: Установка шрифта Consolas и размера
reg add HKCU\Console /v FaceName /t REG_SZ /d "Consolas" /f >nul 2>&1
reg add HKCU\Console /v FontSize /t REG_DWORD /d 0x100000 /f >nul 2>&1

:: Определение логотипов с цветами
set "logo1=  [48;5;202m          [m  [48;5;41m          [m"
set "logo2=  [48;5;32m          [m  [48;5;220m          [m"

cls
echo.
echo.
echo    %COL%[37mИдет анализ, пожалуйста подождите...  = [[1;31m 1/9 [m] %COL%[90m

echo.
:: Версия Windows
chcp 850 >nul 2>&1
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "$caption = (Get-CimInstance Win32_OperatingSystem).Caption; $cleanCaption = $caption -replace 'Microsoft|Майкрософт|Профессиональная|Enterprise|Home|Домашняя|Корпоративная', '' -replace '\s+', ' '; [System.IO.File]::WriteAllText('temp_os.txt', $cleanCaption.Trim(), [System.Text.Encoding]::UTF8)"
for /f "usebackq delims=" %%a in ("temp_os.txt") do set "version=%%a"
del "temp_os.txt" >nul 2>&1
set "version=%version:*Windows=Windows%"
for /f "usebackq delims=" %%a in (`%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Version"`) do set "kernel=%%a"
chcp 65001 >nul 2>&1
echo    Анализ ОС...  = [[1;31m 2/9 [m]%COL%[90m

:: Процессор
chcp 850 >nul 2>&1
for /f "usebackq delims=" %%a in (`%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "(((Get-CimInstance Win32_Processor).Name) -replace '\s+', ' ')"`) do set "cpu=%%a"
chcp 65001 >nul 2>&1
echo    Анализ ЦП...  = [[1;31m 3/9 [m]%COL%[90m

:: Видеокарта
chcp 850 >nul 2>&1
for /f "usebackq delims=" %%a in (`%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "(Get-CimInstance Win32_DisplayConfiguration).DeviceName"`) do set "gpu=%%a"
chcp 65001 >nul 2>&1
echo    Анализ ГП...  = [[1;31m 4/9 [m]%COL%[90m

:: Использованная память (ГБ)
chcp 850 >nul 2>&1
for /f "usebackq delims=" %%a in (`%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "$os = Get-CimInstance Win32_OperatingSystem; [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / 1MB, 2)"`) do set "usedMemGb=%%a"
chcp 65001 >nul 2>&1
echo    Анализ используемой ОЗУ...  = [[1;31m 5/9 [m]%COL%[90m

:: Общая память (ГБ)
chcp 850 >nul 2>&1
for /f "usebackq delims=" %%a in (`%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "[math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB, 2)"`) do set "totalMemGb=%%a"
chcp 65001 >nul 2>&1
if not defined totalMemGb set "totalMemGb=Не удалось определить"
echo    Анализ общей ОЗУ...  = [[1;31m 6/9 [m]%COL%[90m

:: Материнская плата
chcp 850 >nul 2>&1
%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "$mobo = Get-CimInstance Win32_BaseBoard; $moboMan = if ($mobo.Manufacturer) {$mobo.Manufacturer} else {'Неизвестно'}; $moboProd = if ($mobo.Product) {$mobo.Product} else {'Неизвестно'}; [System.IO.File]::WriteAllText('temp_mobo.txt', \"$moboMan $moboProd\", [System.Text.Encoding]::UTF8)"
for /f "usebackq delims=" %%a in ("temp_mobo.txt") do set "mobo=%%a"
del "temp_mobo.txt" >nul 2>&1
:: Убираем мусор из начала строки
set "mobo=%mobo:*Gigabyte=Gigabyte%"
set "mobo=%mobo:*ASUS=ASUS%"
set "mobo=%mobo:*MSI=MSI%"
set "mobo=%mobo:*ASRock=ASRock%"
set "mobo=%mobo:*Неизвестно=Неизвестно%"
chcp 65001 >nul 2>&1
echo    Загрузка, пожалуйста подождите...  = [[1;31m 7/9 [m]%COL%[90m

:: Имя пользователя и хоста
chcp 850 >nul 2>&1
for /f "usebackq delims=" %%a in (`%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "[System.Net.Dns]::GetHostName()"`) do set "userinfo=%%a"
for /f "usebackq delims=" %%a in (`%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "$env:USERNAME"`) do set "username=%%a"
chcp 65001 >nul 2>&1
echo    Загрузка, пожалуйста подождите...  = [[1;31m 8/9 [m]%COL%[90m

:: Экран
chcp 850 >nul 2>&1
for /f "usebackq delims=" %%a in (`%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "(Get-WmiObject -Class Win32_VideoController).CurrentRefreshRate"`) do set "hz=%%a"
for /f "usebackq delims=" %%a in (`%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "(Get-WmiObject -Class Win32_VideoController).CurrentHorizontalResolution"`) do set "hozrs=%%a"
for /f "usebackq delims=" %%a in (`%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -Command "(Get-WmiObject -Class Win32_VideoController).CurrentVerticalResolution"`) do set "verrs=%%a"
chcp 65001 >nul 2>&1
echo    Загрузка, пожалуйста подождите...  = [[1;31m 9/9 [m]

:: Время последней загрузки
for /f %%a in ('WMIC OS GET lastbootuptime ^| find "."') do set "DTS=%%a"
set "boot=!DTS:~0,4!-!DTS:~4,2!-!DTS:~6,2!  !DTS:~8,2!:!DTS:~10,2!"

:: Вывод информации
cls
echo.
echo     ASX Hub -[1;36m Основная информация о системе [m
echo    ---------------------------------------------
echo.
echo %logo1%      [1;34m%username%[m@[1;34m%userinfo%[m
echo %logo1%      ---------------------
echo %logo1%      [1;34mОС[m: %version% 64-бит
echo %logo1%      [1;34mЯдро[m: %kernel%
echo %logo1%      [1;34mПроцессор[m: %cpu%
echo %logo1%      [1;34mМатеринская плата[m: %mobo%
echo.
echo %logo2%      [1;34mВидеокарта[m: %gpu%
echo %logo2%      [1;34mРазрешение[m: %hozrs% x %verrs% (%hz% Hz)
echo %logo2%      [1;34mВремя запуска[m: %boot%
echo %logo2%      [1;34mОЗУ[m: %usedMemGb% / %totalMemGb% (ГБ)
echo %logo2%
echo %logo2%      Нажмите любую клавишу для возврата в меню . . .
pause >nul
reg add "HKEY_CURRENT_USER\Console" /v "FaceName" /t REG_SZ /d "__DefaultTTFont__" /f >nul 2>&1
goto GoBack

:ASX_PC_PowerCheck
if not exist "%ASX-Directory%\Files\Utilites\ASX_PC_PowerCheck" (
    mkdir "%ASX-Directory%\Files\Utilites\ASX_PC_PowerCheck" 2>nul
    if errorlevel 1 (
        echo [ERROR] %TIME% - Не удалось создать директорию ASX_PC_PowerCheck >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

if not exist "%ASX-Directory%\Files\Utilites\ASX_PC_PowerCheck\ASX_PC_PowerCheck.exe" (
    echo [INFO ] %TIME% - Загрузка ASX_PC_PowerCheck.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
    curl -g -L -# -o "%ASX-Directory%\Files\Utilites\ASX_PC_PowerCheck\ASX_PC_PowerCheck.exe" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Utilities/ASX_PC_PowerCheck/ASX_PC_PowerCheck.exe" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] %TIME% - Ошибка при загрузке ASX_PC_PowerCheck.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
        echo Не удалось загрузить утилиту. Проверьте подключение к интернету и попробуйте снова.
        timeout /t 3 >nul
        goto GoBack
    )
)

if exist "%ASX-Directory%\Files\Utilites\ASX_PC_PowerCheck\ASX_PC_PowerCheck.exe" (
    echo [INFO ] %TIME% - Запуск ASX_PC_PowerCheck.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
    start "" "%ASX-Directory%\Files\Utilites\ASX_PC_PowerCheck\ASX_PC_PowerCheck.exe"
) else (
    echo [ERROR] %TIME% - Файл ASX_PC_PowerCheck.exe не найден >> "%ASX-Directory%\Files\Logs\%date%.txt"
    echo Файл утилиты не найден. Попробуйте перезапустить ASX Hub.
    timeout /t 3 >nul
)
goto GoBack

:RestoreHub
cls
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":RestoreHub" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=RestoreHub
set choice=NoInput
TITLE Центр восстановления - ASX Hub

REM Получение даты резервной копии
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Data\Dynamic" /v "BackupDate" 2^>nul ^| find /i "BackupDate"') do set "ASX-BackupDate=%%b"

echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: ::::::::: 
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+: 
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########%COL%[37m
echo.
echo.
echo.
echo.

echo                                                            %COL%[36mДоступные резервные копии:
echo                                                            %COL%[37m--------------------------

echo.
:: Константы
set "max_backups=4"
set "lines_per_backup=5"
set /a "max_total_lines=%max_backups% * %lines_per_backup%"

:: Подсчет количества резервных копий
set "backup_count=0"
if exist "%ASX-Directory%\Files\Restore" (
    for /f "tokens=*" %%d in ('dir /b /ad "%ASX-Directory%\Files\Restore" 2^>nul') do (
        set /a "backup_count+=1"
    )
) else (
    mkdir "%ASX-Directory%\Files\Restore" >nul 2>&1
    echo [INFO ] %TIME% - Создана директория для резервных копий >> "%ASX-Directory%\Files\Logs\%date%.txt"
)

:: Расчет общего количества строк для резервных копий
set /a "total_backup_lines=%backup_count% * %lines_per_backup%"

:: Расчет пустых строк для добавления
set /a "empty_lines=%max_total_lines% - %total_backup_lines%"
if %empty_lines% lss 0 set "empty_lines=0"

:: Отображение резервных копий в обратном порядке (новые сверху)
set "count=1"
if %backup_count% gtr 0 (
    for /f "tokens=*" %%d in ('dir /b /ad /o-d "%ASX-Directory%\Files\Restore" 2^>nul') do (
        if "!count!"=="1" (
            echo                                                             %COL%[36mASX Restore !count! %COL%[92m^[НОВАЯ^]%COL%[37m
        ) else (
            echo                                                             %COL%[36mASX Restore !count!%COL%[37m
        )
        echo                                                             └ %COL%[37m%%d
        echo                                                               └ %COL%[90mR!count! чтобы открыть%COL%[37m
        echo.
        echo.
        set /a "count+=1"
        if !count! gtr %max_backups% goto :end_backup_list
    )
) else (
    echo                                                            %COL%[90mРезервные копии не найдены
    echo                                                       %COL%[90mНажмите F для создания резервной копии%COL%[37m
    set /a "empty_lines-=2"
)

:end_backup_list

:: Добавление пустых строк для выравнивания интерфейса
if %empty_lines% gtr 0 (
    for /l %%i in (1,1,%empty_lines%) do (
        echo.
    )
)

:: Отображение меню опций
echo.
echo.
echo                                           %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m       %COL%[36m[ F - Создать ]%COL%[90m
echo.
set /p choice="%DEL%                                                                      >: " 

:: Обработка выбора резервной копии
set "count=1"
for /f "tokens=*" %%d in ('dir /b /ad /o-d "%ASX-Directory%\Files\Restore" 2^>nul') do (
    if /i "%choice%"=="R!count!" (
        start "" "%ASX-Directory%\Files\Restore\%%d"
        goto RestoreHub
    )
    set /a "count+=1"
    if !count! gtr %max_backups% goto :end_restore_processing
)
:end_restore_processing

:: Обработка других команд
if /i "%choice%"=="C" ( set "history=RestoreHub;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=RestoreHub;!history!" && goto ASX_CMD )
if /i "%choice%"=="F" ( set "history=RestoreHub;!history!" && goto RestoreCreate )
if /i "%choice%"=="а" ( set "history=RestoreHub;!history!" && goto RestoreCreate )
if /i "%choice%"=="X" ( set "history=RestoreHub;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=RestoreHub;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
goto RestoreHub

:ContextMenu-checker
echo [INFO ] %TIME% - Вызван "ContextMenu-checker" >> "%ASX-Directory%\Files\Logs\%date%.txt"

set "files="
REM Check Values
for %%i in ( ContMenuOwner ContMenuNotepad ContMenuExplorer ScanWithWindowsDefender OldContMenuWindows ContMenuCopytoFolder RunWithPriority  DeleteAllAppsFromStartMenu EmptyRecycleBin DeleteFolderContents SettingsCME WindowsTools EditInNotepad ) do (set "%%i=%COL%[92mВКЛ ") >nul 2>&1
for %%i in ( UnnecessaryItems ) do (set "%%i=%COL%[91mВЫКЛ") >nul 2>&1

REM for %%i in (%files%) do (
REM     if not exist "%ASX-Directory%\Files\Resources\Context Menu Editor\%%i" (
REM 		set typeS=1
REM         echo Загрузка Файла "%%i"
REM         curl -g -L -# -o "%ASX-Directory%\Files\Resources\Context Menu Editor\%%i" "https://raw.githubusercontent.com/ALFiX01/ASX-Hub/main/Files/Resources/ContextMenuEditor/%%i" >nul 2>&1
REM 
REM     )
REM )


reg query "%SaveData%\ParameterFunction" /v "UnnecessaryItems" >nul 2>&1 && set "UnnecessaryItems=%COL%[92mВКЛ " >nul 2>&1
reg query "%SaveData%\ParameterFunction" /v "ContextMenuOwner" >nul 2>&1 || set "ContMenuOwner=%COL%[91mВЫКЛ" >nul 2>&1
reg query "%SaveData%\ParameterFunction" /v "ContextMenuNotepad" >nul 2>&1 || set "ContMenuNotepad=%COL%[91mВЫКЛ" >nul 2>&1
reg query "%SaveData%\ParameterFunction" /v "ContextMenuExplorer" >nul 2>&1 || set "ContMenuExplorer=%COL%[91mВЫКЛ" >nul 2>&1
reg query "%SaveData%\ParameterFunction" /v "ScanWithWindowsDefender" >nul 2>&1 || set "ScanWithWindowsDefender=%COL%[91mВЫКЛ" >nul 2>&1
reg query "%SaveData%\ParameterFunction" /v "ContMenuCopytoFolder" >nul 2>&1 || set "ContMenuCopytoFolder=%COL%[91mВЫКЛ" >nul 2>&1

reg query "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" >nul 2>&1 && set "OldContMenuWindows=%COL%[91mВЫКЛ" >nul 2>&1
reg query "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" >nul 2>&1 && set "OldContMenuWindows=%COL%[92mВКЛ " >nul 2>&1

reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{CA6CC9F1-867A-481E-951E-A28C5E4F01EA}" >nul 2>&1 && set "EditInNotepad=%COL%[91mВЫКЛ" >nul 2>&1

reg query "%SaveData%\ParameterFunction" /v "RunWithPriority" >nul 2>&1 || set "RunWithPriority=%COL%[91mВЫКЛ" >nul 2>&1
reg query "%SaveData%\ParameterFunction" /v "DeleteAllAppsFromStartMenu" >nul 2>&1 || set "DeleteAllAppsFromStartMenu=%COL%[91mВЫКЛ" >nul 2>&1
reg query "%SaveData%\ParameterFunction" /v "EmptyRecycleBin" >nul 2>&1 || set "EmptyRecycleBin=%COL%[91mВЫКЛ" >nul 2>&1
reg query "%SaveData%\ParameterFunction" /v "DeleteFolderContents" >nul 2>&1 || set "DeleteFolderContents=%COL%[91mВЫКЛ" >nul 2>&1
reg query "%SaveData%\ParameterFunction" /v "SettingsCME" >nul 2>&1 || set "SettingsCME=%COL%[91mВЫКЛ" >nul 2>&1
reg query "%SaveData%\ParameterFunction" /v "WindowsTools" >nul 2>&1 || set "WindowsTools=%COL%[91mВЫКЛ" >nul 2>&1

reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v TaskbarEndTask | find "0x1" >nul 2>&1
if %errorlevel% == 0 (
    set "EndTask=%COL%[92mВКЛ " >nul 2>&1
) else (
    set "EndTask=%COL%[91mВЫКЛ" >nul 2>&1
)

goto :eof

:EditContextMenu
call :ContextMenu-checker
cls
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":EditContextMenu" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=EditContextMenu
set choice=NoInput
TITLE Редактор контекстного меню - ASX Hub
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo          %COL%[36mДОБАВЛЕНИЕ НОВЫХ ПУНКТОВ
echo          %COL%[97m------------------------
echo          %COL%[90mДля файлов:%COL%[37m
echo           1 %COL%[36m[%COL%[37m %ContMenuOwner% %COL%[36m]%COL%[37m Пункт "Сменить владельца"
echo           2 %COL%[36m[%COL%[37m %ContMenuNotepad% %COL%[36m]%COL%[37m Пункт "Открыть через БЛОКНОТ"
echo           3 %COL%[36m[%COL%[37m %ContMenuExplorer% %COL%[36m]%COL%[37m Пункт "Перезапустить ПРОВОДНИК"
echo           4 %COL%[36m[%COL%[37m %ContMenuCopytoFolder% %COL%[36m]%COL%[37m Пункт "Копировать в папку..."
echo           5 %COL%[36m[%COL%[37m %RunWithPriority% %COL%[36m]%COL%[37m Пункт "Запустить с приоритетом"
echo           6 %COL%[36m[%COL%[37m %DeleteFolderContents% %COL%[36m]%COL%[37m Пункт "Удалить содержимое папки"
echo           7 %COL%[36m[%COL%[37m %EditInNotepad% %COL%[36m]%COL%[37m Пункт "Изменить в Блокноте"
echo.
echo          %COL%[90mДля рабочего стола:%COL%[37m
echo           8 %COL%[36m[%COL%[37m %EmptyRecycleBin% %COL%[36m]%COL%[37m Пункт "Очистить корзину"
echo           9 %COL%[36m[%COL%[37m %SettingsCME% %COL%[36m]%COL%[37m Пункт "Настройки"
echo          10 %COL%[36m[%COL%[37m %WindowsTools% %COL%[36m]%COL%[37m Пункт "Инструменты Windows"
echo.
echo          %COL%[90mДля панели задач:%COL%[37m
echo          11 %COL%[36m[%COL%[37m %EndTask% %COL%[36m]%COL%[37m Пункт "Завершить задачу"
echo.
echo.
echo.
echo.
echo          %COL%[36mУДАЛЕНИЕ СТАРЫХ ПУНКТОВ
echo          %COL%[97m-----------------------
echo          11 %COL%[36m[%COL%[37m %UnnecessaryItems% %COL%[36m]%COL%[37m Удалить ненужные пункты из контекстного меню
echo          12 %COL%[36m[%COL%[37m %ScanWithWindowsDefender% %COL%[36m]%COL%[37m Удалить пункт "проверка с использованием Win Defender"
echo          13 %COL%[36m[%COL%[37m %DeleteAllAppsFromStartMenu% %COL%[36m]%COL%[37m Удалить все программы из меню пуск
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
set /p choice="%DEL%                                                                      >: "
if /i "%choice%"=="1" ( set "history=EditContextMenu;!history!" && call:Owner )
if /i "%choice%"=="2" ( set "history=EditContextMenu;!history!" && call:Notepad )
if /i "%choice%"=="3" ( set "history=EditContextMenu;!history!" && call:Explorer )
if /i "%choice%"=="4" ( set "history=EditContextMenu;!history!" && call:CopytoFolder )
if /i "%choice%"=="5" ( set "history=EditContextMenu;!history!" && call:RunWithPriority )
if /i "%choice%"=="6" ( set "history=EditContextMenu;!history!" && call:DeleteFolderContents )
if /i "%choice%"=="7" ( set "history=EditContextMenu;!history!" && call:EditInNotepad )
if /i "%choice%"=="8" ( set "history=EditContextMenu;!history!" && call:EmptyRecycleBin )
if /i "%choice%"=="9" ( set "history=EditContextMenu;!history!" && call:SettingsCME )
if /i "%choice%"=="10" ( set "history=EditContextMenu;!history!" && call:WindowsTools )
if /i "%choice%"=="11" ( set "history=EditContextMenu;!history!" && call:EndTask )

if /i "%choice%"=="12" ( set "history=EditContextMenu;!history!" && call:RemoveUnnecessaryItems )
if /i "%choice%"=="13" ( set "history=EditContextMenu;!history!" && call:ScanWithWindowsDefender )
if /i "%choice%"=="14" ( set "history=EditContextMenu;!history!" && call:DeleteAllAppsFromStartMenu )

if /i "%choice%"=="C" ( set "history=EditContextMenu;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=EditContextMenu;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=EditContextMenu;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=EditContextMenu;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="R" ( set "history=EditContextMenu;!history!" && goto EditContextMenu )
if /i "%choice%"=="к" ( set "history=EditContextMenu;!history!" && goto EditContextMenu )
if /i "%choice%"=="NoInput" goto WrongInput
call:WrongInput
goto EditContextMenu

:RemoveUnnecessaryItems
if "%ContMenuOwner%" == "%COL%[91mВЫКЛ" (
    echo [INFO ] %TIME% - Редактирование контекстного меню +UnnecessaryItems >> "%ASX-Directory%\Files\Logs\%date%.txt"	
    reg add "%SaveData%\ParameterFunction" /v "UnnecessaryItems" /f >nul 2>&1
    REM Пункт "Предоставить доступ к"
    reg delete "HKCR\*\shellex\ContextMenuHandlers\Sharing" /f >nul 2>&1
    reg delete "HKCR\Directory\shellex\ContextMenuHandlers\Sharing" /f >nul 2>&1
    reg delete "HKCR\Directory\Background\shellex\ContextMenuHandlers\Sharing" /f >nul 2>&1
    reg delete "HKCR\Drive\shellex\ContextMenuHandlers\Sharing" /f >nul 2>&1
    REM Пункт "Добавить в избранное" 
    reg delete "HKCR\*\shell\pintohomefile" /f >nul 2>&1
    REM Пункт "Отправить" 
    reg delete "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\Send To" /f >nul 2>&1
    REM Пункт "Исправление проблем с совместимостью" 
    reg delete "HKCR\exefile\shellex\ContextMenuHandlers\Compatibility" /f >nul 2>&1
    reg delete "HKCR\mscfile\shellex\ContextMenuHandlers\Compatibility" /f >nul 2>&1
    reg delete "HKCR\batfile\shellex\ContextMenuHandlers\Compatibility" /f >nul 2>&1
    reg delete "HKCR\cmdfile\shellex\ContextMenuHandlers\Compatibility" /f >nul 2>&1
    reg delete "HKCR\comfile\shellex\ContextMenuHandlers\Compatibility" /f >nul 2>&1
    reg delete "HKCR\piffile\shellex\ContextMenuHandlers\Compatibility" /f >nul 2>&1
    set "operation_name=Удаление ненужных пунктов из контекстного меню"
) >nul 2>&1 else (
    echo [INFO ] %TIME% - Редактирование контекстного меню -UnnecessaryItems >> "%ASX-Directory%\Files\Logs\%date%.txt"		
    reg delete "%SaveData%\ParameterFunction" /v "UnnecessaryItems" /f >nul 2>&1
    REM Пункт "Предоставить доступ к"
    reg add "HKCR\*\shellex\ContextMenuHandlers\Sharing" /ve /d "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}" /f >nul 2>&1
    reg add "HKCR\Directory\shellex\ContextMenuHandlers\Sharing" /ve /d "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}" /f >nul 2>&1
    reg add "HKCR\Directory\Background\shellex\ContextMenuHandlers\Sharing" /ve /d "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}" /f >nul 2>&1
    reg add "HKCR\Drive\shellex\ContextMenuHandlers\Sharing" /ve /d "{f81e9010-6ea4-11ce-a7ff-00aa003ca9f6}" /f >nul 2>&1
    REM Пункт "Добавить в избранное" 
    reg add "HKCR\*\shell\pintohomefile" /ve /d "Add to favorites" /f >nul 2>&1
    reg add "HKCR\*\shell\pintohomefile" /v "Icon" /d "%SystemRoot%\System32\imageres.dll,-115" /f >nul 2>&1
    reg add "HKCR\*\shell\pintohomefile\command" /ve /d "explorer.exe shell:::{679f85cb-0220-4080-b29b-5540cc05aab6} -pinitem \"%1\"" /f >nul 2>&1
    REM Пункт "Отправить" 
    reg add "HKEY_CLASSES_ROOT\AllFilesystemObjects\shellex\ContextMenuHandlers\Send To" /ve /t REG_SZ /d "{7BA4C740-9E81-11CF-99D3-00AA004AE837}" /f >nul 2>&1
    REM Пункт "Исправление проблем с совместимостью" 
    reg add "HKCR\exefile\shellex\ContextMenuHandlers\Compatibility" /ve /d "{1d27f844-3a1f-4410-85ac-14651078412d}" /f >nul 2>&1
    reg add "HKCR\mscfile\shellex\ContextMenuHandlers\Compatibility" /ve /d "{1d27f844-3a1f-4410-85ac-14651078412d}" /f >nul 2>&1
    reg add "HKCR\batfile\shellex\ContextMenuHandlers\Compatibility" /ve /d "{1d27f844-3a1f-4410-85ac-14651078412d}" /f >nul 2>&1
    reg add "HKCR\cmdfile\shellex\ContextMenuHandlers\Compatibility" /ve /d "{1d27f844-3a1f-4410-85ac-14651078412d}" /f >nul 2>&1
    reg add "HKCR\comfile\shellex\ContextMenuHandlers\Compatibility" /ve /d "{1d27f844-3a1f-4410-85ac-14651078412d}" /f >nul 2>&1
    reg add "HKCR\piffile\shellex\ContextMenuHandlers\Compatibility" /ve /d "{1d27f844-3a1f-4410-85ac-14651078412d}" /f >nul 2>&1
    set "operation_name=Возвращение ненужных пунктов из контекстного меню"
) >nul 2>&1
call:Complete_notice
goto GoBack

:Owner
if "%ContMenuOwner%" == "%COL%[91mВЫКЛ" (
echo [INFO ] %TIME% - Редактирование контекстного меню +ContextMenuOwner >> "%ASX-Directory%\Files\Logs\%date%.txt"	
	reg add "%SaveData%\ParameterFunction" /v "ContextMenuOwner" /f >nul 2>&1
    REM ; For files
	reg add "HKCR\*\shell\ChangeOwner" /v "MUIVerb" /t REG_SZ /d "Сменить владельца" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner" /v "Icon" /t REG_SZ /d "imageres.dll,-88" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner" /v "SubCommands" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\01Owner" /ve /t REG_SZ /d "Текущий владелец" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\01Owner" /v "Icon" /t REG_SZ /d "imageres.dll,-1029" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\01Owner\command" /ve /t REG_SZ /d "powershell -NoExit Get-ACL '%%1'| Format-List -Property Owner" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\02Owner" /ve /t REG_SZ /d "Сделать СЕБЯ новым владельцем" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\02Owner" /v "HasLUAShield" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\02Owner" /v "NeverDefault" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\02Owner" /v "CommandFlags" /t REG_DWORD /d "32" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\02Owner\command" /ve /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c takeown /f \\\"%%1\\\" && icacls \\\"%%1\\\" /grant *S-1-3-4:F /t /c /l' -Verb runAs\"" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\Administrators" /ve /t REG_SZ /d "Сделать АДМИНИСТРАТОРА новым владельцем" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\Administrators" /v "HasLUAShield" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\Administrators" /v "CommandFlags" /t REG_DWORD /d "32" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\Administrators\command" /ve /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c icacls \\\"%%1\\\" /setowner \"Administrators\" /t /c /l' -Verb runAs\"" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\Administrators\command" /v "IsolatedCommand" /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c icacls \\\"%%1\\\" /setowner \"Administrators\" /t /c /l' -Verb runAs\"" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\SYSTEM" /ve /t REG_SZ /d "Сделать СИСТЕМУ новым владельцем" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\SYSTEM" /v "HasLUAShield" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\SYSTEM\command" /ve /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c icacls \\\"%%1\\\" /setowner \"SYSTEM\" /t /c /l' -Verb runAs\"" /f >nul 2>&1
	reg add "HKCR\*\shell\ChangeOwner\shell\SYSTEM\command" /v "IsolatedCommand" /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c icacls \\\"%%1\\\" /setowner \"SYSTEM\" /t /c /l' -Verb runAs\"" /f >nul 2>&1
	REM ; For folders
	reg add "HKCR\Directory\shell\ChangeOwner" /v "MUIVerb" /t REG_SZ /d "Сметить владельца" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner" /v "AppliesTo" /t REG_SZ /d "NOT (System.ItemPathDisplay:=\"C:\Users\" OR System.ItemPathDisplay:=\"C:\ProgramData\" OR System.ItemPathDisplay:=\"C:\Windows\" OR System.ItemPathDisplay:=\"C:\Windows\System32\" OR System.ItemPathDisplay:=\"C:\Program Files\" OR System.ItemPathDisplay:=\"C:\Program Files (x86)\")" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner" /v "Icon" /t REG_SZ /d "imageres.dll,-88" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner" /v "NoWorkingDirectory" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner" /v "Position" /t REG_SZ /d "middle" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner" /v "SubCommands" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\01Owner" /ve /t REG_SZ /d "Текущий владелец" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\01Owner" /v "Icon" /t REG_SZ /d "imageres.dll,-1029" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\01Owner\command" /ve /t REG_SZ /d "powershell -NoExit Get-ACL '%%1'| Format-List -Property Owner" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\02Owner" /ve /t REG_SZ /d "Сделать СЕБЯ новым владельцем" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\02Owner" /v "HasLUAShield" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\02Owner" /v "CommandFlags" /t REG_DWORD /d "32" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\02Owner\command" /ve /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c takeown /f \\\"%%1\\\" /r /d y && icacls \\\"%%1\\\" /grant *S-1-3-4:F /t /c /l /q' -Verb runAs\"" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\02Owner\command" /v "IsolatedCommand" /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c takeown /f \\\"%%1\\\" /r /d y && icacls \\\"%%1\\\" /grant *S-1-3-4:F /t /c /l /q' -Verb runAs\"" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\Administrators" /ve /t REG_SZ /d "Сделать АДМИНИСТРАТОРА новым владельцем" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\Administrators" /v "HasLUAShield" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\Administrators" /v "CommandFlags" /t REG_DWORD /d "32" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\Administrators\command" /ve /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c icacls \\\"%%1\\\" /setowner \"Administrators\" /t /c /l' -Verb runAs\"" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\Administrators\command" /v "IsolatedCommand" /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c icacls \\\"%%1\\\" /setowner \"Administrators\" /t /c /l' -Verb runAs\"" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\SYSTEM" /ve /t REG_SZ /d "Сделать СИСТЕМУ новым владельцем" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\SYSTEM" /v "HasLUAShield" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\SYSTEM\command" /ve /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c icacls \\\"%%1\\\" /setowner \"SYSTEM\" /t /c /l' -Verb runAs\"" /f >nul 2>&1
	reg add "HKCR\Directory\shell\ChangeOwner\shell\SYSTEM\command" /v "IsolatedCommand" /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c icacls \\\"%%1\\\" /setowner \"SYSTEM\" /t /c /l' -Verb runAs\"" /f >nul 2>&1
	REM ; For drives
	reg add "HKCR\Drive\shell\ChangeOwner" /v "MUIVerb" /t REG_SZ /d "Сменить владельца" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner" /v "AppliesTo" /t REG_SZ /d "NOT (System.ItemPathDisplay:=\"C:\\\")" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner" /v "Icon" /t REG_SZ /d "imageres.dll,-88" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner" /v "NoWorkingDirectory" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner" /v "Position" /t REG_SZ /d "middle" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner" /v "SubCommands" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\01Owner" /ve /t REG_SZ /d "Текущий владелец" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\01Owner" /v "Icon" /t REG_SZ /d "imageres.dll,-1029" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\01Owner\command" /ve /t REG_SZ /d "powershell -NoExit Get-ACL '%%1'| Format-List -Property Owner" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runas" /ve /t REG_SZ /d "Сделать СЕБЯ новым владельцем" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runas" /v "HasLUAShield" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runas" /v "CommandFlags" /t REG_DWORD /d "32" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runas\command" /ve /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\\\" /r /d y && icacls \"%%1\\\" /grant *S-1-3-4:F /t /c" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runas\command" /v "IsolatedCommand" /t REG_SZ /d "cmd.exe /c takeown /f \"%%1\\\" /r /d y && icacls \"%%1\\\" /grant *S-1-3-4:F /t /c" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runasAdministrators" /ve /t REG_SZ /d "Сделать АДМИНИСТРАТОРА новым владельцем" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runasAdministrators" /v "HasLUAShield" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runasAdministrators" /v "CommandFlags" /t REG_DWORD /d "32" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runasAdministrators\command" /ve /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c icacls \"%%1\\\" /setowner \"Administrators\" /c' -Verb runAs\"" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runasAdministrators\command" /v "IsolatedCommand" /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c icacls \"%%1\\\" /setowner \"Administrators\" /c' -Verb runAs\"" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runasSYSTEM" /ve /t REG_SZ /d "Сделать СИСТЕМУ новым владельцем" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runasSYSTEM" /v "HasLUAShield" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runasSYSTEM\command" /ve /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c icacls \"%%1\\\" /setowner \"SYSTEM\" /c' -Verb runAs\"" /f >nul 2>&1
	reg add "HKCR\Drive\shell\ChangeOwner\shell\runasSYSTEM\command" /v "IsolatedCommand" /t REG_SZ /d "powershell -windowstyle hidden -command \"Start-Process cmd -ArgumentList '/c icacls \"%%1\\\" /setowner \"SYSTEM\" /c' -Verb runAs\"" /f >nul 2>&1

	set "operation_name=Добавление пункта в контекстное меню"
) >nul 2>&1 else (
echo [INFO ] %TIME% - Редактирование контекстного меню -ContextMenuOwner >> "%ASX-Directory%\Files\Logs\%date%.txt"
	reg delete "%SaveData%\ParameterFunction" /v "ContextMenuOwner" /f >nul 2>&1
    REM ; For files
    reg delete "HKCR\*\shell\ChangeOwner" /f >nul 2>&1
    REM ; For folders
    reg delete "HKCR\Directory\shell\ChangeOwner" /f >nul 2>&1
    REM ; For drives
    reg delete "HKCR\Drive\shell\ChangeOwner" /f >nul 2>&1
	set "operation_name=Удаление пункта из контекстного меню"
) >nul 2>&1
call:Complete_notice
goto GoBack

:Notepad
if "%ContMenuNotepad%" == "%COL%[91mВЫКЛ" (
    echo [INFO ] %TIME% - Редактирование контекстного меню +ContextMenuNotepad >> "%ASX-Directory%\Files\Logs\%date%.txt"
	reg add "%SaveData%\ParameterFunction" /v "ContextMenuNotepad" /f >nul 2>&1
    reg add "HKCR\*\shell\Open With Notepad" /v "MUIVerb" /t REG_SZ /d "Открыть через БЛОКНОТ" /f >nul 2>&1
    reg add "HKCR\*\shell\Open With Notepad\command" /ve /t REG_SZ /d "notepad.exe %%1" /f >nul 2>&1
	set "operation_name=Добавление пункта в контекстное меню"
) >nul 2>&1 else (
    echo [INFO ] %TIME% - Редактирование контекстного меню -ContextMenuNotepad >> "%ASX-Directory%\Files\Logs\%date%.txt"
	reg delete "%SaveData%\ParameterFunction" /v "ContextMenuNotepad" /f >nul 2>&1
    reg delete "HKCR\*\shell\Open with Notepad" /f >nul 2>&1
	set "operation_name=Удаление пункта из контекстного меню"
) >nul 2>&1
call:Complete_notice
goto GoBack

:Explorer
if "%ContMenuExplorer%" == "%COL%[91mВЫКЛ" (
echo [INFO ] %TIME% - Редактирование контекстного меню +добавлено ContextMenuExplorer >> "%ASX-Directory%\Files\Logs\%date%.txt"			
	reg add "%SaveData%\ParameterFunction" /v "ContextMenuExplorer" /f >nul 2>&1
    reg add "HKCR\DesktopBackground\Shell\Restart Explorer" /v "MUIVerb" /t REG_SZ /d "Перезапустить ПРОВОДНИК" /f >nul 2>&1
    reg add "HKCR\DesktopBackground\Shell\Restart Explorer" /v "icon" /t REG_SZ /d "explorer.exe" /f >nul 2>&1
    reg add "HKCR\DesktopBackground\Shell\Restart Explorer" /v "Position" /t REG_SZ /d "Bottom" /f >nul 2>&1
    reg add "HKCR\DesktopBackground\Shell\Restart Explorer" /v "SubCommands" /t REG_SZ /d "" /f >nul 2>&1
    reg add "HKCR\DesktopBackground\Shell\Restart Explorer\shell\01menu" /v "MUIVerb" /t REG_SZ /d "Перезапустить ПРОВОДНИК" /f >nul 2>&1
    reg add "HKCR\DesktopBackground\Shell\Restart Explorer\shell\01menu\command" /ve /t REG_EXPAND_SZ /d "cmd.exe /c taskkill /f /im explorer.exe  & start explorer.exe" /f >nul 2>&1
    reg add "HKCR\DesktopBackground\Shell\Restart Explorer\shell\02menu" /v "MUIVerb" /t REG_SZ /d "Перезапустить ПРОВОДНИК с паузой" /f >nul 2>&1
    reg add "HKCR\DesktopBackground\Shell\Restart Explorer\shell\02menu" /v "CommandFlags" /t REG_DWORD /d "32" /f >nul 2>&1
    reg add "HKCR\DesktopBackground\Shell\Restart Explorer\shell\02menu\command" /ve /t REG_EXPAND_SZ /d "cmd.exe /c @echo off & echo. & echo Stopping explorer.exe process . . . & echo. & taskkill /f /im explorer.exe & echo. & echo. & echo Waiting to start explorer.exe process when you are ready . . . & pause && start explorer.exe && exit" /f >nul 2>&1
    set "operation_name=Добавление пункта в контекстное меню"
) >nul 2>&1 else (
echo [INFO ] %TIME% - Редактирование контекстного меню -ContextMenuExplorer >> "%ASX-Directory%\Files\Logs\%date%.txt"	
	reg delete "%SaveData%\ParameterFunction" /v "ContextMenuExplorer" /f >nul 2>&1
    reg delete "HKCR\DesktopBackground\Shell\Restart Explorer" /f >nul 2>&1
    set "operation_name=Удаление пункта из контекстного меню"
) >nul 2>&1
call:Complete_notice
goto GoBack

:ScanWithWindowsDefender
if "%ScanWithWindowsDefender%" == "%COL%[91mВЫКЛ" (
echo [INFO ] %TIME% - Редактирование контекстного меню +ScanWithWindowsDefender >> "%ASX-Directory%\Files\Logs\%date%.txt"		
	reg add "%SaveData%\ParameterFunction" /v "ScanWithWindowsDefender" /f >nul 2>&1
    reg delete "HKCR\*\shellex\ContextMenuHandlers\EPP" /f >nul 2>&1
    reg delete "HKCR\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f >nul 2>&1
    reg delete "HKCR\Directory\shellex\ContextMenuHandlers\EPP" /f >nul 2>&1
    reg delete "HKCR\Drive\shellex\ContextMenuHandlers\EPP" /f >nul 2>&1
    set "operation_name=Удаление пункта из контекстного меню"
) >nul 2>&1 else (
echo [INFO ] %TIME% - Редактирование контекстного меню -ScanWithWindowsDefender >> "%ASX-Directory%\Files\Logs\%date%.txt"	
	reg delete "%SaveData%\ParameterFunction" /v "ScanWithWindowsDefender" /f >nul 2>&1
    reg add "HKCR\*\shellex\ContextMenuHandlers\EPP" /ve /t REG_SZ /d "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f >nul 2>&1
    reg add "HKCR\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32" /ve /t REG_SZ /d "C:\Program Files\Windows Defender\shellext.dll" /f >nul 2>&1
    reg add "HKCR\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\InprocServer32" /v "ThreadingModel" /t REG_SZ /d "Apartment" /f >nul 2>&1
    reg add "HKCR\CLSID\{09A47860-11B0-4DA5-AFA5-26D86198A780}\Version" /ve /t REG_SZ /d "10.0.18362.1" /f >nul 2>&1
    reg add "HKCR\Directory\shellex\ContextMenuHandlers\EPP" /ve /t REG_SZ /d "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f >nul 2>&1
    reg add "HKCR\Drive\shellex\ContextMenuHandlers\EPP" /ve /t REG_SZ /d "{09A47860-11B0-4DA5-AFA5-26D86198A780}" /f >nul 2>&1
	set "operation_name=Добавление пункта в контекстное меню"
) >nul 2>&1
call:Complete_notice
goto GoBack

:CopytoFolder
if "%ContMenuCopytoFolder%" == "%COL%[91mВЫКЛ" (
echo [INFO ] %TIME% - Редактирование контекстного меню +ContMenuCopytoFolder >> "%ASX-Directory%\Files\Logs\%date%.txt"	
	reg add "%SaveData%\ParameterFunction" /v "ContMenuCopytoFolder" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\Copyto" /ve /t REG_SZ /d "{C2FBB630-2971-11d1-A18C-00C04FD75D13}" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\Moveto" /ve /t REG_SZ /d "{C2FBB631-2971-11d1-A18C-00C04FD75D13}" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Classes\Folder\shellex\ContextMenuHandlers\Copyto" /ve /t REG_SZ /d "{C2FBB630-2971-11d1-A18C-00C04FD75D13}" /f >nul 2>&1
	reg add "HKLM\SOFTWARE\Classes\Folder\shellex\ContextMenuHandlers\Moveto" /ve /t REG_SZ /d "{C2FBB631-2971-11d1-A18C-00C04FD75D13}" /f >nul 2>&1
    set "operation_name=Добавление пункта в контекстное меню"
) >nul 2>&1 else (
echo [INFO ] %TIME% - Редактирование контекстного меню -ContMenuCopytoFolder >> "%ASX-Directory%\Files\Logs\%date%.txt"		
	reg delete "%SaveData%\ParameterFunction" /v "ContMenuCopytoFolder" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\Copyto" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Classes\*\shellex\ContextMenuHandlers\Moveto" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Classes\Folder\shellex\ContextMenuHandlers\Copyto" /f >nul 2>&1
    reg delete "HKLM\SOFTWARE\Classes\Folder\shellex\ContextMenuHandlers\Moveto" /f >nul 2>&1
	set "operation_name=Удаление пункта из контекстного меню"
) >nul 2>&1
call:Complete_notice
goto GoBack

:OldContextMenu
if "%OldContMenuWindows%" == "%COL%[91mВЫКЛ" (	
    echo [INFO ] %TIME% - Установлено контекстное меню win10 >> "%ASX-Directory%\Files\Logs\%date%.txt"	
	reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /t REG_SZ /d "" /f >nul 2>&1
	taskkill /f /im explorer.exe
    start explorer.exe
    set "operation_name=Изменение стиля контекстного меню на win10"
) >nul 2>&1 else (
    echo [INFO ] %TIME% - Установлено контекстное меню win11 >> "%ASX-Directory%\Files\Logs\%date%.txt"		
	reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f >nul 2>&1
	taskkill /f /im explorer.exe
    start explorer.exe
    set "operation_name=Изменение стиля контекстного меню на win11"
) >nul 2>&1
call:Complete_notice
goto GoBack

:RunWithPriority
if "%RunWithPriority%" == "%COL%[91mВЫКЛ" (
    echo [INFO ] %TIME% - Редактирование контекстного меню +RunWithPriority >> "%ASX-Directory%\Files\Logs\%date%.txt"		
	reg add "%SaveData%\ParameterFunction" /v "RunWithPriority" /f >nul 2>&1
	reg add "HKCR\exefile\shell\Priority" /v "MUIVerb" /t REG_SZ /d "Запустить с приоритетом" /f >nul 2>&1
	reg add "HKCR\exefile\shell\Priority" /v "SubCommands" /t REG_SZ /d "" /f >nul 2>&1
	reg add "HKCR\exefile\Shell\Priority\shell\001flyout" /ve /t REG_SZ /d "Реального времени" /f >nul 2>&1
	reg add "HKCR\exefile\Shell\Priority\shell\001flyout\command" /ve /t REG_SZ /d "cmd.exe /c start \"\" /Реального времени \"%%1\"" /f >nul 2>&1
	reg add "HKCR\exefile\Shell\Priority\shell\002flyout" /ve /t REG_SZ /d "Высокий" /f >nul 2>&1
	reg add "HKCR\exefile\Shell\Priority\shell\002flyout\command" /ve /t REG_SZ /d "cmd.exe /c start \"\" /Высокий \"%%1\"" /f >nul 2>&1
	reg add "HKCR\exefile\Shell\Priority\shell\003flyout" /ve /t REG_SZ /d "Выше обычного" /f >nul 2>&1
	reg add "HKCR\exefile\Shell\Priority\shell\003flyout\command" /ve /t REG_SZ /d "cmd.exe /c start \"\" /Выше обычного \"%%1\"" /f >nul 2>&1
	reg add "HKCR\exefile\Shell\Priority\shell\004flyout" /ve /t REG_SZ /d "Обычный" /f >nul 2>&1
	reg add "HKCR\exefile\Shell\Priority\shell\004flyout\command" /ve /t REG_SZ /d "cmd.exe /c start \"\" /Обычный \"%%1\"" /f >nul 2>&1
	reg add "HKCR\exefile\Shell\Priority\shell\005flyout" /ve /t REG_SZ /d "Ниже обычного" /f >nul 2>&1
	reg add "HKCR\exefile\Shell\Priority\shell\005flyout\command" /ve /t REG_SZ /d "cmd.exe /c start \"\" /Ниже обычного \"%%1\"" /f >nul 2>&1
	reg add "HKCR\exefile\Shell\Priority\shell\006flyout" /ve /t REG_SZ /d "Низкий" /f >nul 2>&1
	reg add "HKCR\exefile\Shell\Priority\shell\006flyout\command" /ve /t REG_SZ /d "cmd.exe /c start \"\" /Низкий \"%%1\"" /f >nul 2>&1
    set "operation_name=Добавление пункта в контекстное меню"
) >nul 2>&1 else (
    echo [INFO ] %TIME% - Редактирование контекстного меню -RunWithPriority >> "%ASX-Directory%\Files\Logs\%date%.txt"			
	reg delete "%SaveData%\ParameterFunction" /v "RunWithPriority" /f >nul 2>&1
    reg delete "HKCR\exefile\shell\Priority" /f >nul 2>&1
	reg delete "HKCR\exefile\Shell\Priority\shell\001flyout" /f >nul 2>&1
	reg delete "HKCR\exefile\Shell\Priority\shell\001flyout\command" /f >nul 2>&1
	reg delete "HKCR\exefile\Shell\Priority\shell\002flyout" /f >nul 2>&1
	reg delete "HKCR\exefile\Shell\Priority\shell\002flyout\command" /f >nul 2>&1
	reg delete "HKCR\exefile\Shell\Priority\shell\003flyout" /f >nul 2>&1
	reg delete "HKCR\exefile\Shell\Priority\shell\003flyout\command" /f >nul 2>&1
	reg delete "HKCR\exefile\Shell\Priority\shell\004flyout" /f >nul 2>&1
	reg delete "HKCR\exefile\Shell\Priority\shell\004flyout\command" /f >nul 2>&1
	reg delete "HKCR\exefile\Shell\Priority\shell\005flyout" /f >nul 2>&1
	reg delete "HKCR\exefile\Shell\Priority\shell\005flyout\command" /f >nul 2>&1
	reg delete "HKCR\exefile\Shell\Priority\shell\006flyout" /f >nul 2>&1
	reg delete "HKCR\exefile\Shell\Priority\shell\006flyout\command" /f >nul 2>&1
	set "operation_name=Удаление пункта из контекстного меню"
) >nul 2>&1
call:Complete_notice
goto GoBack

:DeleteAllAppsFromStartMenu
if "%DeleteAllAppsFromStartMenu%" == "%COL%[91mВЫКЛ" (
echo [INFO ] %TIME% - Редактирование контекстного меню +DeleteAllAppsFromStartMenu >> "%ASX-Directory%\Files\Logs\%date%.txt"
	reg add "%SaveData%\ParameterFunction" /v "DeleteAllAppsFromStartMenu" /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoStartMenuMorePrograms" /t REG_DWORD /d "1" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoStartMenuMorePrograms" /t REG_DWORD /d "1" /f >nul 2>&1
    set "operation_name=Добавление пункта в контекстное меню"
) >nul 2>&1 else (
echo [INFO ] %TIME% - Редактирование контекстного меню -DeleteAllAppsFromStartMenu >> "%ASX-Directory%\Files\Logs\%date%.txt"
	reg delete "%SaveData%\ParameterFunction" /v "DeleteAllAppsFromStartMenu" /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoStartMenuMorePrograms" /t REG_DWORD /d "2" /f >nul 2>&1
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoStartMenuMorePrograms" /t REG_DWORD /d "2" /f >nul 2>&1
	set "operation_name=Удаление пункта из контекстного меню"
) >nul 2>&1
call:Complete_notice
goto GoBack

:EmptyRecycleBin
if "%EmptyRecycleBin%" == "%COL%[91mВЫКЛ" (
echo [INFO ] %TIME% - Редактирование контекстного меню +EmptyRecycleBin >> "%ASX-Directory%\Files\Logs\%date%.txt"
	reg add "%SaveData%\ParameterFunction" /v "EmptyRecycleBin" /f >nul 2>&1
    reg add "HKCR\Directory\Background\shell\empty" /v "CommandStateHandler" /t REG_SZ /d "{c9298eef-69dd-4cdd-b153-bdbc38486781}" /f >nul 2>&1
    reg add "HKCR\Directory\Background\shell\empty" /v "Description" /t REG_SZ /d "@shell32.dll,-31332" /f >nul 2>&1
    reg add "HKCR\Directory\Background\shell\empty" /v "Icon" /t REG_SZ /d "shell32.dll,-254" /f >nul 2>&1
    reg add "HKCR\Directory\Background\shell\empty" /v "MUIVerb" /t REG_SZ /d "@shell32.dll,-10564" /f >nul 2>&1
    reg add "HKCR\Directory\Background\shell\empty" /v "Position" /t REG_SZ /d "Bottom" /f >nul 2>&1
    reg add "HKCR\Directory\Background\shell\empty\command" /v "DelegateExecute" /t REG_SZ /d "{48527bb3-e8de-450b-8910-8c4099cb8624}" /f >nul 2>&1
    set "operation_name=Добавление пункта в контекстное меню"
) >nul 2>&1 else (
echo [INFO ] %TIME% - Редактирование контекстного меню -EmptyRecycleBin >> "%ASX-Directory%\Files\Logs\%date%.txt"
	reg delete "%SaveData%\ParameterFunction" /v "EmptyRecycleBin" /f >nul 2>&1
    reg delete "HKCR\Directory\Background\shell\empty" /f >nul 2>&1
	set "operation_name=Удаление пункта из контекстного меню"
) >nul 2>&1
call:Complete_notice
goto GoBack

:DeleteFolderContents
if "%DeleteFolderContents%" == "%COL%[91mВЫКЛ" (
echo [INFO ] %TIME% - Редактирование контекстного меню +DeleteFolderContents >> "%ASX-Directory%\Files\Logs\%date%.txt"
	reg add "%SaveData%\ParameterFunction" /v "DeleteFolderContents" /f >nul 2>&1
    reg add "HKCR\Directory\shell\Empty" /v "Icon" /t REG_SZ /d "shell32.dll,-16715" /f >nul 2>&1
    reg add "HKCR\Directory\shell\Empty" /v "MUIVerb" /t REG_SZ /d "Удалить содержимое папки" /f >nul 2>&1
    reg add "HKCR\Directory\shell\Empty" /v "Position" /t REG_SZ /d "bottom" /f >nul 2>&1
    reg delete "HKCR\Directory\shell\Empty" /v "Extended" /f >nul 2>&1
    reg add "HKCR\Directory\shell\Empty" /v "SubCommands" /t REG_SZ /d "" /f >nul 2>&1
    reg add "HKCR\Directory\shell\Empty\shell\001flyout" /v "Icon" /t REG_SZ /d "shell32.dll,-16715" /f >nul 2>&1
    reg add "HKCR\Directory\shell\Empty\shell\001flyout" /v "MUIVerb" /t REG_SZ /d "Удалить содержимое папки и подпапок" /f >nul 2>&1
    reg add "HKCR\Directory\shell\Empty\shell\001flyout\command" /ve /t REG_SZ /d "cmd /c title Empty \"%%1\" & (cmd /c chcp 65001 >nul 2>&1 & echo. & echo Это приведет к окончательному удалению всего, что находится в этой папке. & echo. & choice /c:yn /m \"Вы уверены?\") & (if errorlevel 2 exit) & (cmd /c rd /s /q \"%%1\" & md \"%%1\")" /f >nul 2>&1
    reg add "HKCR\Directory\shell\Empty\shell\002flyout" /v "Icon" /t REG_SZ /d "shell32.dll,-16715" /f >nul 2>&1
    reg add "HKCR\Directory\shell\Empty\shell\002flyout" /v "MUIVerb" /t REG_SZ /d "Удалить содержимое папки, но оставить подпапки" /f >nul 2>&1
    reg add "HKCR\Directory\shell\Empty\shell\002flyout\command" /ve /t REG_SZ /d "cmd /c title Empty \"%%1\" & (cmd /c chcp 65001 >nul 2>&1 & echo. & echo Это приведет к окончательному удалению всего в этой папке, но не подпапок. & echo. & choice /c:yn /m \"Вы уверены?\") & (if errorlevel 2 exit) & (cmd /c \"cd /d %%1 && del /f /q *.*\")" /f >nul 2>&1
    set "operation_name=Добавление пункта в контекстное меню"
) >nul 2>&1 else (
echo [INFO ] %TIME% - Редактирование контекстного меню -DeleteFolderContents >> "%ASX-Directory%\Files\Logs\%date%.txt"
	reg delete "%SaveData%\ParameterFunction" /v "DeleteFolderContents" /f >nul 2>&1
    reg delete "HKCR\Directory\shell\Empty" /f >nul 2>&1
	set "operation_name=Удаление пункта из контекстного меню"
) >nul 2>&1
call:Complete_notice
goto GoBack

:SettingsCME
if "%SettingsCME%" == "%COL%[91mВЫКЛ" (
echo [INFO ] %TIME% - Редактирование контекстного меню +SettingsCME >> "%ASX-Directory%\Files\Logs\%date%.txt"
	reg add "%SaveData%\ParameterFunction" /v "SettingsCME" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings" /v "Position" /t REG_SZ /d "Bottom" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings" /v "Icon" /t REG_SZ /d "SystemSettingsBroker.exe" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings" /v "MUIVerb" /t REG_SZ /d "Настройки" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings" /v "SubCommands" /t REG_SZ /d "" /f >nul 2>&1
		REM ; Settings home page
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\01menu" /v "Icon" /t REG_SZ /d "SystemSettingsBroker.exe" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\01menu" /v "MUIVerb" /t REG_SZ /d "Настройки" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\01menu\command" /ve /t REG_SZ /d "explorer ms-settings:" /f >nul 2>&1
		REM ; System category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\02menu" /v "CommandFlags" /t REG_DWORD /d "32" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\02menu" /v "MUIVerb" /t REG_SZ /d "Система" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\02menu\command" /ve /t REG_SZ /d "explorer ms-settings:display" /f >nul 2>&1
		REM ; Devices category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\03menu" /v "MUIVerb" /t REG_SZ /d "Устройства" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\03menu\command" /ve /t REG_SZ /d "explorer ms-settings:bluetooth" /f >nul 2>&1
		REM ; Phone category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\04menu" /v "MUIVerb" /t REG_SZ /d "Телефон" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\04menu\command" /ve /t REG_SZ /d "explorer ms-settings:mobile-devices" /f >nul 2>&1
		REM ; Network & Internet category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\05menu" /v "MUIVerb" /t REG_SZ /d "Сеть и Интернет" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\05menu\command" /ve /t REG_SZ /d "explorer ms-settings:network" /f >nul 2>&1
		REM ; Personalization category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\06menu" /v "MUIVerb" /t REG_SZ /d "Персонализация" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\06menu\command" /ve /t REG_SZ /d "explorer ms-settings:personalization" /f >nul 2>&1
		REM ; Apps category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\07menu" /v "MUIVerb" /t REG_SZ /d "Приложения" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\07menu\command" /ve /t REG_SZ /d "explorer ms-settings:appsfeatures" /f >nul 2>&1
		REM ; Accounts category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\08menu" /v "MUIVerb" /t REG_SZ /d "Аккаунты" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\08menu\command" /ve /t REG_SZ /d "explorer ms-settings:yourinfo" /f >nul 2>&1
		REM ; Time & language category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\09menu" /v "MUIVerb" /t REG_SZ /d "Время и язык" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\09menu\command" /ve /t REG_SZ /d "explorer ms-settings:dateandtime" /f >nul 2>&1
		REM ; Gaming category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\10menu" /v "MUIVerb" /t REG_SZ /d "Игровые" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\10menu\command" /ve /t REG_SZ /d "explorer ms-settings:gaming-gamebar" /f >nul 2>&1
		REM ; Ease of Access category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\11menu" /v "MUIVerb" /t REG_SZ /d "Специальные возможности" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\11menu\command" /ve /t REG_SZ /d "explorer ms-settings:easeofaccess-narrator" /f >nul 2>&1
		REM ; Search category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\12menu" /v "MUIVerb" /t REG_SZ /d "Поиск" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\12menu\command" /ve /t REG_SZ /d "explorer ms-settings:search-permissions" /f >nul 2>&1
		REM ; Cortana category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\13menu" /v "MUIVerb" /t REG_SZ /d "Cortana" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\13menu\command" /ve /t REG_SZ /d "explorer ms-settings:cortana" /f >nul 2>&1
		REM ; Privacy category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\14menu" /v "MUIVerb" /t REG_SZ /d "Конфиденциальность" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\14menu\command" /ve /t REG_SZ /d "explorer ms-settings:privacy" /f >nul 2>&1
		REM ; Update & security category
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\15menu" /v "MUIVerb" /t REG_SZ /d "Обновление и безопасность" /f >nul 2>&1
	reg add "HKCR\DesktopBackground\Shell\Settings\shell\15menu\command" /ve /t REG_SZ /d "explorer ms-settings:windowsupdate" /f >nul 2>&1
    set "operation_name=Добавление пункта в контекстное меню"
) >nul 2>&1 else (
echo [INFO ] %TIME% - Редактирование контекстного меню -SettingsCME >> "%ASX-Directory%\Files\Logs\%date%.txt"
	reg delete "%SaveData%\ParameterFunction" /v "SettingsCME" /f >nul 2>&1
    reg delete "HKCR\DesktopBackground\Shell\Settings" /f >nul 2>&1
	set "operation_name=Удаление пункта из контекстного меню"
) >nul 2>&1
call:Complete_notice
goto GoBack

:WindowsTools
if "%WindowsTools%" == "%COL%[91mВЫКЛ" (
    echo [INFO ] %TIME% - Редактирование контекстного меню +WindowsTools >> "%ASX-Directory%\Files\Logs\%date%.txt"
    reg add "%SaveData%\ParameterFunction" /v "WindowsTools" /f >nul 2>&1
    reg add "HKCR\DesktopBackground\Shell\WindowsTools" /v "Position" /t REG_SZ /d "Bottom" /f >nul 2>&1
    reg add "HKCR\DesktopBackground\Shell\WindowsTools" /v "Icon" /t REG_EXPAND_SZ /d "%%systemroot%%\system32\imageres.dll,-114" /f >nul 2>&1
    reg add "HKCR\DesktopBackground\Shell\WindowsTools" /v "MUIVerb" /t REG_SZ /d "Инструменты Windows" /f >nul 2>&1
    reg add "HKCR\DesktopBackground\Shell\WindowsTools\command" /ve /t REG_SZ /d "explorer.exe shell:::{D20EA4E1-3957-11d2-A40B-0C5020524153}" /f >nul 2>&1
    set "operation_name=Добавление пункта в контекстное меню"
) >nul 2>&1 else (
    echo [INFO ] %TIME% - Редактирование контекстного меню -WindowsTools >> "%ASX-Directory%\Files\Logs\%date%.txt"
	reg delete "%SaveData%\ParameterFunction" /v "WindowsTools" /f >nul 2>&1
    reg delete "HKCR\DesktopBackground\Shell\WindowsTools" /f >nul 2>&1
    set "operation_name=Удаление пункта из контекстного меню"
) >nul 2>&1
call:Complete_notice
goto GoBack

:EndTask
if "%EndTask%" == "%COL%[91mВЫКЛ" (
    echo [INFO ] %TIME% - Редактирование контекстного меню +EndTask >> "%ASX-Directory%\Files\Logs\%date%.txt"
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v "TaskbarEndTask" /t REG_DWORD /d "1" /f >nul 2>&1

    set "operation_name=Добавление пункта в контекстное меню"
) >nul 2>&1 else (
    echo [INFO ] %TIME% - Редактирование контекстного меню -EndTask >> "%ASX-Directory%\Files\Logs\%date%.txt"
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" /v "TaskbarEndTask" /f >nul 2>&1

    set "operation_name=Удаление пункта из контекстного меню"
) >nul 2>&1
call:Complete_notice
goto GoBack

:EditInNotepad
if "%EditInNotepad%" == "%COL%[91mВЫКЛ" (
    echo [INFO ] %TIME% - Редактирование контекстного меню +EditInNotepad >> "%ASX-Directory%\Files\Logs\%date%.txt"
    reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{CA6CC9F1-867A-481E-951E-A28C5E4F01EA}" /f >nul 2>&1
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /f >nul 2>&1
    set "operation_name=Добавление пункта в контекстное меню"
) >nul 2>&1 else (
    echo [INFO ] %TIME% - Редактирование контекстного меню -EditInNotepad >> "%ASX-Directory%\Files\Logs\%date%.txt"
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{CA6CC9F1-867A-481E-951E-A28C5E4F01EA}" /t REG_SZ /d "" /f >nul 2>&1
    set "operation_name=Удаление пункта из контекстного меню"
) >nul 2>&1
call:Complete_notice
goto GoBack



:ASX_cleaner_Warn
rem chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":ASX_cleaner_Warn" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=ASX_cleaner_Warn

TITLE Очистка ненужных файлов - ASX Hub
cls
echo.
echo.
echo.
echo                                                                         %COL%[91m_
echo                                                                        / \
echo                                                                       /   \
echo                                                                      /     \
echo                                                                     /       \
echo                                                                    /         \
echo                                                                   /           \
echo                                                                  /             \
echo                                                                 /      ___      \
echo                                                                /      ^|   ^|      \
echo                                                               /       ^|   ^|       \
echo                                                              /        ^|   ^|        \
echo                                                             /         ^|   ^|         \
echo                                                            /          ^|   ^|          \
echo                                                           /           ^|   ^|           \
echo                                                          /            ^|   ^|            \
echo                                                         /             ^|___^|             \
echo                                                        /                                 \
echo                                                       /                                   \
echo                                                      /                 ___                 \
echo                                                     /                 ^|___^|                 \
echo                                                    /                                         \
echo                                                   /___________________________________________\
echo.
echo.
echo                                                                  %COL%[91m⚠  ВНИМАНИЕ ⚠ %COL%[37m
echo.
echo                                                Этот инструмент выполняет глубокую очистку системы.
echo                                        Он может удалить временные файлы, кеш, логи и другие ненужные данные.
echo.
echo                                       %COL%[93mПеред запуском убедитесь, что у вас есть резервные копии важных файлов
echo.
echo                                            %COL%[90mИспользуйте утилиту с осторожностью и на свой страх и риск.%COL%[90m
echo.
echo.
echo.
echo.
set /p choice="%DEL%                                      Введите %COL%[96m"ОК"%COL%[90m чтобы продолжить или нажмите %COL%[96m"B"%COL%[90m, чтобы вернуться назад %COL%[37m>%COL%[96m "
if /i "%choice%"=="OK" mode con: cols=146 lines=45 >nul 2>&1 & call:ASX_cleaner
if /i "%choice%"=="ОК" mode con: cols=146 lines=45 >nul 2>&1 & call:ASX_cleaner
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
goto ASX_cleaner_Warn

:ASX_cleaner
if exist "%ASX-Directory%\Files\Utilites\PC_Cleaner\ASX-PC-Cleaner.exe" (
    start "" "%ASX-Directory%\Files\Utilites\PC_Cleaner\ASX-PC-Cleaner.exe"
) else (
    echo         - Скачивание PC Cleaner
    md "%ASX-Directory%\Files\Utilites\PC_Cleaner" >nul 2>&1
    curl -g -L -# -o "%ASX-Directory%\Files\Utilites\PC_Cleaner\ASX-PC-Cleaner.exe" "https://github.com/ALFiX01/ASX-PC-Cleaner/raw/refs/heads/main/Files/PC_cleaner/ASX-PC-Cleaner.exe" >nul 2>&1
    start "" "%ASX-Directory%\Files\Utilites\PC_Cleaner\ASX-PC-Cleaner.exe"
)
goto GoBack


:ASX_sorter
if exist "%ASX-Directory%\Files\Utilites\ASX_FileSorter\FileSorter.exe" (
    "%ASX-Directory%\Files\Utilites\ASX_FileSorter\FileSorter.exe"
) else (
    title Загрузка отсутствующих компонентов...
    echo [INFO ] %TIME% - Загрузка отсутствующего компонента FileSorter.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
	if not exist "%ASX-Directory%\Files\Utilites\ASX_FileSorter" md "%ASX-Directory%\Files\Utilites\ASX_FileSorter" >nul 2>&1
    curl -g -L -# -o "%ASX-Directory%\Files\Utilites\ASX_FileSorter\FileSorter.exe" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Utilities/ASX_FileSorter/FileSorter.exe" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] %TIME% - Ошибка при загрузке компонента FileSorter.exe >> "%ASX-Directory%\Files\Logs\%date%.txt"
        set /a "error_on_loading_1+=1"
    )
)
goto GoBack

:CMD_RecommendedStats
REM Получаем текущее значение статистики для команды
set "CMD_NameStats=0"
for /f "tokens=2*" %%a in ('reg query "%SaveData%\Dynamic\Dynamic_data_CMD" /v "%CMD_Name%" 2^>nul ^| find /i "%CMD_Name%"') do (
    set "CMD_NameStats=%%b"
)

REM Увеличиваем счетчик на единицу
set /a CMD_NameStats+=1

REM Проверяем, содержит ли имя команды пробелы
echo %CMD_Name%| find " " > nul
if %ERRORLEVEL% equ 0 (
    goto GoBack
)

REM Сохраняем новое значение в реестр с обработкой ошибок
reg add "%SaveData%\Dynamic\Dynamic_data_CMD" /v "%CMD_Name%" /t REG_SZ /d "%CMD_NameStats%" /f >nul 2>&1
if errorlevel 1 (
    echo [ERROR] %TIME% - Failed to update statistics for %CMD_Name% >> "%ASX-Directory%\Files\Logs\%date%.txt"
) else (
    echo [INFO] %TIME% - Updated statistics for %CMD_Name% >> "%ASX-Directory%\Files\Logs\%date%.txt"
)
goto GoBack


:ASX_CMD
chcp 65001 >nul 2>&1
REM Значение: !value[1]!
:: Инициализация счётчика
setlocal enabledelayedexpansion
set CMD_count=0

:: Чтение значений из реестра
for /f "tokens=1,2,*" %%a in ('reg query "%SaveData%\Dynamic\Dynamic_data_CMD" /s  ^| findstr /R /C:"^[ ]*[^ ]"') do (
    if "%%b" NEQ "" (
        set /a CMD_count+=1
        set "CMD_value[!CMD_count!]=%%c"
        set "CMD_name[!CMD_count!]=%%a"
        set "CMD_russianName[!CMD_count!]=!%%a!"
    )
)

:: Сортировка значений по убыванию
for /L %%i in (1,1,!CMD_count!) do (
    for /L %%j in (%%i,1,!CMD_count!) do (
        if "!CMD_value[%%i]!" LSS "!CMD_value[%%j]!" (
            set "CMD_tempV=!CMD_value[%%i]!"
            set "CMD_tempN=!CMD_name[%%i]!"
            
            set "CMD_value[%%i]=!CMD_value[%%j]!"
            set "CMD_name[%%i]=!CMD_name[%%j]!"
      
            set "CMD_value[%%j]=!CMD_tempV!"
            set "CMD_name[%%j]=!CMD_tempN!"
        )
    )
)
cls
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":ASX_CMD" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set "choice="
set PageName=ASX_CMD
set choice=NoInput
TITLE Командная строка - ASX Hub
echo.
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
echo.
echo                                                            СПИСОК ОСНОВНЫХ КОМАНД
echo.
echo.
echo          %COL%[94mASX Hub
echo          %COL%[97m-------
echo          %COL%[94mDwFolder %COL%[37m— Открывает папку загрузок ASX Hub.
echo          %COL%[94m-help %COL%[37m— Список команд.
echo          %COL%[94mSearch: ^(Запрос^) %COL%[37m— Быстрый поиск в Google.
echo          %COL%[94mYoutube: ^(Запрос^) %COL%[37m— Быстрый поиск в Youtube.
echo          %COL%[94m^(Ваш Запрос в ASX_CMD^) %COL%[37m— Активирует ASX Search.
echo.
echo.
echo.
echo.
echo.
if defined CMD_name[1] (
		echo          %COL%[94mЧасто используемые
		echo          %COL%[97m------------------
        echo          %COL%[94m!CMD_name[1]! %COL%[37m
    ) else (
		echo.
		echo.
		echo.
	)
if defined CMD_name[2] (
        echo          %COL%[94m!CMD_name[2]! %COL%[37m
    ) else (
		echo.
	)
if defined CMD_name[3] (
        echo          %COL%[94m!CMD_name[3]! %COL%[37m
    ) else (
		echo.
	)		
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
set /p "choice=%DEL%                                           %COL%[90mВведите команду или нажмите < B > чтобы вернуться назад >%COL%[94m "
if not defined choice cls && goto ASX_CMD
set "CMD_Name=%choice%"


if /i "%choice%"=="NoInput" goto WrongInput
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="ч" goto MainMenu

if /i "%choice%"=="Электропитание" ( start %windir%\System32\control.exe powercfg.cpl
    set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Power cfg" ( start %windir%\System32\control.exe powercfg.cpl
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Reg" ( start Regedit 
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Реестр" ( start Regedit
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Regedit" ( start Regedit
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Uac" ( start UserAccountControlSettings.exe
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="gpedit" ( start gpedit.msc
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Символы" ( start Charmap
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Symbol" ( start Charmap
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="CMD" ( start CMD
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="брандмауэр" ( start firewall.cpl
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="брандмауер" ( start firewall.cpl
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="firewall" ( start firewall.cpl
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Startup" ( start %windir%\System32\Taskmgr.exe /0 /startup
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Автозапуск" ( start %windir%\System32\Taskmgr.exe /0 /startup
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="host" ( start %windir%\system32\drivers\etc\
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="монитор ресурсов" ( start resmon
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Диспетчер устройств" ( start devmgmt.msc
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Планировщик заданий" ( start taskschd.msc
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Активация" ( start slui
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Компоненты" ( start optionalfeatures
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="-help" ( 
	set "history=ASX_CMD;!history!" && call:HelpCmd
)

if /i "%choice%"=="-h" ( 
	set "history=ASX_CMD;!history!" && call:HelpCmd
)

if /i "%choice%"=="help" ( 
	set "history=ASX_CMD;!history!" && call:HelpCmd
)

if /i "%choice%"=="Set Custom Patch" ( 
	set "history=ASX_CMD;!history!" && call:CustomPatch
)

REM Расчёт файла подкачки
if /i "%choice%"=="ФП" (
	set "history=ASX_CMD;!history!" && call:File-swap
)

if /i "%choice%"=="FileSwap" (
	set "history=ASX_CMD;!history!" && call:File-swap
)

REM поиск в гугле
for %%a in (Search:, Искать:, S:) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
	REM set "history=ASX_CMD;!history!" && call:search !choice!

	rem Исходная переменная
	set "myStringG=!choice!"
	rem Убираем первые 6 символов
	echo !choice! | find /i "Search:" >nul && start "" "https://www.google.ru/search?q=!myStringG:~7!*" && goto ASX_CMD
	echo !choice! | find /i "Искать:" >nul && start "" "https://www.google.ru/search?q=!myStringG:~7!*" && goto ASX_CMD
	echo !choice! | find /i "S:" >nul && start "" "https://www.google.ru/search?q=!myStringG:~2!*" && goto ASX_CMD
	goto ASX_CMD
    )
)

REM поиск на ютубе
for %%a in (Youtube:, YT:) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
	REM set "history=ASX_CMD;!history!" && call:search !choice!
	rem Исходная переменная
	set "myStringYT=!choice!"
	rem Убираем первые 6 символов
	echo !choice! | find /i "Youtube:" >nul && start "" "https://www.youtube.com/results?search_query=!myStringYT:~8!" && goto ASX_CMD
	echo !choice! | find /i "YT:" >nul && start "" "https://www.youtube.com/results?search_query=!myStringYT:~3!" && goto ASX_CMD
	goto ASX_CMD
    )
)

if /i "%choice%"=="Панель управления" ( start control
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Диспетчер задач" ( start taskmgr.exe
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Диспетчер устройств" ( start devmgmt.msc
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Проводник" ( start explorer
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)

if /i "%choice%"=="Dwfolder" ( start "" "%ASX-Directory%\Files\Downloads"
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)


REM Сайты
if /i "%choice%"=="AZ-center" ( start https://alfix-inc.yonote.ru/share/ALFiX_Zone_Center
	set "history=ASX_CMD;!history!" && goto CMD_RecommendedStats
)
REM ----------------------------------------------

for %%a in (оптим, ускор, буст, boost) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель оптимизации и настроек" 
	 set ASX_SEARCH_GOTO=OptimizationCenterPG1
        goto :ASX_SEARCH_YN
    )
)

for %%a in (установ) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель установки программ" 
	 set ASX_SEARCH_GOTO=AppInstall_PG1
        goto :ASX_SEARCH_YN
    )
)

for %%a in (удал, delete) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель удаления программ" 
	 set ASX_SEARCH_GOTO=AppUninstall
        goto :ASX_SEARCH_YN
    )
)

for %%a in (конфид, приватн, Privacy) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель конфиденциальности" 
	 set ASX_SEARCH_GOTO=Privacy
        goto :ASX_SEARCH_YN
    )
)

for %%a in (контекст, Context) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель контекстного меню" 
	 set ASX_SEARCH_GOTO=EditContextMenu
        goto :ASX_SEARCH_YN
    )
)

for %%a in (сайт, веб-сайт, веб сайт,веб) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель веб-сайтов" 
	 set ASX_SEARCH_GOTO=WebResources
        goto :ASX_SEARCH_YN
    )
)

for %%a in (служ) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель служб" 
	 set ASX_SEARCH_GOTO=Services
        goto :ASX_SEARCH_YN
    )
)

for %%a in (утилит, enbkbns) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель утилит" 
	 set ASX_SEARCH_GOTO=ASX_Utilites
        goto :ASX_SEARCH_YN
    )
)

for %%a in (чист, cleaner) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель очистки временных файлов" 
	 set ASX_SEARCH_GOTO=ASX_cleaner
        goto :ASX_SEARCH_YN
    )
)

for %%a in (сорт, sorter) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель сортировки файлов" 
	 set ASX_SEARCH_GOTO=ASX_sorter
        goto :ASX_SEARCH_YN
    )
)

for %%a in (пегасус, защит, defender) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель утилиты PEGASUS" 
	 set ASX_SEARCH_GOTO=PEGASUS
        goto :ASX_SEARCH_YN
    )
)

for %%a in (систем) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель утилиты WinForce" 
	 set ASX_SEARCH_GOTO=SystemInformation
        goto :ASX_SEARCH_YN
    )
)

for %%a in (11, совмест) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель совместимости с Win11" 
	 set ASX_SEARCH_GOTO=Windows11_CompatibilityCheck
        goto :ASX_SEARCH_YN
    )
)

for %%a in (актив, WinForce) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель утилиты WinForce" 
	 set ASX_SEARCH_GOTO=WinForce
        goto :ASX_SEARCH_YN
    )
)

for %%a in (восст, бэкап, бекап, backup) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель создания backup" 
	 set ASX_SEARCH_GOTO=backup
        goto :ASX_SEARCH_YN
    )
)

for %%a in (тест, перезагр) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель теста скорости презагрузки" 
	 set ASX_SEARCH_GOTO=ASX_Benchmark_Restart_Time
        goto :ASX_SEARCH_YN
    )
)

for %%a in (инфа, информаци, инфо) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель информации" 
	 set ASX_SEARCH_GOTO=ASX_Information
        goto :ASX_SEARCH_YN
    )
)

for %%a in (верс, сборк, ver) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель информации о версии и тд" 
	 set ASX_SEARCH_GOTO=ASX_Information_UpdateCheck
        goto :ASX_SEARCH_YN
    )
)

for %%a in (обновл, патч, ноут) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель Описания обновления" 
	 set ASX_SEARCH_GOTO=PatchNotesOpen
        goto :ASX_SEARCH_YN
    )
)

for %%a in (о программе, об ASX, ASX) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель информации об ASX Hub" 
	 set ASX_SEARCH_GOTO=ASX_Information_About
        goto :ASX_SEARCH_YN
    )
)

for %%a in (разраб, developers) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель разработчиков" 
	 set ASX_SEARCH_GOTO=ASX_Information_Developers
        goto :ASX_SEARCH_YN
    )
)

for %%a in (ДС, дискор, discord) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть дискорд сервер разработчиков" 
	 set ASX_SEARCH_GOTO=Discord
        goto :ASX_SEARCH_YN
    )
)

for %%a in (настр, settings, инфо) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель настроек" 
	 set ASX_SEARCH_GOTO=ASX_settings
        goto :ASX_SEARCH_YN
    )
)


for %%a in (исправ) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель исправления проблем" 
	 set ASX_SEARCH_GOTO=FixProblemPanel
        goto :ASX_SEARCH_YN
    )
)

for %%a in (сортиров, Sort) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
     set "AiA=Открыть панель сортировки файлов" 
	 set ASX_SEARCH_GOTO=ASX_sorter
        goto :ASX_SEARCH_YN
    )
)

for %%a in (загруз) do (
    echo !choice! | find /i "%%a" >nul
    if not errorlevel 1 (
	start "" "%ASX-Directory%\Files\Downloads"
    )
)


:HelpCmd
echo [INFO ] %TIME% - Открыта панель ":HelpCmd" >> "%ASX-Directory%\Files\Logs\%date%.txt"
TITLE Список команд ASX CMD - ASX Hub
set PageName=HelpCmd
set choice=NoInput
cls
echo.
echo   %COL%[94mPower cfg %COL%[37m- Открывает конфигурацию питания.
echo   %COL%[94mReg / Regedit %COL%[37m- Открывает редактор реестра.
echo   %COL%[94mgpedit %COL%[37m- Открывает редактор локальной групповой политики.
echo   %COL%[94mПанель управления %COL%[37m- Открывает панель управления.
echo   %COL%[94mCMD %COL%[37m- Открывает командную строку windows.
echo   %COL%[94mfirewall %COL%[37m- Открывает брандмауэр windows.
echo   %COL%[94mSymbol %COL%[37m- Открывает Charmap.
echo   %COL%[94m-help / -h %COL%[37m- Открывает это меню.
echo   %COL%[94mDwFolder %COL%[37m- Открывает папку загрузок ASX Hub.
echo   %COL%[94mFileSwap %COL%[37m- Открывает меню расчёта и выбора файла подкачки.
echo   %COL%[94mАктивация %COL%[37m- Открывает страницу настроек Windows для проверки активации.
echo   %COL%[94mhost %COL%[37m- Отпрывает папку host в проводнике.
echo   %COL%[94mStable / Beta %COL%[37m- Изменяет ветку получения обновлений.
echo   %COL%[94mSearch: / S: (Запрос) %COL%[37m- быстрый поиск в гугл.
echo   %COL%[94mYT: / Youtube: (Запрос) %COL%[37m- быстрый поиск в гугл.
echo.
echo.
echo  Для продолжения нажмите любую клавишу
pause >nul
goto GoBack

:ASX_SEARCH_YN
cls
setlocal enabledelayedexpansion
set "choice="
set "PageNameBack=%PageName%"
set "PageName=ASX_SEARCH_YN"
set "choice=NoInput"
TITLE Командная строка - ASX Hub
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
echo.
echo.
echo.
echo.
echo                                   Вы имели в виду: "%AiA%"?
echo.
echo.
echo                                                               Y - Да  ^|  N - Нет
echo.
 %SYSTEMROOT%\System32\choice.exe /c:YнNтBиXч /n /m "%DEL%                                                                   >: " 
set choice=%errorlevel%
if "%choice%"=="1" ( set "history=ASX_CMD;!history!" && goto %ASX_SEARCH_GOTO% )
if "%choice%"=="2" ( set "history=ASX_CMD;!history!" && goto %ASX_SEARCH_GOTO% )
REM if "%choice%"=="1" goto %ASX_SEARCH_GOTO%
REM if "%choice%"=="2" goto %ASX_SEARCH_GOTO%
if "%choice%"=="3" goto ASX_CMD
if "%choice%"=="4" goto ASX_CMD
if "%choice%"=="5" goto GoBack
if "%choice%"=="6" goto GoBack
if "%choice%"=="7" goto MainMenu
if "%choice%"=="8" goto MainMenu
call:ASX_SEARCH_YN

:CustomPatch
echo [INFO ] %TIME% - Вызвана панель "CustomPatch" >> "%ASX-Directory%\Files\Logs\%date%.txt"
cls
echo.
echo  %COL%[37mВведите путь к папке "ASX Hub"
echo  Пример: Введите %COL%[96m%Systemdrive%\ProgramData %COL%[37m если полный путь к папке выглядит так %COL%[96m%Systemdrive%\ProgramData\ASX %COL%[37m
echo  Если вам нужно указать путь к диску на котором будет находиться ASX Hub, то используйте %COL%[96m%Systemdrive%%COL%[37m
echo.
set /p CustPatch=">: " 
if /i "%CustPatch%"=="B" (
  goto GoBack
) else (
  reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" /t REG_SZ /d "%CustPatch%" /f >nul 2>&1
) 
set "operation_name=Изменение пути к директории ASX"
call:Complete_notice
goto GoBack

:File-swap
echo [INFO ] %TIME% - Вызвана панель "File-swap" >> "%ASX-Directory%\Files\Logs\%date%.txt"
cls
Title Настройка файла подкачки
set Num2=1024
echo.
set /p Onum=⁣⁣ %COL%[37mВведите колличество вашей оперативной памяти (ГБ): %COL%[96m

if %Onum% == 8 (
    set Num2=2448
)

if %Onum% == 16 (
    set Num2=1324
)

if %Onum% == 24 (
    set Num2=1024
)

if %Onum% == 32 (
    set Num2=1024
)

if %Onum% == 64 (
    set Num2=1024
)

if %Onum% == 128 (
    set Num2=1024
)


set /a Oresult=Onum*Num2
echo    %COL%[37mРекомендуем вам указать: %COL%[96m%Oresult% мб %COL%[37m

echo %Oresult% | clip  >nul 2>&1

echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
set /p choice="%DEL%            %COL%[90mНажмите < B > чтобы вернуться назад или нажмите < E > чтобы перейти в меню редактирования размера файла подкачки >%COL%[96m "
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="у" start systempropertiesperformance & chcp 850 >nul 2>&1 & powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Инструкция: Перейдите в меню ДОПОЛНИТЕЛЬНО и нажмите кнопку ИЗМЕНИТЬ', 'ASX Hub', 'OK', [System.Windows.Forms.MessageBoxIcon]::information);}" & chcp 65001 >nul 2>&1
if /i "%choice%"=="E" start systempropertiesperformance & chcp 850 >nul 2>&1 & powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Инструкция: Перейдите в меню ДОПОЛНИТЕЛЬНО и нажмите кнопку ИЗМЕНИТЬ', 'ASX Hub', 'OK', [System.Windows.Forms.MessageBoxIcon]::information);}" & chcp 65001 >nul 2>&1
call:WrongInput
goto GoBack

:Defrag
echo [INFO ] %TIME% - Вызван "Defrag" >> "%ASX-Directory%\Files\Logs\%date%.txt"
Title Дефрагментация
cls
echo.
set /p disk_liter="%DEL% %COL%[90mВведите только литеру (букву) диска, который вы хотите дефрагментировать (Пример: "D") >%COL%[96m "
echo Дефрагментация диска %disk_liter%...
echo [INFO ] %TIME% - Запущена дефрагментация диска %disk_liter%>> "%ASX-Directory%\Files\Logs\%date%.txt"
defrag %disk_liter%: -f >nul
echo   Диск %disk_liter%: дефрагментация завершена.
echo [INFO ] %TIME% - Дефрагментация диска %disk_liter% завершена>> "%ASX-Directory%\Files\Logs\%date%.txt"
set "operation_name=Дефрагментация диска %disk_liter%"
call:Complete_notice
goto GoBack

:CustomUserName
set PageName=CustomUserName
set CustomUserN=NoInput
set UserNameWarn=0
TITLE Смена имени пользователя - ASX Hub
echo [INFO ] %TIME% - Вызван "CustomUserName" >> "%ASX-Directory%\Files\Logs\%date%.txt"
cls
chcp 65001 >nul 2>&1
echo.
echo.
echo.
echo                                            %COL%[36m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                    %COL%[37mКритерии для создания имени пользователя:%COL%[36m
echo                                                            %COLR1%- Не короче 3-х букв%COL%[36m
echo                                                            %COLR2%- Не длиннее 8-ми букв%COL%[36m
echo                                                            %COLR3%- Только английский язык%COL%[37m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                      %COL%[90mВведите новое Имя пользователя ASX
echo.
set /p CustomUserN="%DEL%                                                                   >: "
set "COLR3=%COL%[36m"
set "COLR1=%COL%[36m"
set "COLR2=%COL%[36m"

if /i "%CustomUserN%"=="NoInput" goto WrongInput
if /i "%CustomUserN%"=="B" goto GoBack
if /i "%CustomUserN%"=="и" goto GoBack

rem Получаем количество букв в переменной
set "length=0"
for /l %%A in (12,-1,0) do (
  set /a "length|=1<<%%A"
  for %%B in (!length!) do if "!CustomUserN:~%%B,1!"=="" set /a "length&=~1<<%%A"
)

:: Проверяем, содержит ли переменная CustomUserN только английские буквы
chcp 850 >nul 2>&1
for /f %%i in ('powershell -Command "( '%CustomUserN%' -cmatch '^[a-zA-Z]+$' )"') do set valid=%%i
chcp 65001 >nul 2>&1


:: Если количество символов больше 7, оставьте только первые 7 символов
if "%valid%" NEQ "True" (
    set "COLR3=%COL%[91m"
    REM set "ASX_ERROR_TEMPLATE_TEXT=      Имя должно содержать только английские буквы"
    set "ASX_ERROR_TEMPLATE_TEXT=    Введенное имя не соответствует заданным критериям"
    call:ASX_ERROR_TEMPLATE
    set /a UserNameWarn+=1
)

if !length! leq 1 (
    set "COLR1=%COL%[91m"
    REM set "ASX_ERROR_TEMPLATE_TEXT=         Имя должно быть не короче 3-х символов"
    set "ASX_ERROR_TEMPLATE_TEXT=    Введенное имя не соответствует заданным критериям"
    call:ASX_ERROR_TEMPLATE
    set /a UserNameWarn+=1
)

if !length! gtr 6 (
    set "COLR2=%COL%[91m"
    REM set "ASX_ERROR_TEMPLATE_TEXT=        Имя должно быть не длиннее 8-ми символов"
    set "ASX_ERROR_TEMPLATE_TEXT=    Введенное имя не соответствует заданным критериям"
    call:ASX_ERROR_TEMPLATE
    set /a UserNameWarn+=1
)

if %UserNameWarn% equ 0 (
    set "COLR3=%COL%[36m"
    set "COLR1=%COL%[36m"
    set "COLR2=%COL%[36m"
    reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CustomUserName" /t REG_SZ /d "%CustomUserN%" /f >nul 2>&1
    set CustomUserNameWarn=0
    set "CustomUserName=%CustomUserN%"
    echo [INFO ] %TIME% - Имя пользователя изменено на "%CustomUserName%" >> "%ASX-Directory%\Files\Logs\%date%.txt"
    set "operation_name=Изменение имени пользователя ASX"
    call:Complete_notice
    goto GoBack
)

for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "CustomUserName" 2^>nul ^| find /i "CustomUserName"') do set "CustomUserName=%%b"
goto CustomUserName

:PEGASUS_Menu_Prepare
cls
for /f "tokens=2*" %%a in ('reg query "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data\ParameterFunction" /v "Pegasus_DisableMode" 2^>nul ^| find /i "Pegasus_DisableMode"') do set "DisableMode_reg=%%b"
color 0a
echo  Загрузка PEGASUS

if not exist "%ASX-Directory%\Files\Utilites\PEGASUS" ( 
    md "%ASX-Directory%\Files\Utilites\PEGASUS" >nul 2>&1
    curl -g -L -# -o "%ASX-Directory%\Files\Downloads\PEGASUS.zip" "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Utilities/PEGASUS/PEGASUS.zip" >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        echo Ошибка: Не удалось скачать файл PEGASUS.zip. Проверьте подключение к интернету и доступность URL.
	    echo [ERROR] %TIME% - Ошибка при загрузке PEGASUS.zip >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto GoBack
    )
    chcp 850 >nul 2>&1 
    powershell -NoProfile Expand-Archive '"%ASX-Directory%\Files\Downloads\PEGASUS.zip"' -DestinationPath '"%ASX-Directory%\Files\Utilites\PEGASUS"' >nul 2>&1
    chcp 65001 >nul 2>&1
)

:PEGASUS_Menu
set PageName=PEGASUS_Menu
REM Проверка состояния Windows Defender
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" | find "0x0" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set "WD_STATUS=%COL%[91mВКЛ "
) else (
    set "WD_STATUS=%COL%[92mВЫКЛ"
)

REM Проверка отключения уведомлений Windows Defender
reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.SecurityAndMaintenance" /v "Enabled" | findstr /i "0x0" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set "WN_STATUS=%COL%[92mВЫКЛ"
) else (
    set "WN_STATUS=%COL%[91mВКЛ "
)

REM Проверка состояния SmartScreen
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" | findstr /i "Off" >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        set "SS_STATUS=%COL%[92mВЫКЛ"
    ) else (
        set "SS_STATUS=%COL%[91mВКЛ "
    )
)
if "%WD_STATUS%"=="%COL%[92mВЫКЛ" if "%WN_STATUS%"=="%COL%[92mВЫКЛ" if "%SS_STATUS%"=="%COL%[92mВЫКЛ" (
    set "ALL_DISABLED=true"
    set "ColorStatus=0a"
    set "ColorStatusCLR=%COL%[92m"
) else (
    set "ALL_DISABLED=false"
    set "ColorStatusCLR=%COL%[91m"
)


::Функция "Полное выключение антивируса"
cls
color %ColorStatus%
set PageName=PEGASUS_Menu
if not defined DisableMode set "DisableMode=избирательный"
title PEGASUS - Мощное средство против Windows Defender
echo.
echo                                                ^|`\
echo                                               /'_/_
echo                                             ,'_/\_/\_                       ,
echo                                           ,'_/\'_\_,/_                    ,'^|
echo                                         ,'_/\_'_ \_ \_/                _,-'_/
echo                                       ,'_/'\_'_ \_ \'_,\           _,-'_,-/ \,
echo                                     ,' /_\ _'_ \_ \'_,/       __,-'^<_,' _,\_,/
echo                                    ^( ^(' ^)\/^(_ \_ \'_,\   __--' _,-_/_,-',_/ _\
echo                                     \_`\^> 6` 7  \'_,/ ,-' _,-,'\,_'_ \,_/'_,\
echo                                       \/-  _/ 7 '/ _,' _/'\_  \,_'_ \_ \'_,/
echo                                        \_'/^>   7'_/' _/' \_ '\,_'_ \_ \'_,\      
echo                                          ^>/  _ ,V  ,^<  \__ '\,_'_ \_ \'_,/
echo                                        /'_  ^( ^)_^)\/-,',__ '\,_'_,\_,\'_\
echo                                       ^( ^) \_ \^|_  `\_    \_,/'\,_'_,/'         ----------------------------------
echo                                        \\_  \_\_^)    `\_                       ^| Утилита:  PEGASUS              ^|
echo                                         \_^)   ^>        `\_                     ^| Версия:  v2.0                  ^|
echo                                              /  `,      ^|`\_                   ^| Автор:  ALFiX.inc              ^| 
echo                                             /    \     / \ `\                  ----------------------------------
echo                                            /   __/^|   /  /  `\
echo                                           ^(`  ^(   ^(` ^(_  \   /
echo                                           /  ,/    ^|  /  /   \
echo                                          / ,/      ^| /   \   `\_
echo                                        _/_/        ^|/    /__/,_/    
echo                                       /_^(         /_^(
echo.
echo    Текущий состояние параметров:
echo    ───────────────────────────── %COL%[37m
echo    WinDefender: %WD_STATUS% %COL%[37m
echo    Уведомления: %WN_STATUS% %COL%[37m
echo    SmartScreen: %SS_STATUS% %ColorStatusCLR%
echo.
echo    Режим PEGASUS: %DisableMode%
if "%DisableMode%"=="избирательный" (
    echo    ──────────────────────────── %COL%[37m
) else (
    echo    ───────────────────── %COL%[37m
)
echo    ^[ DF ^] Запустить dfControl
echo    ^[ MD ^] Сменить режим
echo    ^[ BC ^] Вернуться назад
if defined DisableMode_reg (
    echo    ^[ RV ^] Откатить изменения
)
echo    ^[ ST ^] Запустить отключение
echo.
echo.
echo.
echo.
set /p choice="%DEL%                                                                   > "
if /i "%choice%"=="ST" call:PEGASUS
if /i "%choice%"=="ые" call:PEGASUS
if /i "%choice%"=="S_old" call:PEGASUS_old
if defined RevertMode (
    if /i "%choice%"=="Revert" call:PEGASUS_revert
)
if /i "%choice%"=="DF" ( set "history=PEGASUS_Menu;!history!" && goto DfControl)
if /i "%choice%"=="ва" ( set "history=PEGASUS_Menu;!history!" && goto DfControl)
if /i "%choice%"=="bc" goto GoBack
if /i "%choice%"=="ис" goto GoBack
if /i "%choice%"=="md" (
    if "%DisableMode%"=="избирательный" (
        set "DisableMode=полный"
    ) else (
        set "DisableMode=избирательный"
    )
)
if /i "%choice%"=="ьв" (
    if "%DisableMode%"=="избирательный" (
        set "DisableMode=полный"
    ) else (
        set "DisableMode=избирательный"
    )
)
goto PEGASUS_Menu

:PEGASUS_revert
if defined RevertMode (
    if "%RevertMode%"=="избирательный" (
        reg delete "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data\ParameterFunction" /v "Pegasus_DisableMode" /f >nul 2>&1
        cls
        call "%ASX-Directory%\Files\Utilites\PEGASUS\Scripts\Revert-Defender_and_smartscreen.bat"
        REM Запуск PEGASUS с избирательным отключением Windows Defender
    ) else (
        reg delete "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data\ParameterFunction" /v "Pegasus_DisableMode" /f >nul 2>&1
        cls
        call "%ASX-Directory%\Files\Utilites\PEGASUS\Scripts\Revert-WinDefender.bat"
        REM Запуск PEGASUS с полным отключением Windows Defender
    )
)
set "operation_name=Откат Windows Defender с помощью PEGASUS"
call:Complete_notice
goto GoBack

:PEGASUS
if "%DisableMode%"=="избирательный" (
    reg add "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data\ParameterFunction" /v "Pegasus_DisableMode" /t REG_SZ /d "избирательный" /f >nul 2>&1
    cls
    call "%ASX-Directory%\Files\Utilites\PEGASUS\Scripts\Disable-Defender_and_smartscreen.bat"
    REM Запуск PEGASUS с избирательным отключением Windows Defender
) else (
    reg add "HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data\ParameterFunction" /v "Pegasus_DisableMode" /t REG_SZ /d "полный" /f >nul 2>&1
    cls
    call "%ASX-Directory%\Files\Utilites\PEGASUS\Scripts\FullDisable-WinDefender.bat"
    REM Запуск PEGASUS с полным отключением Windows Defender
)
del "%ASX-Directory%\Files\Downloads\PEGASUS.zip" >nul
call:RestoreCreate
start "" "%ASX-Directory%\Files\Utilites\PEGASUS\PEGASUS_start.bat"
set "operation_name=Отключение Windows Defender с помощью PEGASUS"
call:Complete_notice
goto GoBack

:PEGASUS_old
cls
echo  Вы запустили старую версию PEGASUS, которая поддерживается, которая может нанести повреждения вашей системе.
echo  Если вы запустили её ошибочно, то просто закройте окно и заново запустите ASX Hub.
echo.
echo.
echo  Если вы хотите продолжить, нажмите любую клавишу.
pause
call:RestoreCreate
start "" "%ASX-Directory%\Files\Utilites\PEGASUS\PEGASUS_start.bat"
set "operation_name=Удаление Windows Defender с помощью PEGASUS"
call:Complete_notice
goto GoBack

:WinForce
cls
call :ASX_Hub_Downloads_Title 
IF EXIST "%ASX-Directory%\Files\Resources\WinForce.bat" (
	echo %COL%[36m Запуск %COL%[37m
    start "" "%ASX-Directory%\Files\Resources\WinForce.bat"
) ELSE (
	echo %COL%[36m Загрузка дополнительных компонентов %COL%[37m
    curl -g -L -# -o "%ASX-Directory%\Files\Resources\WinForce.bat" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/WinForce.bat"
	    IF %ERRORLEVEL% NEQ 0 (
        echo Ошибка: Не удалось скачать файл WinForce.bat. Проверьте подключение к интернету и доступность URL.
		echo [ERROR] %TIME% - Ошибка при загрузке WinForce.bat >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto GoBack
    )
	start "" "%ASX-Directory%\Files\Resources\WinForce.bat"
)
goto GoBack

:ASX_Benchmark_Restart_Time
cls
echo.
echo   Ваш ПК будет перезагружен для измерения скорости перезагрузки.
echo          Введите Restart для продоления или b для выхода.
set /p choice="%DEL%                                   >: "
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="ч" goto GoBack
if /i "%choice%"=="R" (
	curl -g -L -# -o "%ASX-Directory%\Files\Resources\RestartTime.vbs" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/RestartTime.vbs"
	    IF %ERRORLEVEL% NEQ 0 (
        echo Ошибка: Не удалось скачать файл RestartTime.vbs. Проверьте подключение к интернету и доступность URL.
		echo [ERROR] %TIME% - Ошибка при загрузке RestartTime.vbs >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto GoBack
    )
	start "" "%ASX-Directory%\Files\Resources\RestartTime.vbs"
)
if /i "%choice%"=="к" (
	curl -g -L -# -o "%ASX-Directory%\Files\Resources\RestartTime.vbs" "https://github.com/ALFiX01/ASX-Hub/releases/download/File/RestartTime.vbs"
	    IF %ERRORLEVEL% NEQ 0 (
        echo Ошибка: Не удалось скачать файл RestartTime.vbs. Проверьте подключение к интернету и доступность URL.
		echo [ERROR] %TIME% - Ошибка при загрузке RestartTime.vbs >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto GoBack
    )
	start "" "%ASX-Directory%\Files\Resources\RestartTime.vbs"
)
if /i "%choice%"=="B" goto GoBack
goto GoBack


REM ================================================================================================


:ASX_Information_Developers
cls
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":ASX_Information_Developers" >> "%ASX-Directory%\Files\Logs\%date%.txt"
TITLE О разработчиках - ASX Hub
set PageName=ASX_Information_Developers
set choice=NoInput
echo.
echo                                                                     %COL%[90m[%COL%[96m1 %COL%[90m/ 1%COL%[90m]
echo.
echo.
echo.
echo                                                     %COL%[90m::::::::::: ::::::::::     :::       :::   :::
echo                                                        :+:     :+:          :+: :+:    :+:+: :+:+:
echo                                                       +:+     +:+         +:+   +:+  +:+ +:+:+ +:+
echo                                                      +#+     +#++:++#   +#++:++#++: +#+  +:+  +#+
echo                                                     +#+     +#+        +#+     +#+ +#+       +#+
echo                                                    #+#     #+#        #+#     #+# #+#       #+#
echo                                                   ###     ########## ###     ### ###       ###%COL%[37m
echo.
echo.
echo.
echo.
echo               %COL%[36mРазработчик:%COL%[37m ALFiX
echo               %COL%[36mТестировщик:%COL%[37m Towlats, Flipix
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo %COL%[90m
echo.
Call :TYPEFast "                                  Я глубоко благодарен нашей команде и сообществу, ведь без их неоценимой помощи,"
echo.
Call :TYPEFast "                                                       ASX Hub бы даже не появился на свет."
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                      %COL%[36m[ B - Назад ]       %COL%[91m[ X - Главное меню ]%COL%[90m
echo.
set /p choice="%DEL%                                                                      >: "
if /i "%choice%"=="C" ( set "history=ASX_Information_Developers;!history!" && goto ASX_CMD )
if /i "%choice%"=="с" ( set "history=ASX_Information_Developers;!history!" && goto ASX_CMD )
if /i "%choice%"=="X" ( set "history=ASX_Information_Developers;!history!" && goto MainMenu )
if /i "%choice%"=="ч" ( set "history=ASX_Information_Developers;!history!" && goto MainMenu )
if /i "%choice%"=="B" goto GoBack
if /i "%choice%"=="и" goto GoBack
if /i "%choice%"=="NoInput" goto WrongInput
call:WrongInput
goto ASX_Information_Developers

:Backup
call:RestoreCreate
set "operation_name=Создание Бэкапа"
call:Complete_notice
goto GoBack

:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul
goto :eof

:ASXHubError
TITLE ОШИБКА - ASX Hub
echo [INFO ] %TIME% - Запущено "ASXHubError" >> "%ASX-Directory%\Files\Logs\%date%.txt"
cls
color 06
echo.
echo  --------------------------------------------------------------
echo                   Эта настройка неприменима
echo  --------------------------------------------------------------
echo.
echo      Вы не можете использовать эту оптимизацию
echo.
echo      %~1
echo.
echo.
echo.
echo.
echo      [X] Закрыть
echo.
%SYSTEMROOT%\System32\choice.exe /c:X /n /m "%DEL%                                >:"
goto :eof


:ASX_Hub_Restart
echo [INFO ] %TIME% - Запущено "AssistantXRestart" >> "%ASX-Directory%\Files\Logs\%date%.txt"
setlocal DisableDelayedExpansion
if "%~2" == "%COL%[91mВЫКЛ" (set "ed=enable") else (set "ed=disable")
start "Restart" cmd /V:ON /C @echo off
Mode 65,16
color 06
echo.
echo  --------------------------------------------------------------
echo             Перезапустите, чтобы полностью применить
echo  --------------------------------------------------------------
echo.
echo      Чтобы %ed% %~1 вы должны перезапустить систему.
echo      Вы хотите Перезапустить сейчас?
echo.
echo.
echo.
echo.
echo      [Y] Да
echo      [N] Нет
echo.
:restartchoice
set /p choice=Хотите ли вы продолжить и перезагрузить компьютер? Y или N? 
if /i "%choice%" == "y" (
	shutdown /r /f /d p:0:0
) else if /i "%choice%" == "n" (
	exit /b
) else (
	goto restartchoice
)

goto :eof

:ColorText    
echo off    
<nul set /p ".=%DEL%" > "%~2"    
findstr /v /a:%1 /R "^$" "%~2" nul    
del "%~2" >nul 2>&1    
goto :eof 

:ComingSoon
cls
chcp 65001 >nul 2>&1
cls
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":ComingSoon" >> "%ASX-Directory%\Files\Logs\%date%.txt"
TITLE Совсем скоро тут будет что-то новенькое - ASX Hub
set PageName=ComingSoon
set choice=NoInput
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                            %COL%[91m Увы, эта функция еще не завершена, но скоро появится.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                %COL%[90m Нажмите любую клавишу, чтобы вернуться назад %COL%[37m
pause >nul
goto GoBack

:Completed-Screen
cls
echo %COL%[96m Завершено
echo %COL%[96m Нажмите любую клавишу для выхода
pause >nul
goto :eof

:Quastion
mode con: cols=146 lines=45 >nul 2>&1
Title Ошибка
cls
set /a "total_errors+=1"
setlocal enabledelayedexpansion
for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" 2^>nul ^| find /i "Directory"') do set "ASX-Directory=%%b"

chcp 65001 >nul 2>&1
cls
echo.
echo  %COL%[91mОшибка получения данных о местонахождении директории ASX Hub%COL%[37m
echo.
echo  %COL%[37mВведите путь к папке в которой будет создана папка "ASX Hub"
echo  Пример: Введите %COL%[96m%Systemdrive%\ProgramData %COL%[37m если полный путь к папке выглядит так %COL%[96m%Systemdrive%\ProgramData\(Дирректория-ASX Hub) %COL%[37m
echo  Если вам нужно указать путь к диску на котором будет находиться ASX Hub, то используйте %COL%[96mC:%COL%[37m
echo.
echo.
echo.
echo.
Call :YesNoBox "Если вы будете указывать новый путь - нажмите ДА, а если вы будете указывать путь к папке, в которой ранее уже был установлен ASX Hub то нажмите НЕТ" "ASX Hub"

if "%YesNo%"=="6" (
	set "DialogText=Введите путь к папке в которой будет создана папка ASX Hub"
	set Dt=1
) else (
	set "DialogText=Введите путь к папке в которой ранее были файлы ASX Hub (внутри должна быть папка Files)"
	set Dt=2
)


call:DialogPatchbox
set "CustPatchT=%folder%"

if "%Dt%"=="1" (
echo %CustPatchT%
pause
md %CustPatchT%\ASX Hub
  reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" /t REG_SZ /d "%CustPatchT%\ASX Hub" /f >nul 2>&1
  start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'"
  exit
) else (
set CustPatchT="%folder%" 
  reg add "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" /t REG_SZ /d "%CustPatchT%" /f >nul 2>&1
  start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'"
  exit
)

for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" 2^>nul ^| find /i "Directory"') do set "ASX-Directory=%%b"
echo - ERROR - Ошибка: В реестре отсутствует значение пути к директории ASX Hub >> "%ASX-Directory%\Files\Logs\%date%.txt"
goto :eof

:MSGBOX [Text] [Argument] [Title]
echo WScript.Quit Msgbox(Replace("%~1","\n",vbCrLf),%~2,"%~3") >"%TMP%\msgbox.vbs"
cscript /nologo "%TMP%\msgbox.vbs"
set "exitCode=!ERRORLEVEL!" & del /f /q "%TMP%\msgbox.vbs"
goto :eof

:info_msg
chcp 850 >nul 2>&1
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('%INFO_TEXT%', 'ASX Hub', 'OK', [System.Windows.Forms.MessageBoxIcon]::information);}"  >nul 2>&1
chcp 65001 >nul 2>&1
goto :eof

:YesNoBox
REM returns 6 = Yes, 7 = No. Type=4 = Yes/No
set YesNo=
set MsgType=4
set heading=%~2
set message=%~1
echo wscript.echo msgbox(WScript.Arguments(0),%MsgType%,WScript.Arguments(1)) >"%temp%\input.vbs"
for /f "tokens=* delims=" %%a in ('cscript //nologo "%temp%\input.vbs" "%message%" "%heading%"') do set YesNo=%%a
goto :eof

:DialogPatchbox
set "psCommand="(new-object -COM 'Shell.Application')^
.BrowseForFolder(0,'%DialogText%',0,0).self.path""
chcp 850 >nul 2>&1
for /f "usebackq delims=" %%I in (`powershell %psCommand%`) do set "folder=%%I"
chcp 65001 >nul 2>&1
goto :eof


:Update_screen
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
echo.
echo.
echo.
echo.
echo.
echo.
TITLE Доступно обновление v%UPDVER%
echo [INFO ] %TIME% - Доступно обновление v%UPDVER% >> "%ASX-Directory%\Files\Logs\%date%.txt"	
echo                                                       Для ASX Hub доступно обновление%COL%[36m v%UPDVER%

echo.
echo.
echo                                                                  Хотите обновить?

echo.
echo.
echo.
echo.
echo                                                      %COL%[92mY - Обновить       %COL%[37m^|%COL%[91m       N - Не обновлять
echo %COL%[90m
echo.
echo.
%SYSTEMROOT%\System32\choice.exe /c:YнNт /n /m "%DEL%                                                                     >: "
set choice=!errorlevel!
if !choice! == 1 ( echo Загрузка обновления...
        set errorlevel=0
        echo.
        echo.
        echo.
        echo.
        echo.
        echo.
		reg add "HKCU\Software\ALFiX inc.\ASX" /t REG_SZ /v "SlientMode" /d "No" /f >nul 2>&1
        reg add "HKCU\Software\ALFiX inc.\ASX" /t REG_SZ /v "LastLaunchUpdateInstalled" /d "Yes" /f >nul 2>&1
        curl -g -L -# -o %TEMP%\ASX-Updater.exe "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Updater/ASX-Updater.exe" >nul 2>&1
        echo [INFO ] %TIME% - Обновление %UPDVER% скачано >> "%ASX-Directory%\Files\Logs\%date%.txt"
        start %TEMP%\ASX-Updater.exe
        exit
)
if !choice! == 2 ( echo Загрузка обновления...
        set errorlevel=0
		echo.
		echo.
		echo.
		echo.
		echo.
		echo.	
		reg add "HKCU\Software\ALFiX inc.\ASX" /t REG_SZ /v "SlientMode" /d "No" /f >nul 2>&1		
        reg add "HKCU\Software\ALFiX inc.\ASX" /t REG_SZ /v "LastLaunchUpdateInstalled" /d "Yes" /f >nul 2>&1	
        curl -g -L -# -o %TEMP%\ASX-Updater.exe "https://github.com/ALFiX01/ASX-Hub/raw/main/Files/Updater/ASX-Updater.exe" >nul 2>&1
        echo [INFO ] %TIME% - Обновление %UPDVER% скачано >> "%ASX-Directory%\Files\Logs\%date%.txt"
        start %TEMP%\ASX-Updater.exe
		exit
)
if !choice! == 3 (
	title Загрузка	
	set NoUpd=1
	call:loading_screen
	) else (
	echo [INFO ] %TIME% - Пользователь отказался от загрузки Обновления %UPDVER% >> "%ASX-Directory%\Files\Logs\%date%.txt"
)
if !choice! == 4 (
	title Загрузка	
	set NoUpd=1
	call:loading_screen
	) else (
	echo [INFO ] %TIME% - Пользователь отказался от загрузки Обновления %UPDVER% >> "%ASX-Directory%\Files\Logs\%date%.txt"
)
call:Update_screen


:TYPE
SET "d[text]=%~1"
CALL :TYPELOOP
GOTO :EOF

:TYPELOOP
IF "%d[text]:~0,1%" == "#" (
    <NUL SET /P "=^!"
) else (
    <NUL SET /P "=d!BS!%d[text]:~0,1%"
)
SET "d[text]=%d[text]:~1%"
IF "%d[text]%" == "" (
    GOTO :EOF
) else (
    FOR /L %%J in (1, 100, 10000000) DO REM
    GOTO :TYPELOOP
)
exit

:TYPEFast
SET "d[text]=%~1"
CALL :TYPELOOPFast
GOTO :EOF

:TYPELOOPFast
IF "%d[text]:~0,1%" == "#" (
    <NUL SET /P "=^!"
) else (
    <NUL SET /P "=d!BS!%d[text]:~0,1%"
)
SET "d[text]=%d[text]:~1%"
IF "%d[text]%" == "" (
    GOTO :EOF
) else (
    FOR /L %%J in (1, 100, 1000000) DO REM
    GOTO :TYPELOOPFast
)
exit

::No Input
:NoInput
chcp 850 >nul 2>&1
powershell -Command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('Error: Nothing selected', 'ASX Hub', 'OK', [System.Windows.Forms.MessageBoxIcon]::information);}"  >nul 2>&1
chcp 65001 >nul 2>&1
GOTO %PageName%

::Wrong Input
:WrongInput
Start "" "%ASX-Directory%\Files\Resources\notification.exe" "Ошибка ввода" "Введенный вами текст не распознан" 2000
GOTO :EOF

:NotWiFiConnection
cls
TITLE Предупреждение - ASX Hub
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                       %COL%[91m_       __                 _            
echo                                                      ^| ^|     / /___ __________  ^(_^)___  ____ _
echo                                                      ^| ^| /^| / / __ `/ ___/ __ \/ / __ \/ __ `/
echo                                                      ^| ^|/ ^|/ / /_/ / /  / / / / / / / / /_/ / 
echo                                                      ^|__/^|__/\__,_/_/  /_/ /_/_/_/ /_/\__, /  
echo                                                                                      /____/
echo                                       %COL%[97m----------------------------------------------------------------------%COL%[90m
echo.
echo                                         Данная панель недоступна из-за отсутствия подключения к интернету
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
pause >nul 2>&1
GOTO :EOF

:EnterToRestart
    REM Код для перезапуска системы
    echo.
    echo %COL%[37mДля перезапуска системы введите %COL%[92mrestart%COL%[37m и нажмите Enter.
    set /p user_input=Ввод: 
    if /i "!user_input!"=="restart" (
        echo [INFO ] %TIME% - Вызван ":EnterToRestart" >> "%ASX-Directory%\Files\Logs\%date%.txt"
        echo [INFO ] %TIME% - Перезапуск системы >> "%ASX-Directory%\Files\Logs\%date%.txt"
        shutdown /r /t 0
    ) else (
        echo %COL%[37mПерезапуск отменён. Пожалуйста, перезапустите систему позже.
    )
    goto :eof

:Dynamic
set "SaveData=HKEY_CURRENT_USER\Software\ALFiX inc.\ASX\Data"
echo [INFO ] %TIME% - Вызван ":Dynamic" >> "%ASX-Directory%\Files\Logs\%date%.txt"
REM Проверка, отличается ли ASX_Version_OLD от Version
if "%ASX_Version_OLD%" NEQ "%Version%" (
    set "Dynamic_Upd_on_startPC=Yes"
) else (
    set "Dynamic_Upd_on_startPC=No"
)

REM Проверка версии драйвера видеокарты
for /f "tokens=2*" %%a in ('reg query "%SaveData%\Dynamic" /v "DisplayD_Version" 2^>nul ^| find /i "DisplayD_Version"') do set "Driver_DisplayVersion_old=%%b"

set "Driver_DisplayVersion="
for /f "tokens=*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" /s /f "Display.Driver" /k 2^>nul') do (
    for /f "tokens=2*" %%B in ('reg query "%%A" /v DisplayVersion 2^>nul ^| find /i "DisplayVersion"') do (
        set "Driver_DisplayVersion=%%C"
    )
)

if defined Driver_DisplayVersion (
    if defined Driver_DisplayVersion_old (
        if "%Driver_DisplayVersion_old%" NEQ "%Driver_DisplayVersion%" (
            echo [INFO ] %TIME% - Обнаружено обновление драйвера видеокарты >> "%ASX-Directory%\Files\Logs\%date%.txt"
            set "Dynamic_DisplayVersion_show=Yes"
            reg add "%SaveData%\Dynamic" /v "DisplayD_Version" /t REG_SZ /d "%Driver_DisplayVersion%" /f >nul 2>&1
        )
    ) else (
        echo [INFO ] %TIME% - Создан ключ реестра DisplayD_Version >> "%ASX-Directory%\Files\Logs\%date%.txt"
        reg add "%SaveData%\Dynamic" /v "DisplayD_Version" /t REG_SZ /d "%Driver_DisplayVersion%" /f >nul 2>&1
    )
) else (
    echo [WARN ] %TIME% - Не удалось определить версию драйвера видеокарты >> "%ASX-Directory%\Files\Logs\%date%.txt"
)

REM Проверка существования ключа LastPathNotesCheck
reg query "%SaveData%\Dynamic" /v "LastPathNotesCheck" >nul 2>&1
if %errorlevel% equ 0 (
    REM Ключ существует, получение значения
    for /f "tokens=2*" %%a in ('reg query "%SaveData%\Dynamic" /v "LastPathNotesCheck" 2^>nul ^| find /i "LastPathNotesCheck"') do set "LastPathNotesCheck=%%b"
) else (
    REM Ключ не существует, создание с дефолтным значением
    reg add "%SaveData%\Dynamic" /v "LastPathNotesCheck" /t REG_SZ /d "0" /f >nul 2>&1
    set "LastPathNotesCheck=0"
    echo [INFO ] %TIME% - Создан новый ключ реестра LastPathNotesCheck со значением 0 >> "%ASX-Directory%\Files\Logs\%date%.txt"
)

REM Проверка существования ключа BackupDate
reg query "%SaveData%\Dynamic" /v "BackupDate" >nul 2>&1
if %errorlevel% equ 0 (
    REM Ключ существует, получение значения
    for /f "tokens=2*" %%a in ('reg query "%SaveData%\Dynamic" /v "BackupDate" 2^>nul ^| find /i "BackupDate"') do set "ASX-BackupDate=%%b"
    set "BackupDate=!ASX-BackupDate!"
) else (
    REM Ключ не существует, создание с дефолтным значением
    if not exist "%SaveData%\Dynamic" (
        reg add "%SaveData%\Dynamic" /f >nul 2>&1
    )
    reg add "%SaveData%\Dynamic" /v "BackupDate" /t REG_SZ /d "%date%" /f >nul 2>&1
    echo [INFO ] %TIME% - Создан новый ключ реестра BackupDate со значением %date% >> "%ASX-Directory%\Files\Logs\%date%.txt"
    set "ASX-BackupDate=%date%"
    set "BackupDate=%date%"
)

:: Вызов PowerShell для получения списка точек восстановления
set "found_ASX_Restore_Point=No"
chcp 850 >nul 2>&1
for /f "tokens=*" %%A in ('powershell -command "Get-ComputerRestorePoint | Where-Object {$_.Description -like '*ASX Hub Restore Point*'}" 2^>nul') do (
    set "found_ASX_Restore_Point=Yes"
    chcp 65001 >nul 2>&1
)
if not exist "%ASX-Directory%\Files\Restore\%BackupDate%" (
    set "found_ASX_Restore_Point=No"
)
chcp 65001 >nul 2>&1

echo [INFO ] %TIME% - Вызван ":Dynamic 2" >> "%ASX-Directory%\Files\Logs\%date%.txt"

REM Проверка существования ключа ProcessErrorCount
reg query "%SaveData%\Dynamic" /v "ProcessErrorCount" >nul 2>&1
if %errorlevel% equ 0 (
    REM Ключ существует, получение значения
    for /f "tokens=2*" %%a in ('reg query "%SaveData%\Dynamic" /v "ProcessErrorCount" 2^>nul ^| find /i "ProcessErrorCount"') do set "ProcessErrorCount=%%b"
) else (
    REM Ключ не существует, создание с дефолтным значением
    if not exist "%SaveData%\Dynamic" (
        reg add "%SaveData%\Dynamic" /f >nul 2>&1
    )
    reg add "%SaveData%\Dynamic" /v "ProcessErrorCount" /t REG_SZ /d "0" /f >nul 2>&1
    set "ProcessErrorCount=0"
    echo [INFO ] %TIME% - Создан новый ключ реестра ProcessErrorCount со значением 0 >> "%ASX-Directory%\Files\Logs\%date%.txt"
)

if not exist "%ASX-Directory%\Files\Restore" set "NotFoundRestoreFolder=1"

set "count=0"
for /f "tokens=1 delims=," %%a in ('tasklist /NH /FO CSV /FI "IMAGENAME eq ASX Hub.exe" 2^>nul') do (
    set /a count+=1
    set "processName=%%~a"
)

if !count! gtr 1 (
    for /f "tokens=2*" %%a in ('reg query "%SaveData%\Dynamic" /v "ProcessErrorCount" 2^>nul ^| find /i "ProcessErrorCount"') do (
        set "ProcessErrorCount=%%b"
    )
    set /a ProcessErrorCount+=1
    set "DynamicProcessErrorCount=Yes"
    reg add "%SaveData%\Dynamic" /v "ProcessErrorCount" /t REG_SZ /d "!ProcessErrorCount!" /f >nul 2>&1
    echo [WARN ] %time% - Запуск произведён - Запущено более 1 процесса ASX Hub >> "%ASX-Directory%\Files\Logs\%date%.txt"
    if !ProcessErrorCount! gtr 2 (
        echo [ERROR] %time% - Запуск ASX Hub был принудительно отменён - Запущено более 1 процесса ASX Hub >> "%ASX-Directory%\Files\Logs\%date%.txt"
        exit
    )
)


REM Кол-во месяцев (Dynamic)
chcp 850 >nul 2>&1
for /f %%a in ('powershell -Command "$date1 = [datetime]::ParseExact('%BackupDate%', 'dd.MM.yyyy', $null); $date2 = Get-Date; [math]::Abs(($date2 - $date1).Days)"') do set "days=%%a"
echo [INFO ] %TIME% - Количество дней с момента создания backup: %days% >> "%ASX-Directory%\Files\Logs\%date%.txt"
chcp 65001 >nul 2>&1
echo [INFO ] %TIME% - Завершен ":Dynamic" >> "%ASX-Directory%\Files\Logs\%date%.txt"
REM Подсчёт элементов автозагрузки
set "StartupCount=0"
:: Перебираем ключи в указанном разделе реестра
for /f "tokens=3 delims= " %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /t REG_SZ 2^>nul') do (
  :: Увеличиваем счетчик для каждого найденного ключа REG_SZ
  set /a "StartupCount+=1"
)
:: Вычитаем стандартный ключ REG_SZ
set /a "StartupCount-=1"

:: if not defined DriverFinder_Count (
::     set "DriverFinder_Count=1"
::     "%ASX-Directory%\Files\Utilites\ASX_DriverFinder\DriverFinder_FindService.exe"
:: ) else (
::     set /a "DriverFinder_Count+=1"
:: )


GOTO :EOF

:: Система - Dynamic
:Dynamic_Script

for /f "tokens=2*" %%a in ('reg query "%SaveData%\Dynamic" /v "LastPathNotesCheck" 2^>nul ^| find /i "LastPathNotesCheck"') do set "LastPathNotesCheck=%%b"
 if not defined LastPathNotesCheck set "LastPathNotesCheck=0"

for /f "tokens=2*" %%a in ('reg query "%SaveData%\Dynamic" /v "OutdatedDrivers" 2^>nul ^| find /i "OutdatedDrivers"') do set "OutdatedDrivers=%%b"
 if not defined OutdatedDrivers set "OutdatedDrivers=0"


echo [INFO ] %TIME% - Вызван ":Dynamic_Script" >> "%ASX-Directory%\Files\Logs\%date%.txt"
set "Assistant_Message="

if "%total_errors%" GEQ "1" (
    set "Assistant_Message=Ассистент: Внимание были обнаружены ошибки (%total_errors%) [ F ]"
    REM echo                                              %COL%[90mАссистент: %COL%[91mВнимание %COL%[90mбыли обнаружены ошибки ^(%total_errors%^) ^[ F ^]
    set "RecomendedPanelNameGOTO=OpenLogs"
) else if "%Dynamic_Upd_on_startPC%"=="Yes" (    
    REM ASX Hub был обновлён до v%Version%
    set "Assistant_Message=Ассистент: ASX Hub был обновлен до v%Version%  [ F ]"
    set "RecomendedPanelNameGOTO=PatchNotesOpen"
) else if "%DynamicProcessErrorCount%"=="Yes" (    
    REM Запуск ASX Hub был принудительно отменён - Запущено более 1 процесса ASX Hub
    set "Assistant_Message=Ассистент: Оставьте открытым только 1 ASX Hub из !count! запущенных [ F ]"
    set "RecomendedPanelNameGOTO=Dynamic_Close_ASX"
) else if "%CustomUserName%"=="User" (
    REM Пользователь не зарегистрирован
    set "Assistant_Message=Ассистент: Совет - Вы можете сменить имя пользователя ASX Hub [ F ]"
    set "PageName=MainMenu"
    set "RecomendedPanelNameGOTO=CustomUserName"
) else if "%CustomUserNameWarn%"=="1" (
    REM Пользователь не зарегистрирован
    set "Assistant_Message=Ассистент: Отредактировать имя пользователя ASX Hub [ F ]"
    set "PageName=MainMenu"
    set "RecomendedPanelNameGOTO=CustomUserName"
) else if "%WiFi%"=="Off" (
    REM WiFi выключен
    set "Assistant_Message=Ассистент: Проверить сеть WiFi [ F ]"
    set "RecomendedPanelNameGOTO=Dynamic_WiFiCheck"
) else if !NotFoundRestoreFolder! equ 1 (
    REM Не найдена папка восстановления
    set "Assistant_Message=Ассистент: Не найдена папка восстановления. Необходимо создать точку восстановления [ F ]"
    echo [DEBUG] %TIME% - Не найдена папка восстановления. Необходимо создать точку восстановления >> "%ASX-Directory%\Files\Logs\%date%.txt"
    set "RecomendedPanelNameGOTO=RestoreHub"
) else if !days! gtr 50 (
    REM Точка восстановления слишком старшая
    set "Assistant_Message=Ассистент: Точка восстановления слишком старая. Необходимо создать новую [ F ]"
    echo [DEBUG] %TIME% - Точка восстановления слишком старшая. Необходимо создать точку восстановления >> "%ASX-Directory%\Files\Logs\%date%.txt"
    set "RecomendedPanelNameGOTO=RestoreHub"
) else if "%found_ASX_Restore_Point%"=="No" (
    REM Не найдена точка восстановления
    set "Assistant_Message=Ассистент: Не найдена точка восстановления. Необходимо создать её [ F ]"
    echo [DEBUG] %TIME% - Не найдена точка восстановления. Необходимо создать точку восстановления >> "%ASX-Directory%\Files\Logs\%date%.txt"
    set "RecomendedPanelNameGOTO=RestoreHub"
) else if "%LastPathNotesCheck%" NEQ "%VersionNumberCurrent%" (
    REM Не просмотрены последние обновления
    set "Assistant_Message=Ассистент: Ознакомиться с описанием обновления v%FullVersionNameCurrent% [ F ]"
    set "RecomendedPanelNameGOTO=PatchNotesOpen"
) else if %OutdatedDrivers% geq 2 (
    REM Устаревшие версии драйверов
    set "Assistant_Message=Ассистент: Рекомендуется удалить устаревшие версии драйверов [ F ]"
    set "RecomendedPanelNameGOTO=DriverFinder_Menu"
) else if !StartupCount! gtr 10 (
    set "Assistant_Message=Ассистент: В автозагрузке слишком много программ ^(!StartupCount!^) [ F ]"
    set "RecomendedPanelNameGOTO=Dynamic_StartupManager"
    echo [INFO ] %TIME% - Много программ в автозагрузке: !StartupCount! >> "%ASX-Directory%\Files\Logs\%date%.txt"
)

rem Найдем длину строки Assistant_Message
set "length=0"
if defined Assistant_Message (
    for /L %%i in (0,1,146) do (
        set "char=!Assistant_Message:~%%i,1!"
        if "!char!"=="" goto end_Assistant_Message
        set /A length+=1
    )
)
:end_Assistant_Message

rem Рассчитаем количество пробелов для выравнивания по центру
set /A spaces=(146-length)/2
if %spaces% lss 0 set "spaces=0"

rem Создадим строку с пробелами
set "padding_Assistant_Message="
for /L %%i in (1,1,%spaces%) do set "padding_Assistant_Message=!padding_Assistant_Message! "

rem Добавим пробелы перед Assistant_Message
if defined Assistant_Message (
    set "Assistant_Message=!padding_Assistant_Message!!Assistant_Message!"
    echo %COL%[90m!Assistant_Message!%COL%[0m
) else (
    echo.
)

echo [INFO ] %TIME% - Завершен ":Dynamic_Script" >> "%ASX-Directory%\Files\Logs\%date%.txt"
GOTO :EOF

:OpenLogs
start "" "%ASX-Directory%\Files\Logs\%date%.txt"
goto GoBack

:Dynamic_WiFiCheck
start ms-settings:network-wifi
goto GoBack

:Dynamic_DownloadsOpen
start "" "%UserProfile%\Downloads"
goto GoBack

:Dynamic_Close_ASX
exit
goto MainMenu

:Dynamic_StartupManager
Start "" "%ASX-Directory%\Files\Resources\notification.exe" "Откройте в реестре" "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" 15000
start regedit.exe
goto MainMenu

:Dynamic_Backup
call:RestoreCreate
REM goto RestoreHub
set "operation_name=Создание Бэкапа"
call:Complete_notice
goto GoBack

:PatchNotesOpen
cls
reg add "%SaveData%\Dynamic" /v "LastPathNotesCheck" /t REG_SZ /d "%VersionNumberCurrent%" /f >nul 2>&1
echo [INFO ] %TIME% - Открыта панель ":PatchNotesOpen" - было предложено системой Dynamic >> "%ASX-Directory%\Files\Logs\%date%.txt"
set PageName=PatchNotesOpen
set choice=NoInput
set "ASX_Version_OLD=%Version%"
TITLE Описание обновления %Version% - ASX Hub
set "ASX_Version_TEXT=Описание обновления %FullVersionNameCurrent%"
set "length_ASX_Version_TEXT=0"
for /L %%i in (0,1,146) do (
    set "char=!ASX_Version_TEXT:~%%i,1!"
    if "!char!"=="" goto end_ASX_Version_TEXT
    set /A length_ASX_Version_TEXT+=1
)

:end_ASX_Version_TEXT
set "dashes="
for /L %%i in (1,1,%length_ASX_Version_TEXT%) do set "dashes=!dashes!-"

echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: :::::::::
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+:
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
echo.
echo.
echo.
echo       %COL%[36mОписание обновления %COL%[37m%FullVersionNameCurrent%%COL%[37m
echo       %COL%[97m!dashes!
echo.
echo         %COL%[36m1.%COL%[37m На панель Кастомизации добавлен пункт "Корзина в проводнике".
echo         %COL%[36m2.%COL%[37m На панель Complete_notice добавлена подсказка "Нажми Enter, чтобы продолжить".
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                %COL%[90m Нажмите любую клавишу, чтобы вернуться назад %COL%[37m
pause >nul 2>&1
goto GoBack

:RestoreCreate
cls
title Создание файлов восстановления [0/6]
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")
echo.
echo.
echo.
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: ::::::::: 
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+: 
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+  
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+    
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+    
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#     
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  #########
echo.
echo.
echo           Пожалуйста, подождите немного.
echo           Мы создаём файлы восстановления, чтобы вы могли вернуть всё, или почти всё, в исходное состояние, если что-то пойдёт не так.
echo.
echo.

REM Подсчёт количества папок
set /a folderCount=0
for /d %%A in ("%ASX-Directory%\Files\Restore\*") do (
    set /a folderCount+=1
)

REM Удаление старых папок, если их больше 3
if !folderCount! gtr 3 (
    for /f "skip=3 delims=" %%A in ('dir "%ASX-Directory%\Files\Restore" /ad /o-d /b') do (
        rd /s /q "%ASX-Directory%\Files\Restore\%%A"
        echo [INFO ] %TIME% - Папка '%ASX-Directory%\Files\Restore\%%A' была удалена для оптимизации директории ASX >> "%ASX-Directory%\Files\Logs\%date%.txt"
    )
)

echo           %COL%[92m- Создание точки восстановления системы...
reg add "%SaveData%\Dynamic" /v "BackupDate" /t REG_SZ /d "%date%" /f >nul
chcp 850 >nul 2>&1
powershell.exe -Command "Enable-ComputerRestore -Drive %systemdrive%"
powershell.exe -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description 'ASX Hub Restore Point %date%' -RestorePointType 'MODIFY_SETTINGS'"
chcp 65001 >nul 2>&1

title Подготовка файлов восстановления...
SET RegBackupPath=%ASX-Directory%\Files\Restore\%date%

if exist "%ASX-Directory%\Files\Restore\%date%" rd /s /q "%ASX-Directory%\Files\Restore\%date%" >nul
if not exist "%ASX-Directory%\Files\Restore\%date%" mkdir "%ASX-Directory%\Files\Restore\%date%" >nul

echo           - Копирование HKCR реестра...
title Создание файлов восстановления [1/6]
REG export HKCR "%RegBackupPath%\HKCR.Reg" /y >nul

echo           - Копирование HKCU реестра...
title Создание файлов восстановления [2/6]
REG export HKCU "%RegBackupPath%\HKCU.Reg" /y >nul

echo           - Копирование HKLM реестра...
title Создание файлов восстановления [3/6]
REG export HKLM "%RegBackupPath%\HKLM.reg" /y >nul

echo           - Копирование HKU реестра...
title Создание файлов восстановления [4/6]
REG export HKU "%RegBackupPath%\HKU.Reg" /y >nul

echo           - Копирование HKCC реестра...
title Создание файлов восстановления [5/6]
REG export HKCC "%RegBackupPath%\HKCC.Reg" /y >nul

echo           - Объединение файлов реестра...
title Завершение создания файлов восстановления...
COPY "%RegBackupPath%\HKLM.reg"+"%RegBackupPath%\HKCU.reg"+"%RegBackupPath%\HKCR.reg"+"%RegBackupPath%\HKU.reg"+"%RegBackupPath%\HKCC.reg" "%RegBackupPath%\Backup.reg" >nul

echo           - Копирование служб реестра...
title Создание файла восстановления служб [1/1]
REG export HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services "%RegBackupPath%\Services.Reg" /y >nul

echo           - Создание файлов восстановления завершено

REM Подсчет количества папок в директории Restore
set "folder_count=0"
for /d %%D in ("%ASX-Directory%\Files\Restore\*") do set /a folder_count+=1

if %folder_count% gtr 2 (
    REM Создаем временный файл для сортировки папок по дате
    dir /ad /b /o-d "%ASX-Directory%\Files\Restore\*" > "%TEMP%\folders.txt"
    
    REM Пропускаем первые 2 строки (самые новые папки)
    set "line_count=0"
    for /f "skip=2" %%F in (%TEMP%\folders.txt) do (
        rd /s /q "%ASX-Directory%\Files\Restore\%%F" >nul 2>&1
        if errorlevel 1 (
            echo [ERROR] %TIME% - Ошибка при удалении старой папки "%%F" из Restore >> "%ASX-Directory%\Files\Logs\%date%.txt"
            set /a "error_on_loading_6+=1"
        ) else (
            echo           - Удаление старых файлов восстановления завершено%COL%[90m
            echo [INFO ] %TIME% - Удалена старая папка "%%F" из Restore >> "%ASX-Directory%\Files\Logs\%date%.txt"
        )
    )
    
    REM Удаляем временный файл
    del "%TEMP%\folders.txt" >nul 2>&1
)

title Cоздание файлов восстановления ЗАВЕРШЕНО
goto GoBack

:GoBack
REM Переход на предыдущую страницу из истории, если она есть
if defined history (
    if "!history!"=="" (
        echo [INFO ] %TIME% - История пуста, возврат невозможен >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto MainMenu
    )
    
    for /F "tokens=1,* delims=;" %%a in ("!history!") do (
        set "page=%%a"
        set "history=%%b"
        goto :processPage
    )
    :processPage
    if defined page (
        echo [INFO ] %TIME% - Переход на страницу !page! >> "%ASX-Directory%\Files\Logs\%date%.txt"
        goto !page!
    ) else (
        echo [INFO ] %TIME% - История пуста, страница не определена >> "%ASX-Directory%\Files\Logs\%date%.txt"
        pause
    )
) else (
    echo [INFO ] %TIME% - История не определена, возврат на главную страницу >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto MainMenu
)
goto :eof

:ASX_ERROR_TEMPLATE
cls
TITLE Ошибка - ASX Hub
if not defined ASX_ERROR_TEMPLATE_TEXT set "ASX_ERROR_TEMPLATE_TEXT=Произошла неизвестная ошибка"
echo [ERROR] %TIME% - %ASX_ERROR_TEMPLATE_TEXT% >> "%ASX-Directory%\Files\Logs\%date%.txt"

set "ASX_ERROR_TEMPLATE_TEXT_VIEW=%COL%[90m%ASX_ERROR_TEMPLATE_TEXT%"
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                               %COL%[91m______                    
echo                                                              / ____/_____________  _____
echo                                                             / __/ / ___/ ___/ __ \/ ___/
echo                                                            / /___/ /  / /  / /_/ / /    
echo                                                           /_____/_/  /_/   \____/_/
echo                                             %COL%[97m----------------------------------------------------------
echo                                              %COL%[91mПодробности:
echo.
echo                                              %ASX_ERROR_TEMPLATE_TEXT_VIEW%
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
pause >nul 2>&1
goto :eof

:ASX_Hub_Downloads_Title 
cls
chcp 65001 >nul 2>&1
echo.
echo.
echo                                            %COL%[90m:::      ::::::::  :::    :::          :::    ::: :::    ::: ::::::::: 
echo                                         :+: :+:   :+:    :+: :+:    :+:          :+:    :+: :+:    :+: :+:    :+: 
echo                                       +:+   +:+  +:+         +:+  +:+           +:+    +:+ +:+    +:+ +:+    +:+  
echo                                     +#++:++#++: +#++:++#++   +#++:+            +#++:++#++ +#+    +:+ +#++:++#+    
echo                                    +#+     +#+        +#+  +#+  +#+           +#+    +#+ +#+    +#+ +#+    +#+    
echo                                   #+#     #+# #+#    #+# #+#    #+#          #+#    #+# #+#    #+# #+#    #+#     
echo                                  ###     ###  ########  ###    ###          ###    ###  ########  ######### 
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                                        %COL%[90m___
echo                                                                       %COL%[90m^|   ^| 
echo                                                                       %COL%[90m^|   ^|
echo                                                                       %COL%[90m^|   ^|
echo                                                                     %COL%[90m__^|   ^|__
echo                                                                     %COL%[90m\       /
echo                                                                      %COL%[90m\     /
echo                                                                       %COL%[90m\   /
echo                                                                        %COL%[90m\_/
echo.
echo                                                             %COL%[90m^|  ^|                 ^|  ^|
echo                                                             %COL%[90m^|  ^|_________________^|  ^|
echo                                                             %COL%[90m^|_______________________^|
echo.
echo.
goto :eof


REM Вызов функции Reg_default с аргументами
:Reg_default
set "SubKey=%~1"
set "ValueName=%~2"
set "KeyName=%~3"

REM Формируем путь к реестру с учетом переданной подпапки
if defined SubKey (
    set "DF_Setting_Key=HKCU\Software\ALFiX inc.\ASX\DF_Setting\%SubKey%"
) else (
    set "DF_Setting_Key=HKCU\Software\ALFiX inc.\ASX\DF_Setting"
)

REM Получаем значение и тип ключа JPEGImportQuality из "HKCU\Control Panel\Desktop"
for /f "tokens=2,3" %%A in ('reg query "%KeyName%" /v "%ValueName%" 2^>nul') do (
    set "ValueType=%%A"
    set "DesktopValue=%%B"
)

if not defined DesktopValue (
    echo [DEBUG] %TIME% - Значение %ValueName% не найдено в %KeyName%. >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto :eof
)

REM Проверяем наличие ключа в %DF_Setting_Key%
for /f "tokens=2,3" %%A in ('reg query "%DF_Setting_Key%" /v "%ValueName%" 2^>nul') do set "DFSettingValue=%%B"

if not defined DFSettingValue (
    REM Ключа нет, добавляем его в реестр
    echo [DEBUG] %TIME% - Ключ %ValueName% не найден в %DF_Setting_Key%. Добавляем... >> "%ASX-Directory%\Files\Logs\%date%.txt"

    REM Выбираем правильный тип данных для записи
    if /I "!ValueType!" EQU "REG_DWORD" (
        reg add "%DF_Setting_Key%" /v "%ValueName%" /t REG_DWORD /d %DesktopValue% /f >nul 2>&1
    ) else if /I "!ValueType!" EQU "REG_SZ" (
        reg add "%DF_Setting_Key%" /v "%ValueName%" /t REG_SZ /d "%DesktopValue%" /f >nul 2>&1
    )

    echo [DEBUG] %TIME% - Значение %ValueName% добавлено в %DF_Setting_Key% со значением %DesktopValue% и типом %ValueType%. >> "%ASX-Directory%\Files\Logs\%date%.txt"
) else (
    REM Ключ есть, выводим его значение
    echo [DEBUG] %TIME% - echo Ключ %ValueName% уже существует в %DF_Setting_Key% со значением %DFSettingValue%. >> "%ASX-Directory%\Files\Logs\%date%.txt"
)
goto :eof

:Reg_default_Check
REM удалить
set "SubKey=%~1"
set "ValueName=%~2"

REM Включаем косвенное расширение переменных

REM Формируем путь к реестру с учетом переданной подпапки
if defined SubKey (
    set "DF_Setting_Key=HKCU\Software\ALFiX inc.\ASX\DF_Setting\%SubKey%"
) else (
    set "DF_Setting_Key=HKCU\Software\ALFiX inc.\ASX\DF_Setting"
)

REM Проверяем наличие ключа в %DF_Setting_Key%
for /f "tokens=2,3" %%A in ('reg query "%DF_Setting_Key%" /v "%ValueName%" 2^>nul') do set "DFSettingValue=%%B"

if not defined DFSettingValue (
    REM Ключ не найден
    echo [ERROR] %TIME% - Ключ %ValueName% не найден в %DF_Setting_Key%. >> "%ASX-Directory%\Files\Logs\%date%.txt"
    goto :eof
)

REM Сохраняем значение ключа в переменную с динамическим именем
set "VarName=DFSettingValue_%ValueName%"
set "!VarName!=%DFSettingValue%"

REM Выводим значение для проверки
echo [DEBUG] %TIME% - Значение ключа %ValueName% в %DF_Setting_Key% сохранено в переменную !VarName! = !DFSettingValue_%ValueName%! >> "%ASX-Directory%\Files\Logs\%date%.txt"
goto :eof



:ASX_Uninstall
curl -g -L -# -o %TEMP%\ASX_Uninstaller.exe "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/Scripts/ASX_Uninstaller.exe" >nul 2>&1
start %TEMP%\ASX_Uninstaller.exe
exit

:: операторы
REM < - Меньше
REM > - Больше
REM == - Равно
REM EQU | равняется
REM NEQ | не равно
REM LSS | менее
REM LEQ | меньше или равно
REM GTR | больше, чем
REM GEQ | больше или равно

endlocal