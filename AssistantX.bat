REM Copyright (C) 2023 GENESIS, Inc.

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
mkdir %SYSTEMDRIVE%\AssistantX\Drivers >nul 2>&1
mkdir %SYSTEMDRIVE%\AssistantX\Renders >nul 2>&1
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

REM Add ANSI escape sequences
reg add HKCU\CONSOLE /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1


:Disclaimer
reg query "HKCU\Software\AssistantX" /v "Disclaimer" >nul 2>&1 && goto CheckForUpdates
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
echo        (ex. not following the disclaimers carefully).
echo.
echo     %COL%[96m2.%COL%[37m If you don't know what a tweak is, do not use it and contact our support team to receive more assistance.
echo.
echo     %COL%[96m3.%COL%[37m Even though we have an automatic restore point feature, we highly recommend making a manual restore point before running.
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
set local=1.3
set localtwo=%LOCAL%
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

REM Restart Checks
if exist "%SYSTEMDRIVE%\AssistantX\Drivers\NvidiaAssistantX.exe" "%SYSTEMDRIVE%\Desktop\AssistantX\Drivers\NvidiaAssistantX.exe" >nul 2>&1
if exist "%SYSTEMDRIVE%\AssistantX\Drivers\NvidiaAssistantX.exe" del /Q "%SYSTEMDRIVE%\Desktop\AssistantX\Drivers\NvidiaAssistantX.exe" >nul 2>&1
if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Driverinstall.bat" del /Q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Driverinstall.bat" >nul 2>&1

REM Attempt to enable WMIC
dism /online /enable-feature /featurename:MicrosoftWindowsWMICore /NoRestart >nul 2>&1

REM Check If First Launch
set firstlaunch=1
>nul 2>&1 call "%SYSTEMDRIVE%\AssistantX\AssistantXRevert\firstlaunch.bat"
if "%firstlaunch%" == "0" (goto MainMenu)

REM Restore Point
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
powershell -ExecutionPolicy Unrestricted -NoProfile Checkpoint-Computer -Description 'AssistantX Restore Point' >nul 2>&1

REM HKCU & HKLM backup

for /F "tokens=2" %%i in ('date /t') do set date=%%i
set date1=%date:/=.%
>nul 2>&1 md %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%
reg export HKCU %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%\HKLM.reg /y >nul 2>&1
reg export HKCU %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%\HKCU.reg /y >nul 2>&1
echo set "firstlaunch=0" > %SYSTEMDRIVE%\AssistantX\AssistantXRevert\firstlaunch.bat

:MainMenu
Mode 130,45
set "choice="
cls
echo.
echo.
call :AssistantXTitle
TITLE Control Panel - AssistantX v%localtwo%
echo.
echo                                               %COL%[90m  AssistantX is a free desktop utility
echo                                        %COL%[90m     made to improve your day-to-day productivity
echo.
echo.
echo.
echo.
echo.
echo                                              %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Optimizations              %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Ai
echo.
echo.
echo.
echo.
echo                                              %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m App Panel                  %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m More
echo.
echo.
echo.
echo.
echo.
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
%SYSTEMROOT%\System32\choice.exe /c:1234XD /n /m "%DEL%                                         Select a corresponding number to the options above > "
set choice=%errorlevel%
if "%choice%"=="1" set PG=TweaksPG1 & goto Tweaks
if "%choice%"=="2" goto Ai
if "%choice%"=="3" call:AppPanel
if "%choice%"=="4" goto More
if "%choice%"=="5" goto MainMenu
goto MainMenu

:AssistantXTitle 
echo                                                                                           %COL%[33m##      ##
echo                                   %COL%[33m####              ##         ##                   ##     ##    ##
echo                                  %COL%[33m##  ##   ###  ###       ###  ####   ####  #####   ####     ##  ##
echo                                  %COL%[33m######  ###  ###   ##  ###    ##   ## ##  ##  ##   ##        ##
echo                                  %COL%[33m##  ##    ##   ##  ##    ##   ##   ## ##  ##  ##   ##      ##  ##
echo                                  %COL%[33m##  ##  ###  ###   ##  ##     ###   ####  ##  ##   ###    ##    ##
echo                                                                                           %COL%[33m##      ## 
echo.
goto :eof

:AppPanel
cls
echo.
echo.
call :AssistantXTitle
TITLE App Panel - AssistantX v%localtwo%
echo.
echo.
echo.
echo.
echo                               %COL%[96m[%COL%[37m R %COL%[96m]%COL%[37m Recommended apps                      %COL%[96m[%COL%[37m N %COL%[96m]%COL%[37m NO Recommended apps
echo                               %COL%[90mList of programs recommended by us          %COL%[90mList of programs not recommended by us
echo.
echo.
echo                                                      %COL%[96m[%COL%[37m U %COL%[96m]%COL%[37m App Uninstall panel
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                               %COL%[36m[ B for back ]        %COL%[31m[ X to Main Menu ]        %COL%[90m[ F to Download folder ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="R" goto AppRecommended
if /i "%choice%"=="N" goto AppNORecommended
if /i "%choice%"=="U" goto AppUninstall
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="F" call:DwFolder
if /i "%choice%"=="B" goto MainMenu
goto AppPanel

:DwFolder
start %SYSTEMDRIVE%\AssistantX\Downloads
goto AppPanel

:AppRecommended
cls
echo.
echo                                                                                                                        %COL%[36mPage 1/3
call :AssistantXTitle
TITLE App Panel - AssistantX v%localtwo%
echo.
echo.
echo.
echo                                                             %COL%[1;4;34mFor Gamers%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Discord                         %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Steam                       %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m Epic Games Launcher 
echo.
echo              %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m MSI Afterburner
echo.
echo                                                         %COL%[1;4;34mFor Optimization%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m Win Tweaker                     %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m QuickCpu                    %COL%[96m[%COL%[37m 7 %COL%[96m]%COL%[37m Auslogics BoostSpeed
echo.
echo                                                      %COL%[1;4;34mFor Personalization Windows %COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 8 %COL%[96m]%COL%[37m Start11                         %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m WinDynamicDesktop
echo.
echo                                                            %COL%[1;4;34mPhoto Editors %COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 10 %COL%[96m]%COL%[37m Paint.net                      %COL%[96m[%COL%[37m 11 %COL%[96m]%COL%[37m Adobe Photoshop            %COL%[96m[%COL%[37m 12 %COL%[96m]%COL%[37m Topaz Photo AI
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                  %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]         %COL%[36m[ N page two ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
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
if /i "%choice%"=="12" call:TopazPhotoAi
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto AppPanel
if /i "%choice%"=="N" (set "PG=AppRecommendedPG2") & goto AppRecommendedPG2
goto Downloads

:AppRecommendedPG2
cls
echo.
echo                                                                                                                        %COL%[36mPage 2/3
call :AssistantXTitle
TITLE Files Downloads Panel - AssistantX v%localtwo%
echo                                                    %COL%[1;4;34mFor watch movies and series%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Zona
echo.
echo                                                             %COL%[1;4;34mFor devices%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m GeForce Experience                 %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m NVIDIA Broadcast               %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m ThunderMaster
echo.
echo              %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m Logitech G hub                     %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m JBL Quantum ENGINE 
echo.
echo                                                             %COL%[1;4;34mWeb Browsers%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 7 %COL%[96m]%COL%[37m Microsoft Edge                     %COL%[96m[%COL%[37m 8 %COL%[96m]%COL%[37m Chrome                         %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m Firefox
echo.
echo.
echo                                                            %COL%[1;4;34mFor Developers%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 10 %COL%[96m]%COL%[37m GitHub Desktop                    %COL%[96m[%COL%[37m 11 %COL%[96m]%COL%[37m Visual Studio Code            %COL%[96m[%COL%[37m 12 %COL%[96m]%COL%[37m Pycharm
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                  %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]         %COL%[36m[ N page two ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
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
goto Downloads

:AppRecommendedPG3
cls
echo.
echo                                                                                                                        %COL%[36mPage 3/3
call :AssistantXTitle
TITLE Files Downloads Panel - AssistantX v%localtwo%
echo                                                             %COL%[1;4;34mOthers Files%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m AIDA64                            %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m dfControl                     %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m qbittorrent
echo.
echo              %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m WinRaR                            %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m Uninstall Tool                %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m Windows Digital Activation
echo.
echo              %COL%[96m[%COL%[37m 7 %COL%[96m]%COL%[37m DirectX                           %COL%[96m[%COL%[37m 8 %COL%[96m]%COL%[37m Visual C++                    %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m Auslogics Driver Updater
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                  %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]         %COL%[36m[ N page two ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" call:AIDA64
if /i "%choice%"=="2" call:dfControl
if /i "%choice%"=="3" call:qbittorrent
if /i "%choice%"=="4" call:WinRaR
if /i "%choice%"=="5" call:UninstallTool
if /i "%choice%"=="6" call:WinDigActivation
if /i "%choice%"=="7" call:DirectX
if /i "%choice%"=="8" call:VisualC
if /i "%choice%"=="9" call:AuslogicsDriverUpdater
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto AppRecommended
if /i "%choice%"=="N" (set "PG=AppRecommended") & goto AppRecommended
goto Downloads

:AppNORecommended
cls
echo.
echo.
call :AssistantXTitle
TITLE App Panel - AssistantX v%localtwo%
echo.
echo.
echo.
echo                                                            %COL%[1;4;34mWeb Browsers%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m YandexBrowser
echo.
echo                                                            %COL%[1;4;34mOthers Files%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Ccleaner
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
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
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" call:YandexBrowser
if /i "%choice%"=="2" call:Ccleaner
if /i "%choice%"=="U" goto AppUninstall
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto AppPanel
goto AppNORecommended

:Discord
echo %COL%[32m Discord download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\DiscordSetup.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/DiscordSetup.exe"
echo %COL%[32m Discord download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\DiscordSetup.exe
goto AppRecommended

:EGS
echo %COL%[32m Epic Games Launcher download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Epic.Games.msi "https://github.com/ALFiX01/AssistantX/releases/download/File/Epic.Games.msi"
echo %COL%[32m Epic Games Launcher download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\Epic.Games.msi
goto AppRecommended

:Steam
echo %COL%[32m Steam download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\SteamSetup.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/SteamSetup.exe"
echo %COL%[32m Steam download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\SteamSetup.exe
goto AppRecommended

:MSIAfterburner
echo %COL%[32m MSI Afterburner download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\MSIAfterburnerSetup.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/MSIAfterburnerSetup.exe"
echo %COL%[32m MSI Afterburner download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\MSIAfterburnerSetup.exe
goto AppRecommended

:WinTweaker
echo %COL%[32m WinTweaker download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Win.Tweaker.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Win.Tweaker.exe"
echo %COL%[32m WinTweaker download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\Win.Tweaker.exe
goto AppRecommended

:QuickCpu
echo %COL%[32m QuickCpu download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\QuickCpuSetup.msi "https://github.com/ALFiX01/AssistantX/releases/download/File/QuickCpuSetup.msi"
echo %COL%[32m QuickCpu download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\QuickCpuSetup.msi
goto AppRecommended

:AuslogicsBoostSpeed
echo %COL%[32m Auslogics Boost Speed download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Auslogics.BoostSpeed.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Auslogics.BoostSpeed.exe"
echo %COL%[32m Auslogics Boost Speed download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\Auslogics.BoostSpeed.exe
goto AppRecommended

:Start11
echo %COL%[32m Start11 download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Start11-1.36.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Start11-1.36.exe"
echo %COL%[32m Start11 download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\Start11-1.36.exe
goto AppRecommended

:WinDynamicDesktop
echo %COL%[32m WinDynamicDesktop download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\WinDynamicDesktop.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/WinDynamicDesktop.exe"
echo %COL%[32m WinDynamicDesktop download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\WinDynamicDesktop.exe
goto AppRecommended

:PaintNet
echo %COL%[32m PaintNet download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\paintnet.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/paintnet.exe"
echo %COL%[32m PaintNet download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\paintnet.exe
goto AppRecommended

:Zona
echo %COL%[32m Zona download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\ZonaSetup.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/ZonaSetup.exe"
echo %COL%[32m Zona download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\ZonaSetup.exe
goto AppRecommendedPG2

:AIDA64
echo %COL%[32m AIDA64 download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\AIDA64.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/AIDA64.exe"
echo %COL%[32m AIDA64 download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\AIDA64.exe
goto AppRecommendedPG2

:dfControl
echo %COL%[32m dfControl download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\dfControl.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/dfControl.exe"
echo %COL%[32m dfControl download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\dfControl.exe
goto AppRecommendedPG2

:qbittorrent
echo %COL%[32m Qbittorrent download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\qbittorrent.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/qbittorrent.exe"
echo %COL%[32m Qbittorrent download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\qbittorrent.exe
goto AppRecommendedPG2

:WinRaR
echo %COL%[32m WinRaR download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\WinRAR.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/WinRAR.exe"
echo %COL%[32m WinRaR download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\WinRAR.exe
goto AppRecommendedPG2

:UninstallTool
echo %COL%[32m UninstallTool download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Uninstall.Tool.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Uninstall.Tool.exe"
echo %COL%[32m UninstallTool download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\Uninstall.Tool.exe
goto AppRecommendedPG2

:WinDigActivation
echo %COL%[32m WinDigActivation download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\WinDigitalActivation.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/WinDigitalActivation.exe"
echo %COL%[32m WinDigActivation download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\WinDigitalActivation.exe
goto AppRecommendedPG2

:DirectX
echo %COL%[32m DirectX download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\DirectX.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/DirectX.exe"
echo %COL%[32m DirectX download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\DirectX.exe
goto AppRecommendedPG2

:VisualC
echo %COL%[32m VisualC download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Visual.C++.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Visual.C++.exe"
echo %COL%[32m VisualC download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\Visual.C++.exe
goto AppRecommendedPG2

:GitHubDesktop
echo %COL%[32m GitHub Desktop download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\GitHubDesktop.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/GitHubDesktop.exe"
echo %COL%[32m GitHub Desktop download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\GitHubDesktop.exe
goto AppRecommendedPG2

:AuslogicsDriverUpdater
echo %COL%[32m Auslogics Driver Updater download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Auslogics.Driver.Updater.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Auslogics.Driver.Updater.exe"
echo %COL%[32m Auslogics Driver Updater download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\Auslogics.Driver.Updater.exe
goto AppRecommendedPG2

:GeForceExperience
echo %COL%[32m NVIDIA GeForce Experience download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\GeForce_Experience.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/GeForce_Experience.exe"
echo %COL%[32m NVIDIA GeForce Experience download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\GeForce_Experience.exe
goto AppRecommendedPG2

:NVIDIABroadcast
echo %COL%[32m NVIDIA Broadcast download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\NVIDIA_Broadcast.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/NVIDIA_Broadcast.exe"
echo %COL%[32m NVIDIA Broadcast download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\NVIDIA_Broadcast.exe
goto AppRecommendedPG2

:ThunderMaster
echo %COL%[32m ThunderMaster download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Setup_ThunderMaster.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Setup_ThunderMaster.exe"
echo %COL%[32m ThunderMaster download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\Setup_ThunderMaster.exe
goto AppRecommendedPG2

:LogitechGhub
echo %COL%[32m Logitech Ghub download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Logitech.Ghub.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Logitech.Ghub.exe"
echo %COL%[32m Logitech Ghub download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\Logitech.Ghub.exe
goto AppRecommendedPG2

:JBLQuantumENGINE
echo %COL%[32m JBLQuantumENGINE download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\JBL_QuantumENGINE.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/JBL_QuantumENGINE.exe"
echo %COL%[32m JBLQuantumENGINE download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\JBL_QuantumENGINE.exe
goto AppRecommendedPG2

:Edge
echo %COL%[32m Microsoft Edge download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\MicrosoftEdge.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/MicrosoftEdge.exe"
echo %COL%[32m Microsoft Edge download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\MicrosoftEdge.exe
goto AppRecommendedPG2

:Chrome
echo %COL%[32m Google Chrome download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Chrome.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Chrome.exe"
echo %COL%[32m Google Chrome download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\Chrome.exe
goto AppRecommendedPG2

:FireFox
echo %COL%[32m Mozilla FireFox download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Firefox.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Firefox.exe"
echo %COL%[32m Mozilla FireFox download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\Firefox.exe
goto AppRecommendedPG2

:Photoshop
echo %COL%[32m Adobe Photoshop download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Adobe.Photoshop.2022.v23.5.0.669.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Adobe.Photoshop.2022.v23.5.0.669.exe"
echo %COL%[32m Adobe Photoshop download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\Adobe.Photoshop.2022.v23.5.0.669.exe
goto AppRecommended

:YandexBrowser
echo %COL%[32m YandexBrowser download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\Yandex.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Yandex.exe"
echo %COL%[32m YandexBrowser download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\Yandex.exe
goto AppNORecommended

:Ccleaner
echo %COL%[32m Ccleaner download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\CCleaner.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/CCleaner.exe"
echo %COL%[32m Ccleaner download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\CCleaner.exe
goto AppNORecommended

:TopazPhotoAi
mkdir %SYSTEMDRIVE%\AssistantX\Downloads\TopazPhotoAi >nul 2>&1
cd %SYSTEMDRIVE%\AssistantX
echo %COL%[32m Topaz Photo Ai download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\TopazPhotoAi\Topaz.Photo.AI.1.2.6.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Topaz.Photo.AI.1.2.6.exe"
echo %COL%[32m File "Topaz.Photo.AI.1.2.6.exe" uploaded, 3 more files left %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\TopazPhotoAi\Topaz.Photo.AI.1.2.6-3.bin "https://github.com/ALFiX01/AssistantX/releases/download/File/Topaz.Photo.AI.1.2.6-3.bin"
echo %COL%[32m File "Topaz.Photo.AI.1.2.6-3.bin" uploaded, 2 more files left %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\TopazPhotoAi\Topaz.Photo.AI.1.2.6-2.bin "https://github.com/ALFiX01/AssistantX/releases/download/File/Topaz.Photo.AI.1.2.6-2.bin"
echo %COL%[32m File "Topaz.Photo.AI.1.2.6-2.bin" uploaded, 1 more files left %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\TopazPhotoAi\Topaz.Photo.AI.1.2.6-1.bin "https://github.com/ALFiX01/AssistantX/releases/download/File/Topaz.Photo.AI.1.2.6-1.bin"
echo %COL%[32m Topaz Photo AI Download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\TopazPhotoAi
goto AppNORecommended

:VScode
echo %COL%[32m Visual Studio Code download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\VSCode.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/VSCode.exe"
echo %COL%[32m Visual Studio Code download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\VSCode.exe
goto AppNORecommended

:Pycharm
echo %COL%[32m Pycharm download started %COL%[37m
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\pycharm.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/pycharm.exe"
echo %COL%[32m Pycharm download complete %COL%[37m
start %SYSTEMDRIVE%\AssistantX\Downloads\pycharm.exe
goto AppNORecommended

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

:Tweaks
Mode 130,45
TITLE Control Panel - AssistantX v%localtwo%
set "choice="
set "BLANK=   "
REM Check Values
for %%i in (PWROF MEMOF FSOOF AUDOF TMROF NETOF AFFOF MOUOF AFTOF NICOF DSSOF SERVOF DEBOF MITOF ME2OF NPIOF NVIOF NVTOF HDCOF CMAOF ALLOF MSIOF TCPOF DWCOF CRSOF) do (set "%%i=%COL%[92mON ") >nul 2>&1
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
	REM CSRSS
	reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v CpuPriorityClass | find "0x4" || set "CRSOF=%COL%[91mOFF"
	reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v IoPriority | find "0x3" || set "CRSOF=%COL%[91mOFF"
	REM Power Plan
	powercfg /GetActiveScheme | find "AssistantX" || set "PWROF=%COL%[91mOFF"
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
	REM Network Internet Tweaks
	reg query "HKCU\Software\AssistantX" /v "InternetTweaks" || set "NETOF=%COL%[91mOFF"
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
	REM Timer Res
	sc query STR | find "RUNNING" || set "TMROF=%COL%[91mOFF"
	REM Audio Service
	sc query AssistantXAudio | find "RUNNING" || set "AUDOF=%COL%[91mOFF"
	REM Check If Applicable For PC
	REM Laptop
	wmic path Win32_Battery Get BatteryStatus | find "1" && set "PWROF=%COL%[93mN/A"
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

:TweaksPG1
cls
echo.
echo                                                                                                                        %COL%[36mPage 1/2
call :AssistantXTitle
TITLE Optimization panel - AssistantX v%localtwo%
echo                                                               %COL%[1;4;34mTweaks%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Power Plan Panel              %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m SvcHostSplitThreshold %MEMOF%      %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m Disable Keys 
echo              %COL%[90mOpens the power optimization        %COL%[90mChanges the split threshold for      %COL%[90mCSRSS is responsible for mouse input
echo              %COL%[90mmenu                                %COL%[90mservice host to your RAM             %COL%[90mset to high to improve input latency
echo.
echo              %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m Timer Resolution %TMROF%          %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m MSI Mode %MSIOF%                   %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m Affinity %AFFOF%
echo              %COL%[90mThis tweak changes how fast         %COL%[90mEnable MSI Mode for gpu and          %COL%[90mThis tweak will spread devices
echo              %COL%[90myour cpu refreshes                  %COL%[90mnetwork adapters                     %COL%[90mon multiple cpu cores
echo.
echo              %COL%[96m[%COL%[37m 7 %COL%[96m]%COL%[37m Disable Windows Telemetry     %COL%[96m[%COL%[37m 8 %COL%[96m]%COL%[37m Memory Optimization %ME2OF%        %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m Disable FSO and GameBar     
echo              %COL%[90mDisables Windows telemetry          %COL%[90mOptimizes your fsutil, win
echo              %COL%[91mDangerous                           %COL%[90mstartup settings and more
echo.
echo                                                            %COL%[1;4;34mNvidia Tweaks%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m Disable HDCP %HDCOF%              %COL%[96m[%COL%[37m 10 %COL%[96m]%COL%[37m Disable Preemption %CMAOF%        %COL%[96m[%COL%[37m 11 %COL%[96m]%COL%[37m ProfileInspector %NPIOF%
echo              %COL%[90mDisable copy protection technology   %COL%[90mDisable preemption requests from     %COL%[90mWill edit your Nvidia control panel
echo              %COL%[90mof illegal High Definition content   %COL%[90mthe GPU scheduler                    %COL%[90mand add various tweaks
echo.
echo              %COL%[96m[%COL%[37m 11 %COL%[96m]%COL%[37m Disable Nvidia Telemetry %NVTOF% %COL%[96m[%COL%[37m 12 %COL%[96m]%COL%[37m Nvidia Tweaks %NVIOF%             %COL%[96m[%COL%[37m 13 %COL%[96m]%COL%[37m Disable Write Combining %DWCOF%
echo              %COL%[90mRemove built in Nvidia telemetry     %COL%[90mVarious essential tweaks for         %COL%[90mStops data from being combined
echo              %COL%[90mfrom your computer and driver.       %COL%[90mNvidia graphics cards                %COL%[90mand temporarily stored
echo.
echo.
echo.
echo.
echo.
echo.
echo      %COL%[90m[ G for Game-Booster ]       %COL%[36m[ B for back ]       %COL%[31m[ X to Main Menu ]       %COL%[36m[ N page two ]       %COL%[90m[ A for Advanced Tweak ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" Call:PowerPlanPN
if /i "%choice%"=="2" goto ServicesOptimization
if /i "%choice%"=="3" goto Dsk
if /i "%choice%"=="4" goto TimerRes
if /i "%choice%"=="5" goto MSI
if /i "%choice%"=="6" goto Affinity
if /i "%choice%"=="7" goto DissWinTelemetry
if /i "%choice%"=="8" goto MemOptimization
if /i "%choice%"=="9" goto DissableFSOandGameBar
echo %NPIOF% | find "N/A" >nul && if "%choice%" geq "10" if "%choice%" leq "15" call :AssistantX Error "You don't have an NVIDIA GPU" && goto Tweaks
if /i "%choice%"=="9" goto DisableHDCP
if /i "%choice%"=="10" goto DisablePreemtion
if /i "%choice%"=="11" goto ProfileInspector
if /i "%choice%"=="12" goto NVTelemetry
if /i "%choice%"=="13" goto NvidiaTweaks
if /i "%choice%"=="14" goto DisableWriteCombining
if /i "%choice%"=="G" call:gameBooster
if /i "%choice%"=="A" call:AdvancedTW
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto MainMenu
if /i "%choice%"=="N" (set "PG=TweaksPG2") & goto TweaksPG2
goto Tweaks

:TweaksPG2
cls
echo.
echo                                                                                                                        %COL%[36mPage 2/2
call :AssistantXTitle
TITLE Optimization Panel page 2 - AssistantX v%localtwo%
echo                                                           %COL%[1;4;34mNetwork Tweaks%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Optimize TCP/IP %TCPOF%            %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Optimize NIC %NICOF%               %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m Optimize Netsh %NETOF%
echo              %COL%[90mTweaks your Internet Protocol        %COL%[90mOptimize your Network Card settings  %COL%[90mThis tweak will optimize your
echo              %COL%[91mDon't use if you are using Wi-Fi     %COL%[91mDon't use if you are using Wi-Fi     %COL%[90mcomputer network configuration
echo.
echo                                                             %COL%[1;4;34mGPU ^& CPU%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m All GPU Tweaks %ALLOF%             %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m Optimize Intel iGPU %DSSOF%        %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m AMD GPU Tweaks %AMDOF%
echo              %COL%[90mVarious essential tweaks for all     %COL%[90mIncrease dedicated video vram on     %COL%[90mConfigure AMD GPU to optimized
echo              %COL%[90mGPU brands and manufacturers         %COL%[90ma intel iGPU                         %COL%[90msettings
echo.
echo                                                        %COL%[1;4;34mMiscellaneous Tweaks%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 7 %COL%[96m]%COL%[37m Reduce Audio Latency %AUDOF%       %COL%[96m[%COL%[37m 8 %COL%[96m]%COL%[37m Debloat %COL%[93mN/A                    %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m Disable Mitigations %MITOF%
echo              %COL%[90mReduces Audio Latency  		  %COL%[91mComing Soon			       %COL%[90mDisable protections against memory
echo              %COL%[91mDon't use on slow or old CPU's	  %COL%[90m				       %COL%[90mbased attacks that consume perf
echo.
echo              %COL%[96m[%COL%[37m 10 %COL%[96m]%COL%[37m Cleaner %BLANK%                   %COL%[96m[%COL%[37m 12 %COL%[96m]%COL%[37m Soft Restart %BLANK%
echo              %COL%[90mRemove adware, unused devices, and   %COL%[90mIf your PC has been running a while
echo              %COL%[90mtemp files. Empties recycle bin.     %COL%[90muse this to receive a quick boost
echo.
echo.
echo.
echo.
echo.
echo.
echo                                    %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]         %COL%[36m[ N page one ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto TCPIP
if /i "%choice%"=="2" goto NIC
if /i "%choice%"=="3" goto Netsh
if /i "%choice%"=="4" goto AllGPUTweaks
if /i "%choice%"=="5" goto Intel
if /i "%choice%"=="6" goto AMD
if /i "%choice%"=="7" goto AudioLatency
if /i "%choice%"=="8" call:Comingsoon
if /i "%choice%"=="9" goto Mitigations
if /i "%choice%"=="10" call:Cleaner
if /i "%choice%"=="11" call:gameBooster
if /i "%choice%"=="12" call:softRestart
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto TweaksPG1
if /i "%choice%"=="N" (set "PG=TweaksPG1") & goto TweaksPG1
goto TweaksPG2

:FixProblem
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\Downloads\FixProblem.zip "https://github.com/ALFiX01/AssistantX/releases/download/File/FixProblem.zip"
start %SYSTEMDRIVE%\AssistantX\Downloads\FixProblem.zip
goto :MainMenu

:AppUninstall
cls
echo.
call :AssistantXTitle
TITLE App Uninstall Panel - AssistantX v%localtwo%
echo                                                           %COL%[1;4;34mUninstall method%COL%[0m
echo.
echo                                    %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m  Elective                               %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Prepared 
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
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
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" call:Selective-M
if /i "%choice%"=="2" call:Prepared-M
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto AppPanel
goto AppPanel

:Prepared-M
TITLE Prepared Uninstall Panel - AssistantX v%localtwo%
powershell -executionpolicy -command "Get-AppxPackage -allusers *people* | Remove-AppxPackage"
powershell -executionpolicy -command "Get-AppxPackage -allusers *zunevideo* | Remove-AppxPackage"
powershell -executionpolicy -command "Get-AppxPackage -allusers *3dbuilder* | Remove-AppxPackage"
powershell -executionpolicy -command "Get-AppxPackage -allusers *skypeapp* | Remove-AppxPackage"
powershell -executionpolicy -command "Get-AppxPackage -allusers *solitaire* | Remove-AppxPackage"
powershell -executionpolicy -command "Get-AppxPackage -allusers *officehub* | Remove-AppxPackage"
powershell -executionpolicy -command "Get-AppxPackage -allusers *maps* | Remove-AppxPackage"
powershell -executionpolicy -command "Get-AppxPackage -allusers *bing* | Remove-AppxPackage"
powershell -executionpolicy -command "Get-AppxPackage -allusers *onenote* | Remove-AppxPackage"
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingfinance* | Remove-AppxPackage"
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingsports* | Remove-AppxPackage"
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingnews* | Remove-AppxPackage"
powershell -executionpolicy -command "Get-AppxPackage -allusers *Microsoft.549981C3F5F10* | Remove-AppxPackage"
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.GetHelp_8wekyb3d8bbwe"
powershell -executionpolicy -command "Remove-Appxpackage MicrosoftTeams_22336.907.1742.9730_x64__8wekyb3d8bbwe"
powershell -executionpolicy -command "Remove-Appxpackage MicrosoftTeams_23034.1300.1846.7680_x64__8wekyb3d8bbwe"
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.PowerAutomateDesktop_1.0.65.0_x64__8wekyb3d8bbwe"
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.OneDriveSync_21220.1024.5.0_neutral__8wekyb3d8bbwe"
pause
goto MainMenu

:Selective-M
cls
echo.
call:AssistantXTitle
TITLE Selective Uninstall Panel - AssistantX v%localtwo%
echo.
echo                                                           %COL%[1;4;34mUninstall Programm%COL%[0m
echo.
echo               %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m People                           %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Movie and TV                      %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m 3D builder
echo.
echo               %COL%[96m[%COL%[37m 4 %COL%[96m]%COL%[37m Skype                            %COL%[96m[%COL%[37m 5 %COL%[96m]%COL%[37m Solitaire                         %COL%[96m[%COL%[37m 6 %COL%[96m]%COL%[37m Office
echo.
echo               %COL%[96m[%COL%[37m 7 %COL%[96m]%COL%[37m maps                             %COL%[96m[%COL%[37m 8 %COL%[96m]%COL%[37m Bing                              %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m OneNote
echo.
echo               %COL%[96m[%COL%[37m 10 %COL%[96m]%COL%[37m Bing Finance                     %COL%[96m[%COL%[37m 11 %COL%[96m]%COL%[37m Bing Sports                       %COL%[96m[%COL%[37m 12 %COL%[96m]%COL%[37m Bing News
echo.
echo               %COL%[96m[%COL%[37m 13 %COL%[96m]%COL%[37m Cortana                         %COL%[96m[%COL%[37m 14 %COL%[96m]%COL%[37m GetHelp                          %COL%[96m[%COL%[37m 15 %COL%[96m]%COL%[37m MicrosoftTeams
echo.
echo.
echo.
echo.
echo.
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
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" call:iPeople
if /i "%choice%"=="2" call:iMovie and TV
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
if /i "%choice%"=="B" goto Tweaks
goto MainMenu

:iPeople
powershell -executionpolicy -command "Get-AppxPackage -allusers *people* | Remove-AppxPackage"
goto Selective-M

:iMovie and TV
powershell -executionpolicy -command "Get-AppxPackage -allusers *zunevideo* | Remove-AppxPackage"
goto Selective-M

:i3Dbuilder
powershell -executionpolicy -command "Get-AppxPackage -allusers *3dbuilder* | Remove-AppxPackage"
goto Selective-M

:iSkype
powershell -executionpolicy -command "Get-AppxPackage -allusers *skypeapp* | Remove-AppxPackage"
goto Selective-M

:iSolitaire
powershell -executionpolicy -command "Get-AppxPackage -allusers *solitaire* | Remove-AppxPackage"
goto Selective-M

:iOffice
powershell -executionpolicy -command "Get-AppxPackage -allusers *officehub* | Remove-AppxPackage"
goto Selective-M

:imaps
powershell -executionpolicy -command "Get-AppxPackage -allusers *maps* | Remove-AppxPackage"
goto Selective-M

:ibing
powershell -executionpolicy -command "Get-AppxPackage -allusers *bing* | Remove-AppxPackage"
goto Selective-M

:iOneNote
powershell -executionpolicy -command "Get-AppxPackage -allusers *onenote* | Remove-AppxPackage"
goto Selective-M

:iBingFinance
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingfinance* | Remove-AppxPackage"
goto Selective-M

:iBingSports
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingsports* | Remove-AppxPackage"
goto Selective-M

:iBingNews
powershell -executionpolicy -command "Get-AppxPackage -allusers *bingnews* | Remove-AppxPackage"
goto Selective-M

:iCortana
powershell -executionpolicy -command "Get-AppxPackage -allusers *Microsoft.549981C3F5F10* | Remove-AppxPackage"
goto Selective-M

:iGetHelp
powershell -executionpolicy -command "Remove-Appxpackage Microsoft.GetHelp_8wekyb3d8bbwe"
goto Selective-M

:iMicrosoftTeams
powershell -executionpolicy -command "Remove-AppxpackageMicrosoftTeams_22336.907.1742.9730_x64__8wekyb3d8bbwe"
goto Selective-M

:PowerPlanPN
cls
echo.
call:AssistantXTitle
TITLE Power Plan Panel - AssistantX v%localtwo%
echo.
echo                                                           %COL%[1;4;34mPower Plan Tweaks%COL%[0m
echo.
echo             %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Max Power Plan              %COL%[96m[%COL%[37m 2 %COL%[96m]%COL%[37m Delete Power Saving Plan           %COL%[96m[%COL%[37m 3 %COL%[96m]%COL%[37m Delete High Performance Plan 
echo             %COL%[90mMaximum performance mode          %COL%[90mDeletes the power saving plan            %COL%[90mDeletes the high performance plan
echo             %COL%[31mDo not enable on laptops
echo.
echo.
echo.
echo.
echo.
echo.
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
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto MaxPowerPlan
if /i "%choice%"=="2" goto DeletePowerSavingPlan
if /i "%choice%"=="3" goto DeleteHighPerformancePlan
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto Tweaks
goto Tweaks

:DissableFSOandGameBar
		reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "AllowAutoGameMode" /t REG_DWORD /d "0" /f
            reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "AutoGameModeEnabled" /t REG_DWORD /d "0" /f
		reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "GamePanelStartupTipIndex" /t REG_DWORD /d "3" /f
            reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "ShowStartupPanel" /t REG_DWORD /d "0" /f
            reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\GameBar"  /v "UseNexusForGameBarEnabled" /t REG_DWORD /d "0" /f
            reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"  /v "AppCaptureEnabled" /t REG_DWORD /d "0" /f
            reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f
            reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f
            reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f
            reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f
            reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f
            reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f
            reg add "HKEY_CURRENT_USER\System\GameConfigStore"  /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f
            reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\GameDVR"  /v "AllowGameDVR" /t REG_DWORD /d "0" /f
            reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR"  /v "value" /t REG_DWORD /d "0" /f
            reg add "HKEY_CURRENT_USER\Software\Microsoft\GameBar"  /v "AutoGameModeEnabled" /t REG_DWORD /d "1" /f
goto tweaks

:DeleteHighPerformancePlan
TITLE Removing the high performance plan - AssistantX v%localtwo%
echo %PWROF% | find "N/A" >nul && call :AssistantX Error "This power plan isn't recommended for batteries." && goto Tweaks
      powercfg -delete 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
cls
color A
echo.
echo.
echo             ##
echo            ##
echo      ##   ##
echo       ## ##
echo        ##
echo.
echo     Completed
echo.
timeout 2
color 06
goto PowerPlanPN

:DeletePowerSavingPlan
TITLE Removing the power saving plan - AssistantX v%localtwo%
echo %PWROF% | find "N/A" >nul && call :AssistantX Error "This power plan isn't recommended for batteries." && goto Tweaks
      powercfg -delete a1841308-3541-4fab-bc81-f71556f20b4a
cls
color A
echo.
echo.
echo             ##
echo            ##
echo      ##   ##
echo       ## ##
echo        ##
echo.
echo     Completed
echo.
timeout 2
color 06
goto PowerPlanPN

:MaxPowerPlan
TITLE Enabling maximum performance mode - AssistantX v%localtwo%
echo %PWROF% | find "N/A" >nul && call :AssistantX Error "This power plan isn't recommended for batteries." && goto Tweaks
      powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
cls
color A
echo.
echo.
echo             ##
echo            ##
echo      ##   ##
echo       ## ##
echo        ##
echo.
echo     Completed
echo.
timeout 2
color 06
goto tweaks

:ServicesOptimization
if "%MEMOF%" == "%COL%[91mOFF" (
	for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do set /a mem=%%i + 1024000
		reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d %mem% /f
) >nul 2>&1 else (
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d 3670016 /f
) >nul 2>&1
goto tweaks

:TimerRes
cd %SYSTEMDRIVE%\AssistantX\Resources
sc config "STR" start= auto >nul 2>&1
start /b net start STR >nul 2>&1
if "%TMROF%" == "%COL%[91mOFF" (
	if not exist SetTimerResolutionService.exe (
		REM https://forums.guru3d.com/threads/windows-timer-resolution-tool-in-form-of-system-service.376458/
		curl -g -L -# -o "%SYSTEMDRIVE%\AssistantX\Resources\SetTimerResolutionService.exe" "https://github.com/auraside/AssistantXCtrl/raw/main/Files/SetTimerResolutionService.exe"
		%SYSTEMROOT%\Microsoft.NET\Framework\v4.0.30319\InstallUtil.exe /i SetTimerResolutionService.exe
	)
	sc config "STR" start=auto
	start /b net start STR
	bcdedit /set disabledynamictick yes
	bcdedit /deletevalue useplatformclock
	for /F "tokens=2 delims==" %%G in (
		'wmic OS get buildnumber /value'
	) do @for /F "tokens=*" %%x in ("%%G") do (
		set "VAR=%%~x"
	)
	if !VAR! geq 19042 (
		bcdedit /deletevalue useplatformtick
	)
	if !VAR! lss 19042 (
		bcdedit /set useplatformtick yes
	)
) >nul 2>&1 else (
	sc config "STR" start=disabled
	start /b net stop STR
	bcdedit /deletevalue useplatformclock
	bcdedit /deletevalue useplatformtick
	bcdedit /deletevalue disabledynamictick
) >nul 2>&1
goto tweaks

REM :KBoost
REM if "%KBOOF%" == "%COL%[91mOFF" (
	REM for /f %%i in ('reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		REM reg add "%%a" /v "PowerMizerEnable" /t REG_DWORD /d "1" /f
		REM reg add "%%a" /v "PowerMizerLevel" /t REG_DWORD /d "1" /f
		REM reg add "%%a" /v "PowerMizerLevelAC" /t REG_DWORD /d "1" /f
		REM reg add "%%a" /v "PerfLevelSrc" /t REG_DWORD /d "8738" /f
	REM )
REM ) >nul 2>&1 else (
	REM for /f %%i in ('reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		REM reg delete "%%a" /v "PowerMizerEnable" /f 
		REM reg delete "%%a" /v "PowerMizerLevel" /f
		REM reg delete "%%a" /v "PowerMizerLevelAC" /f
		REM reg delete "%%a" /v "PerfLevelSrc" /f
	REM )
REM ) >nul 2>&1
REM call :AssistantXCtrlRestart "KBoost" "%KBOOF%"
REM Mode 130,45
REM goto Tweaks

:Dsk
   reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_SZ /d "506" /f
   reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_SZ /d "58" /f
   reg add Control Panel\Accessibility\Keyboard Response" /v "DelayBeforeAcceptance" /t REG_SZ /d "0" /f
   reg add Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatRate" /t REG_SZ /d "0" /f
   reg add Control Panel\Accessibility\Keyboard Response" /v "AutoRepeatDelay" /t REG_SZ /d "0" /f
   reg add Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_SZ /d "122" /f
cls
color A
echo.
echo.
echo             ##
echo            ##
echo      ##   ##
echo       ## ##
echo        ##
echo.
echo     Completed
echo.
timeout 2
goto Tweaks

:MSI
if "%MSIOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v "MSIModeTweaks" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /t REG_DWORD /d "1" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v "MSIModeTweaks" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f
	for /f %%g in ('wmic path win32_VideoController get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties" /v "MSISupported" /f
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID ^| findstr /L "VEN_"') do reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority " /f
) >nul 2>&1
goto Tweaks

:Affinity
if "%AFFOF%" == "%COL%[91mOFF" (
reg add "HKCU\Software\AssistantX" /v AffinityTweaks /f
for /f "tokens=*" %%f in ('wmic cpu get NumberOfCores /value ^| find "="') do set %%f
for /f "tokens=*" %%f in ('wmic cpu get NumberOfLogicalProcessors /value ^| find "="') do set %%f
if "!NumberOfCores!" == "2" (
	cls
	echo You have 2 cores. Affinities won't work.
	pause
	reg delete "HKCU\Software\AssistantX" /v AffinityTweaks /f
	goto Tweaks
)
if !NumberOfCores! gtr 4 (
	for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "3" /f
		reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
	)
	for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
		reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "5" /f
		reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
	)
)
if !NumberOfLogicalProcessors! gtr !NumberOfCores! (
REM HyperThreading Enabled
for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "C0" /f
)
for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "C0" /f
)
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "30" /f
)
) else (
REM HyperThreading Disabled
for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "08" /f
)
for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "02" /f
)
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "04" /f
)
)
) >nul 2>&1 else (
reg delete "HKCU\Software\AssistantX" /v AffinityTweaks /f
for /f %%i in ('wmic path Win32_USBController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
)
for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
)
for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
)
) >nul 2>&1
goto Tweaks

:DissWinTelemetry
cls
color A
echo.
echo.
echo             ##
echo            ##
echo      ##   ##
echo       ## ##
echo        ##
echo.
echo     Completed
echo.
timeout 2
		reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching"  /v "SearchOrderConfig" /t REG_DWORD /d "0" /f
            reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"  /v "EnableLua" /t REG_DWORD /d "0" /f
		reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR"  /v "value" /t REG_DWORD /d "0" /f
            reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowSharedUserAppData"  /v "value" /t REG_DWORD /d "0" /f
            reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowStore"  /v "value" /t REG_DWORD /d "0" /f 1
            reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance"  /v "MaintenanceDisabled" /t REG_DWORD /d "0" /f
goto tweaks

goto Tweaks

:MemOptimization
if "%ME2OF%" == "%COL%[91mOFF" (
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
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v MemoryTweaks /f
	REM Delete FTH
	reg delete "HKLM\Software\Microsoft\FTH" /v "Enabled" /f
	REM Delete Desktop Composition
	reg delete "HKCU\Software\Microsoft\Windows\DWM" /v "Composition" /f
	REM Enable Background apps
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /f
	reg delete "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /f
	reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /f
	REM Disallow drivers to get paged into virtual memory
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /f
	REM Enable Page Combining and memory compression
	powershell -NoProfile -Command "Enable-MMAgent -PagingCombining -mc"
	REM Use Large System Cache to improve microstuttering
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /f
	REM Don't free unused ram
	reg delete "HKLM\System\CurrentControlSet\Control\Session Manager" /v "HeapDeCommitFreeBlockThreshold" /f
	REM Don't restart Powershell on error
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoRestartShell" /t REG_DWORD /d "0" /f
	REM Disk Optimizations
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DontVerifyRandomDrivers" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "LongPathsEnabled" /f
	REM Enable Prefetch
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t Reg_DWORD /d "3" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnableSuperfetch" /t Reg_DWORD /d "3" /f
	REM Background Apps
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t Reg_DWORD /d "0" /f
	reg delete "HKLM\Software\Policies\Microsoft\Windows\AppPrivacy" /v "LetAppsRunInBackground" /f
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t Reg_DWORD /d "1" /f
	REM Hibernation + Fast Startup
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabledDefault" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /f
	REM Wait time to kill app during shutdown
	reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t Reg_SZ /d "20000" /f
	REM Wait to end service at shutdown
	reg add "HKLM\System\CurrentControlSet\Control" /v "WaitToKillServiceTimeout" /t Reg_SZ /d "20000" /f
	REM Wait to kill non-responding app
	reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t Reg_SZ /d "5000" /f
	REM fsutil
	if exist "%SYSTEMROOT%\System32\fsutil.exe" (
		REM Set default limit of paged pool memory
		fsutil behavior set memoryusage 1
		REM https://www.serverbrain.org/solutions-2003/the-mft-zone-can-be-optimized.html
		fsutil behavior set mftzone 1
		REM Default Last Access information on directories, performance/privacy value
		fsutil behavior set disablelastaccess 2
		REM Default Virtual Memory Pagefile Encryption value
		fsutil behavior set encryptpagingfile 0
		REM Default creation of legacy 8.3 character-length file names on FAT- and NTFS-formatted volumes value
		fsutil behavior set disable8dot3 1
		REM Default NTFS compression
		fsutil behavior set disablecompression 0
		REM Enable Trim
		fsutil behavior set disabledeletenotify 0
	)
) >nul 2>&1
call :AssistantXCtrlRestart "Memory Optimization" "%ME2OF%"
Mode 130,45
goto Tweaks

:DisableHDCP
for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
	if "%HDCOF%" == "%COL%[91mOFF" (
		reg add "HKCU\Software\AssistantX" /v HDCTweaks /f
		reg add "%%a" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "1" /f
	) else (
		reg delete "HKCU\Software\AssistantX" /v HDCTweaks /f
		reg add "%%a" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "0" /f
	)
) >nul 2>&1
goto Tweaks

:DisablePreemtion
if "%CMAOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /t Reg_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /t Reg_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /t Reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /t Reg_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /t Reg_DWORD /d "0" /f
) >nul 2>&1 else (
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemption" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableCudaContextPreemption" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "EnableCEPreemption" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisablePreemptionOnS3S4" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "ComputePreemption" /f
) >nul 2>&1
goto Tweaks

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
goto Tweaks

:NVTelemetry
if "%NVTOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v NVTTweaks /f
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /t REG_DWORD /d 0 /f
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /t REG_DWORD /d 0 /f
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /t REG_DWORD /d 0 /f
	reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /t REG_DWORD /d 0 /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "NvBackend" /f
	schtasks /change /disable /tn "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /disable /tn "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /disable /tn "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /disable /tn "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /f
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\NvControlPanel2\Client" /v "OptInOrOutPreference" /f
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID44231" /f
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID64640" /f
	reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\FTS" /v "EnableRID66610" /f
	schtasks /change /enable /tn "NvTmRep_CrashReport1_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /enable /tn "NvTmRep_CrashReport2_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /enable /tn "NvTmRep_CrashReport3_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
	schtasks /change /enable /tn "NvTmRep_CrashReport4_{B2FE1952-0186-46C3-BAEC-A80AA35AC5B8}"
) >nul 2>&1
goto tweaks

:NvidiaTweaks
if "%NVIOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v "NvidiaTweaks" /f
	rem Nvidia Reg
	reg add "HKCU\Software\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" /v "NvCplUseColorCorrection" /t Reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t Reg_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /t Reg_DWORD /d "0" /f
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
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\FTS" /v "EnableRID61684" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v "NvidiaTweaks" /f
	rem Nvidia Reg
	reg delete "HKCU\Software\NVIDIA Corporation\Global\NVTweak\Devices\509901423-0\Color" /v "NvCplUseColorCorrection" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "PlatformSupportMiracast" /t Reg_DWORD /d "1" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /f
	rem Nvidia Registry Key
	for /f %%a in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		rem Reset Tiled Display
		reg delete "%%a" /v "EnableTiledDisplay" /f
		rem Reset TCC
		reg delete "%%a" /v "TCCSupported" /f
	)
) >nul 2>&1
goto Tweaks

:DisableWriteCombining
if "%DWCOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /t Reg_DWORD /d "1" /f
) >nul 2>&1 else (
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /f
) >nul 2>&1
goto Tweaks

:Mitigations
if "%MITOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v MitigationsTweaks /f
	REM Turn Core Isolation Memory Integrity OFF
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d "0" /f
	REM Disable SEHOP
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /t Reg_DWORD /d "1" /f
	REM Disable Spectre And Meltdown
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f
	cd %TEMP%
	if not exist "%TEMP%\NSudo.exe" curl -g -L -# -o "%TEMP%\NSudo.exe" "https://github.com/ALFiX01/AssistantX/raw/main/Files/NSudo.exe"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t Reg_DWORD /d "3" /f"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "sc start "TrustedInstaller""
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %SYSTEMROOT%\System32\mcupdate_GenuineIntel.dll mcupdate_GenuineIntel.old"
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %SYSTEMROOT%\System32\mcupdate_AuthenticAMD.dll mcupdate_AuthenticAMD.old"
	REM Disable CFG Lock
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /t Reg_DWORD /d "0" /f
	REM Disable NTFS/ReFS and FS Mitigations
	reg add "HKLM\System\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /t Reg_DWORD /d "0" /f
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v MitigationsTweaks /f
	REM Turn Core Isolation Memory Integrity ON
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d "1" /f
	REM Enable SEHOP
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "DisableExceptionChainValidation" /f
	REM Enable Spectre And Meltdown
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettings /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /f
	cd %TEMP%
	if not exist "%TEMP%\NSudo.exe" curl -g -L -# -o "%TEMP%\NSudo.exe" "https://github.com/ALFiX01/AssistantX/raw/main/Files/NSudo.exe"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "reg add "HKLM\SYSTEM\CurrentControlSet\Services\TrustedInstaller" /v "Start" /t Reg_DWORD /d "2" /f"
	NSudo -U:S -ShowWindowMode:Hide -wait cmd /c "sc start "TrustedInstaller"" 
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %SYSTEMROOT%\System32\mcupdate_GenuineIntel.old mcupdate_GenuineIntel.dll"
	NSudo -U:T -P:E -M:S -ShowWindowMode:Hide -wait cmd /c "ren %SYSTEMROOT%\System32\mcupdate_AuthenticAMD.old mcupdate_AuthenticAMD.dll"
	REM Enable CFG Lock
	reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "EnableCfg" /f
	REM Enable NTFS/ReFS and FS Mitigations
	reg delete "HKLM\System\CurrentControlSet\Control\Session Manager" /v "ProtectionMode" /f
) >nul 2>&1
goto Tweaks

:TCPIP
Reg query "HKCU\Software\AssistantX" /v "WifiDisclaimer" >nul 2>&1 && goto TCPIP2
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
echo %COL%[91m  This tweak is for Ethernet users only, if you're on Wi-Fi, do not run this tweak.
echo.
echo   %COL%[37mFor any questions and/or concerns, please join our discord: discord.gg/J7wghdhKsx
echo.
echo   %COL%[37mPlease enter "I understand" without quotes to continue:
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!" neq "i understand" goto Tweaks
Reg add "HKCU\Software\AssistantX" /v "WifiDisclaimer" /f >nul 2>&1
:TCPIP2
if "%TCPOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v "TCPIP" /f
	powershell -NoProfile -NonInteractive -Command ^
	Enable-NetAdapterQos -Name "*";^
	Disable-NetAdapterPowerManagement -Name "*";^
	Disable-NetAdapterIPsecOffload -Name "*";^
	Set-NetTCPSetting -SettingName "*" -MemoryPressureProtection Disabled -InitialCongestionWindow 10 -ErrorAction SilentlyContinue
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxConnectRetransmissions" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "32" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckFrequency" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckTicks" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "CongestionAlgorithm" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MultihopSets" /t REG_DWORD /d "15" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "IRPStackSize" /t REG_DWORD /d "50" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SizReqBuf" /t REG_DWORD /d "17424" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "Size" /t REG_DWORD /d "3" /f
	reg add "HKLM\Software\Policies\Microsoft\Windows\Psched" /v "TimerResolution" /t REG_DWORD /d "1" /f
	reg add "HKLM\System\CurrentControlSet\Services\Tcpip\QoS" /v "Do not use NLA" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeCacheTime" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeSOACacheTime" /t REG_DWORD /d "0" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NetFailureCacheTime" /t REG_DWORD /d "0" /f
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d "0" /f
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableAutoDoh" /t REG_DWORD /d "2" /f
	reg add "HKLM\SYSTEM\CurrDisableNagleentControlSet\Services\AFD\Parameters" /v "DoNotHoldNicBuffers" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DisableRawSecurity" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "NonBlockingSendSpecialBuffering" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "IgnorePushBitOnReceives" /t REG_DWORD /d "1" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DynamicSendBufferDisable" /t REG_DWORD /d "0" /f
	reg add "HKLM\Software\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /t REG_DWORD /d "1" /f
	for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" /f "ServiceName" /s ^|findstr /i /l "ServiceName"') do (
		reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /t Reg_DWORD /d "1" /f
		reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /t Reg_DWORD /d "1" /f
		reg add "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /t Reg_DWORD /d "0" /f
		reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpInitialRTT" /d "300" /t REG_DWORD /f
		reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "UseZeroBroadcast" /d "0" /t REG_DWORD /f
		reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "DeadGWDetectDefault" /d "1" /t REG_DWORD /f
	)
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v "TCPIP" /f
	powershell -NoProfile -NonInteractive -Command ^
	Set-NetTCPSetting -SettingName "*" -InitialCongestionWindow 4 -ErrorAction SilentlyContinue
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxConnectRetransmissions" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckFrequency" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DelayedAckTicks" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "CongestionAlgorithm" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MultihopSets" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "IRPStackSize" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "SizReqBuf" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v "Size" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\QoS" /v "Do not use NLA" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeCacheTime" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NegativeSOACacheTime" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "NetFailureCacheTime" /f
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters" /v "EnableAutoDoh" /f
	reg delete "HKLM\SYSTEM\CurrDisableNagleentControlSet\Services\AFD\Parameters" /v "DoNotHoldNicBuffers" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DisableRawSecurity" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "NonBlockingSendSpecialBuffering" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "IgnorePushBitOnReceives" /f
	reg delete "HKLM\SYSTEM\CurrentControlSet\Services\AFD\Parameters" /v "DynamicSendBufferDisable" /f
	reg delete "HKLM\Software\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /f
	for /f "tokens=3*" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkCards" /f "ServiceName" /s ^|findstr /i /l "ServiceName"') do (
		reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /f
		reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /f
		reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /f
		reg delete "HKLM\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "TcpInitialRTT" /f
		reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "UseZeroBroadcast" /f
		reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\%%i" /v "DeadGWDetectDefault" /f
	)
) >nul 2>&1
start /B cmd /c "ipconfig /release & ipconfig /renew" >nul 2>&1
goto Tweaks

:NIC
Reg query "HKCU\Software\AssistantX" /v "Wifiadvancedtv" >nul 2>&1 && goto NIC2
cls
echo.
echo.
call :AssistantXTitle
echo.
echo                                               %COL%[90m AssistantX is a free and desktop utility
echo                                        %COL%[90m    made to improve your day-to-day productivity
echo.
echo.
echo.
echo %COL%[91m  WARNING:
echo %COL%[91m  This tweak is for ethernet users only, if you're on Wi-Fi, do not run this tweak.
echo.
echo   %COL%[37mFor any questions and/or concerns, please join our discord: discord.gg/J7wghdhKsx
echo.
echo   %COL%[37mPlease enter "I understand" without quotes to continue:
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
set /p "input=%DEL%                                                            >: %COL%[92m"
if /i "!input!" neq "i understand" goto Tweaks
Reg add "HKCU\Software\AssistantX" /v "Wifiadvancedtv" /f >nul 2>&1
:NIC2
cd %SYSTEMDRIVE%\AssistantX\AssistantXRevert
if "%NICOF%" neq "%COL%[91mOFF" (
	reg import ognic1.reg
	reg import ognic2.reg
	reg import ognic3.reg
	reg import ognic4.reg
	del ognic1.reg
	del ognic2.reg
	del ognic3.reg
	del ognic4.reg
	goto Tweaks
) >nul 2>&1
set ognic=1
for /f "tokens=*" %%f in ('wmic cpu get NumberOfCores /value ^| find "="') do set %%f
for /f "tokens=3*" %%a in ('reg query "HKLM\Software\Microsoft\Windows NT\CurrentVersion\NetworkCards" /k /v /f "Description" /s /e ^| findstr /ri "REG_SZ"') do (
	for /f %%g in ('reg query "HKLM\System\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}" /s /f "%%b" /d ^| findstr /C:"HKEY"') do (
		reg export "%%g" "%SYSTEMDRIVE%\AssistantX\AssistantXRevert\ognic!ognic!.reg" /y
		reg add "%%g" /v "MIMOPowerSaveMode" /t REG_SZ /d "3" /f
		reg add "%%g" /v "PowerSavingMode" /t REG_SZ /d "0" /f
		reg add "%%g" /v "EnableGreenEthernet" /t REG_SZ /d "0" /f
		reg add "%%g" /v "*EEE" /t REG_SZ /d "0" /f
		reg add "%%g" /v "EnableConnectedPowerGating" /t REG_DWORD /d "0" /f
		reg add "%%g" /v "EnableDynamicPowerGating" /t REG_SZ /d "0" /f
		reg add "%%g" /v "EnableSavePowerNow" /t REG_SZ /d "0" /f
		reg add "%%g" /v "PnPCapabilities" /t REG_SZ /d "24" /f
		REM more powersaving options
		reg add "%%g" /v "*NicAutoPowerSaver" /t REG_SZ /d "0" /f
		reg add "%%g" /v "ULPMode" /t REG_SZ /d "0" /f
		reg add "%%g" /v "EnablePME" /t REG_SZ /d "0" /f
		reg add "%%g" /v "AlternateSemaphoreDelay" /t REG_SZ /d "0" /f
		reg add "%%g" /v "AutoPowerSaveModeEnabled" /t REG_SZ /d "0" /f
		set /a ognic+=1
	)
) >nul 2>&1
start /B cmd /c "ipconfig /release & ipconfig /renew" >nul 2>&1
goto Tweaks

:Netsh
if "%NETOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v InternetTweaks /f
	netsh int tcp set global dca=enabled
	netsh int tcp set global netdma=enabled
	netsh interface isatap set state disabled
	netsh int tcp set global timestamps=disabled
	netsh int tcp set global rss=enabled
	netsh int tcp set global nonsackrttresiliency=disabled
	netsh int tcp set global initialRto=2000
	netsh int tcp set supplemental template=custom icw=10
	netsh interface ip set interface ethernet currenthoplimit=64
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v InternetTweaks /f
	netsh int tcp set supplemental Internet congestionprovider=default
	netsh int tcp set global initialRto=3000
	netsh int tcp set global rss=default
	netsh int tcp set global chimney=default
	netsh int tcp set global dca=default
	netsh int tcp set global netdma=default
	netsh int tcp set global timestamps=default
	netsh int tcp set global nonsackrttresiliency=default
) >nul 2>&1
goto Tweaks

:AllGPUTweaks
if "%ALLOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v "AllGPUTweaks" /f
	REM Enable Hardware Accelerated Scheduling
	reg query "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" && reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t Reg_DWORD /d "2" /f
	REM Enable gdi hardware acceleration
	for /f %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do reg add "%%a" /v "KMD_EnableGDIAcceleration" /t Reg_DWORD /d "1" /f
	REM Enable GameMode
	reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t Reg_DWORD /d "1" /f
	reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t Reg_DWORD /d "1" /f
	REM FSO
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d "0" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /t REG_DWORD /d "2" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /t REG_DWORD /d "2" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /t REG_DWORD /d "1" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /t REG_DWORD /d "1" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /t REG_DWORD /d "0" /f
	reg add "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /t REG_DWORD /d "2" /f
	REM Disable GpuEnergyDrv
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t Reg_DWORD /d "4" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDr" /v "Start" /t Reg_DWORD /d "4" /f
	REM Disable Preemption
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t Reg_DWORD /d "0" /f
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v "AllGPUTweaks" /f
	REM Enable Hardware Accelerated Scheduling
	reg query "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" && reg add "HKLM\System\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t Reg_DWORD /d "1" /f
	REM Disable gdi hardware acceleration
	for /f %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class" /v "VgaCompatible" /s ^| findstr "HKEY"') do reg delete "%%a" /v "KMD_EnableGDIAcceleration" /f
	REM Enable GameMode
	reg add "HKCU\Software\Microsoft\GameBar" /v "AllowAutoGameMode" /t Reg_DWORD /d "1" /f
	reg add "HKCU\Software\Microsoft\GameBar" /v "AutoGameModeEnabled" /t Reg_DWORD /d "1" /f
	REM FSO
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehaviorMode" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_FSEBehavior" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_HonorUserFSEBehaviorMode" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_DXGIHonorFSEWindowsCompatible" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_EFSEFeatureFlags" /f
	reg delete "HKCU\System\GameConfigStore" /v "GameDVR_DSEBehavior" /f
	REM Disable GpuEnergyDrv
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDrv" /v "Start" /t Reg_DWORD /d "2" /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\GpuEnergyDr" /v "Start" /t Reg_DWORD /d "2" /f
	REM Disable Preemption
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t Reg_DWORD /d "1" /f
) >nul 2>&1
goto Tweaks

:Intel
echo %DSSOF% | find "N/A" >nul && call :AssistantXCtrlError "You don't have an intel GPU" && goto Tweaks
REM DedicatedSegmentSize in Intel iGPU
if "%DSSOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" /t REG_DWORD /d "1024" /f
) >nul 2>&1 else (
	reg delete "HKLM\SOFTWARE\Intel\GMM" /v "DedicatedSegmentSize" /f
) >nul 2>&1
goto Tweaks

:AMD
echo %AMDOF% | find "N/A" >nul && call :AssistantXCtrlError "You don't have an AMD GPU" && goto Tweaks
REM AMD Registry Location
for /f %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /s /v "DriverDesc"^| findstr "HKEY AMD ATI"') do if /i "%%i" neq "DriverDesc" (set "REGPATH_AMD=%%i")
REM AMD Tweaks
reg add "%REGPATH_AMD%" /v "3D_Refresh_Rate_Override_DEF" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "3to2Pulldown_NA" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AAF_NA" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "Adaptive De-interlacing" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AllowRSOverlay" /t Reg_SZ /d "false" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AllowSkins" /t Reg_SZ /d "false" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AllowSnapshot" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AllowSubscription" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AntiAlias_NA" /t Reg_SZ /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AreaAniso_NA" /t Reg_SZ /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "ASTT_NA" /t Reg_SZ /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "AutoColorDepthReduction_NA" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableSAMUPowerGating" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableUVDPowerGatingDynamic" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableVCEPowerGating" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableAspmL0s" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableAspmL1" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableUlps" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableUlps_NA" /t Reg_SZ /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "KMD_DeLagEnabled" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "KMD_FRTEnabled" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableDMACopy" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableBlockWrite" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "StutterMode" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "EnableUlps" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "PP_SclkDeepSleepDisable" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "PP_ThermalAutoThrottlingEnable" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "DisableDrmdmaPowerGating" /t Reg_DWORD /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%" /v "KMD_EnableComputePreemption" /t Reg_DWORD /d "0" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "Main3D_DEF" /t Reg_SZ /d "1" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "Main3D" /t Reg_BINARY /d "3100" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "FlipQueueSize" /t Reg_BINARY /d "3100" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "ShaderCache" /t Reg_BINARY /d "3200" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "Tessellation_OPTION" /t Reg_BINARY /d "3200" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "Tessellation" /t Reg_BINARY /d "3100" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "VSyncControl" /t Reg_BINARY /d "3000" /f >nul 2>&1
reg add "%REGPATH_AMD%\UMD" /v "TFQ" /t Reg_BINARY /d "3200" /f >nul 2>&1
reg add "%REGPATH_AMD%\DAL2_DATA__2_0\DisplayPath_4\EDID_D109_78E9\Option" /v "ProtectionControl" /t Reg_BINARY /d "0100000001000000" /f >nul 2>&1
goto Tweaks

:AudioLatency
cd %SYSTEMDRIVE%\AssistantX\Resources
if "%AUDOF%" == "%COL%[91mOFF" (
	if not exist nssm.exe (
		curl -g -L -# -o "%SYSTEMDRIVE%\AssistantX\Resources\nssm.exe" "https://github.com/ALFiX01/AssistantX/raw/main/Files/nssm.exe"
		curl -g -L -# -o "%SYSTEMDRIVE%\AssistantX\Resources\REAL.exe" "https://github.com/ALFiX01/AssistantX/raw/main/Files/REAL.exe"
		nssm install AssistantXAudio "%SYSTEMDRIVE%\AssistantX\Resources\REAL.exe"
		nssm set AssistantXAudio DisplayName AssistantX Audio Latency Reducer Service
		nssm set AssistantXAudio Description Reduces Audio Latency
		nssm set AssistantXAudio Start SERVICE_AUTO_START
		nssm set AssistantXAudio AppAffinity 1
	)
nssm set AssistantXAudio start SERVICE_AUTO_START
nssm start AssistantXAudio
) >nul 2>&1 else (
nssm set AssistantXAudio start SERVICE_DISABLED
nssm stop AssistantXAudio
) >nul 2>&1
goto Tweaks

:Cleaner
cls
rmdir /S /Q "%SYSTEMDRIVE%\AssistantX\Resources\DeviceCleanupCmd\" >nul 2>&1
del /F /Q "%SYSTEMDRIVE%\AssistantX\Resources\AdwCleaner.exe" >nul 2>&1
del /F /Q "%SYSTEMDRIVE%\AssistantX\Resources\EmptyStandbyList.exe" >nul 2>&1
curl -g -L -# -o "%SYSTEMDRIVE%\AssistantX\Resources\EmptyStandbyList.exe" "https://github.com/ALFiX01/AssistantX/raw/main/Files/EmptyStandbyList.exe"
curl -g -L -# -o "%SYSTEMDRIVE%\AssistantX\Resources\DeviceCleanupCmd.zip" "https://www.uwe-sieber.de/files/DeviceCleanupCmd.zip"
curl -g -L -# -o "%SYSTEMDRIVE%\AssistantX\Resources\AdwCleaner.exe" "https://adwcleaner.malwarebytes.com/adwcleaner?channel=release"
powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\AssistantX\Resources\DeviceCleanupCmd.zip' -DestinationPath '%SYSTEMDRIVE%\AssistantX\Resources\DeviceCleanupCmd\'
del /F /Q "%SYSTEMDRIVE%\AssistantX\Resources\DeviceCleanupCmd.zip" >nul 2>&1
del /Q %LOCALAPPDATA%\Microsoft\Windows\INetCache\IE\*.* >nul 2>&1
del /Q "%SYSTEMROOT%\Downloaded Program Files\*.*" >nul 2>&1
rd /s /q %SYSTEMDRIVE%\$Recycle.bin >nul 2>&1
del /Q %TEMP%\*.* >nul 2>&1
del /Q %SYSTEMROOT%\Temp\*.* >nul 2>&1
del /Q %SYSTEMROOT%\Prefetch\*.* >nul 2>&1
cd %SYSTEMDRIVE%\AssistantX\Resources >nul 2>&1
AdwCleaner.exe /eula /clean /noreboot
for %%g in (workingsets modifiedpagelist standbylist priority0standbylist) do EmptyStandbyList.exe %%g
cd "%SYSTEMDRIVE%\AssistantX\Resources\DeviceCleanupCmd\x64" >nul 2>&1
DeviceCleanupCmd.exe *
goto tweaks

:gameBooster
TITLE Game Booster Panel - AssistantX v%localtwo%
cls & echo Select the game location, you can do it a second time to revert the changes.
set dialog="about:<input type=file id=FILE><script>FILE.click();new ActiveXObject
set dialog=%dialog%('Scripting.FileSystemObject').GetStandardStream(1).WriteLine(FILE.value);
set dialog=%dialog%close();resizeTo(0,0);</script>"
for /f "tokens=* delims=" %%p in ('mshta.exe %dialog%') do set "file=%%p"
if "%file%"=="" goto :eof
for %%F in ("%file%") do reg query "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%file%" && (
	reg delete "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "%file%" /f
	reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%file%" /f
	reg delete "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%~nxF\PerfOptions" /v "CpuPriorityClass" /f
	cls
	echo Game boost has been reverted!
	Timeout 5
) || (
	reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "%file%" /t Reg_SZ /d "GpuPreference=2;" /f >nul 2>&1
	reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%file%" /t Reg_SZ /d "~ DISABLEDXMAXIMIZEDWINDOWEDMODE" /f >nul 2>&1
	reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\%%~nxF\PerfOptions" /v "CpuPriorityClass" /t Reg_DWORD /d "3" /f >nul 2>&1
) >nul 2>&1
goto :eof

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
goto tweaks

:Ai
cls
TITLE AI Panel - AssistantX v%localtwo%
echo.
echo.
echo                                                                                %COL%[33m##      ##
echo                        %COL%[33m####              ##         ##                   ##     ##    ##            ####    ##
echo                       %COL%[33m##  ##   ###  ###       ###  ####   ####  #####   ####     ##  ##            ##  ## 
echo                       %COL%[33m######  ###  ###   ##  ###    ##   ## ##  ##  ##   ##        ##              ######   ##
echo                       %COL%[33m##  ##    ##   ##  ##    ##   ##   ## ##  ##  ##   ##      ##  ##            ##  ##   ##
echo                       %COL%[33m##  ##  ###  ###   ##  ##     ###   ####  ##  ##   ###    ##    ##           ##  ##   ##
echo                                                                                %COL%[33m##      ##
echo.
echo.
echo                                                   %COL%[90m AssistantX Ai - free virtual assistant
echo                                                           %COL%[90m Based on GPT-3.5 Turbo
echo.
echo.
echo.
echo                                %COL%[96m[ %COL%[37m1 %COL%[96m]%COL%[37m Install/Update Ai                                 %COL%[96m[ %COL%[37m2 %COL%[96m]%COL%[37m Launch Ai
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
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
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" call:AIdownload
if /i "%choice%"=="2" call:AIstart
if /i "%choice%"=="B" goto MainMenu
if /i "%choice%"=="X" goto MainMenu
goto Ai

:AIdownload
del /S /Q %SYSTEMDRIVE%\AssistantX\AssistantAi\Assistant.exe
curl -g -L -# -o %SYSTEMDRIVE%\AssistantX\AssistantAi\Assistant.exe "https://github.com/ALFiX01/AssistantX/releases/download/File/Assistant.exe"
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
if /i "!input!"=="B" goto TweaksPG1
if /i "!input!" neq "i agree" goto Advanced
reg add "HKCU\Software\AssistantX" /v "advancedtv" /f >nul 2>&1

:Advanced 
REM for /f "tokens=2 delims==" %%a in ('wmic path Win32_Battery Get BatteryStatus /value ^| findstr "BatteryStatus"') do set status=%%a
REM if %status% == 1 ( set Battery=DC ) else ( set Battery=AC )
set "choice="
for %%i in (DSCOF AUTOF DRIOF BCDOF NONOF CS0OF TOFOF PS0OF IDLOF CONG DPSOF) do (set "%%i=%COL%[92mON ") >nul 2>&1
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
	rem Disable USB Powersavings
	reg query "HKCU\Software\AssistantX" /v "DUSBPowerSavings" || set "DPSOF=%COL%[91mOFF"
	rem Nvidia Drivers
	cd "%SYSTEMDRIVE%\Program Files\NVIDIA Corporation\NVSMI"
	for /f "tokens=1 skip=1" %%a in ('nvidia-smi --query-gpu^=driver_version --format^=csv') do if "%%a" neq "531.29" set "DRIOF=%COL%[91mOFF"
	rem BCDEDIT
	reg query "HKCU\Software\AssistantX" /v "BcdEditTweaks" || set "BCDOF=%COL%[91mOFF"
	rem NonBestEffortLimit Tweak
	reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" | find "0xa" || set "NONOF=%COL%[91mOFF"
	rem CS0 Tweak
	reg query "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" | find "0x0" || set "CS0OF=%COL%[91mOFF"
	rem Task Offloading
	reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" | find "off" || set "TOFOF=%COL%[91mOFF"
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
echo.
cls
echo.
echo                                                                                                                        %COL%[36mPage 1/2
call :AssistantXTitle
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
echo              %COL%[96m[%COL%[37m 8 %COL%[96m]%COL%[37m Nvidia Driver %DRIOF%              %COL%[96m[%COL%[37m 9 %COL%[96m]%COL%[37m BCDEdit %BCDOF%                    %COL%[96m[%COL%[37m 10 %COL%[96m]%COL%[37m Disable Smartscreen
echo              %COL%[90mInstall the best tweaked nvidia      %COL%[90mTweaks your windows boot config      %COL%[90mDisable Antivirus Smartscreen
echo              %COL%[90mdriver for latency and fps           %COL%[90mdata to optimized settings
echo.
echo              %COL%[96m[%COL%[37m 11 %COL%[96m]%COL%[37m Old context menu              %COL%[96m[%COL%[37m 12 %COL%[96m]%COL%[37m Uninstall Widgets             %COL%[96m[%COL%[37m 13 %COL%[96m]%COL%[37m Disable background programs
echo              %COL%[91mOnly for win 11                                                          %COL%[90m Disables programs running in
echo.                                                                                      %COL%[90m the background
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                   %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]         %COL%[36m[ N page two ]
echo.
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto NonBestEffortLimit
if /i "%choice%"=="2" goto Autotuning
if /i "%choice%"=="3" goto DSCPValue
if /i "%choice%"=="4" goto Congestion
if /i "%choice%"=="5" goto cstates
if /i "%choice%"=="6" goto pstates0
if /i "%choice%"=="7" goto DisableIdle
if /i "%choice%"=="8" goto Driver
if /i "%choice%"=="9" goto BCDEdit
if /i "%choice%"=="10" goto Smartscreen
if /i "%choice%"=="11" goto OldContextMenu
if /i "%choice%"=="12" goto WidgetUninstall
if /i "%choice%"=="13" goto DisableBackgroundPrograms
if /i "%choice%"=="N" goto AdvancedPG2
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto TweaksPG1
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
echo                                                           %COL%[1;4;34mOther Tweaks%COL%[0m
echo.
echo              %COL%[96m[%COL%[37m 1 %COL%[96m]%COL%[37m Disable all notifications
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
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
set /p choice="%DEL%                                        %COL%[37mSelect a corresponding number to the options above > "
if /i "%choice%"=="1" goto DisableAllNotifications
if /i "%choice%"=="2" goto Autotuning
if /i "%choice%"=="3" goto DSCPValue
if /i "%choice%"=="X" goto MainMenu
if /i "%choice%"=="B" goto Advanced
goto Advanced

:Smartscreen
cls
color A
echo.
echo.
echo             ##
echo            ##
echo      ##   ##
echo       ## ##
echo        ##
echo.
echo     Completed
echo.
timeout 2
      reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "PromptOnSecureDesktop" /t REG_DWORD /d 0 /f
      reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "ConsentPromptBehaviorAdmin" /t REG_DWORD /d 0 /f
      reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "Off" /f
goto Advanced

:DisableAllNotifications
cls
color A
echo.
echo.
echo             ##
echo            ##
echo      ##   ##
echo       ## ##
echo        ##
echo.
echo     Completed
echo.
timeout 2
      reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /t REG_DWORD /d 0 /f
goto AdvancedPG2

:WidgetUninstall
cls
color A
powershell -executionpolicy -command "winget uninstall "windows web experience pack""
echo.
echo.
echo             ##
echo            ##
echo      ##   ##
echo       ## ##
echo        ##
echo.
echo     Completed
echo.
timeout 3
goto Advanced

:DisableBackgroundPrograms
cls
color A
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v "BackgroundAppGlobalToggle" /t REG_DWORD /d 0 /f
echo.
echo.
echo             ##
echo            ##
echo      ##   ##
echo       ## ##
echo        ##
echo.
echo     Completed
echo.
timeout 2
goto Advanced

:OldContextMenu
cls
color A
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f
echo.
echo.
echo             ##
echo            ##
echo      ##   ##
echo       ## ##
echo        ##
echo.
echo     Completed
echo.
timeout 2
goto Advanced

:NonBestEffortLimit
if "%NONOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /t REG_DWORD /d "10" /f
) >nul 2>&1 else (
	reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "NonBestEffortLimit" /f
) >nul 2>&1
goto Advanced


:Autotuning
if "%AUTOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v TuningTweak /f
	netsh int tcp set global autotuninglevel=disabled
	netsh winsock set autotuning off
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v TuningTweak /f
	netsh int tcp set global autotuninglevel=normal
	netsh winsock set autotuning on
) >nul 2>&1
goto Advanced

:DSCPValue
if "%DSCOF%" == "%COL%[91mOFF" (
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\Psched" /v "Start" /t Reg_DWORD /d "1" /f
	sc start Psched
	for %%i in (csgo VALORANT-Win64-Shipping javaw FortniteClient-Win64-Shipping ModernWarfare r5apex) do (
		reg query "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" || (
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Application Name" /t Reg_SZ /d "%%i.exe" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Version" /t Reg_SZ /d "1.0" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Protocol" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local Port" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local IP" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Local IP Prefix Length" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote Port" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote IP" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Remote IP Prefix Length" /t Reg_SZ /d "*" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "DSCP Value" /t Reg_SZ /d "46" /f
			reg add "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /v "Throttle Rate" /t Reg_SZ /d "-1" /f
		)
	)
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "46" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "56" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "46" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "56" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeGuaranteed" /t REG_DWORD /d "5" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeNetworkControl" /t REG_DWORD /d "7" /f
	reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /t REG_DWORD /d "65000" /f
) >nul 2>&1 else (
	for %%i in (csgo VALORANT-Win64-Shipping javaw FortniteClient-Win64-Shipping ModernWarfare r5apex) do (
		reg delete "HKLM\Software\Policies\Microsoft\Windows\QoS\%%i" /f
	)
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeGuaranteed" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingConforming" /v "ServiceTypeNetworkControl" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeGuaranteed" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\DiffservByteMappingNonConforming" /v "ServiceTypeNetworkControl" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeGuaranteed" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched\UserPriorityMapping" /v "ServiceTypeNetworkControl" /f
	reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Psched" /v "MaxOutstandingSends" /f
) >nul 2>&1
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
	reg add "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" /t REG_DWORD /d "0" /f
) >nul 2>&1 else (
	reg add "HKLM\SYSTEM\ControlSet001\Control\Class\{4D36E968-E325-11CE-BFC1-08002BE10318}\0000" /v "AllowDeepCStates" /t REG_DWORD /d "1" /f
) >nul 2>&1
call :AssistantXCtrlRestart "CStates" "%CS0OF%"
Mode 130,45
goto Advanced

:PStates0
if "%PS0OF%" == "%COL%[91mOFF" (
	for /f %%i in ('reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		reg add "%%i" /v "DisableDynamicPstate" /t REG_DWORD /d "1" /f
	)
) >nul 2>&1 else  (
	for /f %%i in ('reg query "HKLM\System\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}" /t REG_SZ /s /e /f "NVIDIA" ^| findstr "HKEY"') do (
		reg delete "%%i" /v "DisableDynamicPstate" /f
	)
) >nul 2>&1
call :AssistantXCtrlRestart "PStates 0" "%PS0OF%"
Mode 130,45
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
goto Advanced

:Driver
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\DevicePath" /v "NoAutoUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\DriverSearching" /v "DriverUpdateWizardWuSearchEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AUCustom" /v "TurnOffWindowsUpdateDeviceDriverSearching" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v "SearchOrderConfig" /t REG_DWORD /d 0 /f >nul 2>&1
cls
echo This will uninstall your current graphics driver. The optimized driver will be installed after you reboot.
echo Please be patient and wait until the script finishes.
echo.
echo Would you like to install?
%SYSTEMROOT%\System32\choice.exe /c:YN /n /m "[Y] Yes  [N] No"
if %errorlevel% == 2 goto Advanced
cd "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
curl -LJ https://github.com/ALFiX01/AssistantX/blob/main/Files/Driverinstall.bat?raw=true -o Driverinstall.bat 
title Executing DDU...
curl -g -L -# -o "%SYSTEMDRIVE%\AssistantX\Resources\DDU.zip" "https://github.com/ALFiX01/AssistantX/releases/download/File/DDU.zip"
powershell -NoProfile Expand-Archive '%SYSTEMDRIVE%\AssistantX\Resources\DDU.zip' -DestinationPath '%SYSTEMDRIVE%\AssistantX\Resources\DDU\' >nul 2>&1
del "%SYSTEMDRIVE%\AssistantX\Resources\DDU.zip"
cd %SYSTEMDRIVE%\AssistantX\Resources\DDU
DDU.exe -silent -cleannvidia
title Restart Confirmation
cls
echo Your PC NEEDS to restart before downloading and installing the driver!
echo.
echo Other Nvidia tweaks will not be available until you restart.
echo.
echo Drivers will be installed upon PC startup.
echo.
:restartchoice
set /p choice=Would you like to continue and restart your PC? Y or N?: 
if /i "%choice%" == "y" (
	shutdown /r /f /d p:0:0
) else if /i "%choice%" == "n" (
	goto Advanced
) else (
	goto restartchoice
)

:BCDEdit
if "%BCDOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v BcdEditTweaks /f
	rem tscsyncpolicy
	bcdedit /set tscsyncpolicy enhanced
	rem Quick Boot
	rem if "%dualboot%" == "no" (bcdedit /timeout 3)
	bcdedit /set bootux disabled
	bcdedit /set bootmenupolicy standard
	rem bcdedit /set hypervisorlaunchtype off
	rem bcdedit /set tpmbootentropy ForceDisable
	bcdedit /set quietboot yes
	rem Windows 8 Boot (windows 8.1)
	rem for /f "tokens=4-9 delims=. " %%i in ('ver') do set winversion=%%i.%%j
	rem if "!winversion!" == "6.3.9600" (
	rem 	bcdedit /set {globalsettings} custom:16000067 true
	rem 	bcdedit /set {globalsettings} custom:16000068 true
	rem )
	rem nx
	echo %PROCESSOR_IDENTIFIER% ^| find "Intel" >nul && bcdedit /set nx optout || bcdedit /set nx alwaysoff
	rem Disable some of the kernel memory mitigations
	rem Forcing Intel SGX and setting isolatedcontext to No will cause a black screen
	rem bcdedit /set isolatedcontext No
	bcdedit /set allowedinmemorysettings 0x0
	rem Disable DMA memory protection and cores isolation
	bcdedit /set vsmlaunchtype Off
	bcdedit /set vm No
	reg add "HKLM\Software\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /t Reg_DWORD /d "0" /f
	reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /t Reg_DWORD /d "0" /f
	reg add "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /t Reg_DWORD /d "0" /f
	rem Avoid using uncontiguous low-memory. Boosts memory performance & microstuttering.
	rem Can freeze the system on unstable memory OC
	rem bcdedit /set firstmegabytepolicy UseAll
	rem bcdedit /set avoidlowmemory 0x8000000
	rem bcdedit /set nolowmem Yes
	rem Enable X2Apic and enable Memory Mapping for PCI-E devices
	bcdedit /set x2apicpolicy Enable
	bcdedit /set uselegacyapicmode No
	bcdedit /set configaccesspolicy Default
	bcdedit /set usephysicaldestination No
	bcdedit /set usefirmwarepcisettings No 
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v "BcdEditTweaks" /f
	rem Better Input
	bcdedit /deletevalue tscsyncpolicy
	rem Quick Boot
	rem if "%dualboot%" == "no" (bcdedit /timeout 0)
	bcdedit /deletevalue bootux
	bcdedit /set bootmenupolicy standard
	bcdedit /set hypervisorlaunchtype Auto
	bcdedit /deletevalue tpmbootentropy
	bcdedit /deletevalue quietboot
	rem Windows 8 Boot Stuff (windows 8.1)
	rem for /f "tokens=4-9 delims=. " %%i in ('ver') do set winversion=%%i.%%j
	rem if "!winversion!" == "6.3.9600" (
	rem	bcdedit /set {globalsettings} custom:16000067 false
	rem	bcdedit /set {globalsettings} custom:16000069 false
	rem	bcdedit /set {globalsettings} custom:16000068 false
	rem )
	rem nx
	bcdedit /set nx optin
	rem Disable some of the kernel memory mitigations
	bcdedit /set allowedinmemorysettings 0x17000077
	bcdedit /set isolatedcontext Yes
	rem Disable DMA memory protection and cores isolation
	bcdedit /deletevalue vsmlaunchtype
	bcdedit /deletevalue vm
	reg delete "HKLM\Software\Policies\Microsoft\FVE" /v "DisableExternalDMAUnderLock" /f
	reg delete "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "EnableVirtualizationBasedSecurity" /f
	reg delete "HKLM\Software\Policies\Microsoft\Windows\DeviceGuard" /v "HVCIMATRequired" /f
	bcdedit /deletevalue firstmegabytepolicy
	bcdedit /deletevalue avoidlowmemory
	bcdedit /deletevalue nolowmem
	bcdedit /deletevalue configaccesspolicy
	bcdedit /deletevalue x2apicpolicy
	bcdedit /deletevalue usephysicaldestination
	bcdedit /deletevalue usefirmwarepcisettings
	bcdedit /deletevalue uselegacyapicmode
) >nul 2>&1
goto Advanced

:DUSBPowerSavings
if "%DPSOF%" == "%COL%[91mOFF" (
	reg add "HKCU\Software\AssistantX" /v DUSBPowerSavings /f
	for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "StorPort" ^| findstr "StorPort"') do reg add "%%i" /v "EnableIdlePowerManagement" /t REG_DWORD /d "0" /f
	for /f "tokens=*" %%i in ('wmic PATH Win32_PnPEntity GET DeviceID ^| findstr "USB\VID_"') do (
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnhancedPowerManagementEnabled" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "AllowIdleIrpInD3" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnableSelectiveSuspend" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "DeviceSelectiveSuspended" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendEnabled" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendOn" /t REG_DWORD /d "0" /f
	reg add "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "D3ColdSupported" /t REG_DWORD /d "0" /f
	)
) >nul 2>&1 else (
	reg delete "HKCU\Software\AssistantX" /v DUSBPowerSavings /f
	for /f "tokens=*" %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "StorPort" ^| findstr "StorPort"') do reg delete "%%i" /v "EnableIdlePowerManagement" /f
	for /f "tokens=*" %%i in ('wmic PATH Win32_PnPEntity GET DeviceID ^| findstr "USB\VID_"') do (
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnhancedPowerManagementEnabled" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "AllowIdleIrpInD3" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "EnableSelectiveSuspend" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "DeviceSelectiveSuspended" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendEnabled" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "SelectiveSuspendOn" /f
	reg delete "HKLM\System\CurrentControlSet\Enum\%%i\Device Parameters" /v "D3ColdSupported" /f
	)
) >nul 2>&1
goto Advanced

:More
TITLE More Panel - AssistantX v%localtwo%
cls
echo.
echo.
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
echo.
echo.
echo                                 %COL%[96m[ %COL%[37m1 %COL%[96m] %COL%[37mAbout                                            %COL%[96m[ %COL%[37m2 %COL%[96m] %COL%[37mDisclaimer
echo.
echo.
echo                                 %COL%[96m[ %COL%[37m3 %COL%[96m] %COL%[37mBackup                                           %COL%[96m[ %COL%[37m4 %COL%[96m] %COL%[37mWe are on Discord
echo                                 %COL%[90mBackup your current registry ^& create a
echo                                 %COL%[90mrestore point used to revert tweaks applied.
echo.
echo.
echo                                 %COL%[96m[ %COL%[37m5 %COL%[96m] %COL%[37mCredits                                          %COL%[96m[ %COL%[37m6 %COL%[96m] %COL%[37mClear Downloads
echo.
echo                                 %COL%[96m[ %COL%[37m7 %COL%[96m] %COL%[37mFix Problem
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo                                              %COL%[36m[ B for back ]         %COL%[31m[ X to Main Menu ]%COL%[37m
echo.
%SYSTEMROOT%\System32\choice.exe /c:1234567BX /n /m "%DEL%                                        Select a corresponding number to the options above >"
set choice=%errorlevel%
if "%choice%"=="1" goto About
if "%choice%"=="2" goto ViewDisclaimer
if "%choice%"=="3" call:Backup
if "%choice%"=="4" goto Discord
if "%choice%"=="5" goto Credits
if "%choice%"=="6" call:ClDownload
if "%choice%"=="7" call:FixProblem
if /i "%choice%"=="8" goto MainMenu
if /i "%choice%"=="9" goto MainMenu
goto More

:ClDownload
cls
color A
del /S /Q %SYSTEMDRIVE%\AssistantX\Downloads\
echo.
echo             ##
echo            ##
echo      ##   ##
echo       ## ##
echo        ##
echo.
echo     Completed
echo.
timeout 2
goto More

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
echo.
echo       About:
echo       Owned by ALFiX, Inc. Copyright Claimed.
echo       This is a GUI for the Tweaks.
echo       %COL%[94m%LOCAL%
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
call :ColorText 8 "                                                      [ press X to go back ]"
echo.
echo.
echo.
%SYSTEMROOT%\System32\choice.exe /c:X /n /m "%DEL%                                                               >:"
set choice=%errorlevel%
if "%choice%"=="1" goto More

:ViewDisclaimer
TITLE Disclaimer Panel - AssistantX v%localtwo%
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
echo %COL%[37m  Please note that we cannot guarantee an FPS boost from applying our optimizations, every system + configuration is different.
echo.
echo     %COL%[96m1.%COL%[37m Everything is "use at your own risk", we are %COL%[91mNOT LIABLE%COL%[37m if you damage your system in any way
echo        (ex. not following the disclaimers carefully).
echo.
echo     %COL%[96m2.%COL%[37m If you don't know what a tweak is, do not use it and contact our support team to receive more assistance.
echo.
echo     %COL%[96m3.%COL%[37m Even though we have an automatic restore point feature, we highly recommend making a manual restore point before running.
echo.
echo   For any questions and/or concerns, please join our discord: discord.gg/J7wghdhKsx
echo.
echo   Please enter "I agree" without quotes to continue:
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
%SYSTEMROOT%\System32\choice.exe /c:X /n /m "%DEL%                                                                 >:"
set choice=%errorlevel%
if "%choice%"=="1" goto More

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
call :ColorText 8 "                                                     [ press B to go back ]"
echo.
%SYSTEMROOT%\System32\choice.exe /c:B /n /m "%DEL%                                                               >:"
set choice=%errorlevel%
if "%choice%"=="1" goto More

:Backup
TITLE Backup Panel - AssistantX v%localtwo%
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1
powershell Enable-ComputerRestore -Drive 'C:\', 'D:\', 'E:\', 'F:\', 'G:\' >nul 2>&1
powershell Checkpoint-Computer -Description 'AssistantX Restore Point' >nul 2>&1
for /F "tokens=2" %%i in ('date /t') do set date=%%i  >nul 2>&1
set date1=%date:/=.%  >nul 2>&1
md %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%  >nul 2>&1
reg export HKCU %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%\HKLM.reg /y & reg export HKCU %SYSTEMDRIVE%\AssistantX\AssistantXRevert\%date1%\HKCU.reg /y >nul 2>&1
cls
goto :eof

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

:AssistantXCtrlError
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





:AssistantXCtrlRestart
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