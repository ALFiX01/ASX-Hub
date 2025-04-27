@echo off

:: Запуск от имени администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    REM start "" /wait /I /min powershell -NoProfile -Command "Start-Process -FilePath '%~s0' -Verb RunAs"
    powershell -Command "Start-Process 'cmd.exe' -ArgumentList '/c \"\"%~f0\" admin\"' -Verb RunAs"
    exit /b
)

setlocal EnableDelayedExpansion

chcp 65001 >nul 2>&1

REM Setting the Directory variable
reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" >nul 2>&1
if errorlevel 1 (
    REM If the key does not exist, create it and the directory
) else (
    REM If the key exists, gets the value
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\ALFiX inc.\ASX\Settings" /v "Directory" 2^>nul ^| find /i "Directory"') do set "ASX-Directory=%%b"
)


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
pause