@echo off
pushd "%CD%"
CD /D "%~dp0"
:: Arguments Section
IF "%1"== "y" GOTO :removedef
IF "%1"== "Y" GOTO :removedef
:--------------------------------------


:--------------------------------------
::Menu Section
cls
echo ------Defender Remover Script , version 1.0------
echo Select an option:
echo.
echo Do you want to remove Windows Defender and alongside components? After this you'll need to reboot.
echo If you PC have a Microsoft Pluton Chip, you can disable from BIOS anytime. (This script removes the integration of Pluton Chip Support and Processing from Windows.)
echo After confirmation of Removal, your Device will RESTART!!
echo A backup and/or System Restore point is recommended.
echo Press Y to Remove, press N to exit from this script.
set /P c=Select one of the options to continue:
if /I "%c%" EQU "Y" goto :removedef
:--------------------------------------


:--------------------------------------
:: If none of the valid keys are pressed, do nothing
goto :eof
:--------------------------------------

:--------------------------------------
:removedef
::killing proceses
CLS
echo Killing Processes which are using Windows Defender Files...
taskkill /f /im smartscreen.exe >nul
taskkill /f /im SecurityHealthSystray.exe >nul
taskkill /f /im SecurityHealthHost.exe >nul
taskkill /f /im SecurityHealthService.exe >nul
taskkill /f /im SecurityHealthHost.exe >nul
taskkill /f /im DWWIN.EXE >nul
taskkill /f /im CompatTelRunner.exe >nul
taskkill /f /im GameBarPresenceWriter.exe >nul
taskkill /f /im DeviceCensus.exe >nul
bcdedit /set hypervisorlaunchtype off

CLS
echo Removing Windows Security UWP App...
:: Remove Windows Security App
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""RemoveSecHealthApp.ps1""' -Verb RunAs}"

