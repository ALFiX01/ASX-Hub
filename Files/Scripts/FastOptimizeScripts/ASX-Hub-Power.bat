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


echo [INFO ] %TIME% - Активация плана электропитания ASX >> "%ASX-Directory%\Files\Logs\%date%.txt"
echo Активация плана электропитания ASX
  chcp 850 >nul 2>&1	
  powercfg -restoredefaultschemes
  chcp 65001 >nul 2>&1
  curl -g -L -s -o "%temp%\ASX-Power.pow" "https://github.com/ALFiX01/ASX-Hub/raw/refs/heads/main/Files/PowerPlan/ASX-Power.pow"
  if %errorlevel% equ 0 (
      for %%A in ("%temp%\ASX-Power.pow") do (
        if %%~zA gtr 6144 (
          echo [INFO ] %TIME% - Установка плана электропитания ASX прошла успешно >> "%ASX-Directory%\Files\Logs\%date%.txt"
          echo Успешно
          chcp 850 >nul 2>&1
          powercfg /d 44444444-4444-4444-4444-444444444449 >nul 2>&1 
          powercfg -import "%temp%\ASX-Power.pow" 44444444-4444-4444-4444-444444444449 >nul 2>&1 
          powercfg -SETACTIVE "44444444-4444-4444-4444-444444444449" >nul 2>&1 
          chcp 65001 >nul 2>&1
          REM powercfg /changename 44444444-4444-4444-4444-444444444449 "ASX Power" "Оптимизировано для высокой частоты кадров и минимальной задержки." >nul 2>&1 
          del "%temp%\ASX-Power.pow" >nul 2>&1
        ) else (
            echo [INFO ] %TIME% - Ошибка при установке плана электропитания ASX >> "%ASX-Directory%\Files\Logs\%date%.txt"
            echo Ошибка при установке плана электропитания ASX %COL%[37m
        )
      )
  ) else (
      echo [ERROR] %TIME% - Ошибка при загрузке плана электропитания ASX >> "%ASX-Directory%\Files\Logs\%date%.txt"
      echo Ошибка: Загрузка файла плана электропитания ASX не удалась. %COL%[37m
  )
  pause >nul 2>&1