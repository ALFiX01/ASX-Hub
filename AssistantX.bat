REM Copyright (C) 2023 ALFiX, Inc.

REM This program is free software: you can redistribute it and/or modify
REM it under the terms of the GNU Affero General Public License as published
REM by the Free Software Foundation, either version 3 of the License, or

REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; even without the implied security guarantee

REM You should have received a copy of the GNU Affero General Public License
REM along with this program.  If not, see <https://www.gnu.org/licenses/>.

@echo off
title Preparing...
color 06
Mode 130,45
setlocal EnableDelayedExpansion

REM Make Directories
mkdir %SYSTEMDRIVE%\AssistantX >nul 2>&1
mkdir %SYSTEMDRIVE%\AssistantX\Resources >nul 2>&1
mkdir %SYSTEMDRIVE%\AssistantX\AssistantXRevert >nul 2>&1
mkdir %SYSTEMDRIVE%\AssistantX\Downloads >nul 2>&1
mkdir %SYSTEMDRIVE%\AssistantX\AssistantAi >nul 2>&1
cd %SYSTEMDRIVE%\AssistantX

REM Run as Admin
reg add HKLM /F >nul 2>&1
if %errorlevel% neq 0 start "" /wait /I /min powershell -NoProfile -Command start -verb runas "'%~s0'" && exit /b

REM Show Detailed BSoD
reg add "HKLM\System\CurrentControlSet\Control\CrashControl" /v "DisplayParameters" /t REG_DWORD /d "1" /f >nul 2>&1


REM Blank/Color Character
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (set "DEL=%%a" & set "COL=%%b")