CLS
echo Unregister Windows Defender Security Components...
:: Registry Remove of Windows Defender
FOR /R %%f IN (Remove_defender\*.reg) DO regedit.exe /s "%%f"
FOR /R %%f IN (Remove_defender\*.reg) DO PowerRun.exe regedit.exe /s "%%f"
FOR /R %%f IN (Remove_SecurityComp\*.reg) DO regedit.exe /s "%%f"
FOR /R %%f IN (Remove_SecurityComp\*.reg) DO PowerRun.exe regedit.exe /s "%%f"
CLS
:: Removing files and folders
for %%d in ("%Systemdrive%\Windows\WinSxS\FileMaps\wow64_windows-defender*.manifest" "%Systemdrive%\Windows\WinSxS\FileMaps\x86_windows-defender*.manifest" "%Systemdrive%\Windows\WinSxS\FileMaps\amd64_windows-defender*.manifest" "%Systemdrive%\Windows\System32\SecurityAndMaintenance_Error.png" "%Systemdrive%\Windows\System32\SecurityAndMaintenance.png" "%Systemdrive%\Windows\System32\SecurityHealthSystray.exe" "%Systemdrive%\Windows\System32\SecurityHealthService.exe" "%Systemdrive%\Windows\System32\SecurityHealthHost.exe" "%Systemdrive%\Windows\System32\drivers\SgrmAgent.sys" "%Systemdrive%\Windows\System32\drivers\WdDevFlt.sys" "%Systemdrive%\Windows\System32\drivers\WdBoot.sys" "%Systemdrive%\Windows\System32\drivers\WdFilter.sys" "%Systemdrive%\Windows\System32\wscsvc.dll" "%Systemdrive%\Windows\System32\drivers\WdNisDrv.sys" "%Systemdrive%\Windows\System32\wscsvc.dll" "%Systemdrive%\Windows\System32\wscproxystub.dll" "%Systemdrive%\Windows\System32\wscisvif.dll" "%Systemdrive%\Windows\System32\SecurityHealthProxyStub.dll" "%Systemdrive%\Windows\System32\smartscreen.dll" "%Systemdrive%\Windows\SysWOW64\smartscreen.dll" "%Systemdrive%\Windows\System32\smartscreen.exe" "%Systemdrive%\Windows\SysWOW64\smartscreen.exe" "%Systemdrive%\Windows\System32\DWWIN.EXE" "%Systemdrive%\Windows\SysWOW64\smartscreenps.dll" "%Systemdrive%\Windows\System32\smartscreenps.dll" "%Systemdrive%\Windows\System32\SecurityHealthCore.dll" "%Systemdrive%\Windows\System32\SecurityHealthSsoUdk.dll" "%Systemdrive%\Windows\System32\SecurityHealthUdk.dll" "%Systemdrive%\Windows\System32\SecurityHealthAgent.dll" "%Systemdrive%\Windows\System32\wscapi.dll" "%Systemdrive%\Windows\System32\wscadminui.exe" "%Systemdrive%\Windows\SysWOW64\GameBarPresenceWriter.exe" "%Systemdrive%\Windows\System32\GameBarPresenceWriter.exe" "%Systemdrive%\Windows\SysWOW64\DeviceCensus.exe" "%Systemdrive%\Windows\SysWOW64\CompatTelRunner.exe" "%Systemdrive%\Windows\system32\drivers\msseccore.sys" "%Systemdrive%\Windows\system32\drivers\MsSecFltWfp.sys" "%Systemdrive%\Windows\system32\drivers\MsSecFlt.sys") DO PowerRun cmd.exe /c del /f "%%d"
:: part 2
for %%d in ("%Systemdrive%\Windows\WinSxS\amd64_security-octagon*" "%Systemdrive%\Windows\WinSxS\x86_windows-defender*" "%Systemdrive%\Windows\WinSxS\wow64_windows-defender*" "%Systemdrive%\Windows\WinSxS\amd64_windows-defender*" "%Systemdrive%\Windows\SystemApps\Microsoft.Windows.AppRep.ChxApp_cw5n1h2txyewy" "C:\ProgramData\Microsoft\Windows Defender" "C:\ProgramData\Microsoft\Windows Defender Advanced Threat Protection" "C:\Program Files (x86)\Windows Defender Advanced Threat Protection" "C:\Program Files\Windows Defender Advanced Threat Protection" "C:\ProgramData\Microsoft\Windows Security Health" "C:\ProgramData\Microsoft\Storage Health" "%Systemdrive%\Windows\System32\drivers\wd" "C:\Program Files (x86)\Windows Defender" "C:\Program Files\Windows Defender" "%Systemdrive%\Windows\System32\SecurityHealth" "%Systemdrive%\Windows\System32\WebThreatDefSvc" "%Systemdrive%\Windows\System32\Sgrm" "%Systemdrive%\Windows\Containers\WindowsDefenderApplicationGuard.wim" "%Systemdrive%\Windows\SysWOW64\WindowsPowerShell\v1.0\Modules\DefenderPerformance" "%Systemdrive%\Windows\System32\WindowsPowerShell\v1.0\Modules\DefenderPerformance" "%Systemdrive%\Windows\System32\WindowsPowerShell\v1.0\Modules\Defender" "%Systemdrive%\Windows\System32\Tasks_Migrated\Microsoft\Windows\Windows Defender" "%Systemdrive%\Windows\System32\Tasks\Microsoft\Windows\Windows Defender" "%Systemdrive%\Windows\SysWOW64\WindowsPowerShell\v1.0\Modules\Defender" "%Systemdrive%\Windows\System32\HealthAttestationClient" "%Systemdrive%\Windows\GameBarPresenceWriter" "%Systemdrive%\Windows\bcastdvr" "%Systemdrive%\Windows\Containers\serviced\WindowsDefenderApplicationGuard.wim") do PowerRun cmd.exe /c rmdir "%%~d" /s /q
echo Your PC will reboot in 10 seconds..
timeout 10
shutdown /r /f /t 0
exit
:--------------------------------------
