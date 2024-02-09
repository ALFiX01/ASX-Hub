@echo off
taskkill /f /im smartscreen.exe
if exist "%SystemRoot%\System32\smartscreen.exe" (
del /f /q "%SystemRoot%\System32\smartscreen.exe" >nul 2>&1
)

if exist "%SystemRoot%\System32\smartscreen.dll" (
del /f /q "%SystemRoot%\System32\smartscreen.dll" >nul 2>&1
)

REM ; Remove Data...
for %%F in ("%AllUsersProfile%\Microsoft\Windows Defender Advanced Threat Protection" "%AllUsersProfile%\Microsoft\Windows Security Health" "%AllUsersProfile%\Microsoft\Storage Health" "%SystemDrive%\Program Files\Windows Defender" "%SystemDrive%\Program Files\Windows Defender Sleep" "%SystemDrive%\Program Files\Windows Defender Advanced Threat Protection" "%SystemDrive%\Program Files\Windows Security") do (
    if not exist "%%F" (
	del /f /q "%%F" >nul 2>&1
    )
)