:Disclaimer
for %%i in (Branch) do (set "%%i=Release") >nul 2>&1
reg query "HKCU\Software\AssistantX" /v "BETAbranch" || set "Branch=Release" >nul 2>&1
reg query "HKCU\Software\AssistantX" /v "RELEASEbranch" || set "Branch=Beta" >nul 2>&1
cls
if "%Branch%" == "Release" (
reg query "HKCU\Software\AssistantX" /v "Disclaimer" >nul 2>&1 && goto CheckForUpdates >nul 2>&1
) >nul 2>&1 else (
reg query "HKCU\Software\AssistantX" /v "Disclaimer" >nul 2>&1 && goto CheckForBetaUpdates >nul 2>&1
) >nul 2>&1
if "%Branch%" == "Beta" (
goto CheckForBetaUpdates)
cls
echo.
echo.
call :AssistantXTitle
TITLE Disclaimer - AssistantX v%localtwo%
echo.
echo                                              %COL%[90m  AssistantX is a free desktop utility
echo                                        %COL%[90m     made to improve your day-to-day productivity
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo %COL%[37m  Please note that we cannot guarantee an FPS boost from applying our optimizations, every system + configuration is different.
echo.
echo     %COL%[96m1.%COL%[37m Everything is "use at your own risk", we are %COL%[91mNOT LIABLE%COL%[37m if you damage your system in any way
echo.
echo     %COL%[96m2.%COL%[37m If you don't know what a tweak is, do not use it and contact our support team to receive more assistance.
echo.
echo     %COL%[96m3.%COL%[37m Although we have an automatic restore feature, we strongly recommend that you make a manual restore point before running it.
echo.
echo   For any questions and/or concerns, please join our discord: discord.gg/J7wghdhKsx
echo.
echo   Please enter "I agree" without quotes to continue:
echo.
echo.
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!" neq "i agree" goto Disclaimer
reg add "HKCU\Software\AssistantX" /v "Disclaimer" /f >nul 2>&1

:CheckForUpdates
set local=1.5.0
set localtwo=%LOCAL%
TITLE Checking for updates...
if exist "%TEMP%\Updater.bat" DEL /S /Q /F "%TEMP%\Updater.bat" >nul 2>&1
curl -g -L -# -o "%TEMP%\Updater.bat" "https://raw.githubusercontent.com/ALFiX01/AssistantX/main/Files/AssistantXVersion" >nul 2>&1
call "%TEMP%\Updater.bat"
if "%LOCAL%" gtr "%LOCALTWO%" (
	clsr
	Mode 65,16
	echo.
	echo  --------------------------------------------------------------
	echo                           Update found
	echo  --------------------------------------------------------------
	echo.
	echo                    Your current version: %COL%[94m%LOCALTWO%%COL%[33m
	echo.
	echo                          New version: %COL%[94m%LOCAL%
	echo.
	echo.
	echo.
	echo      %COL%[32m[Y] Yes, Update
	echo      %COL%[31m[N] No%COL%[37m
	echo.
	%SYSTEMROOT%\System32\choice.exe /c:YN /n /m "%DEL%                                >:"
	set choice=!errorlevel!
	if !choice! == 1 (
		curl -L -o %0 "https://github.com/ALFiX01/AssistantX/releases/download/Stable/AssistantX.bat" >nul 2>&1
		call %0
		exit /b
	)
	Mode 130,45
)
REM Attempt to enable WMIC
dism /online /enable-feature /featurename:MicrosoftWindowsWMICore /NoRestart >nul 2>&1

REM Check If First Launch
set firstlaunch=1
>nul 2>&1 call "%SYSTEMDRIVE%\AssistantX\AssistantXRevert\firstlaunch.bat"
if "%firstlaunch%" == "1" ( set "Branch=Release" >nul 2>&1 )
if "%firstlaunch%" == "0" (goto MainMenu)
reg add HKCU\CONSOLE /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

REM Restore Point
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Checkpoint-Computer -Description 'AssistantX Restore Point' >nul 2>&1

REM HKCU & HKLM backup
for /F "tokens=2" %%i in ('date /t') do set date=%%i
set date1=%date:/=.%
>nul 2>&1 md %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%
reg export HKLM %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%\HKLM.reg /y >nul 2>&1
reg export HKCU %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%\HKCU.reg /y >nul 2>&1
echo set "firstlaunch=0" > %SYSTEMDRIVE%\AssistantX\AssistantXRevert\firstlaunch.bat

:AssistantXTitle 
echo                                                                                            %COL%[33m##      ##
echo                                    %COL%[33m####              ##         ##                   ##     ##    ##
echo                                   %COL%[33m##  ##   ###  ###       ###  ####   ####  #####   ####     ##  ##
echo                                   %COL%[33m######  ###  ###   ##  ###    ##   ## ##  ##  ##   ##        ##
echo                                   %COL%[33m##  ##    ##   ##  ##    ##   ##   ## ##  ##  ##   ##      ##  ##
echo                                   %COL%[33m##  ##  ###  ###   ##  ##     ###   ####  ##  ##   ###    ##    ##
echo                                                                                            %COL%[33m##      ## 
echo.
goto :eof

:CheckForBetaUpdates
set localnum=0
set localnumtwo=%LOCALNUM%
set local=1.6.0
set localtwo=%LOCAL%
TITLE Checking beta updates...
if exist "%TEMP%\Updater.bat" DEL /S /Q /F "%TEMP%\Updater.bat" >nul 2>&1
curl -g -L -# -o "%TEMP%\Updater.bat" "https://raw.githubusercontent.com/ALFiX01/AssistantX/main/Files/AssistantXBetaVersionNum" >nul 2>&1
call "%TEMP%\Updater.bat"
if "%LOCALNUM%" gtr "%LOCALNUMTWO%" (
	clsr
	Mode 65,16
	echo.
	echo  --------------------------------------------------------------
	echo                         Beta Update found
	echo  --------------------------------------------------------------
	echo.
	echo                   Your current version: %COL%[94m%LOCALTWO% beta %LOCALNUMTWO%%COL%[33m
	echo.
	echo                         New version: %COL%[94m%LOCAL% beta %LOCALNUM%
	echo.
	echo.
	echo.
	echo      %COL%[32m[Y] Yes, Update
	echo      %COL%[31m[N] No%COL%[37m
	echo.
	%SYSTEMROOT%\System32\choice.exe /c:YN /n /m "%DEL%                                >:"
	set choice=!errorlevel!
	if !choice! == 1 (
		curl -L -o %0 "https://github.com/ALFiX01/AssistantX/releases/download/BetaFile/AssistantX.bat" >nul 2>&1
		call %0
		exit /b
	)
	Mode 130,45
)
REM Attempt to enable WMIC
dism /online /enable-feature /featurename:MicrosoftWindowsWMICore /NoRestart >nul 2>&1

REM Check If First Launch
set firstlaunch=1
>nul 2>&1 call "%SYSTEMDRIVE%\AssistantX\AssistantXRevert\firstlaunch.bat"
if "%firstlaunch%" == "0" (goto MainMenu)
reg add HKCU\CONSOLE /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1

REM Restore Point
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Checkpoint-Computer -Description 'AssistantX Restore Point' >nul 2>&1

REM HKCU & HKLM backup
for /F "tokens=2" %%i in ('date /t') do set date=%%i
set date1=%date:/=.%
>nul 2>&1 md %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%
reg export HKLM %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%\HKLM.reg /y >nul 2>&1
reg export HKCU %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%\HKCU.reg /y >nul 2>&1
echo set "firstlaunch=0" > %SYSTEMDRIVE%\AssistantX\AssistantXRevert\firstlaunch.bat
goto :eof

:MainMenu
Mode 130,45
set "choice="
cls
mode con: cols=135 lines=45
echo.
echo.
call :AssistantXTitle
echo                                            %username%, Thank you for choosing us, Enjoy your use
TITLE Main Menu - AssistantX v%localtwo% %Branch% %LOCALNUMTWO%
echo                         %COL%[37m______________________________________________________________________________________
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                               %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Optimizations              %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Ai
echo.
echo.
echo.
echo.
echo                                               %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m App Panel                  %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m More
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                            %COL%[31m[ X to Main Menu ]%COL%[37m       
echo.
echo                         %COL%[37m______________________________________________________________________________________
echo.
%SYSTEMROOT%\System32\choice.exe /c:1234XD /n /m "%DEL%                                                    %COL%[97mChoose the appropriate number > "
set choice=%errorlevel%
if "%choice%"=="1" goto OptimizationPanel
if "%choice%"=="2" goto Ai
if "%choice%"=="3" call:AppPanel
if "%choice%"=="4" goto More
if "%choice%"=="5" goto MainMenu
goto MainMenu

:Comingsoon
cls
echo.
echo.
call :AssistantXTitle
echo.
echo                                               %COL%[90m AssistantX is a free desktop utility
echo                                        %COL%[90m    made to improve your day-to-day productivity
echo.
echo.
echo.
echo.
echo                                  %COL%[31m This feature has not been finished yet but will be coming soon.
echo.
echo.
echo.
echo.
echo                                                    %COL%[97m[ Press any key to go back ]%COL%[37m
pause >nul
goto :eof

:: Панель оптимизации
:OptimizationPanel
cls
mode con: cols=135 lines=45
echo.
echo.
call :AssistantXTitle
TITLE Optimization type Panel - AssistantX v%localtwo%
echo                         %COL%[37m______________________________________________________________________________________
echo.
echo                                                       %COL%[1;4;34mChoose an optimization method%COL%[0m
echo.
echo.
echo.
echo                                     %COL%[96m[%COL%[37m M %COL%[96m]%COL%[37m Manual method                      %COL%[96m[%COL%[37m A %COL%[96m]%COL%[37m Automatic method
echo                                     %COL%[90mCompletely up to you                     %COL%[90mPre-built profiles
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                   %COL%[36m[ B for back ]       %COL%[31m[ X to Main Menu ]
echo.
echo                         %COL%[37m______________________________________________________________________________________
echo.
set /p choice="%DEL%                                                    %COL%[97mChoose the appropriate letter > "
if /i "%choice%"=="M" set PG=OptimizationPG1 & goto Optimization
if /i "%choice%"=="A" goto AutomaticOptimizationPanel
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="F" call:DwFolder
if /i "%choice%"=="B" goto MainMenu
goto OptimizationPanel

:AutomaticOptimizationPanel
powershell -ExecutionPolicy Unrestricted -NoProfile Checkpoint-Computer -Description 'AssistantX Restore Point before auto-optimization' >nul 2>&1
cls
mode con: cols=135 lines=45
echo.
echo.
call :AssistantXTitle
TITLE Automatic Optimization Panel - AssistantX v%localtwo%
echo                         %COL%[37m______________________________________________________________________________________
echo.
echo                                                       %COL%[1;4;34mChoose an optimization mode%COL%[0m
echo.
echo.
echo.
echo                             %COL%[96m[%COL%[37m L %COL%[96m]%COL%[37m LITE mode            %COL%[96m[%COL%[37m S %COL%[96m]%COL%[37m STANDART mode            %COL%[96m[%COL%[37m H %COL%[96m]%COL%[37m HARDCORE mode
echo                             %COL%[92mSafe for everyone          %COL%[93mLess safe                      %COL%[91mNOT safe
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                        %COL%[36m[ B for back ]       %COL%[31m[ X to Main Menu ]       %COL%[90m[ F to Download folder ]
echo.
echo                         %COL%[37m______________________________________________________________________________________
echo.
set /p choice="%DEL%                                                     %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="L" goto LITE-mode
if /i "%choice%"=="S" goto STANDART-modeWarn
if /i "%choice%"=="H" goto HARDCORE-modeWarn
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="F" call:DwFolder
if /i "%choice%"=="B" goto OptimizationPanel
goto AutomaticOptimizationPanel

:: Режимы авто-оптимизации
:LITE-mode
REM Планирование GPU с аппаратным ускорением - включить или выключить
echo Enabling Hardware Accelerated GPU Scheduling
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f >nul 2>&1
REM Отключение Windows Defender
echo Disabling defender
icacls "C:\Program Files\Windows Defender" /t /c /q /grant administrators:F  >nul 2>&1
takeown /f "C:\Program Files\Windows Defender" >nul 2>&1
RD /S /Q "C:\Program Files\Windows Defender" >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Sense" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdNisSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdFilter" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WinDefend" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SamSs" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wscsvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SgrmBroker" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
sc stop WinDefend >nul 2>&1
sc config WinDefend start=disabled >nul 2>&1
sc delete WinDefend >nul 2>&1
sc stop WdNisSvc >nul 2>&1
sc config WdNisSvc start=disabled >nul 2>&1
sc delete WdNisSvc >nul 2>&1
sc stop WdFilter  >nul 2>&1
sc config WdFilter start=disabled >nul 2>&1
sc stop Sense >nul 2>&1
sc config Sense start=disabled >nul 2>&1
sc delete Sense >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "OneTimeSqmDataSent" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d 0 / >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 / >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 / >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\UX Configuration" /v "DisablePrivacyMode" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "AutomaticallyCleanAfterScan" /t REG_DWORD /d "0" /f >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable > NUL 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable > NUL 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable > NUL 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv" /v "Start" /t REG_DWORD /d 4 /f  >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdBoot" /v "Start" /t REG_DWORD /d 4 /f  >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
regsvr32 /s /u "%ProgramFiles%\Windows Defender\shellext.dll" >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableAntiSpywareRealtimeProtection" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DpaDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ProductStatus" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ManagedDefenderProductType" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableSpecialRunningModes" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ForceUpdateFromMU" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "DisableBlockAtFirstSeen" /t REG_DWORD /d "1" /f >nul 2>&1
sc stop SecurityHealthService >nul 2>&1
sc config SecurityHealthService start=disabled >nul 2>&1
sc stop InstallService >nul 2>&1
sc config InstallService start=disabled >nul 2>&1
sc stop WdNisSvc >nul 2>&1
sc config WdNisSvc start=disabled >nul 2>&1
REM Отключение SmartScreen
echo Disabling SmartScreen
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d "0" /f >nul 2>&1
echo SmartScreen is off
REM Power Plan - ASX
сurl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Resources\AssistantX-Power.pow "https://github.com/ALFiX01/AssistantX/releases/download/Stable/AssistantX-Power.pow"
powercfg -import %SYSTEMDRIVE%\AssistantX\Resources\AssistantX-Power.pow
powercfg /d 381b4222-f694-41f0-9685-ff5bb260df2e
powercfg /d 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /d a1841308-3541-4fab-bc81-f71556f20b4a
powercfg /d a9758bf0-cfc6-439c-a392-7783990ff716
start powercfg.cpl
echo The "AssistantX Power" Power plan circuit is set
REM FSO and GameBar
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "GamePanelStartupTipIndex" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "ShowStartupPanel" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"  /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR"  /v "AllowGameDVR" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR"  /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\GameBar"  /v "AutoGameModeEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
echo FSO and GameBar are disabled
REM Keys
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "DelayBeforeAcceptance" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatRate" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatDelay" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f >nul 2>&1
echo Disabled key sticking
REM Uninstall Programm and Cortana
powershell -executionpolicy -command "Get-AppxPackage -allusers *people* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.People_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *zunevideo* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.ZuneVideo_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *3dbuilder* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.3DBuilder_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *skypeapp* | Remove-AppxPackage" >nul 2>&1
winget uninstall skype --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *solitaire* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *officehub* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *maps* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.WindowsMaps_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bing* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bing* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *onenote* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.Office.OneNote_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingfinance* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingsports* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingnews* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.GetHelp_8wekyb3d8bbwe" >nul 2>&1
winget uninstall Microsoft.GetHelp_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage MicrosoftTeams_22336.907.1742.9730_x64__8wekyb3d8bbwe" >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage MicrosoftTeams_23034.1300.1846.7680_x64__8wekyb3d8bbwe" >nul 2>&1
winget uninstall MicrosoftTeams_8wekyb3d8bbwe --accept-source-agreements --silent
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.PowerAutomateDesktop_1.0.65.0_x64__8wekyb3d8bbwe" >nul 2>&1
winget uninstall Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.OneDriveSync_21220.1024.5.0_neutral__8wekyb3d8bbwe" >nul 2>&1
winget uninstall Microsoft.OneDrive --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.Getstarted_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.BingWeather_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.Wallet_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.MixedReality.Portal_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.Todos_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.BingNews_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Clipchamp.Clipchamp_yxz26nhyzhsrt --accept-source-agreements --silent
winget uninstall 5319275A.WhatsAppDesktop_cv1g1gvanyjgm --accept-source-agreements --silent
rem Выключение Cortana
taskkill /f /im Cortana.exe >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /t REG_DWORD /d 0 /f  >nul 2>&1
rd /s /q "%WinDir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy" >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCortanaButton" /t REG_DWORD /d "0" /f >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe >nul 2>&1
echo Superfluous programs removed
REM Remove widget
powershell -executionpolicy -command "winget uninstall "windows web experience pack"" >nul 2>&1
echo Widgets removed
REM Chrome Tweaks
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "TranslateEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "TaskManagerEndProcessEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "UserFeedbackAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SpellCheckServiceEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SpellcheckEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MediaRouterCastAllowAllIPs" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "AllowDinosaurEasterEgg" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultGeolocationSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultCookiesSetting" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileHandlingGuardSetting" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileSystemReadGuardSetting" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileSystemWriteGuardSetting" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultImagesSetting" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultPopupsSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultSensorsSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultSerialGuardSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultWebBluetoothGuardSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultWebUsbGuardSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "EnableMediaRouter" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "ShowCastIconInToolbar" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "CloudPrintProxyEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "PrintRasterizationMode" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "PrintingEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultPluginsSetting" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SafeBrowsingProtectionLevel" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SafeBrowsingExtendedReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "HomepageIsNewTabPage" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "HomepageLocation" /t REG_SZ /d "google.com" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "NewTabPageLocation" /t REG_SZ /d "google.com" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome\Recommended" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome\Recommended" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome\Recommended" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome\Recommended" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Install{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_DWORD /d "5" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "TargetChannel{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_SZ /d "stable" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Update{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Install{4CCED17F-7852-4AFC-9E9E-C89D8795BDD2}" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "AutoUpdateCheckPeriodMinutes" /t REG_DWORD /d "43200" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "DownloadPreference" /t REG_SZ /d "cacheable" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedStartHour" /t REG_DWORD /d "23" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedStartMin" /t REG_DWORD /d "48" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedDurationMin" /t REG_DWORD /d "55" /f >nul 2>&1
echo Chrome settings applied
echo %COL%[92mOptimization is complete%COL%[37m
pause
goto AutomaticOptimizationPanel

:STANDART-mode
REM Планирование GPU с аппаратным ускорением - включить или выключить
echo Enabling Hardware Accelerated GPU Scheduling
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f >nul 2>&1
REM Отключение Win Defender
echo Disabling defender
icacls "C:\Program Files\Windows Defender" /t /c /q /grant administrators:F  >nul 2>&1
takeown /f "C:\Program Files\Windows Defender" >nul 2>&1
RD /S /Q "C:\Program Files\Windows Defender" >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Sense" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdNisSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdFilter" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WinDefend" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SamSs" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wscsvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SgrmBroker" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
sc stop WinDefend >nul 2>&1
sc config WinDefend start=disabled >nul 2>&1
sc delete WinDefend >nul 2>&1
sc stop WdNisSvc >nul 2>&1
sc config WdNisSvc start=disabled >nul 2>&1
sc delete WdNisSvc >nul 2>&1
sc stop WdFilter  >nul 2>&1
sc config WdFilter start=disabled >nul 2>&1
sc stop Sense >nul 2>&1
sc config Sense start=disabled >nul 2>&1
sc delete Sense >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "OneTimeSqmDataSent" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d 0 / >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 / >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 / >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\UX Configuration" /v "DisablePrivacyMode" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "AutomaticallyCleanAfterScan" /t REG_DWORD /d "0" /f >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable > NUL 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable > NUL 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable > NUL 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv" /v "Start" /t REG_DWORD /d 4 /f  >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdBoot" /v "Start" /t REG_DWORD /d 4 /f  >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
regsvr32 /s /u "%ProgramFiles%\Windows Defender\shellext.dll" >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableAntiSpywareRealtimeProtection" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DpaDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ProductStatus" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ManagedDefenderProductType" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableSpecialRunningModes" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ForceUpdateFromMU" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "DisableBlockAtFirstSeen" /t REG_DWORD /d "1" /f >nul 2>&1
sc stop SecurityHealthService >nul 2>&1
sc config SecurityHealthService start=disabled >nul 2>&1
sc stop InstallService >nul 2>&1
sc config InstallService start=disabled >nul 2>&1
sc stop WdNisSvc >nul 2>&1
sc config WdNisSvc start=disabled >nul 2>&1
REM Отключение SmartScreen
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d "0" /f >nul 2>&1
echo SmartScreen is off
REM Power Plan - ASX
сurl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Resources\AssistantX-Power.pow "https://github.com/ALFiX01/AssistantX/releases/download/Stable/AssistantX-Power.pow"
powercfg -import %SYSTEMDRIVE%\AssistantX\Resources\AssistantX-Power.pow
powercfg /d 381b4222-f694-41f0-9685-ff5bb260df2e
powercfg /d 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /d a1841308-3541-4fab-bc81-f71556f20b4a
powercfg /d a9758bf0-cfc6-439c-a392-7783990ff716
start powercfg.cpl
echo The "AssistantX Power" Power plan circuit is set
REM FSO GameBar
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "GamePanelStartupTipIndex" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "ShowStartupPanel" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"  /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR"  /v "AllowGameDVR" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR"  /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\GameBar"  /v "AutoGameModeEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
echo FSO and GameBar are disabled
REM Remove Keys
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "DelayBeforeAcceptance" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatRate" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatDelay" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f >nul 2>&1
echo Disabled key sticking
REM Uninstall programm
powershell -executionpolicy -command "Get-AppxPackage -allusers *people* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.People_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *zunevideo* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.ZuneVideo_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *3dbuilder* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.3DBuilder_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *skypeapp* | Remove-AppxPackage" >nul 2>&1
winget uninstall skype --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *solitaire* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *officehub* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *maps* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.WindowsMaps_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bing* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bing* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *onenote* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.Office.OneNote_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingfinance* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingsports* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingnews* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.GetHelp_8wekyb3d8bbwe" >nul 2>&1
winget uninstall Microsoft.GetHelp_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage MicrosoftTeams_22336.907.1742.9730_x64__8wekyb3d8bbwe" >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage MicrosoftTeams_23034.1300.1846.7680_x64__8wekyb3d8bbwe" >nul 2>&1
winget uninstall MicrosoftTeams_8wekyb3d8bbwe --accept-source-agreements --silent
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.PowerAutomateDesktop_1.0.65.0_x64__8wekyb3d8bbwe" >nul 2>&1
winget uninstall Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.OneDriveSync_21220.1024.5.0_neutral__8wekyb3d8bbwe" >nul 2>&1
winget uninstall Microsoft.OneDrive --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.Getstarted_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.BingWeather_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.Wallet_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.MixedReality.Portal_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.Todos_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.BingNews_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Clipchamp.Clipchamp_yxz26nhyzhsrt --accept-source-agreements --silent
winget uninstall 5319275A.WhatsAppDesktop_cv1g1gvanyjgm --accept-source-agreements --silent
rem Выключение Cortana
taskkill /f /im Cortana.exe >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /t REG_DWORD /d 0 /f  >nul 2>&1
rd /s /q "%WinDir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy" >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCortanaButton" /t REG_DWORD /d "0" /f >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe >nul 2>&1
echo Superfluous programs removed
REM Remove Widgets
powershell -executionpolicy -command "winget uninstall "windows web experience pack"" >nul 2>&1
echo Widgets removed
REM Enable Chrome tweaks
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "TranslateEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "TaskManagerEndProcessEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "UserFeedbackAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SpellCheckServiceEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SpellcheckEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MediaRouterCastAllowAllIPs" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "AllowDinosaurEasterEgg" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultGeolocationSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultCookiesSetting" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileHandlingGuardSetting" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileSystemReadGuardSetting" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileSystemWriteGuardSetting" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultImagesSetting" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultPopupsSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultSensorsSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultSerialGuardSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultWebBluetoothGuardSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultWebUsbGuardSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "EnableMediaRouter" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "ShowCastIconInToolbar" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "CloudPrintProxyEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "PrintRasterizationMode" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "PrintingEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultPluginsSetting" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SafeBrowsingProtectionLevel" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SafeBrowsingExtendedReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "HomepageIsNewTabPage" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "HomepageLocation" /t REG_SZ /d "google.com" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "NewTabPageLocation" /t REG_SZ /d "google.com" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome\Recommended" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome\Recommended" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome\Recommended" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome\Recommended" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Install{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_DWORD /d "5" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "TargetChannel{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_SZ /d "stable" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Update{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Install{4CCED17F-7852-4AFC-9E9E-C89D8795BDD2}" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "AutoUpdateCheckPeriodMinutes" /t REG_DWORD /d "43200" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "DownloadPreference" /t REG_SZ /d "cacheable" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedStartHour" /t REG_DWORD /d "23" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedStartMin" /t REG_DWORD /d "48" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedDurationMin" /t REG_DWORD /d "55" /f >nul 2>&1
echo Chrome settings applied
REM Enable MSI Mode
for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
echo MSI mode enabled
REM Disable Telemetry
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"  /v "EnableLua" /t REG_DWORD /d "0" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR"  /v "value" /t REG_DWORD /d "0" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowSharedUserAppData"  /v "value" /t REG_DWORD /d "0" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance"  /v "MaintenanceDisabled" /t REG_DWORD /d "0" /f
echo Disabled Telemetry
REM Disable DirectX tweaks
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "CpuCoresAlways" /t REG_DWORD /d "18" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "CpuUtilization" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "LatencyPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "RenderingSpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "RenderingPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuMax" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "MaxPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "MinPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "PerformancePriority" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "PerformanceSpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuMaxPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "CpuMaxPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuAccelerating" /t REG_DWORD /d "256" /f  >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuSpeed" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /ve /t REG_SZ /d "True" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "LatencySpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "RenderingPriority" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "LatencyPriority" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "CpuSpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuRenderingPriority" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "RenderingSpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "SpreadPriority" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX\{39A262FC-984B-11ED-9501-806E6F6E6963}" /v "GPMinCores" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX\{39A262FE-984B-11ED-9501-806E6F6E6963}" /v "GPUMaxCores" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX\{39A262FE-984B-11ED-9501-806E6F6E6963}" /v "GPUMinCores1" /t REG_DWORD /d "0" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SecurityHealthService.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Windows.Media.BackgroundPlayback.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sfc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wusa.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\wbemtest.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\scrcons.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ApplyTrustOffline.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CustomInstallExec.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\deploymentcsphelper.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\expand.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ReAgentc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RelPost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MuiUnattend.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dxdiag.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fontdrvhost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\winlogon.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ucsvc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fltMC.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lsass.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ntoskrnl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\services.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\smss.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\csrss.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Boot\winload.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\AggregatorHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dtdump.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\runexehelper.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rdrleakdiag.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wpr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\pacjsworker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\userinit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wininit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DeviceCensus.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dllhost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\conhost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\extrac32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\makecab.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\svchost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\compact.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dwm.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dcomcnfg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Locator.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Com\MigRegDB.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RpcPing.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\mtstocom.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Com\comrepl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dllhst3g.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\setupcl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\setupugc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wimserv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\chkdsk.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\chkntfs.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wsqmcons.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\autochk.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\browser_broker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\browserexport.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Boot\winresume.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\winresume.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\winload.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\bthudtask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fsquirt.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\bitsadmin.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\refsutil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\appidcertstorecheck.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\appidpolicyconverter.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1     
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wlanext.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LockScreenContentServer.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SlideToShutDown.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\systray.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RunLegacyCPLElevated.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\control.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fontview.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wifitask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tzutil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\w32tm.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dmclient.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dsregcmd.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\UtcDecoderHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TpmTool.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\HealthAttestationClientAgent.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TpmInit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CloudNotifications.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemSettingsBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\mofcomp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\unsecapp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\WMIADAP.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\WmiApSrv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RMActivate.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RMActivate_isv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RMActivate_ssp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RMActivate_ssp_isv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\printfilterpipelinesvc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\provtool.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PrintIsolationHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\spoolsv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PinEnrollmentBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WpcTok.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WpcMon.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ApproveChildRequest.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ofdeploy.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DmNotificationBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MDMAgent.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MicrosoftEdgeBCHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Eap3Host.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1 
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\choice.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\clip.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\doskey.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\forfiles.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\print.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\subst.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cttune.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cttunesvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\help.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\msdtc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CastSrv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\UserDataSource.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\curl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tar.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\spaceman.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\spaceutil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\EDPCleanup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MDMAppInstaller.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ARP.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\finger.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\HOSTNAME.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MRINFO.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\NETSTAT.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ROUTE.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sort.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TCPSVCS.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\xcopy.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\auditpol.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\mountvol.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\net.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\net1.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\netsh.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PATHPING.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PING.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\reg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\setx.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TRACERT.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\attrib.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ClipUp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\diskusage.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\findstr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\icacls.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ipconfig.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CIDiag.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\comp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fsutil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\recover.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sdclt.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PerceptionSimulation\PerceptionSimulationService.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tcblaunch.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\securekernel.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SgrmBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SgrmLpac.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\upnpcont.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\BioIso.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\NgcIso.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dusmtask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WinBioPlugIns\FaceFodUninstaller.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\oobeldr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\windeploy.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\audit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\AuditShD.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MBR2GPT.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\Setup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\poqexec.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PkgMgr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1     
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\mcbuilder.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MSchedExe.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WUDFCompanionHost.exe" /t REG_SZ /d "GpuPreference=1;" /f   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WUDFHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\AxInstUI.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\consent.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LanguageComponentsInstallerComHandler.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LockAppHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\la57setup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lpk-" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lpksetup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lpremove.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DsmUserTask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\netcfg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\runonce.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\secinit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\colorcpl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dccw.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Dism.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\proquota.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\UserAccountControlSettings.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\shutdown.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\efsui.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cipher.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\edpnotify.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MicrosoftEdgeCP.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rekeywiz.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dnscacheugc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\nslookup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lodctr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\unlodctr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ddodiag.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\omadmclient.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\omadmprc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DmOmaCpMo.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\coredpussvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DeviceEnroller.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dmcertinst.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dmcfghost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CredentialUIBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SensorDataService.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SecurityHealthHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\prproc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1       
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\audiodg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SpatialAudioLicenseSrv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CompPkgSrv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\agentactivationruntimestarter.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\IcsEntitlementHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\XblGameSaveTask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\notepad.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TsWpfWrp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\explorer.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1 
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Dism\DismHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cmdkey.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dpapimig.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LsaIso.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cscript.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RmClient.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SecEdit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wscript.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\icsunattend.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\NetHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cmmon32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cmstp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cmdl32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rasautou.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rasdial.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rasphone.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ntprint.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\printui.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DeviceEject.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\powercfg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sigverif.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\drvinst.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\hdwwiz.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\pnputil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wowreg32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\InfDefault-" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ndadmin.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\newdev.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\driverquery.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PnPUnattend.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\FirstLogonAnim.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\msoobe.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\UserOOBEBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\netbtugc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\netiougc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\nbtstat.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\NetCfgNotifyObjectHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\djoin.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\getmac.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\shrpubw.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesAdvanced.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesComputerName.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesDataExecutionPrevention.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesHardware.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesPerformance.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesProtection.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesRemote.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\winver.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sxstrace.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Sysprep\sysprep.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WSCollect.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WSReset.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\changepk.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LicensingUI.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\phoneactivate.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\UpgradeResultsUI.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\GenValObj.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\slui.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SppExtComObj.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sppsvc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Speech\SpeechUX\SpeechUXWiz.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\snmptrap.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\immersivetpmvscmgrsvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rmttpmvscmgrsvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tpmvscmgr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tpmvscmgrsvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\OpenWith.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ThumbnailExtractionHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\verclsid.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WallpaperHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\prevhost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rundll32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1
echo DirectX settings applied
REM Disable useless services
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Wecsvc" /v "Start" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\WbioSrvc" /v "Start" /t REG_DWORD /d "4" /f
echo Disabling useless services
echo %COL%[92mOptimization is complete%COL%[37m
pause
goto AutomaticOptimizationPanel

:HARDCORE-mode
REM Планирование GPU с аппаратным ускорением - включить или выключить
echo Enabling Hardware Accelerated GPU Scheduling
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f >nul 2>&1
echo Disabling defender
icacls "C:\Program Files\Windows Defender" /t /c /q /grant administrators:F  >nul 2>&1
takeown /f "C:\Program Files\Windows Defender" >nul 2>&1
RD /S /Q "C:\Program Files\Windows Defender" >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Sense" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdNisSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdFilter" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WinDefend" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SamSs" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wscsvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SgrmBroker" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
sc stop WinDefend >nul 2>&1
sc config WinDefend start=disabled >nul 2>&1
sc delete WinDefend >nul 2>&1
sc stop WdNisSvc >nul 2>&1
sc config WdNisSvc start=disabled >nul 2>&1
sc delete WdNisSvc >nul 2>&1
sc stop WdFilter  >nul 2>&1
sc config WdFilter start=disabled >nul 2>&1
sc stop Sense >nul 2>&1
sc config Sense start=disabled >nul 2>&1
sc delete Sense >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "OneTimeSqmDataSent" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d 0 / >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 / >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 / >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\UX Configuration" /v "DisablePrivacyMode" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "AutomaticallyCleanAfterScan" /t REG_DWORD /d "0" /f >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable > NUL 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable > NUL 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable > NUL 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv" /v "Start" /t REG_DWORD /d 4 /f  >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdBoot" /v "Start" /t REG_DWORD /d 4 /f  >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
regsvr32 /s /u "%ProgramFiles%\Windows Defender\shellext.dll" >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableAntiSpywareRealtimeProtection" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DpaDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ProductStatus" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ManagedDefenderProductType" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableSpecialRunningModes" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ForceUpdateFromMU" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "DisableBlockAtFirstSeen" /t REG_DWORD /d "1" /f >nul 2>&1
sc stop SecurityHealthService >nul 2>&1
sc config SecurityHealthService start=disabled >nul 2>&1
sc stop InstallService >nul 2>&1
sc config InstallService start=disabled >nul 2>&1
sc stop WdNisSvc >nul 2>&1
sc config WdNisSvc start=disabled >nul 2>&1
REM Отключение SmartScreen
echo Disabling SmartScreen
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d "0" /f >nul 2>&1
echo SmartScreen is off
REM Power Plan - ASX
сurl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Resources\AssistantX-Power.pow "https://github.com/ALFiX01/AssistantX/releases/download/Stable/AssistantX-Power.pow"
powercfg -import %SYSTEMDRIVE%\AssistantX\Resources\AssistantX-Power.pow
powercfg /d 381b4222-f694-41f0-9685-ff5bb260df2e
powercfg /d 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /d a1841308-3541-4fab-bc81-f71556f20b4a
powercfg /d a9758bf0-cfc6-439c-a392-7783990ff716
start powercfg.cpl
echo The "AssistantX Power" Power plan circuit is set
REM FSO and GameBar
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "GamePanelStartupTipIndex" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "ShowStartupPanel" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"  /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR"  /v "AllowGameDVR" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR"  /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\GameBar"  /v "AutoGameModeEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
echo FSO and GameBar are disabled
REM Keys
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "DelayBeforeAcceptance" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatRate" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatDelay" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f >nul 2>&1
echo Disabled key sticking
REM Uninstall programm
powershell -executionpolicy -command "Get-AppxPackage -allusers *people* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.People_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *zunevideo* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.ZuneVideo_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *3dbuilder* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.3DBuilder_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *skypeapp* | Remove-AppxPackage" >nul 2>&1
winget uninstall skype --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *solitaire* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *officehub* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *maps* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.WindowsMaps_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bing* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bing* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *onenote* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.Office.OneNote_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingfinance* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingsports* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingnews* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.GetHelp_8wekyb3d8bbwe" >nul 2>&1
winget uninstall Microsoft.GetHelp_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage MicrosoftTeams_22336.907.1742.9730_x64__8wekyb3d8bbwe" >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage MicrosoftTeams_23034.1300.1846.7680_x64__8wekyb3d8bbwe" >nul 2>&1
winget uninstall MicrosoftTeams_8wekyb3d8bbwe --accept-source-agreements --silent
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.PowerAutomateDesktop_1.0.65.0_x64__8wekyb3d8bbwe" >nul 2>&1
winget uninstall Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.OneDriveSync_21220.1024.5.0_neutral__8wekyb3d8bbwe" >nul 2>&1
winget uninstall Microsoft.OneDrive --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.Getstarted_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.BingWeather_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.Wallet_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.MixedReality.Portal_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.Todos_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.BingNews_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Clipchamp.Clipchamp_yxz26nhyzhsrt --accept-source-agreements --silent
winget uninstall 5319275A.WhatsAppDesktop_cv1g1gvanyjgm --accept-source-agreements --silent
REM Выключение Cortana
taskkill /f /im Cortana.exe >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /t REG_DWORD /d 0 /f  >nul 2>&1
rd /s /q "%WinDir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy" >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCortanaButton" /t REG_DWORD /d "0" /f >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe >nul 2>&1
echo Superfluous programs removed
REM Remove Widgets
powershell -executionpolicy -command "winget uninstall "windows web experience pack""
echo Widgets removed
REM Disable useless services
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\Wecsvc" /v "Start" /t REG_DWORD /d "4" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\WbioSrvc" /v "Start" /t REG_DWORD /d "4" /f
echo Disabling useless services
REM Enable Chrome tweaks
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "TranslateEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "TaskManagerEndProcessEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "UserFeedbackAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SpellCheckServiceEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SpellcheckEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MediaRouterCastAllowAllIPs" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "AllowDinosaurEasterEgg" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultGeolocationSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultCookiesSetting" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileHandlingGuardSetting" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileSystemReadGuardSetting" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileSystemWriteGuardSetting" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultImagesSetting" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultPopupsSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultSensorsSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultSerialGuardSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultWebBluetoothGuardSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultWebUsbGuardSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "EnableMediaRouter" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "ShowCastIconInToolbar" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "CloudPrintProxyEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "PrintRasterizationMode" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "PrintingEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultPluginsSetting" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SafeBrowsingProtectionLevel" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SafeBrowsingExtendedReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "HomepageIsNewTabPage" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "HomepageLocation" /t REG_SZ /d "google.com" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "NewTabPageLocation" /t REG_SZ /d "google.com" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome\Recommended" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome\Recommended" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome\Recommended" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome\Recommended" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Install{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_DWORD /d "5" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "TargetChannel{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_SZ /d "stable" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Update{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Install{4CCED17F-7852-4AFC-9E9E-C89D8795BDD2}" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "AutoUpdateCheckPeriodMinutes" /t REG_DWORD /d "43200" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "DownloadPreference" /t REG_SZ /d "cacheable" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedStartHour" /t REG_DWORD /d "23" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedStartMin" /t REG_DWORD /d "48" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedDurationMin" /t REG_DWORD /d "55" /f >nul 2>&1
echo Chrome settings applied
REM Enable MSI MODE
for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
echo MSI mode enabled
REM Disable Telemetry
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching"  /v "SearchOrderConfig" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"  /v "EnableLua" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR"  /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowSharedUserAppData"  /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowStore"  /v "value" /t REG_DWORD /d "0" /f 1 >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance"  /v "MaintenanceDisabled" /t REG_DWORD /d "0" /f >nul 2>&1
echo Disabled Telemetry
REM Disable DirectX tweaks
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "CpuCoresAlways" /t REG_DWORD /d "18" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "CpuUtilization" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "LatencyPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "RenderingSpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "RenderingPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuMax" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "MaxPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "MinPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "PerformancePriority" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "PerformanceSpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuMaxPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "CpuMaxPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuAccelerating" /t REG_DWORD /d "256" /f  >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuSpeed" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /ve /t REG_SZ /d "True" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "LatencySpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "RenderingPriority" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "LatencyPriority" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "CpuSpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuRenderingPriority" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "RenderingSpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "SpreadPriority" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX\{39A262FC-984B-11ED-9501-806E6F6E6963}" /v "GPMinCores" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX\{39A262FE-984B-11ED-9501-806E6F6E6963}" /v "GPUMaxCores" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX\{39A262FE-984B-11ED-9501-806E6F6E6963}" /v "GPUMinCores1" /t REG_DWORD /d "0" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SecurityHealthService.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Windows.Media.BackgroundPlayback.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sfc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wusa.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\wbemtest.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\scrcons.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ApplyTrustOffline.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CustomInstallExec.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\deploymentcsphelper.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\expand.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ReAgentc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RelPost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MuiUnattend.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dxdiag.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fontdrvhost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\winlogon.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ucsvc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fltMC.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lsass.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ntoskrnl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\services.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\smss.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\csrss.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Boot\winload.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\AggregatorHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dtdump.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\runexehelper.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rdrleakdiag.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wpr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\pacjsworker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\userinit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wininit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DeviceCensus.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dllhost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\conhost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\extrac32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\makecab.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\svchost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\compact.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dwm.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dcomcnfg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Locator.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Com\MigRegDB.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RpcPing.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\mtstocom.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Com\comrepl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dllhst3g.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\setupcl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\setupugc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wimserv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\chkdsk.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\chkntfs.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wsqmcons.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\autochk.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\browser_broker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\browserexport.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Boot\winresume.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\winresume.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\winload.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\bthudtask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fsquirt.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\bitsadmin.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\refsutil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\appidcertstorecheck.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\appidpolicyconverter.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1     
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wlanext.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LockScreenContentServer.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SlideToShutDown.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\systray.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RunLegacyCPLElevated.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\control.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fontview.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wifitask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tzutil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\w32tm.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dmclient.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dsregcmd.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\UtcDecoderHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TpmTool.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\HealthAttestationClientAgent.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TpmInit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CloudNotifications.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemSettingsBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\mofcomp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\unsecapp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\WMIADAP.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\WmiApSrv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RMActivate.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RMActivate_isv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RMActivate_ssp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RMActivate_ssp_isv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\printfilterpipelinesvc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\provtool.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PrintIsolationHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\spoolsv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PinEnrollmentBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WpcTok.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WpcMon.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ApproveChildRequest.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ofdeploy.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DmNotificationBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MDMAgent.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MicrosoftEdgeBCHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Eap3Host.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1 
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\choice.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\clip.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\doskey.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\forfiles.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\print.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\subst.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cttune.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cttunesvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\help.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\msdtc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CastSrv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\UserDataSource.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\curl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tar.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\spaceman.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\spaceutil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\EDPCleanup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MDMAppInstaller.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ARP.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\finger.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\HOSTNAME.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MRINFO.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\NETSTAT.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ROUTE.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sort.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TCPSVCS.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\xcopy.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\auditpol.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\mountvol.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\net.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\net1.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\netsh.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PATHPING.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PING.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\reg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\setx.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TRACERT.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\attrib.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ClipUp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\diskusage.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\findstr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\icacls.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ipconfig.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CIDiag.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\comp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fsutil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\recover.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sdclt.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PerceptionSimulation\PerceptionSimulationService.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tcblaunch.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\securekernel.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SgrmBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SgrmLpac.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\upnpcont.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\BioIso.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\NgcIso.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dusmtask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WinBioPlugIns\FaceFodUninstaller.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\oobeldr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\windeploy.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\audit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\AuditShD.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MBR2GPT.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\Setup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\poqexec.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PkgMgr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1     
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\mcbuilder.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MSchedExe.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WUDFCompanionHost.exe" /t REG_SZ /d "GpuPreference=1;" /f   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WUDFHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\AxInstUI.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\consent.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LanguageComponentsInstallerComHandler.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LockAppHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\la57setup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lpk-" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lpksetup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lpremove.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DsmUserTask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\netcfg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\runonce.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\secinit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\colorcpl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dccw.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Dism.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\proquota.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\UserAccountControlSettings.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\shutdown.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\efsui.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cipher.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\edpnotify.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MicrosoftEdgeCP.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rekeywiz.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dnscacheugc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\nslookup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lodctr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\unlodctr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ddodiag.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\omadmclient.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\omadmprc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DmOmaCpMo.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\coredpussvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DeviceEnroller.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dmcertinst.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dmcfghost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CredentialUIBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SensorDataService.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SecurityHealthHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\prproc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1       
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\audiodg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SpatialAudioLicenseSrv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CompPkgSrv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\agentactivationruntimestarter.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\IcsEntitlementHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\XblGameSaveTask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\notepad.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TsWpfWrp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\explorer.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1 
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Dism\DismHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cmdkey.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dpapimig.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LsaIso.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cscript.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RmClient.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SecEdit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wscript.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\icsunattend.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\NetHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cmmon32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cmstp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cmdl32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rasautou.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rasdial.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rasphone.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ntprint.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\printui.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DeviceEject.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\powercfg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sigverif.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\drvinst.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\hdwwiz.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\pnputil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wowreg32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\InfDefault-" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ndadmin.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\newdev.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\driverquery.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PnPUnattend.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\FirstLogonAnim.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\msoobe.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\UserOOBEBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\netbtugc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\netiougc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\nbtstat.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\NetCfgNotifyObjectHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\djoin.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\getmac.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\shrpubw.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesAdvanced.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesComputerName.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesDataExecutionPrevention.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesHardware.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesPerformance.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesProtection.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesRemote.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\winver.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sxstrace.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Sysprep\sysprep.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WSCollect.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WSReset.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\changepk.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LicensingUI.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\phoneactivate.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\UpgradeResultsUI.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\GenValObj.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\slui.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SppExtComObj.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sppsvc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Speech\SpeechUX\SpeechUXWiz.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\snmptrap.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\immersivetpmvscmgrsvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rmttpmvscmgrsvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tpmvscmgr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tpmvscmgrsvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\OpenWith.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ThumbnailExtractionHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\verclsid.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WallpaperHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\prevhost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rundll32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1 
echo DirectX settings applied
REM Disable NVIDIA Telemetry
reg add "HKCU\Software\AssistantX" /v NVTTweaks /f >nul 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d 0 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "NvBackend" /f >nul 2>&1
schtasks /change /disable /tn "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
schtasks /change /disable /tn "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
schtasks /change /disable /tn "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
schtasks /change /disable /tn "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
echo Disabled NVIDIA Telemetry
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d 0 /f
echo Disabling background programs
reg add "HKCU\Software\AssistantX" /v "MemoryTweaks" /f
REM Disable FTH
reg add "HKLM\Software\Microsoft\FTH" /v "Enabled" /t Reg_DWORD /d "0" /f
REM Disable Desktop Composition
reg add "HKCU\Software\Microsoft\Windows\DWM" /v "Composition" /t REG_DWORD /d "0" /f
REM Disable Background apps
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t Reg_DWORD /d "1" /f
reg add "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /t Reg_DWORD /d "2" /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t Reg_DWORD /d "0" /f
REM Disallow drivers to get paged into virtual memory
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t Reg_DWORD /d "1" /f
REM Disable Page Combining and Memory Compression
powershell -NoProfile -Command "Disable-MMAgent -PagingCombining -mc"
reg add "HKLM\System\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePageCombining" /t REG_DWORD /d "1" /f
REM Use Large System Cache to improve microstuttering
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t Reg_DWORD /d "1" /f
REM Free unused ram
reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "HeapDeCommitFreeBlockThreshold" /t REG_DWORD /d "262144" /f
REM Auto restart Powershell on error
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoRestartShell" /t REG_DWORD /d "1" /f
REM Disk Optimizations
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DontVerifyRandomDrivers" /t REG_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /t REG_DWORD /d "0" /f
REM Disable Prefetch and Superfetch
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t Reg_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t Reg_DWORD /d "0" /f
REM Disable Hibernation + Fast Startup
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabledDefault" /t REG_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d "0" /f
REM Wait time to kill app during shutdown
reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t Reg_SZ /d "1000" /f
REM Wait to end service at shutdown
reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t Reg_SZ /d "1000" /f
REM Wait to kill non-responding app
reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t Reg_SZ /d "1000" /f
REM fsutil
if exist "%SYSTEMROOT%\System32\fsutil.exe" (
	REM Raise the limit of paged pool memory
	fsutil behavior set memoryusage 2
	REM https://www.serverbrain.org/solutions-2003/the-mft-zone-can-be-optimized.html
	fsutil behavior set mftzone 2
	REM Disable Last Access information on directories, performance/privacy
	fsutil behavior set disablelastaccess 1
	REM Disable Virtual Memory Pagefile Encryption
	fsutil behavior set encryptpagingfile 0
	REM Disables the creation of legacy 8.3 character-length file names on FAT- and NTFS-formatted volumes.
	fsutil behavior set disable8dot3 1
	REM Disable NTFS compression
	fsutil behavior set disablecompression 1
	REM Enable Trim
	fsutil behavior set disabledeletenotify 0
	)
echo Memory is optimized
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /t Reg_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /t Reg_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /t Reg_DWORD /d "0" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /t Reg_DWORD /d "1" /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /t Reg_DWORD /d "0" /f
echo Disable preemption requests GPU
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "PerfEnergyPreference" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPMinCores" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPMaxCores" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPMinCores1" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPMaxCores1" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CpLatencyHintUnpark1" /t REG_DWORD /d "100" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPDistribution" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CpLatencyHintUnpark" /t REG_DWORD /d "100" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "MaxPerformance1" /t REG_DWORD /d "100" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "MaxPerformance" /t REG_DWORD /d "100" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPDistribution1" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPHEADROOM" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPCONCURRENCY" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPIncreaseTime" /t REG_DWORD /d "0" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\audiodg.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dllhost.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\explorer.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsm.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ntoskrnl.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\rundll32.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\services.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\smss.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\svchost.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskeng.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wininit.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\winlogon.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerMizerEnable" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PerfLevelSrc" /t REG_DWORD /d "8738" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerMizerLevelAC" /t REG_DWORD /d "1" /f
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerSaverHsyncOn" /t REG_DWORD /d "0" /f
echo NVIDIA settings applied
echo %COL%[92mOptimization is complete%COL%[37m
pause
goto AutomaticOptimizationPanel

:: Конец режимов авто-оптимизации

:STANDART-modeWarn
TITLE STANDART Panel - AssistantX v%localtwo%
echo.
echo.
call :AssistantXTitle
echo.
echo.
echo %COL%[91m  WARNING:
echo.
echo     %COL%[96m1.%COL%[37m Auto-optimization contains a lot of preset parameters, which can lead to both positive and %COL%[91munfortunate%COL%[37m outcome!
echo.
echo     %COL%[96m1.%COL%[37m Everything is "use at your own risk", we are %COL%[91mNOT LIABLE%COL%[37m if you damage your system in any way.
echo.
echo     %COL%[96m1.%COL%[37m Even though we have an automatic restore point feature, we %COL%[91mHighly%COL%[37m recommend making a manual restore point before running.
echo.
echo     %COL%[96m1.%COL%[37m Next, there will be massive changes. %COL%[91m(Dangerous.)%COL%[37m
echo.
echo     Please enter "Continue anyway" (without quotes) to continue:
echo.
echo.
echo                                                        %COL%[90m[ B for back ]
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!"=="B" goto AutomaticOptimizationPanel
if /i "!input!" neq "Continue anyway" call:STANDART-mode

:HARDCORE-modeWarn
TITLE HARDCORE Panel - AssistantX v%localtwo%
echo.
echo.
call :AssistantXTitle
echo.
echo.
echo %COL%[91m  WARNING:
echo.
echo     %COL%[96m1.%COL%[37m Auto-optimization contains a lot of preset parameters, which can lead to both positive and %COL%[91munfortunate%COL%[37m outcome!
echo.
echo     %COL%[96m1.%COL%[37m Everything is "use at your own risk", we are %COL%[91mNOT LIABLE%COL%[37m if you damage your system in any way.
echo.
echo     %COL%[96m1.%COL%[37m Even though we have an automatic restore point feature, we %COL%[91mHighly%COL%[37m recommend making a manual restore point before running.
echo.
echo     %COL%[96m1.%COL%[37m Next, there will be massive changes. %COL%[91m(Dangerous.)%COL%[37m
echo.
echo     Please enter "Continue anyway" (without quotes) to continue:
echo.
echo.
echo                                                        %COL%[90m[ B for back ]
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!"=="B" goto AutomaticOptimizationPanel
if /i "!input!" neq "Continue anyway" call:HARDCORE-mode

:Optimization 
Mode 130,45
TITLE Checking - AssistantX v%localtwo%
set "choice="
set "BLANK=   "
REM Check Values
for %%i in (ASXPW MEMOF FSOOF AFFOF MOUOF AFTOF NICOF DSSOF SERVOF DEBOF MITOF ME2OF NPIOF NVIOF NVTOF HDCOF CMAOF ALLOF MSIOF TCPOF DWCOF CRSOF) do (set "%%i=%COL%[92mON ") >nul 2>&1
(
	REM MSI Mode
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do (
		reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" | find "0x1" || set "MSIOF=%COL%[91mOFF"
		reg query "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" && set "MSIOF=%COL%[91mOFF"
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do (
		reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" | find "0x1" || set "MSIOF=%COL%[91mOFF"
		reg query "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" && set "MSIOF=%COL%[91mOFF"
	)
	REM Services Optimization
	for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do (set /a mem=%%i + 1024000)
	for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB"') do (set /a currentmem=%%a)
	if "!currentmem!" neq "!mem!" set "MEMOF=%COL%[91mOFF"
	REM Nvidia Telemetry
	reg query "HKCU\Software\AssistantX" /v "NVTTweaks" || set "NVTOF=%COL%[91mOFF"
	REM DissableFSOandGameBar
	reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar" /v "AllowAutoGameMode" || set "FSOOF=%COL%[91mOFF"
	REM Nvidia HDCP
	for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do reg query "%%a" /v "RMHdcpKeyglobZero" | find "0x1" || set "HDCOF=%COL%[91mOFF"
	REM Disable Preemption
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" | find "0x1" || set "CMAOF=%COL%[91mOFF"
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" | find "0x1" || set "CMAOF=%COL%[91mOFF"
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" | find "0x0" || set "CMAOF=%COL%[91mOFF"
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" | find "0x1" || set "CMAOF=%COL%[91mOFF"
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" | find "0x0" || set "CMAOF=%COL%[91mOFF"
	REM Power Plan
	powercfg /GetActiveScheme | find "AssistantX Power" || set "ASXPW=%COL%[91mOFF"
	REM All GPU Tweaks
	reg query "HKCU\Software\AssistantX" /v "AllGPUTweaks" || set "ALLOF=%COL%[91mOFF"
	REM Profile Inspector Tweaks
	reg query "HKCU\Software\AssistantX" /v "NpiTweaks" || set "NPIOF=%COL%[91mOFF"
	REM TCPIP
	reg query "HKCU\Software\AssistantX" /v "TCPIP" || set "TCPOF=%COL%[91mOFF"
	REM Nvidia Tweaks
	reg query "HKCU\Software\AssistantX" /v "NvidiaTweaks" || set "NVIOF=%COL%[91mOFF"
	REM Memory Optimization
	reg query "HKCU\Software\AssistantX" /v "MemoryTweaks" || set "ME2OF=%COL%[91mOFF"
	REM Services Tweaks
	reg query "HKCU\Software\AssistantX" /v "ServicesTweaks" || set "SERVOF=%COL%[91mOFF"
	REM Debloat Tweaks
	reg query "HKCU\Software\AssistantX" /v "DebloatTweaks" || set "DEBOF=%COL%[91mOFF"
	REM Mitigations Tweaks
	reg query "HKCU\Software\AssistantX" /v "MitigationsTweaks" || set "MITOF=%COL%[91mOFF"
	REM Affinities
	reg query "HKCU\Software\AssistantX" /v "AffinityTweaks" || set "AFFOF=%COL%[91mOFF"
	REM DisableWriteCombining
	reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" || set "DWCOF=%COL%[91mOFF"
	REM Mouse Fix
	reg query "HKCU\Control Panel\Mouse" /v "SmoothMouseYCurve" | find "0000000000000000000038000000000000007000000000000000A800000000000000E00000000000" || set "MOUOF=%COL%[91mOFF"
	REM NIC
	if not exist "%SYSTEMDRIVE%\AssistantX\AssistantXRevert\ognic1.reg" set "NICOF=%COL%[91mOFF"
	REM Intel iGPU
	reg query "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" | find "0x400" || set "DSSOF=%COL%[91mOFF"
	REM Check If Applicable For PC
	REM GPU
	for /f "tokens=2 delims==" %%a in ('wmic path Win32_VideoController get VideoProcessor /value') do (
		for %%n in (GeForce NVIDIA RTX GTX) do echo %%a | find "%%n" >nul && set "NVIDIAGPU=Found"
		for %%n in (AMD Ryzen) do echo %%a | find "%%n" >nul && set "AMDGPU=Found"
		for %%n in (Intel UHD) do echo %%a | find "%%n" >nul && set "INTELGPU=Found"
	)
	if "!NVIDIAGPU!" neq "Found" for %%g in (HDCOF CMAOF NPIOF NVTOF NVIOF) do set "%%g=%COL%[93mN/A"
	if "!AMDGPU!" neq "Found" for %%g in (AMDOF) do set "%%g=%COL%[93mN/A"
	if "!INTELGPU!" neq "Found" for %%g in (DSSOF) do set "%%g=%COL%[93mN/A"
) >nul 2>&1
goto %PG%

:OptimizationPG1
cls
mode con: cols=134 lines=45
echo.
REM echo                                                                                                                        %COL%[36mPage 1/2
call :AssistantXTitle
TITLE Optimization panel - AssistantX v%localtwo%
echo              %COL%[37m_____________________________________________________________________________________________________________
echo.
echo                                                                  %COL%[1;4;34mTweaks%COL%[0m
echo.
echo               %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m ASX Power Plan %ASXPW%             %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Disable Keys sticking         %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m MSI Mode %MSIOF% 
echo.
echo               %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m Disable Windows Telemetry      %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m Disable FSO and GameBar %FSOOF%   %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m DirextX Tweaks
echo               %COL%[91mDangerous
echo. 
echo               %COL%[96m[%COL%[37m 7 %COL%[96m]%COL%[37m Chrome Tweaks                  %COL%[96m[%COL%[37m 8 %COL%[96m]%COL%[37m NVidia Addon Tweaks           %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m Mouse Tweaks
echo.
echo                                                               %COL%[1;4;34mNvidia Tweaks%COL%[0m
echo.
echo               %COL%[96m[%COL%[37m 10 %COL%[96m]%COL%[37m Disable HDCP %HDCOF%             %COL%[96m[%COL%[37m 11 %COL%[96m]%COL%[37m Disable Preemption %CMAOF%        %COL%[96m[%COL%[37m 12 %COL%[96m]%COL%[37m ProfileInspector %NPIOF%
echo               %COL%[90mDisable copy protection technology  %COL%[90mDisable preemption requests from     %COL%[90mWill edit your Nvidia control panel
echo               %COL%[90mof illegal High Definition content  %COL%[90mthe GPU scheduler                    %COL%[90mand add various tweaks
echo.
echo               %COL%[96m[%COL%[37m 13 %COL%[96m]%COL%[37m Disable Nvidia Telemetry %NVTOF% %COL%[96m[%COL%[37m 14 %COL%[96m]%COL%[37m Nvidia Tweaks %NVIOF%             %COL%[96m[%COL%[37m 15 %COL%[96m]%COL%[37m Disable Write Combining %DWCOF%
echo               %COL%[90mRemove Nvidia telemetry from        %COL%[90mVarious essential tweaks for         %COL%[90mStops data from being combined
echo               %COL%[90myour computer and drivers.          %COL%[90mNvidia graphics cards                %COL%[90mand temporarily stored
echo.
echo.
echo.
echo.
echo.
echo              %COL%[37m_____________________________________________________________________________________________________________
echo.
echo.
echo                                           %COL%[90m[ G for Game-Booster ]       %COL%[90m[ A for Advanced Tweak ]   
echo.  
echo                                                %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]   
REM echo                                  %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]         %COL%[36m[ N next page ]       
echo.
set /p choice="%DEL%                                                     %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" Call:ASXPowerPlan
if /i "%choice%"=="2" goto Dsk
if /i "%choice%"=="3" goto MSI
if /i "%choice%"=="4" goto DissWinTelemetry
if /i "%choice%"=="5" goto DissableFSOandGameBar
echo %NPIOF% | find "N/A" >nul && if "%choice%" geq "10" if "%choice%" leq "15" call :AssistantX Error "You don't have an NVIDIA GPU" && goto Tweaks
if /i "%choice%"=="6" call:DirectXtweaks
if /i "%choice%"=="7" Call:ChromeTweaks
if /i "%choice%"=="8" Call:NVidiaAddonTweaks
if /i "%choice%"=="9" Call:MouseTweaks
if /i "%choice%"=="10" goto DisableHDCP
if /i "%choice%"=="11" goto DisablePreemtion
if /i "%choice%"=="12" goto ProfileInspector
if /i "%choice%"=="13" goto NVTelemetry
if /i "%choice%"=="14" goto NvidiaTweaks
if /i "%choice%"=="15" goto DisableWriteCombining
if /i "%choice%"=="G" call:gameBooster
if /i "%choice%"=="A" call:AdvancedTW
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto OptimizationPanel
REM if /i "%choice%"=="N" (set "PG=OptimizationPG2") & goto OptimizationPG2
goto OptimizationPG1

:OptimizationPG2
cls
mode con: cols=134 lines=45
echo.
echo                                                                                                                        %COL%[36mPage 2/2
call :AssistantXTitle
TITLE Optimization panel - AssistantX v%localtwo%
echo              %COL%[37m_____________________________________________________________________________________________________________
echo.
echo                                                                  %COL%[1;4;34mTweaks%COL%[0m
echo.
echo               %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Chrome Tweaks               %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m NVidia Addon Tweaks               %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m Mouse Tweaks
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo              %COL%[37m_____________________________________________________________________________________________________________
echo.
echo.
echo                                          %COL%[90m[ G for Game-Booster ]       %COL%[90m[ A for Advanced Tweak ]   
echo.  
echo                                                  %COL%[36m[ B for back ]       %COL%[31m[ X to Main Menu ]           
echo.
set /p choice="%DEL%                                                     %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" Call:ChromeTweaks
if /i "%choice%"=="2" Call:NVidiaAddonTweaks
if /i "%choice%"=="3" Call:MouseTweaks
if /i "%choice%"=="G" call:gameBooster
if /i "%choice%"=="A" call:AdvancedTW
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto OptimizationPG1
goto OptimizationPG2

:FixProblem
IF EXIST "%SYSTEMDRIVE%\AssistantX\Resources\FixProblem.zip" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Resources\FixProblem.zip
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Resources\FixProblem.zip "https://github.com/ALFiX01/AssistantX/releases/download/File/FixProblem.zip"
	echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Resources\FixProblem.zip
)
goto :More

:: Панель приложений
:AppPanel
cls
mode con: cols=135 lines=45
echo.
echo.
call :AssistantXTitle
TITLE App Panel - AssistantX v%localtwo%
echo                         %COL%[37m______________________________________________________________________________________
echo.
echo.
echo.
echo                                                                  %COL%[96m[%COL%[37m R %COL%[96m]
echo                                                            %COL%[92m Recommended apps%COL%[37m
echo                                                         %COL%[90mProgrammes we recommend
echo.
echo.
echo.
echo.
echo                                                                  %COL%[96m[%COL%[37m N %COL%[96m]
echo                                                           %COL%[33m NO Recommended apps%COL%[37m
echo                                                       %COL%[90mProgrammes we do not recommend
echo.
echo.
echo.
echo.
echo                                                                  %COL%[96m[%COL%[37m U %COL%[96m]
echo                                                           %COL%[97m App Uninstall panel%COL%[37m
echo                                                     %COL%[90mUninstall software from Microsoft
echo.
echo.
echo.
echo.
echo.
echo                                        %COL%[36m[ B for back ]       %COL%[31m[ X to Main Menu ]       %COL%[90m[ F to Download folder ]
echo.
echo                         %COL%[37m______________________________________________________________________________________
echo.
set /p choice="%DEL%                                                     %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="R" goto AppRecommended
if /i "%choice%"=="N" goto AppNORecommended
if /i "%choice%"=="U" goto AppUninstall
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="F" call:DwFolder
if /i "%choice%"=="B" goto MainMenu
goto AppPanel

:: Открывает папку загрузок ASX
:DwFolder
start %SYSTEMDRIVE%\AssistantX\Downloads
goto AppPanel

:AppRecommended
cls
mode con: cols=135 lines=45
echo.
echo                                                                                                                        %COL%[36mPage 1/3
call :AssistantXTitle
TITLE App Panel - AssistantX v%localtwo%
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
echo.
echo.
echo                 %COL%[1;4;34mFor Gamers%COL%[0m
echo.
echo                 %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Discord                         %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Steam                       %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m Epic Games Launcher 
echo.
echo                 %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m MSI Afterburner
echo.
echo                 %COL%[1;4;34mFor Optimization%COL%[0m
echo.
echo                 %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m Win Tweaker                     %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m QuickCpu                    %COL%[96m[%COL%[37m 7 %COL%[96m]%COL%[37m Auslogics BoostSpeed
echo.
echo                 %COL%[1;4;34mFor Personalization Windows%COL%[0m
echo.
echo                 %COL%[96m[%COL%[37m 8 %COL%[96m]%COL%[37m Start11                         %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m WinDynamicDesktop
echo.
echo                 %COL%[1;4;34mPhoto Editors%COL%[0m
echo.
echo                 %COL%[96m[%COL%[37m 10 %COL%[96m]%COL%[37m Paint.net                      %COL%[96m[%COL%[37m 11 %COL%[96m]%COL%[37m Adobe Photoshop            %COL%[96m[%COL%[37m 12 %COL%[96m]%COL%[37m Topaz Gigapixel AI
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                  %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]         %COL%[36m[ N next page ]
echo.
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
set /p choice="%DEL%                                                    %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" call:Discord
if /i "%choice%"=="2" call:Steam
if /i "%choice%"=="3" call:EGS
if /i "%choice%"=="4" call:MSIAfterburner
if /i "%choice%"=="5" call:WinTweaker
if /i "%choice%"=="6" call:QuickCpu
if /i "%choice%"=="7" call:AuslogicsBoostSpeed
if /i "%choice%"=="8" call:Start11
if /i "%choice%"=="9" call:WinDynamicDesktop
if /i "%choice%"=="10" call:PaintNet
if /i "%choice%"=="11" call:Photoshop
if /i "%choice%"=="12" call:TopazGigapixelAI
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto AppPanel
if /i "%choice%"=="N" (set "PG=AppRecommendedPG2") & goto AppRecommendedPG2
goto AppRecommended

:AppRecommendedPG2
cls
mode con: cols=135 lines=45
echo.
echo                                                                                                                        %COL%[36mPage 2/3
call :AssistantXTitle
TITLE Files Downloads Panel - AssistantX v%localtwo%
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
echo.
echo.
echo                 %COL%[1;4;34mFor watch movies and series%COL%[0m
echo.
echo                 %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Zona
echo.
echo                 %COL%[1;4;34mFor devices%COL%[0m
echo.
echo                 %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m GeForce Experience                 %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m NVIDIA Broadcast               %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m ThunderMaster
echo.
echo                 %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m Logitech G hub                     %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m JBL Quantum ENGINE 
echo.
echo                 %COL%[1;4;34mWeb Browsers%COL%[0m
echo.
echo                 %COL%[96m[%COL%[37m 7 %COL%[96m]%COL%[37m Microsoft Edge                     %COL%[96m[%COL%[37m 8 %COL%[96m]%COL%[37m Chrome                         %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m Firefox
echo.
echo.
echo                 %COL%[1;4;34mFor Developers%COL%[0m
echo.
echo                 %COL%[96m[%COL%[37m 10 %COL%[96m]%COL%[37m GitHub Desktop                    %COL%[96m[%COL%[37m 11 %COL%[96m]%COL%[37m Visual Studio Code            %COL%[96m[%COL%[37m 12 %COL%[96m]%COL%[37m Pycharm
echo.
echo.
echo.
echo.
echo.
echo.
echo                                  %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]         %COL%[36m[ N next page ]
echo.
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
set /p choice="%DEL%                                                    %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" call:Zona
if /i "%choice%"=="2" call:GeForceExperience
if /i "%choice%"=="3" call:NVIDIABroadcast
if /i "%choice%"=="4" call:ThunderMaster
if /i "%choice%"=="5" call:LogitechGhub
if /i "%choice%"=="6" call:JBLQuantumENGINE
if /i "%choice%"=="7" call:Edge
if /i "%choice%"=="8" call:Chrome
if /i "%choice%"=="9" call:FireFox
if /i "%choice%"=="10" call:GitHubDesktop
if /i "%choice%"=="11" call:VScode
if /i "%choice%"=="12" call:Pycharm
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto AppRecommended
if /i "%choice%"=="N" (set "PG=AppRecommendedPG3") & goto AppRecommendedPG3
goto AppRecommendedPG2

:AppRecommendedPG3
cls
mode con: cols=135 lines=45
echo.
echo                                                                                                                        %COL%[36mPage 3/3
call :AssistantXTitle
TITLE Files Downloads Panel - AssistantX v%localtwo%
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
echo.
echo.
echo                 %COL%[1;4;34mOthers Files%COL%[0m
echo.
echo                 %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m AIDA64                            %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m dfControl                     %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m qbittorrent
echo.
echo                 %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m WinRaR                            %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m Uninstall Tool                %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m Windows Digital Activation
echo.
echo                 %COL%[96m[%COL%[37m 7 %COL%[96m]%COL%[37m DirectX                           %COL%[96m[%COL%[37m 8 %COL%[96m]%COL%[37m Visual C++                    %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m Auslogics Driver Updater
echo.
echo                 %COL%[96m[%COL%[37m 10 %COL%[96m]%COL%[37m Vpn (WireGuard)
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                  %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]         %COL%[36m[ N next page ]
echo.
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
set /p choice="%DEL%                                                    %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" call:AIDA64
if /i "%choice%"=="2" call:dfControl
if /i "%choice%"=="3" call:qbittorrent
if /i "%choice%"=="4" call:WinRaR
if /i "%choice%"=="5" call:UninstallTool
if /i "%choice%"=="6" call:WinDigActivation
if /i "%choice%"=="7" call:DirectX
if /i "%choice%"=="8" call:VisualC
if /i "%choice%"=="9" call:AuslogicsDriverUpdater
if /i "%choice%"=="10" call:WireGuard
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto AppRecommendedPG2
if /i "%choice%"=="N" (set "PG=AppRecommended") & goto AppRecommended
goto AppRecommendedPG3

:AppNORecommended
cls
echo.
echo.
call :AssistantXTitle
TITLE App Panel - AssistantX v%localtwo%
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
echo.
echo.
echo                 %COL%[1;4;34mWeb Browsers%COL%[0m
echo.
echo                 %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m YandexBrowser
echo.
echo                 %COL%[1;4;34mOthers Files%COL%[0m
echo.
echo                 %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Ccleaner
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                               %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]
echo.
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
set /p choice="%DEL%                                                     %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" call:YandexBrowser
if /i "%choice%"=="2" call:Ccleaner
if /i "%choice%"=="U" goto AppUninstall
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto AppPanel
goto AppNORecommended

:: Начало установочных файлов
:Discord
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\DiscordSetup.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\DiscordSetup.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\DiscordSetup.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/DiscordSetup.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\DiscordSetup.exe
)
goto AppRecommended

:Steam
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\SteamSetup.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\SteamSetup.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\SteamSetup.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/SteamSetup.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\SteamSetup.exe
)
goto AppRecommended

:EGS
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\Epic.Games.msi" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\Epic.Games.msi
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Epic.Games.msi "https://github.com/ALFiX01/AssistantX/releases/download/File/Epic.Games.msi"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\Epic.Games.msi
)
goto AppRecommended

:MSIAfterburner
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\MSIAfterburnerSetup.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\MSIAfterburnerSetup.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\MSIAfterburnerSetup.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/MSIAfterburnerSetup.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\MSIAfterburnerSetup.exe
)
goto AppRecommended

:WinTweaker
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\Win.Tweaker.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\Win.Tweaker.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Win.Tweaker.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Win.Tweaker.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\Win.Tweaker.exe
)
goto AppRecommended

:QuickCpu
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\QuickCpuSetup.msi" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\QuickCpuSetup.msi
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\QuickCpuSetup.msi "https://github.com/ALFiX01/AssistantX/releases/download/File/QuickCpuSetup.msi"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\QuickCpuSetup.msi
)
goto AppRecommended

:AuslogicsBoostSpeed
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\AuslogicsBoostSpeed-13.0.0.3\Auslogics.BoostSpeed.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\AuslogicsBoostSpeed-13.0.0.3\Auslogics.BoostSpeed.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Auslogics.BoostSpeed.zip "https://github.com/ALFiX01/AssistantX/releases/download/File/Auslogics.BoostSpeed.zip"
	powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\AssistantX\Downloads\Auslogics.BoostSpeed.zip' -DestinationPath '%SYSTEMDRIVE%\AssistantX\Downloads\'	
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\AuslogicsBoostSpeed-13.0.0.3\Auslogics.BoostSpeed.exe
)
goto AppRecommended

:Start11
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\Start11.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\Start11.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Start11.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Start11.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\Start11.exe
)
goto AppRecommended

:WinDynamicDesktop
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\WinDynamicDesktop.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\WinDynamicDesktop.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\WinDynamicDesktop.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/WinDynamicDesktop.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\WinDynamicDesktop.exe
)
goto AppRecommended

:PaintNet
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\paintnet.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\paintnet.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\paintnet.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/paintnet.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\paintnet.exe
)
goto AppRecommended

:Photoshop
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\Adobe.Photoshop.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\Adobe.Photoshop.exe
) ELSE (
	    echo %COL%[32m Downloads cleared %COL%[37m
		del /S /Q %SYSTEMDRIVE%\AssistantX\Downloads\ >nul 2>&1
		echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Adobe-Photoshop.zip "https://github.com/ALFiX01/AssistantX/releases/download/File/Adobe-Photoshop.zip"
		powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\AssistantX\Downloads\Adobe-Photoshop.zip' -DestinationPath '%SYSTEMDRIVE%\AssistantX\Downloads\Adobe-Photoshop'
	del %SYSTEMDRIVE%\AssistantX\Downloads\Adobe-Photoshop.zip
		echo %COL%[32m Downloading prerequisites %COL%[37m			
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\PHSP.zip "https://github.com/ALFiX01/AssistantX/releases/download/File/PHSP.zip"
		powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\AssistantX\Downloads\PHSP.zip' -DestinationPath '%SYSTEMDRIVE%\AssistantX\Downloads\Adobe-Photoshop\Adobe 2023\products\'
	del %SYSTEMDRIVE%\AssistantX\Downloads\PHSP.zip		
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\products.zip "https://github.com/ALFiX01/AssistantX/releases/download/File/products.zip"	
		powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\AssistantX\Downloads\products.zip' -DestinationPath '%SYSTEMDRIVE%\AssistantX\Downloads\Adobe-Photoshop\Adobe 2023\products\'	
	del %SYSTEMDRIVE%\AssistantX\Downloads\products.zip				
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\Adobe-Photoshop\autoplay.exe
)
goto AppRecommended

:TopazGigapixelAI
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\CCleaner.exe" (
	echo %COL%[32m Launching %COL%[37m
reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "forceLogin" /t REG_SZ /d "false" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "ia0" /t REG_SZ /d "aWk=" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "lastLoggedInUserName" /t REG_SZ /d "any name" /f >nul 2>&1	
reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "userPw" /t REG_SZ /d "any password" /f >nul 2>&1	
start %SYSTEMDRIVE%\AssistantX\Downloads\TopazGigapixelAI\TopazGigapixelAI.exe
) ELSE (
	echo %COL%[32m Downloads cleared %COL%[37m
	del /S /Q %SYSTEMDRIVE%\AssistantX\Downloads\ >nul 2>&1
	cd %SYSTEMDRIVE%\AssistantX
	mkdir %SYSTEMDRIVE%\AssistantX\Downloads\TopazGigapixelAI >nul 2>&1
	    echo %COL%[32m Download started %COL%[37m
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\TopazGigapixelAI\TopazGigapixelAI.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/TopazGigapixelAI.exe"
reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "forceLogin" /t REG_SZ /d "false" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "ia0" /t REG_SZ /d "aWk=" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "lastLoggedInUserName" /t REG_SZ /d "any name" /f >nul 2>&1	
reg add "HKEY_CURRENT_USER\Software\Topaz Labs LLC\Topaz Gigapixel AI\appMain"  /v "userPw" /t REG_SZ /d "any password" /f >nul 2>&1
  echo 127.0.0.1 topazlabs.com >> %SYSTEMDRIVE%\Windows\System32\drivers\etc\hosts
  echo 127.0.0.1 et.topazlabs.com >> %SYSTEMDRIVE%\Windows\System32\drivers\etc\hosts
  echo 127.0.0.1 104.22.33.115 >> %SYSTEMDRIVE%\Windows\System32\drivers\etc\hosts
  echo 127.0.0.1 172.67.37.186 >> %SYSTEMDRIVE%\Windows\System32\drivers\etc\hosts      
start %SYSTEMDRIVE%\AssistantX\Downloads\TopazGigapixelAI\TopazGigapixelAI.exe
)
goto AppRecommended

:Zona
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\ZonaSetup64.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\ZonaSetup64.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\ZonaSetup64.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/ZonaSetup64.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\ZonaSetup64.exe
)
goto AppRecommendedPG2

:GeForceExperience
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\GeForce_Experience.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\GeForce_Experience.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\GeForce_Experience.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/GeForce_Experience.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\GeForce_Experience.exe
)
goto AppRecommendedPG2

:NVIDIABroadcast
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\NVIDIA_Broadcast.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\NVIDIA_Broadcast.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\NVIDIA_Broadcast.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/NVIDIA_Broadcast.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\NVIDIA_Broadcast.exe
)
goto AppRecommendedPG2

:ThunderMaster
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\Setup_ThunderMaster.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\Setup_ThunderMaster.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Setup_ThunderMaster.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Setup_ThunderMaster.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\Setup_ThunderMaster.exe
)
goto AppRecommendedPG2

:LogitechGhub
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\Logitech.Ghub.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\Logitech.Ghub.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Logitech.Ghub.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Logitech.Ghub.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\Logitech.Ghub.exe
)
goto AppRecommendedPG2

:JBLQuantumENGINE
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\JBL_QuantumENGINE.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\JBL_QuantumENGINE.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\JBL_QuantumENGINE.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/JBL_QuantumENGINE.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\JBL_QuantumENGINE.exe
)
goto AppRecommendedPG2

:Edge
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\MicrosoftEdge.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\MicrosoftEdge.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\MicrosoftEdge.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/MicrosoftEdge.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\MicrosoftEdge.exe
)
goto AppRecommendedPG2

:Chrome
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\Chrome.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\Chrome.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Chrome.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Chrome.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\Chrome.exe
)
goto AppRecommendedPG2

:FireFox
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\Firefox.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\Firefox.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Firefox.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Firefox.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\Firefox.exe
)
goto AppRecommendedPG2

:GitHubDesktop
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\GitHubDesktop.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\GitHubDesktop.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\GitHubDesktop.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/GitHubDesktop.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\GitHubDesktop.exe
)
goto AppRecommendedPG2

:VScode
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\VSCode.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\VSCode.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\VSCode.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/VSCode.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\VSCode.exe
)
goto AppRecommendedPG2

:Pycharm
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\Pycharm.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\Pycharm.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Pycharm.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Pycharm.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\Pycharm.exe
)
goto AppRecommendedPG2

:AIDA64
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\AIDA64.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\AIDA64.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\AIDA64.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/AIDA64.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\AIDA64.exe
)
goto AppRecommendedPG3

:dfControl
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\dfControl.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\dfControl.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\dfControl.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/dfControl.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\dfControl.exe
)
goto AppRecommendedPG3

:qbittorrent
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\qbittorrent.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\qbittorrent.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\qbittorrent.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/qbittorrent.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\qbittorrent.exe
)
goto AppRecommendedPG3

:WinRaR
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\WinRAR.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\WinRAR.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\WinRAR.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/WinRAR.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\WinRAR.exe
)
goto AppRecommendedPG3

:UninstallTool
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\Uninstall.Tool.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\Uninstall.Tool.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Uninstall.Tool.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Uninstall.Tool.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\Uninstall.Tool.exe
)
goto AppRecommendedPG3

:WinDigActivation
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\WinDigitalActivation.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\WinDigitalActivation.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\WinDigitalActivation.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/WinDigitalActivation.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\WinDigitalActivation.exe
)
goto AppRecommendedPG3

:DirectX
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\DirectX.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\DirectX.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\DirectX.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/DirectX.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\DirectX.exe
)
goto AppRecommendedPG3

:VisualC
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\Visual.C++.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\Visual.C++.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Visual.C++.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Visual.C++.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\Visual.C++.exe
)
goto AppRecommendedPG3

:AuslogicsDriverUpdater
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\Auslogics.Driver.Updater.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\Auslogics.Driver.Updater.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Auslogics.Driver.Updater.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Auslogics.Driver.Updater.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\Auslogics.Driver.Updater.exe
)
goto AppRecommendedPG3

:YandexBrowser
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\Yandex.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\Yandex.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Yandex.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Yandex.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\Yandex.exe
)
goto AppNORecommended

:Ccleaner
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\CCleaner.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\CCleaner.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\CCleaner.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/CCleaner.exe"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\CCleaner.exe
)
goto AppNORecommended

:WireGuard
IF EXIST "%SYSTEMDRIVE%\AssistantX\Downloads\wireguard.exe" (
	echo %COL%[32m Launching %COL%[37m
    start %SYSTEMDRIVE%\AssistantX\Downloads\wireguard.exe
) ELSE (
	    echo %COL%[32m Download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\wireguard.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/wireguard.exe"
	echo %COL%[32m Wireguard VPN Config download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\DE_1324690943.conf "https://github.com/ALFiX01/AssistantX/releases/download/File/DE_1324690943.conf"
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\LU_1324690943.conf "https://github.com/ALFiX01/AssistantX/releases/download/File/LU_1324690943.conf"
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\RU_1324690943.conf "https://github.com/ALFiX01/AssistantX/releases/download/File/RU_1324690943.conf"
		echo %COL%[32m Downloading completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Downloads\wireguard.exe
)
goto AppRecommendedPG3
:: Конец установочных файлов

:AppUninstall
cls
echo.
call :AssistantXTitle
TITLE App Uninstall Panel - AssistantX v%localtwo%
echo                         %COL%[37m______________________________________________________________________________________
echo.
echo                                                           %COL%[1;4;34mUninstall method%COL%[0m
echo.
echo.
echo                                      %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Selective                               %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Automatic
echo                                      %COL%[90mIt's your choice                              %COL%[90mDeletes only junk
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                               %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]
echo.
echo                         %COL%[37m______________________________________________________________________________________
echo.
set /p choice="%DEL%                                                    %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" call:Selective-M
if /i "%choice%"=="2" call:Prepared-M
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto AppPanel
goto AppUninstall

:Prepared-M
TITLE Prepared Uninstall Panel - AssistantX v%localtwo%
powershell -executionpolicy -command "Get-AppxPackage -allusers *people* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.People_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *zunevideo* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.ZuneVideo_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *3dbuilder* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.3DBuilder_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *skypeapp* | Remove-AppxPackage" >nul 2>&1
winget uninstall skype --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *solitaire* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *officehub* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *maps* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.WindowsMaps_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bing* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bing* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *onenote* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.Office.OneNote_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingfinance* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingsports* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingnews* | Remove-AppxPackage" >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.GetHelp_8wekyb3d8bbwe" >nul 2>&1
winget uninstall Microsoft.GetHelp_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage MicrosoftTeams_22336.907.1742.9730_x64__8wekyb3d8bbwe" >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage MicrosoftTeams_23034.1300.1846.7680_x64__8wekyb3d8bbwe" >nul 2>&1
winget uninstall MicrosoftTeams_8wekyb3d8bbwe --accept-source-agreements --silent
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.PowerAutomateDesktop_1.0.65.0_x64__8wekyb3d8bbwe" >nul 2>&1
winget uninstall Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.OneDriveSync_21220.1024.5.0_neutral__8wekyb3d8bbwe" >nul 2>&1
winget uninstall Microsoft.OneDrive --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.Getstarted_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.BingWeather_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.Wallet_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.MixedReality.Portal_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.Todos_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.BingNews_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Clipchamp.Clipchamp_yxz26nhyzhsrt --accept-source-agreements --silent
winget uninstall 5319275A.WhatsAppDesktop_cv1g1gvanyjgm --accept-source-agreements --silent
call:DisableCortana
echo %COL%[92mCompleted%COL%[37m
pause
goto AppUninstall

:Selective-M
cls
echo.
call:AssistantXTitle
TITLE Selective Uninstall Panel - AssistantX v%localtwo%
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
echo                                                           %COL%[1;4;34mUninstall Programm%COL%[0m
echo.
echo                      %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m People                           %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Movie and TV                      %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m 3D builder
echo.
echo                      %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m Skype                            %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m Solitaire                         %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m Office
echo.
echo                      %COL%[96m[%COL%[37m 7 %COL%[96m]%COL%[37m maps                             %COL%[96m[%COL%[37m 8 %COL%[96m]%COL%[37m Bing                              %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m OneNote
echo.
echo                      %COL%[96m[%COL%[37m 10 %COL%[96m]%COL%[37m Bing Finance                    %COL%[96m[%COL%[37m 11 %COL%[96m]%COL%[37m Bing Sports                       %COL%[96m[%COL%[37m 12 %COL%[96m]%COL%[37m Bing News
echo.
echo                      %COL%[96m[%COL%[37m 13 %COL%[96m]%COL%[37m Cortana                         %COL%[96m[%COL%[37m 14 %COL%[96m]%COL%[37m GetHelp                          %COL%[96m[%COL%[37m 15 %COL%[96m]%COL%[37m MicrosoftTeams
echo.
echo                      %COL%[96m[%COL%[37m 14 %COL%[96m]%COL%[37m Xbox Applications 
echo                      %COL%[90m(GamingApp, XboxApp, XboxSpeechToTextOverlay,
echo                      XboxIdentityProvider, XboxGamingOverlay, XboxGameOverlay)%COL%[37m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                 %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]         
echo.
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
set /p choice="%DEL%                                                     %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" call:iPeople
if /i "%choice%"=="2" call:iMovie
if /i "%choice%"=="3" call:i3Dbuilder
if /i "%choice%"=="4" call:iSkype
if /i "%choice%"=="5" call:iSolitaire
if /i "%choice%"=="6" call:iOffice
if /i "%choice%"=="7" call:imaps
if /i "%choice%"=="8" call:ibing
if /i "%choice%"=="9" call:iOneNote
if /i "%choice%"=="10" call:iBingFinance
if /i "%choice%"=="11" call:iBingSports
if /i "%choice%"=="12" call:iBingNews
if /i "%choice%"=="13" call:iCortana
if /i "%choice%"=="14" call:iGetHelp
if /i "%choice%"=="15" call:iMicrosoftTeams
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto AppUninstall
goto Selective-M

:iPeople
powershell -executionpolicy -command "Get-AppxPackage -allusers *people* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.People_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:iMovie
powershell -executionpolicy -command "Get-AppxPackage -allusers *zunevideo* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.ZuneVideo_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:i3Dbuilder
powershell -executionpolicy -command "Get-AppxPackage -allusers *3dbuilder* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.3DBuilder_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:iSkype
powershell -executionpolicy -command "Get-AppxPackage -allusers *skypeapp* | Remove-AppxPackage" >nul 2>&1
winget uninstall skype --accept-source-agreements --silent >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:iSolitaire
powershell -executionpolicy -command "Get-AppxPackage -allusers *solitaire* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:iOffice
powershell -executionpolicy -command "Get-AppxPackage -allusers *officehub* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:imaps
powershell -executionpolicy -command "Get-AppxPackage -allusers *maps* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.WindowsMaps_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:ibing
powershell -executionpolicy -command "Get-AppxPackage -allusers *bing* | Remove-AppxPackage" >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:iOneNote
powershell -executionpolicy -command "Get-AppxPackage -allusers *onenote* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.Office.OneNote_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:iBingFinance
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingfinance* | Remove-AppxPackage" >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M


:iBingSports
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingsports* | Remove-AppxPackage" >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:iBingNews
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingnews* | Remove-AppxPackage" >nul 2>&1
winget uninstall Microsoft.PowerAutomateDesktop_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:iCortana
powershell -executionpolicy -command "Get-AppxPackage -allusers *Microsoft.549981C3F5F10* | Remove-AppxPackage" >nul 2>&1
winget uninstall cortana --accept-source-agreements --silent >nul 2>&1
call:DisableCortana
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:iGetHelp
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.GetHelp_8wekyb3d8bbwe" >nul 2>&1
winget uninstall Microsoft.GetHelp_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:iMicrosoftTeams
powershell -executionpolicy -command "Remove-AppxpackageMicrosoftTeams_22336.907.1742.9730_x64__8wekyb3d8bbwe" >nul 2>&1
winget uninstall MicrosoftTeams_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:iXbox
winget uninstall Microsoft.GamingApp_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.XboxApp_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.Xbox.TCUI_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.XboxSpeechToTextOverlay_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.XboxIdentityProvider_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.XboxGamingOverlay_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
winget uninstall Microsoft.XboxGameOverlay_8wekyb3d8bbwe --accept-source-agreements --silent >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Selective-M

:DissableFSOandGameBar
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "GamePanelStartupTipIndex" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "ShowStartupPanel" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"  /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR"  /v "AllowGameDVR" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR"  /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\GameBar"  /v "AutoGameModeEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG1

:DirectXtweaks
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "CpuCoresAlways" /t REG_DWORD /d "18" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "CpuUtilization" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "LatencyPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "RenderingSpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "RenderingPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuMax" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "MaxPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "MinPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "PerformancePriority" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "PerformanceSpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuMaxPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "CpuMaxPerformance" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuAccelerating" /t REG_DWORD /d "256" /f  >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuSpeed" /t REG_DWORD /d "256" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /ve /t REG_SZ /d "True" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "LatencySpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "RenderingPriority" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "LatencyPriority" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "CpuSpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "GpuRenderingPriority" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "RenderingSpread" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\GraphicsSettings" /v "SpreadPriority" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX\{39A262FC-984B-11ED-9501-806E6F6E6963}" /v "GPMinCores" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX\{39A262FE-984B-11ED-9501-806E6F6E6963}" /v "GPUMaxCores" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\DirectX\{39A262FE-984B-11ED-9501-806E6F6E6963}" /v "GPUMinCores1" /t REG_DWORD /d "0" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SecurityHealthService.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Windows.Media.BackgroundPlayback.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sfc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wusa.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\wbemtest.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\scrcons.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ApplyTrustOffline.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CustomInstallExec.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\deploymentcsphelper.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\expand.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ReAgentc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RelPost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MuiUnattend.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dxdiag.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fontdrvhost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\winlogon.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ucsvc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fltMC.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lsass.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ntoskrnl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\services.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\smss.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\csrss.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Boot\winload.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\AggregatorHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dtdump.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\runexehelper.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rdrleakdiag.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wpr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\pacjsworker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\userinit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wininit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DeviceCensus.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dllhost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\conhost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\extrac32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\makecab.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\svchost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\compact.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dwm.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dcomcnfg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Locator.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Com\MigRegDB.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RpcPing.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\mtstocom.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Com\comrepl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dllhst3g.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\setupcl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\setupugc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wimserv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\chkdsk.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\chkntfs.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wsqmcons.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\autochk.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\browser_broker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\browserexport.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Boot\winresume.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\winresume.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\winload.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\bthudtask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fsquirt.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\bitsadmin.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\refsutil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\appidcertstorecheck.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\appidpolicyconverter.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1     
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wlanext.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LockScreenContentServer.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SlideToShutDown.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\systray.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RunLegacyCPLElevated.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\control.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fontview.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wifitask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tzutil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\w32tm.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dmclient.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dsregcmd.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\UtcDecoderHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TpmTool.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\HealthAttestationClientAgent.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TpmInit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CloudNotifications.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemSettingsBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\mofcomp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\unsecapp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\WMIADAP.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wbem\WmiApSrv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RMActivate.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RMActivate_isv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RMActivate_ssp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RMActivate_ssp_isv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\printfilterpipelinesvc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\provtool.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PrintIsolationHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\spoolsv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PinEnrollmentBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WpcTok.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WpcMon.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ApproveChildRequest.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ofdeploy.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DmNotificationBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MDMAgent.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MicrosoftEdgeBCHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Eap3Host.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1 
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\choice.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\clip.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\doskey.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\forfiles.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\print.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\subst.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cttune.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cttunesvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\help.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\msdtc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CastSrv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\UserDataSource.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\curl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tar.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\spaceman.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\spaceutil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\EDPCleanup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MDMAppInstaller.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ARP.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\finger.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\HOSTNAME.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MRINFO.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\NETSTAT.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ROUTE.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sort.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TCPSVCS.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\xcopy.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\auditpol.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\mountvol.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\net.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\net1.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\netsh.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PATHPING.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PING.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\reg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\setx.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TRACERT.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\attrib.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ClipUp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\diskusage.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\findstr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\icacls.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ipconfig.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CIDiag.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\comp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\fsutil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\recover.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sdclt.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PerceptionSimulation\PerceptionSimulationService.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tcblaunch.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\securekernel.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SgrmBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SgrmLpac.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\upnpcont.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\BioIso.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\NgcIso.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dusmtask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WinBioPlugIns\FaceFodUninstaller.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\oobeldr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\windeploy.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\audit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\AuditShD.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MBR2GPT.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\Setup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\poqexec.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PkgMgr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1     
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\mcbuilder.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MSchedExe.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WUDFCompanionHost.exe" /t REG_SZ /d "GpuPreference=1;" /f   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WUDFHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\AxInstUI.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\consent.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LanguageComponentsInstallerComHandler.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LockAppHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\la57setup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lpk-" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lpksetup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lpremove.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DsmUserTask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\netcfg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\runonce.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\secinit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\colorcpl.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dccw.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Dism.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\proquota.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\UserAccountControlSettings.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\shutdown.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\efsui.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cipher.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\edpnotify.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\MicrosoftEdgeCP.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rekeywiz.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dnscacheugc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\nslookup.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\lodctr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\unlodctr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ddodiag.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\omadmclient.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\omadmprc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DmOmaCpMo.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\coredpussvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DeviceEnroller.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dmcertinst.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dmcfghost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CredentialUIBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SensorDataService.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SecurityHealthHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\prproc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1       
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\audiodg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SpatialAudioLicenseSrv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\CompPkgSrv.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\agentactivationruntimestarter.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\IcsEntitlementHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\XblGameSaveTask.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\notepad.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\TsWpfWrp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\explorer.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1 
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Dism\DismHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cmdkey.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\dpapimig.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LsaIso.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cscript.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\RmClient.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SecEdit.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wscript.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\icsunattend.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\NetHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cmmon32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cmstp.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\cmdl32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rasautou.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rasdial.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rasphone.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ntprint.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\printui.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\DeviceEject.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\powercfg.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sigverif.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\drvinst.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\hdwwiz.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\pnputil.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\wowreg32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\InfDefault-" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ndadmin.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\newdev.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\driverquery.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\PnPUnattend.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\FirstLogonAnim.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\msoobe.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\oobe\UserOOBEBroker.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\netbtugc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\netiougc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\nbtstat.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\NetCfgNotifyObjectHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\djoin.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\getmac.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\shrpubw.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesAdvanced.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesComputerName.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesDataExecutionPrevention.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesHardware.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesPerformance.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesProtection.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SystemPropertiesRemote.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\winver.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sxstrace.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Sysprep\sysprep.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WSCollect.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WSReset.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\changepk.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\LicensingUI.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\phoneactivate.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\UpgradeResultsUI.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\GenValObj.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\slui.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\SppExtComObj.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\sppsvc.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\Speech\SpeechUX\SpeechUXWiz.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\snmptrap.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\immersivetpmvscmgrsvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1  
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rmttpmvscmgrsvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tpmvscmgr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\tpmvscmgrsvr.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\OpenWith.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\ThumbnailExtractionHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\verclsid.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\WallpaperHost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\prevhost.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1   
Reg.exe add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "C:\Windows\System32\rundll32.exe" /t REG_SZ /d "GpuPreference=1;" /f >nul 2>&1 
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG1

:ChromeTweaks
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "TranslateEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "TaskManagerEndProcessEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "UserFeedbackAllowed" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SpellCheckServiceEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SpellcheckEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MediaRouterCastAllowAllIPs" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "AllowDinosaurEasterEgg" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultGeolocationSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultCookiesSetting" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileHandlingGuardSetting" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileSystemReadGuardSetting" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultFileSystemWriteGuardSetting" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultImagesSetting" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultPopupsSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultSensorsSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultSerialGuardSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultWebBluetoothGuardSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultWebUsbGuardSetting" /t REG_DWORD /d "2" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "EnableMediaRouter" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "ShowCastIconInToolbar" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "CloudPrintProxyEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "PrintRasterizationMode" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "PrintingEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DefaultPluginsSetting" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SafeBrowsingProtectionLevel" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "SafeBrowsingExtendedReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "HomepageIsNewTabPage" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "HomepageLocation" /t REG_SZ /d "google.com" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "NewTabPageLocation" /t REG_SZ /d "google.com" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome\Recommended" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome\Recommended" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome\Recommended" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome\Recommended" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Chrome" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome" /v "MetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKCU\SOFTWARE\Policies\Google\Chrome" /v "DeviceMetricsReportingEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Install{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_DWORD /d "5" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "TargetChannel{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_SZ /d "stable" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Update{8A69D345-D564-463C-AFF1-A69D9E530F96}" /t REG_DWORD /d "3" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "Install{4CCED17F-7852-4AFC-9E9E-C89D8795BDD2}" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "AutoUpdateCheckPeriodMinutes" /t REG_DWORD /d "43200" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "DownloadPreference" /t REG_SZ /d "cacheable" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedStartHour" /t REG_DWORD /d "23" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedStartMin" /t REG_DWORD /d "48" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Policies\Google\Update" /v "UpdatesSuppressedDurationMin" /t REG_DWORD /d "55" /f >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG2

:MouseTweaks
Reg.exe add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorMagnetism" /v "AttractionRectInsetInDIPS" /t REG_DWORD /d "5" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorMagnetism" /v "DistanceThresholdInDIPS" /t REG_DWORD /d "40" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorMagnetism" /v "MagnetismDelayInMilliseconds" /t REG_DWORD /d "50" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorMagnetism" /v "MagnetismUpdateIntervalInMilliseconds" /t REG_DWORD /d "16" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorMagnetism" /v "VelocityInDIPSPerSecond" /t REG_DWORD /d "360" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorSpeed" /v "CursorSensitivity" /t REG_DWORD /d "10000" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorSpeed" /v "CursorUpdateInterval" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Input\Settings\ControllerProcessor\CursorSpeed" /v "IRRemoteNavigationDelta" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d "20" /f >nul 2>&1
Reg.exe add "HKU\.DEFAULT\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f >nul 2>&1
Reg.exe add "HKU\.DEFAULT\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
Reg.exe add "HKU\.DEFAULT\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Mouse" /v "MouseHoverTime" /t REG_SZ /d "8" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d "20" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "ThreadPriority" /t REG_DWORD /d "31" /f >nul 2>&1
Reg.exe add "HKCU\Control Panel\Mouse" /v "MouseSensitivity" /t REG_SZ /d "10" /f >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG2

:NVidiaAddonTweaks
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "PerfEnergyPreference" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPMinCores" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPMaxCores" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPMinCores1" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPMaxCores1" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CpLatencyHintUnpark1" /t REG_DWORD /d "100" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPDistribution" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CpLatencyHintUnpark" /t REG_DWORD /d "100" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "MaxPerformance1" /t REG_DWORD /d "100" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "MaxPerformance" /t REG_DWORD /d "100" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPDistribution1" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPHEADROOM" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPCONCURRENCY" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Power\Policy\Settings\Processor" /v "CPIncreaseTime" /t REG_DWORD /d "0" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\audiodg.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dllhost.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\dwm.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\explorer.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsass.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\lsm.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ntoskrnl.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\rundll32.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\services.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\smss.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\svchost.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskeng.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\taskmgr.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\wininit.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\winlogon.exe" /v "UseLargePages" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerMizerEnable" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PerfLevelSrc" /t REG_DWORD /d "8738" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerMizerLevelAC" /t REG_DWORD /d "1" /f >nul 2>&1
Reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerSaverHsyncOn" /t REG_DWORD /d "0" /f >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG2

:ASXPowerPlan
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Resources\AssistantX-Power.pow "https://github.com/ALFiX01/AssistantX/releases/download/Stable/AssistantX-Power.pow"
powercfg -import %SYSTEMDRIVE%\AssistantX\Resources\AssistantX-Power.pow
powercfg /d 381b4222-f694-41f0-9685-ff5bb260df2e
powercfg /d 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /d a1841308-3541-4fab-bc81-f71556f20b4a
powercfg /d a9758bf0-cfc6-439c-a392-7783990ff716
start powercfg.cpl
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG1

:Dsk
reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "DelayBeforeAcceptance" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatRate" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatDelay" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG1

:MSI
if "%MSIOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v "MSIModeTweaks" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f >nul 2>&1
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f >nul 2>&1
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f >nul 2>&1
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f >nul 2>&1
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v "MSIModeTweaks" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f >nul 2>&1
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f >nul 2>&1
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f >nul 2>&1
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority " /f >nul 2>&1
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG1

:DissWinTelemetry
		reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching"  /v "SearchOrderConfig" /t REG_DWORD /d "0" /f >nul 2>&1
            reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"  /v "EnableLua" /t REG_DWORD /d "0" /f >nul 2>&1
		reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR"  /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
            reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowSharedUserAppData"  /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
            reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowStore"  /v "value" /t REG_DWORD /d "0" /f 1 >nul 2>&1
            reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance"  /v "MaintenanceDisabled" /t REG_DWORD /d "0" /f >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG1

:DisableHDCP
for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
	if "%HDCOF%" == "%COL%[91mOFF" (
		reg add "HKCU\Software\AssistantX" /v HDCTweaks /f >nul 2>&1
		reg add "%%a" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "1" /f >nul 2>&1
	) else (
		reg delete "HKCU\Software\AssistantX" /v HDCTweaks /f >nul 2>&1
		reg add "%%a" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "0" /f >nul 2>&1
	)
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG1

:DisablePreemtion
if "%CMAOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /t Reg_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /t Reg_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /t Reg_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /t Reg_DWORD /d "1" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /t Reg_DWORD /d "0" /f >nul 2>&1
) >nul 2>&1 else (
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /f >nul 2>&1
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG1

:ProfileInspector
if "%NPIOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v NpiTweaks /f
	rmdir /S /Q "%SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector\"
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector.zip "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
	powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector.zip' -DestinationPath '%SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector\'
	del /F /Q "%SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector.zip"
	curl -g -L -# -o "%SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector\Latency_and_Performances_Settings_by_AssistantX_Team2.nip" "https://raw.githubusercontent.com/ALFiX01/AssistantX/main/Files/Latency_and_Performances_Settings_by_AssistantX_Team2.nip"
	cd "%SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector\"
	nvidiaProfileInspector.exe "Latency_and_Performances_Settings_by_AssistantX_Team2.nip"
) >nul 2>&1 else (
	rem https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip
	reg delete "HKCU\Software\AssistantX" /v NpiTweaks /f
	rmdir /S /Q "%SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector\"
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector.zip "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/latest/download/nvidiaProfileInspector.zip"
	powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector.zip' -DestinationPath '%SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector\'
	del /F /Q "%SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector.zip"
	curl -g -L -# -o "%SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector\Base_Profile.nip" "https://raw.githubusercontent.com/auraside/AssistantXCtrl/main/Files/Base_Profile.nip"
	cd "%SYSTEMDRIVE%\AssistantX\Resources\nvidiaProfileInspector\"
	nvidiaProfileInspector.exe "Base_Profile.nip"
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG1

:NVTelemetry
if "%NVTOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v NVTTweaks /f >nul 2>&1
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d 0 /f >nul 2>&1
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d 0 /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "NvBackend" /f >nul 2>&1
	schtasks /change /disable /tn "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
	schtasks /change /disable /tn "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
	schtasks /change /disable /tn "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
	schtasks /change /disable /tn "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /f
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /f >nul 2>&1
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /f >nul 2>&1
	schtasks /change /enable /tn "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
	schtasks /change /enable /tn "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
	schtasks /change /enable /tn "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
	schtasks /change /enable /tn "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}" >nul 2>&1
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG1

:NvidiaTweaks
if "%NVIOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v "NvidiaTweaks" /f >nul 2>&1
	rem Nvidia Reg
	reg add "HKCU\Software\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" /v "NvCplUseColorCorrection" /t Reg_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t Reg_DWORD /d "0" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /t Reg_DWORD /d "0" /f >nul 2>&1
	rem Unrestricted Clocks
	cd "%SYSTEMDRIVE%\Program Files\NVIDIA Corporation\NVSMI\"
	nvidia-smi -acp UNRESTRICTED
	nvidia-smi -acp DEFAULT
	rem Nvidia Registry Key
	for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		rem Disalbe Tiled Display
		reg add "%%a" /v "EnableTiledDisplay" /t REG_DWORD /d "0" /f
		rem Disable TCC
		reg add "%%a" /v "TCCSupported" /t REG_DWORD /d "0" /f
	)
	rem Silk Smoothness Option
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v "EnableRID61684" /t REG_DWORD /d "1" /f >nul 2>&1
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v "NvidiaTweaks" /f >nul 2>&1
	rem Nvidia Reg
	reg delete "HKCU\Software\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" /v "NvCplUseColorCorrection" /f >nul 2>&1
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t Reg_DWORD /d "1" /f >nul 2>&1
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /f >nul 2>&1
	rem Nvidia Registry Key
	for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		rem Reset Tiled Display
		reg delete "%%a" /v "EnableTiledDisplay" /f >nul 2>&1
		rem Reset TCC
		reg delete "%%a" /v "TCCSupported" /f >nul 2>&1
	)
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG1

:DisableWriteCombining
if "%DWCOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /t Reg_DWORD /d "1" /f >nul 2>&1
) >nul 2>&1 else (
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /f >nul 2>&1
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG1

:gameBooster
TITLE Game Booster Panel - AssistantX v%localtwo%
cls & echo Select the game location, you can do it a second time to revert the changes.
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
	echo Game boost has been reverted!
	Timeout 5
) || (
	reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "%file%" /t Reg_SZ /d "GpuPreference=2;" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%file%" /t Reg_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f >nul 2>&1
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%~nxF\PerfOptions" /v "CpuPriorityClass" /t Reg_DWORD /d "3" /f >nul 2>&1
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto OptimizationPG1

:softRestart
cls
cd %TEMP%
if not exist "%TEMP%\NSudo.exe" curl -g -L -# -o "%TEMP%\NSudo.exe" "https://github.com/ALFiX01/AssistantX/raw/main/Files/NSudo.exe"
NSudo.exe -U:S -ShowWindowMode:Hide cmd /c "reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t Reg_DWORD /d "3" /f" >nul 2>&1
NSudo.exe -U:S -ShowWindowMode:Hide cmd /c "sc start "TrustedInstaller"" >nul 2>&1
if not exist "%TEMP%\restart64.exe" curl -g -L -# -o "%TEMP%\Restart64.exe" "https://github.com/ALFiX01/AssistantX/raw/main/Files/restart64.exe"
if not exist "%TEMP%\EmptyStandbyList.exe" curl -g -L -# -o "%TEMP%\EmptyStandbyList.exe" "https://github.com/ALFiX01/AssistantX/raw/main/Files/EmptyStandbyList.exe"
taskkill /f /im explorer.exe >nul 2>&1
cd %SYSTEMROOT% >nul 2>&1
start explorer.exe >nul 2>&1
cd %TEMP%
echo netsh advfirewall reset >RefreshNet.bat
echo ipconfig /release >>RefreshNet.bat
echo ipconfig /renew >>RefreshNet.bat
echo nbtstat -R >>RefreshNet.bat
echo nbtstat -RR >>RefreshNet.bat
echo ipconfig /flushdns >>RefreshNet.bat
echo ipconfig /registerdns >>RefreshNet.bat
NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "%TEMP%\RefreshNet.bat"
Restart64.exe
EmptyStandbyList.exe standbylist
echo.
echo.
echo  --------------------------------------------------------------
echo                      Soft Restart Completed
echo  --------------------------------------------------------------
echo.
echo.
echo                             [X] Close
echo.
%SYSTEMROOT%\System32\choice.exe /c:X /n /m "%DEL%                                >:"
goto MainMenu

:Ai
cls
TITLE AI Panel - AssistantX v%localtwo%
echo.
echo.
echo                                                                                 %COL%[33m##      ##
echo                         %COL%[33m####              ##         ##                   ##     ##    ##           ####    ##
echo                        %COL%[33m##  ##   ###  ###       ###  ####   ####  #####   ####     ##  ##           ##  ## 
echo                        %COL%[33m######  ###  ###   ##  ###    ##   ## ##  ##  ##   ##        ##             ######   ##
echo                        %COL%[33m##  ##    ##   ##  ##    ##   ##   ## ##  ##  ##   ##      ##  ##           ##  ##   ##
echo                        %COL%[33m##  ##  ###  ###   ##  ##     ###   ####  ##  ##   ###    ##    ##          ##  ##   ##
echo                                                                                 %COL%[33m##      ##
echo.
echo.
echo                                     %COL%[90m AssistantX Ai - free virtual assistant based on GPT-3.5 Turbo
echo.
echo                           %COL%[97m__________________________________________________________________________________
echo.
echo.
echo                                 %COL%[96m[ %COL%[37m1 %COL%[96m]%COL%[37m Install/Update Ai                               %COL%[96m[ %COL%[37m2 %COL%[96m]%COL%[37m Launch Ai
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]
echo.
echo                           %COL%[97m__________________________________________________________________________________
echo.
set /p choice="%DEL%                                                    %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" call:AIdownload
if /i "%choice%"=="2" call:AIstart
if /i "%choice%"=="B" goto MainMenu
if /i "%choice%"=="X" goto MainMenu
goto Ai

:AIdownload
del /S /Q %SYSTEMDRIVE%\AssistantX\AssistantAi\Assistant.exe
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\AssistantAi\Assistant.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Assistant.exe"
echo %COL%[92mCompleted%COL%[37m
pause
goto Ai

:AIstart
start %SYSTEMDRIVE%\AssistantX\AssistantAi\Assistant.exe
goto MainMenu

:AdvancedTW
reg query "HKCU\Software\AssistantX" /v "advancedtv" >nul 2>&1 && goto Advanced
cls
TITLE Advanced Optimization Panel - AssistantX v%localtwo%
echo.
echo.
call :AssistantXTitle
echo.
echo                                               %COL%[90m AssistantX is a free desktop utility
echo                                        %COL%[90m    made to improve your day-to-day productivity
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo.
echo     %COL%[96m1.%COL%[37m These Tweaks are HIGHLY experimental, we do %COL%[91mnot%COL%[37m recommend proceeding if you do not know what you're doing!
echo.
echo     %COL%[96m1.%COL%[37m Everything is "use at your own risk", we are %COL%[91mNOT LIABLE%COL%[37m if you damage your system in any way.
echo.
echo     %COL%[96m1.%COL%[37m Even though we have an automatic restore point feature, we %COL%[91mHighly%COL%[37m recommend making a manual restore point before running.
echo.
echo     Please enter "I agree" (without quotes) to continue:
echo.
echo.
echo                                                        %COL%[90m[ B for back ]
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!"=="B" goto OptimizationPG1
if /i "!input!" neq "i agree" goto Advanced
reg add "HKCU\Software\AssistantX" /v "advancedtv" /f >nul 2>&1

:Advanced 
REM for /f "tokens=2 delims==" %%a in ('wmic path Win32_Battery Get BatteryStatus /value ^| findstr "BatteryStatus"') do set status=%%a
REM if %status% == 1 ( set Battery=DC ) else ( set Battery=AC )
set "choice="
for %%i in (DSCOF AUTOF DRIOF BCDOF NONOF CS0OF PS0OF IDLOF CONG ) do (set "%%i=%COL%[92mON ") >nul 2>&1
(
	rem Disable Idle
	powercfg /qh scheme_current sub_processor IDLEDISABLE | find "AC Power Setting Index: 0x00000000" && set "IDLOF=%COL%[91mOFF"
	rem powercfg /qh scheme_current sub_processor IDLEDISABLE | find "Current %Battery% Power Setting Index: 0x00000000" && set "IDLOF=%COL%[91mOFF"
	rem DSCP Tweaks
	reg query "HKLM\Software\Policies\Microsoft\Windows\QoS\javaw" || set "DSCOF=%COL%[91mOFF"
	rem AutoTuning Tweak
	reg query "HKCU\Software\AssistantX" /v "TuningTweak" || set "AUTOF=%COL%[91mOFF"
	rem Congestion Provider Tweak
	reg query "HKCU\Software\AssistantX" /v "CongestionAdvancedON" || set "CONG=%COL%[91mOFF"
	rem Nvidia Drivers
	cd "%SYSTEMDRIVE%\Program Files\NVIDIA Corporation\NVSMI"
	for /f "tokens=1 skip=1" %%a in ('nvidia-smi --query-gpu^=driver_version --format^=csv') do if "%%a" neq "531.29" set "DRIOF=%COL%[91mOFF"
	rem NonBestEffortLimit Tweak
	reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" | find "0xa" || set "NONOF=%COL%[91mOFF"
	rem CS0 Tweak
	reg query "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" | find "0x0" || set "CS0OF=%COL%[91mOFF"
	rem PStates0
	For /F "tokens=*" %%i in ('reg query "HKLM\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HK"') do (reg query "%%i" /v "DisableDynamicPstate" | find "0x1" || set "PS0OF=%COL%[91mOFF")
	rem Check If Applicable For PC
	rem GPU
	for /f "tokens=2 delims==" %%a in ('wmic path Win32_VideoController get VideoProcessor /value') do (
		for %%n in (GeForce NVIDIA RTX GTX) do echo %%a | find "%%n" >nul && set "NVIDIAGPU=Found"
		for %%n in (AMD Ryzen) do echo %%a | find "%%n" >nul && set "AMDGPU=Found"
		for %%n in (Intel UHD) do echo %%a | find "%%n" >nul && set "INTELGPU=Found"
	)
	if "!NVIDIAGPU!" neq "Found" for %%g in (PS0OF DRIOF) do set "%%g=%COL%[93mN/A"
) >nul 2>&1
cls
TITLE Advanced Tweak Panel - AssistantX v%localtwo%
echo.
echo                                                                                                                        %COL%[36mPage 1/2
call :AssistantXTitle
echo              %COL%[37m_____________________________________________________________________________________________________________
echo.
echo                                                           %COL%[1;4;34mNetwork Tweaks%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m NonBestEffortLimit %NONOF%         %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m AutoTuning %AUTOF%                 %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m DSCP Value %DSCOF%
echo              %COL%[90mAllocate more bandwidth to apps      %COL%[90mCan reduce bufferbloat,              %COL%[90mSet the priority of your network
echo              %COL%[90mUse only on fast connections         %COL%[90mbut lower your Network speed         %COL%[90mtraffic to expedited forwarding
echo.
echo.
echo                                                            %COL%[1;4;34mPower Tweaks%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m Disable C-States %CS0OF%           %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m PStates 0 %PS0OF%                  %COL%[96m[%COL%[37m 7 %COL%[96m]%COL%[37m Disable Idle %IDLOF%
echo              %COL%[90mKeep CPU at C0 stopping throttling   %COL%[90mRun graphics card at its highest     %COL%[90mForce CPU to always be running
echo              %COL%[90mwill make PC generate more heat      %COL%[90mdefined frequencies                  %COL%[90mat highest CPU state
echo.
echo.
echo                                                            %COL%[1;4;34mOther Tweaks%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 8 %COL%[96m]%COL%[37m Disable Windows Defender
echo              %COL%[90mDisable Win Smartscreen and Win Deffender        
echo.
echo              %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m Uninstall Widgets             %COL%[96m[%COL%[37m 10 %COL%[96m]%COL%[37m Disable background programs   %COL%[96m[%COL%[37m 11 %COL%[96m]%COL%[37m Disable all notifications
echo             %COL%[90m Disables programs running in
echo.            %COL%[90m the background
echo.
echo.
echo.
echo.
echo                                    %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]         %COL%[36m[ N next page ]
echo.
echo              %COL%[37m_____________________________________________________________________________________________________________
echo.
set /p choice="%DEL%                                                     %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" goto NonBestEffortLimit
if /i "%choice%"=="2" goto Autotuning
if /i "%choice%"=="3" goto DSCPValue
if /i "%choice%"=="4" goto Congestion
if /i "%choice%"=="5" goto cstates
if /i "%choice%"=="6" goto pstates0
if /i "%choice%"=="7" goto DisableIdle
if /i "%choice%"=="8" goto Smartscreen
if /i "%choice%"=="9" goto WidgetUninstall
if /i "%choice%"=="10" goto DisableBackgroundPrograms
if /i "%choice%"=="11" goto DisableAllNotifications
if /i "%choice%"=="N" goto AdvancedPG2
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto OptimizationPG1
goto Advanced

:AdvancedPG2 
cls
TITLE Advanced Tweak Panel Page 2 - AssistantX v%localtwo%
echo.
echo.
cls
echo.
echo                                                                                                                        %COL%[36mPage 2/2
call :AssistantXTitle
echo              %COL%[37m_____________________________________________________________________________________________________________
echo.
echo.
echo                                                           %COL%[1;4;34mOther Tweaks%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Disable Cortana
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                               %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]
echo.
echo              %COL%[37m_____________________________________________________________________________________________________________
echo.
set /p choice="%DEL%                                                     %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" call:DisableCortana
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto Advanced
goto Advanced

::Функция "Полное выключение антивируса"
:Smartscreen
::Отключение Windows Defender
echo Disabling defender
icacls "C:\Program Files\Windows Defender" /t /c /q /grant administrators:F  >nul 2>&1
takeown /f "C:\Program Files\Windows Defender" >nul 2>&1
RD /S /Q "C:\Program Files\Windows Defender" >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Sense" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdNisSvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WdFilter" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\WinDefend" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SamSs" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\wscsvc" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SgrmBroker" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
sc stop WinDefend >nul 2>&1
sc config WinDefend start=disabled >nul 2>&1
sc delete WinDefend >nul 2>&1
sc stop WdNisSvc >nul 2>&1
sc config WdNisSvc start=disabled >nul 2>&1
sc delete WdNisSvc >nul 2>&1
sc stop WdFilter  >nul 2>&1
sc config WdFilter start=disabled >nul 2>&1
sc stop Sense >nul 2>&1
sc config Sense start=disabled >nul 2>&1
sc delete Sense >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "OneTimeSqmDataSent" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpyNetReporting" /t REG_DWORD /d 0 / >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d 1 / >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d 1 / >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\UX Configuration" /v "DisablePrivacyMode" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Scan" /v "AutomaticallyCleanAfterScan" /t REG_DWORD /d "0" /f >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable > NUL 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable > NUL 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable > NUL 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable > NUL 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontOfferThroughWUAU" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv" /v "Start" /t REG_DWORD /d 4 /f  >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdBoot" /v "Start" /t REG_DWORD /d 4 /f  >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\WdFilter" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
regsvr32 /s /u "%ProgramFiles%\Windows Defender\shellext.dll" >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableAntiSpywareRealtimeProtection" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" /v "DpaDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ProductStatus" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender" /v "ManagedDefenderProductType" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /v "DontReportInfectionInformation" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SecurityHealthService" /v "Start" /t REG_DWORD /d "4" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiVirus" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableSpecialRunningModes" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ForceUpdateFromMU" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "DisableBlockAtFirstSeen" /t REG_DWORD /d "1" /f >nul 2>&1
sc stop SecurityHealthService >nul 2>&1
sc config SecurityHealthService start=disabled >nul 2>&1
::Отключение SmartScreen
echo Disabling SmartScreen
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d "0" /f >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Advanced

::Функция "Выключение Cortana"
:DisableCortana
taskkill /f /im Cortana.exe >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "CanCortanaBeEnabled" /t REG_DWORD /d 0 /f  >nul 2>&1
rd /s /q "%WinDir%\SystemApps\Microsoft.Windows.Cortana_cw5n1h2txyewy" >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowSearchToUseLocation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "CortanaEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCortanaButton" /t REG_DWORD /d "0" /f >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto AdvancedPG2

::Функция "Выключение всех уведомлений"
:DisableAllNotifications
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /t REG_DWORD /d 0 /f >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto AdvancedPG2

::Функция "Удаление Виджетов"
:WidgetUninstall
powershell -executionpolicy -command "winget uninstall "windows web experience pack"" >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Advanced

:DisableBackgroundPrograms
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d 0 /f >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Advanced

:NonBestEffortLimit
if "%NONOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d "10" /f >nul 2>&1
) >nul 2>&1 else (
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /f >nul 2>&1
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Advanced


:Autotuning
if "%AUTOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v TuningTweak /f >nul 2>&1
	netsh int tcp set global autotuninglevel=disabled >nul 2>&1
	netsh winsock set autotuning off >nul 2>&1
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v TuningTweak /f >nul 2>&1
	netsh int tcp set global autotuninglevel=normal >nul 2>&1
	netsh winsock set autotuning on >nul 2>&1
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Advanced

:DSCPValue
if "%DSCOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Psched" /v "Start" /t Reg_DWORD /d "1" /f >nul 2>&1
	sc start Psched
	for %%i in (csgo VALORANT-Win64-Shipping javaw FortniteClient-Win64-Shipping ModernWarfare r5apex) do (
		reg query "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" || (
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Application Name" /t Reg_SZ /d "%%i.exe" /f >nul 2>&1
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Version" /t Reg_SZ /d "1.0" /f >nul 2>&1
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Protocol" /t Reg_SZ /d "*" /f >nul 2>&1
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local Port" /t Reg_SZ /d "*" /f >nul 2>&1
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local IP" /t Reg_SZ /d "*" /f >nul 2>&1
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local IP Prefix Length" /t Reg_SZ /d "*" /f >nul 2>&1
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote Port" /t Reg_SZ /d "*" /f >nul 2>&1
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote IP" /t Reg_SZ /d "*" /f >nul 2>&1
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote IP Prefix Length" /t Reg_SZ /d "*" /f >nul 2>&1
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "DSCP Value" /t Reg_SZ /d "46" /f >nul 2>&1
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Throttle Rate" /t Reg_SZ /d "-1" /f >nul 2>&1
		)
	)
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "46" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "56" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "46" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "56" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "5" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "7" /f >nul 2>&1
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /t REG_DWORD /d "65000" /f >nul 2>&1
) >nul 2>&1 else (
	for %%i in (csgo VALORANT-Win64-Shipping javaw FortniteClient-Win64-Shipping ModernWarfare r5apex) do (
		reg delete "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /f
	)
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeGuaranteed" /f >nul 2>&1
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeNetworkControl" /f >nul 2>&1
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeGuaranteed" /f >nul 2>&1
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeNetworkControl" /f >nul 2>&1
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeGuaranteed" /f >nul 2>&1
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeNetworkControl" /f >nul 2>&1
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /f >nul 2>&1
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto Advanced

:Congestion
Reg query "HKCU\Software\AssistantX" /v "WifiDisclaimer3" >nul 2>&1 && goto Congestion2
cls
echo.
echo.
call :AssistantXTitle
echo.
echo                                               %COL%[90m AssistantX is a free desktop utility
echo                                        %COL%[90m    made to improve your day-to-day productivity
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo %COL%[91m  This tweak is for Wi-Fi users only, if you're on Ethernet, do not run this tweak.
echo.
echo   %COL%[37mFor any questions and/or concerns, please join our discord: discord.gg/J7wghdhKsx
echo.
echo   %COL%[37mPlease enter "I understand" without quotes to continue:
echo.
echo.
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!" neq "i understand" goto Tweaks
Reg add "HKCU\Software\AssistantX" /v "WifiDisclaimer3" /f >nul 2>&1
:Congestion2
if "%CONG%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v CongestionAdvancedON /f
	netsh int tcp set supplemental Internet congestionprovider=newreno
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v CongestionAdvancedON /f
	netsh int tcp set supplemental Internet congestionprovider=default
) >nul 2>&1
goto Advanced

:cstates
if "%CS0OF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" /t REG_DWORD /d "0" /f >nul 2>&1
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" /t REG_DWORD /d "1" /f >nul 2>&1
) >nul 2>&1
call :AssistantXRestart "CStates" "%CS0OF%"
Mode 130,45
echo %COL%[92mCompleted%COL%[37m
pause
goto Advanced

:PStates0
if "%PS0OF%" == "%COL%[91mOFF" (
	for /f %%i in ('reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		reg add "%%i" /v "DisableDynamicPstate" /t REG_DWORD /d "1" /f >nul 2>&1
	)
) >nul 2>&1 else  (
	for /f %%i in ('reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		reg delete "%%i" /v "DisableDynamicPstate" /f >nul 2>&1
	)
) >nul 2>&1
call :AssistantXRestart "PStates 0" "%PS0OF%"
Mode 130,45
echo %COL%[92mCompleted%COL%[37m
pause
goto Advanced

:DisableIdle
if "%IDLOF%" == "%COL%[91mOFF" (
powercfg /setacvalueindex scheme_current sub_processor IDLEDISABLE 1
REM	if %battery% == AC (
REM		powercfg /setacvalueindex scheme_current sub_processor IDLEDISABLE 1
REM	) else (
REM		powercfg /setdcvalueindex scheme_current sub_processor IDLEDISABLE 1
REM	)
) else (
powercfg -setacvalueindex scheme_current sub_processor IDLEDISABLE 0
REM	if %battery% == AC (
REM		powercfg -setacvalueindex scheme_current sub_processor IDLEDISABLE 0
REM	) else (
REM		powercfg -setdcvalueindex scheme_current sub_processor IDLEDISABLE 0
REM	)
)
echo %COL%[92mCompleted%COL%[37m
pause
goto Advanced

goto Advanced

:More
cls
echo.
call :AssistantXTitle
TITLE More Panel - AssistantX v%localtwo%
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
echo.
echo.
echo                                       %COL%[96m[ %COL%[37m1 %COL%[96m] %COL%[37mAbout                             %COL%[96m[ %COL%[37m2 %COL%[96m] %COL%[37mCredits
echo.
echo.
echo                                       %COL%[96m[ %COL%[37m3 %COL%[96m] %COL%[37mDiscord                           %COL%[96m[ %COL%[37m4 %COL%[96m] %COL%[37mCreate Backup
echo.
echo.
echo                                       %COL%[96m[ %COL%[37m5 %COL%[96m] %COL%[37mASX Cleaner                       %COL%[96m[ %COL%[37m6 %COL%[96m] %COL%[37mClear ASX Temp
echo.
echo.
echo                                       %COL%[96m[ %COL%[37m7 %COL%[96m] %COL%[37mFix Problems                      %COL%[96m[ %COL%[37m8 %COL%[96m] %COL%[37mWiFi Speed testing
echo.
echo.
echo                                       %COL%[96m[ %COL%[37m9 %COL%[96m] %COL%[37mSoft Restart                      %COL%[96m[ %COL%[37m10 %COL%[96m] %COL%[37mEdit Context Menu
echo.
echo.
echo                                       %COL%[96m[ %COL%[37m11 %COL%[96m] %COL%[37mSelect Branch
echo                                       %COL%[90mSelecting the update branch AssistantX%COL%[37m
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]%COL%[37m
echo.
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
set /p choice="%DEL%                                                     %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" goto About
if /i "%choice%"=="2" goto Credits
if /i "%choice%"=="3" goto Discord
if /i "%choice%"=="4" call:Backup
if /i "%choice%"=="5" goto ASXcleanerMenu
if /i "%choice%"=="6" goto Cl_ASX_TEMP
if /i "%choice%"=="7" call:FixProblem
if /i "%choice%"=="8" call:WiFiTest
if /i "%choice%"=="9" call:softRestart
if /i "%choice%"=="10" goto EditContextMenu
if /i "%choice%"=="11" goto BranchSelect
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto MainMenu
goto More

:WiFiTest
IF EXIST "%SYSTEMDRIVE%\AssistantX\Resources\WiFi-speed" (
    start %SYSTEMDRIVE%\AssistantX\Resources\WiFi-speed\WiFi-speed.exe
) ELSE (
	    echo %COL%[32m WiFispeedTest download started %COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Resources\WiFi-speed.zip "https://github.com/ALFiX01/AssistantX/releases/download/File/WiFi-speed.zip"
	    echo %COL%[32m WiFispeedTest installed started %COL%[37m
    powershell -command "Expand-Archive -Path %SYSTEMDRIVE%\AssistantX\Resources\WiFi-speed.zip  -DestinationPath %SYSTEMDRIVE%\AssistantX\Resources -Force"
		echo %COL%[32m WiFispeedTest installation completed, launching %COL%[37m
	start %SYSTEMDRIVE%\AssistantX\Resources\WiFi-speed\WiFi-speed.exe
)
echo %COL%[92mCompleted%COL%[37m
pause
goto More

:Cl_ASX_TEMP
del /S /Q %SYSTEMDRIVE%\AssistantX\Downloads\ >nul 2>&1
del /S /Q %SYSTEMDRIVE%\AssistantX\Resources\ >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto More

:EditContextMenu
IF EXIST "%SYSTEMDRIVE%\AssistantX\ContextMenuEditor" (
echo available at
) ELSE (
mkdir %SYSTEMDRIVE%\AssistantX\ContextMenuEditor >nul 2>&1
echo %COL%[92mThe necessary components are loaded...%COL%[37m
    curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Add_OWNER_Change.reg "https://github.com/ALFiX01/AssistantX/releases/download/File/Add_OWNER_Change.reg" >nul 2>&1
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Remove_OWNER_Change.reg "https://github.com/ALFiX01/AssistantX/releases/download/File/Remove_OWNER_Change.reg" >nul 2>&1
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Enable.Open.With.Notepad.reg "https://github.com/ALFiX01/AssistantX/releases/download/File/Enable.Open.With.Notepad.reg" >nul 2>&1
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Remove.Open.With.Notepad.reg "https://github.com/ALFiX01/AssistantX/releases/download/File/Remove.Open.With.Notepad.reg" >nul 2>&1
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Add.Restart.Explorer.Context.Menu.reg "https://github.com/ALFiX01/AssistantX/releases/download/File/Add.Restart.Explorer.Context.Menu.reg" >nul 2>&1
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Remove.Restart.Explorer.Context.Menu.reg "https://github.com/ALFiX01/AssistantX/releases/download/File/Remove.Restart.Explorer.Context.Menu.reg" >nul 2>&1
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Add.Scan.with.Windows.Defender.Context.Menu.reg "https://github.com/ALFiX01/AssistantX/releases/download/File/Add.Scan.with.Windows.Defender.Context.Menu.reg" >nul 2>&1
	curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Remove.Scan.with.Windows.Defender.Context.Menu.reg "https://github.com/ALFiX01/AssistantX/releases/download/File/Remove.Scan.with.Windows.Defender.Context.Menu.reg" >nul 2>&1
)
REM Check Values
for %%i in (ContMenuOwner ContMenuNotepad ContMenuExplorer ScanWithWindowsDefender OldContMenuWindows) do (set "%%i=%COL%[92mON ") >nul 2>&1
REM Context menu "Owner"
reg query "HKCU\Software\AssistantX" /v "ContextMenuOwner" || set "ContMenuOwner=%COL%[91mOFF"
reg query "HKCU\Software\AssistantX" /v "ContextMenuNotepad" || set "ContMenuNotepad=%COL%[91mOFF"
reg query "HKCU\Software\AssistantX" /v "ContextMenuExplorer" || set "ContMenuExplorer=%COL%[91mOFF"
reg query "HKCU\Software\AssistantX" /v "ScanWithWindowsDefender" || set "ScanWithWindowsDefender=%COL%[91mOFF"
reg query "HKCU\Software\AssistantX" /v "OldContextMenuWindows" || set "OldContMenuWindows=%COL%[91mOFF"
cls
echo.
call :AssistantXTitle
TITLE Context Menu Editor Panel - AssistantX v%localtwo%
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
echo.
echo                                     %COL%[96m[ %COL%[37m1 %COL%[96m] %COL%[37mBecome an owner %ContMenuOwner%                %COL%[96m[ %COL%[37m2 %COL%[96m] %COL%[37mOpen with Notepad %ContMenuNotepad%
echo.
echo.
echo                                     %COL%[96m[ %COL%[37m3 %COL%[96m] %COL%[37mRestart Explorer %ContMenuExplorer%               %COL%[96m[ %COL%[37m4 %COL%[96m] %COL%[37mRemove scan with Windows Defender %ScanWithWindowsDefender%
echo.
echo                                     %COL%[96m[ %COL%[37m5 %COL%[96m] %COL%[37mOld context menu Win11 %OldContMenuWindows%
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]%COL%[37m
echo.
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
set /p choice="%DEL%                                                     %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" goto Owner
if /i "%choice%"=="2" goto Notepad
if /i "%choice%"=="3" goto Explorer
if /i "%choice%"=="4" goto ScanWithWindowsDefender
if /i "%choice%"=="5" goto OldContextMenu
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto More
goto EditContextMenu


:Owner
if "%ContMenuOwner%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v "ContextMenuOwner" /f
		start %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Add_OWNER_Change.reg
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v "ContextMenuOwner" /f
		start %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Remove_OWNER_Change.reg
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
goto EditContextMenu

:Notepad
if "%ContMenuNotepad%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v "ContextMenuNotepad" /f
		start %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Enable.Open.With.Notepad.reg
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v "ContextMenuNotepad" /f
		start %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Remove.Open.With.Notepad.reg
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
goto EditContextMenu

:Explorer
if "%ContMenuExplorer%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v "ContextMenuExplorer" /f
		start %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Add.Restart.Explorer.Context.Menu.reg
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v "ContextMenuExplorer" /f
		start %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Remove.Restart.Explorer.Context.Menu.reg
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
goto EditContextMenu

:ScanWithWindowsDefender
if "%ContMenuExplorer%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v "ScanWithWindowsDefender" /f
		start %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Remove.Scan.with.Windows.Defender.Context.Menu.reg	
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v "ScanWithWindowsDefender" /f
		start %SYSTEMDRIVE%\AssistantX\ContextMenuEditor\Add.Scan.with.Windows.Defender.Context.Menu.reg
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
goto EditContextMenu

:OldContextMenu
if "%OldContMenuWindows%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v "OldContextMenuWindows" /f
		reg.exe add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve >nul 2>&1
		taskkill /f /im explorer.exe
         start explorer.exe
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v "OldContextMenuWindows" /f
		reg.exe delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f >nul 2>&1
		taskkill /f /im explorer.exe
         start explorer.exe
) >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
goto EditContextMenu

:BranchSelect
cls
echo.
call :AssistantXTitle
TITLE Update branch Select Panel - AssistantX v%localtwo%
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
echo                                       Now %COL%[92m%Branch%
echo.
echo                                       %COL%[96m[ %COL%[37m1 %COL%[96m] %COL%[37mRELEASE                             %COL%[96m[ %COL%[37m2 %COL%[96m] %COL%[37mBETA
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]%COL%[37m
echo.
echo               %COL%[37m____________________________________________________________________________________________________________
echo.
set /p choice="%DEL%                                                     %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="1" goto RELEASEbranch
if /i "%choice%"=="2" goto BETAbranch
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto More
goto BranchSelect

:RELEASEbranch
set Branch=Release
	reg add "HKCU\Software\AssistantX" /v "RELEASEbranch" /f
		reg delete "HKCU\Software\AssistantX" /v "BETAbranch" /f
echo %COL%[92mCompleted%COL%[37m
goto BranchSelect

:BETAbranch
set Branch=Beta
	reg add "HKCU\Software\AssistantX" /v "BETAbranch" /f
		reg delete "HKCU\Software\AssistantX" /v "RELEASEbranch" /f
echo %COL%[92mCompleted%COL%[37m
goto BranchSelect

:About
TITLE About Panel - AssistantX v%localtwo%
cls
echo.
echo.
echo                                                                                           %COL%[33m##      ##
echo                                   %COL%[33m####              ##         ##                   ##     ##    ##
echo                                  %COL%[33m##  ##   ###  ###       ###  ####   ####  #####   ####     ##  ##
echo                                  %COL%[33m######  ###  ###   ##  ###    ##   ## ##  ##  ##   ##        ##
echo                                  %COL%[33m##  ##    ##   ##  ##    ##   ##   ## ##  ##  ##   ##      ##  ##
echo                                  %COL%[33m##  ##  ###  ###   ##  ##     ###   ####  ##  ##   ###    ##    ##
echo                                                                                           %COL%[33m##      ## 
echo.
echo              %COL%[37m_____________________________________________________________________________________________________________
echo.
echo                About:
echo                Owned by ALFiX, Inc. Copyright Claimed.
echo                This is a GUI for the Tweaks.
echo                %COL%[94m%LOCAL%
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
call :ColorText 8 "                                                        [ press b to go back ]"
echo.
echo              %COL%[37m_____________________________________________________________________________________________________________
echo.
echo.
set /p choice="%DEL%                                                     %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="b" goto More

:ASXcleanerMenu
TITLE AssistantX Cleaner - AssistantX v%localtwo%
cls
echo.
echo.
call :AssistantXTitle
echo.
echo %COL%[91m  WARNING:
echo.
echo     %COL%[96m1.%COL%[37m AssistantX Cleaner will now delete files it deems unnecessary. I hope it hasn't deleted anything important for you)
echo.
echo     %COL%[96m2.%COL%[37m Even though we have an automatic restore point feature, we highly recommend making a manual restore point before running.
echo.
echo.
echo   Please enter "I ready" without quotes to continue:
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                                         [ press X to go back ]
echo.
set /p choice="%DEL%                                                                >:"
if /i "%choice%"=="I ready" call:ASXcleaner
::if "%choice%"=="I ready" goto ASXcleaner
goto More

:ASXcleaner
TITLE AssistantX Cleaner - AssistantX v%localtwo%
cls
echo %COL%[92mThe cleaning process has started, %COL%[93mexpect to complete (5-30min) %COL%[32m
echo.
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit" /va /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Applets\Regedit" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites" /va /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Applets\Regedit\Favorites" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRULegacy" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Paint\Recent File List" /va /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Applets\Paint\Recent File List" /va /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Applets\Wordpad\Recent File List" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Map Network Drive MRU" /va /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Map Network Drive MRU" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Search Assistant\ACMru" /va /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /va /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSaveMRU" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\MediaPlayer\Player\RecentFileList" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\MediaPlayer\Player\RecentURLList" /va /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\MediaPlayer\Player\RecentFileList" /va /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\MediaPlayer\Player\RecentURLList" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Direct3D\MostRecentApplication" /va /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Direct3D\MostRecentApplication" /va /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /va /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" /va /f >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1
rd /s /q "%USERPROFILE%\Local Settings\Application Data\Opera\Opera" >nul 2>&1
reg delete "HKCU\Software\Adobe\MediaBrowser\MRU" /va /f >nul 2>&1
takeown /f %LocalAppData%\Microsoft\Windows\Explorer\ /r /d y >nul 2>&1
takeown /f %%G\AppData\Local\Temp\ /r /d y >nul 2>&1
takeown /f %SystemRoot%\TEMP\ /r /d y >nul 2>&1
takeown /f %systemdrive%\$Recycle.bin\ /r /d y >nul 2>&1
takeown /f C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Code Cache\ /r /d y >nul 2>&1
takeown /f C:\Users\%USERNAME%\AppData\Local\Fortnitegame\saved\ /r /d y >nul 2>&1
takeown /f C:\Users\%USERNAME%\AppData\Local\Google\Chrome\User Data\Default\Code Cache\ /r /d y >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*" >nul 2>&1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*" >nul 2>&1
rd /s /q "%USERPROFILE%\Local Settings\Application Data\Opera\Opera" >nul 2>&1
rd /s /q "%localappdata%\Opera\Opera" >nul 2>&1
rd /s /q "%APPDATA%\Opera\Opera" >nul 2>&1
del /f /q "%localappdata%\Microsoft\Windows\INetCache\IE\*" >nul 2>&1
rd /s /q "%localappdata%\Microsoft\Windows\WebCache" >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Internet Explorer\TypedURLs" /va /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Internet Explorer\TypedURLsTime" /va /f >nul 2>&1
rd /s /q %userprofile%\Local Settings\Temporary Internet Files >nul 2>&1
rd /s /q "%localappdata%\Microsoft\Windows\Temporary Internet Files" >nul 2>&1
takeown /f "%localappdata%\Temporary Internet Files" /r /d y >nul 2>&1
icacls "%localappdata%\Temporary Internet Files" /grant administrators:F /t >nul 2>&1
rd /s /q "%localappdata%\Temporary Internet Files" >nul 2>&1
rd /s /q "%localappdata%\Microsoft\Windows\INetCache" >nul 2>&1
rd /s /q "%localappdata%\Microsoft\Feeds Cache" >nul 2>&1
rd /s /q "%APPDATA%\Microsoft\Windows\Cookies" >nul 2>&1
rd /s /q "%localappdata%\Microsoft\Windows\INetCookies" >nul 2>&1
rd /s /q "%localappdata%\Microsoft\InternetExplorer\DOMStore" >nul 2>&1
rd /s /q "%localappdata%\Microsoft\Internet Explorer" >nul 2>&1
rd /s /q "%localappdata%\Google\Chrome\User Data\Crashpad\reports\" >nul 2>&1
rd /s /q "%localappdata%\Google\CrashReports\" >nul 2>&1
del /f /q "%localappdata%\Google\Software Reporter Tool\*.log" >nul 2>&1
rd /s /q "%localappdata%\Mozilla\Firefox\Profiles" >nul 2>&1
rd /s /q "%APPDATA%\Mozilla\Firefox\Profiles" >nul 2>&1
del /q /s /f "%USERPROFILE%\Local Settings\Application Data\Safari\WebpageIcons.db" >nul 2>&1
del /q /s /f "%localappdata%\Apple Computer\Safari\WebpageIcons.db" >nul 2>&1
del /q /s /f "%USERPROFILE%\Local Settings\Application Data\Apple Computer\Safari\Cache.db" >nul 2>&1
del /q /s /f "%localappdata%\Apple Computer\Safari\Cache.db" >nul 2>&1
del /q /s /f "%USERPROFILE%\Local Settings\Application Data\Apple Computer\Safari\Cookies.db" >nul 2>&1
del /q /s /f "%localappdata%\Apple Computer\Safari\Cookies.db" >nul 2>&1
rd /s /q "%USERPROFILE%\Local Settings\Application Data\Apple Computer\Safari" >nul 2>&1
rd /s /q "%AppData%\Apple Computer\Safari" >nul 2>&1
rd /s /q "%LOCALAPPDATA%\Steam\htmlcache" >nul 2>&1
rd /s /q "%AppData%\GitHub Desktop\Cache" >nul 2>&1
del /f /s /q /a %LocalAppData%\Microsoft\Windows\Explorer\*.db >nul 2>&1
del /f /q %localappdata%\Temp\* >nul 2>&1
rd /s /q "%WINDIR%\Temp" >nul 2>&1
rd /s /q "%TEMP%" >nul 2>&1
del /f /s /q %systemdrive%\*.tmp >nul 2>&1
del /f /s /q %systemdrive%\*._mp >nul 2>&1
del /f /s /q %systemdrive%\*.log >nul 2>&1
del /f /s /q %systemdrive%\*.gid >nul 2>&1
del /f /s /q %systemdrive%\*.chk >nul 2>&1
del /f /s /q %systemdrive%\*.old >nul 2>&1
del /f /s /q D:\recycled\*.* >nul 2>&1
del /f /s /q %windir%\*.bak >nul 2>&1
del /f /s /q %windir%\prefetch\*.* >nul 2>&1
rd /s /q %windir%\temp & md %windir%\temp >nul 2>&1
del /f /q %userprofile%\cookies\*.* >nul 2>&1
del /f /q %userprofile%\recent\*.* >nul 2>&1
del /f /s /q “%userprofile%\Local Settings\Temporary Internet Files\*.*” >nul 2>&1
del /f /s /q “%userprofile%\Local Settings\Temp\*.*” >nul 2>&1
del /f /s /q “%userprofile%\recent\*.*” >nul 2>&1
del /f /q "%SystemRoot%\Logs\SIH\*" >nul 2>&1
del /f /q "%LocalAppData%\Microsoft\CLR_v4.0\UsageTraces\*" >nul 2>&1
del /f /q "%LocalAppData%\Microsoft\CLR_v4.0_32\UsageTraces\*" >nul 2>&1
del /f /q "%SystemRoot%\Logs\NetSetup\*" >nul 2>&1
del /f /q "%SystemRoot%\System32\LogFiles\setupcln\*" >nul 2>&1
del /f /q %SystemRoot%\Temp\CBS\* >nul 2>&1
takeown /f %SystemRoot%\Logs\waasmedic /r /d y >nul 2>&1
icacls %SystemRoot%\Logs\waasmedic /grant administrators:F /t >nul 2>&1
rd /s /q %SystemRoot%\Logs\waasmedic >nul 2>&1
del /f /q %SystemRoot%\System32\catroot2\dberr.txt >nul 2>&1
del /f /q %SystemRoot%\System32\catroot2.log >nul 2>&1
del /f /q %SystemRoot%\System32\catroot2.jrs >nul 2>&1
del /f /q %SystemRoot%\System32\catroot2.edb >nul 2>&1
del /f /q %SystemRoot%\System32\catroot2.chk >nul 2>&1
del /f /q "%SystemRoot%\Logs\SIH\*" >nul 2>&1
del /f /q "%SystemRoot%\Traces\WindowsUpdate\*" >nul 2>&1
del /f /q %SystemRoot%\setupact.log >nul 2>&1
del /f /q %SystemRoot%\setuperr.log >nul 2>&1
del /f /q %SystemRoot%\setupapi.log >nul 2>&1
del /f /q %SystemRoot%\inf\setupapi.app.log >nul 2>&1
del /f /q %SystemRoot%\inf\setupapi.dev.log >nul 2>&1
del /f /q %SystemRoot%\inf\setupapi.offline.log >nul 2>&1
echo.
echo %COL%[93mCleaning process is complete%COL%[37m
goto More

:Credits
TITLE Credits Panel - AssistantX v%localtwo%
cls
echo.
echo.
echo.
echo %COL%[90m                                                         Product Lead
echo %COL%[97m                                                       Daniil B. - ALFiX
echo.
echo.
echo.
echo %COL%[90m                                                   Product Development Lead
echo %COL%[97m                                                       Daniil B. - ALFiX
echo.
echo.
echo.
echo %COL%[90m                                                      Product Development
echo %COL%[97m                                                       Daniil B. - ALFiX
echo.
echo.
echo.
echo %COL%[90m                                                     Network Optimizations
echo %COL%[97m                                                       Daniil B. - ALFiX
echo.
echo.
echo.
echo %COL%[90m                                                        Render Settings
echo %COL%[97m                                                       Daniil B. - ALFiX
echo.
echo.
echo.
echo %COL%[90m                                                          Credits to
echo %COL%[97m                                                       Daniil B. - ALFiX
echo.
echo.
echo.
echo.
echo.
echo.
echo.
call :ColorText 8 "                                                      [ press B to go back ]"
echo.
echo              %COL%[37m_____________________________________________________________________________________________________________
echo.
set /p choice="%DEL%                                                     %COL%[97mChoose the appropriate number > "
if /i "%choice%"=="b" goto More

:Backup
TITLE Backup Panel - AssistantX v%localtwo%
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1
powershell Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
powershell Checkpoint-Computer -Description 'AssistantX Restore Point' >nul 2>&1
for /F "tokens=2" %%i in ('date /t') do set date=%%i  >nul 2>&1
set date1=%date:/=.%  >nul 2>&1
md %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%  >nul 2>&1
reg export HKCU %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%\HKLM.reg /y & reg export HKCU %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%\HKCU.reg /y >nul 2>&1
echo %COL%[92mCompleted%COL%[37m
pause
goto More

:Discord
start https://discord.gg/J7wghdhKsx
echo                       %COL%[33m########   ##   ###
echo                       %COL%[33m##         ##  ####
echo                       %COL%[33m##  ####   ## ## ##
echo                       %COL%[33m##    ##   ####  ##
echo                       %COL%[33m########   ###   ##
echo.
echo                                                                                           %COL%[33m##      ##
echo                                   %COL%[33m####              ##         ##                   ##     ##    ##
echo                                  %COL%[33m##  ##   ###  ###       ###  ####   ####  #####   ####     ##  ##
echo                                  %COL%[33m######  ###  ###   ##  ###    ##   ## ##  ##  ##   ##        ##
echo                                  %COL%[33m##  ##    ##   ##  ##    ##   ##   ## ##  ##  ##   ##      ##  ##
echo                                  %COL%[33m##  ##  ###  ###   ##  ##     ###   ####  ##  ##   ###    ##    ##
echo                                                                                           %COL%[33m##      ## 
goto More

:ColorText
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul
goto :eof

:AssistantXError
cls
color 06
echo.
echo  --------------------------------------------------------------
echo                   This tweak is not applicable
echo  --------------------------------------------------------------
echo.
echo      You aren't able to use this optimization
echo.
echo      %~1
echo.
echo.
echo.
echo.
echo      [X] Close
echo.
%SYSTEMROOT%\System32\choice.exe /c:X /n /m "%DEL%                                >:"
goto :eof





:AssistantXRestart
setlocal DisableDelayedExpansion
if "%~2" == "%COL%[91mOFF" (set "ed=enable") else (set "ed=disable")
start "Restart" cmd /V:ON /C @echo off
Mode 65,16
color 06
echo.
echo  --------------------------------------------------------------
echo                       Restart to fully apply
echo  --------------------------------------------------------------
echo.
echo      To %ed% %~1 you must restart, would
echo      you like to restart now?
echo.
echo.
echo.
echo.
echo      [Y] Yes
echo      [N] No
echo.
:restartchoice
set /p choice=Would you like to continue and restart your PC? Y or N?: 
if /i "%choice%" == "y" (
	shutdown /r /f /d p:0:0
) else if /i "%choice%" == "n" (
	exit /b
) else (
	goto restartchoice
)

goto :eof