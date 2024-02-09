@echo off
taskkill /f /im smartscreen.exe


cls
echo   %COL%[37m█ 1%
reg add "HKLM\System\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger" /v "Start" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\System\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger" /v "Start" /t REG_DWORD /d "0" /f >nul 2>&1

::Отключение Задач Windows Defender
cls
echo   %COL%[37m██ 3%
schtasks /Change /TN "Microsoft\Windows\ExploitGuard\ExploitGuard MDM policy Refresh" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cache Maintenance" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Cleanup" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Scheduled Scan" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Windows Defender\Windows Defender Verification" /Disable >nul 2>&1

rem Удаление Windows Defender из контекстного меню
cls
echo   %COL%[37m███ 8%
reg delete "HKCR\*\shellex\ContextMenuHandlers\EPP" /f >nul 2>&1
reg delete "HKCR\Directory\shellex\ContextMenuHandlers\EPP" /f >nul 2>&1
reg delete "HKCR\Drive\shellex\ContextMenuHandlers\EPP" /f >nul 2>&1

::Отключение фильтра SmartScreen в edge
cls
echo   %COL%[37m████ 12%
reg add "HKEY_CURRENT_USER\Software\Microsoft\Edge\SmartScreenEnabled" /ve /t REG_DWORD /d 1 /f >nul 2>&1

::Отключение уведомлений о необхожимости включить Win Defender
cls
echo   %COL%[37m█████ 14 
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows Defender Security Center\Notifications" /v "DisableNotifications" /t REG_DWORD /d "1" /f >nul 2>&1

rem Удаление Windows Defender и подключенных компонентов безопасности Windows
cls
echo   %COL%[37m██████ 17%
reg delete "HKCR\exefile\shell\WindowsFirewall" /f >nul 2>&1
reg delete "HKCR\DesktopBackground\Shell\Firewall" /f >nul 2>&1

rem Отключение Защитника Windows и компонентов безопасности
cls
echo   %COL%[37m███████ 20%
REM ; Disable Windows Defender Security Center Notifications
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\DisableEnhancedNotifications" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\DisableNotifications" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\HideWindowsSecurityNotificationAreaControl" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
REM ; Disable Windows Security Center Notifications
reg delete "HKLM\SOFTWARE\Microsoft\Security Center" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v "FirewallDisableNotify" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Security Center" /v "UpdatesDisableNotify" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" /v "DisableEnhancedNotifications" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Notifications" /v "DisableNotifications" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowIOAVProtection" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "PUAProtection" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "ServiceKeepAlive" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "AllowFastServiceStartup" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableLocalAdminMerge" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v "RandomizeScheduleTaskTimes" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowArchiveScanning" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowBehaviorMonitoring" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowCloudProtection" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowEmailScanning" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowFullScanOnMappedNetworkDrives" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowFullScanRemovableDriveScanning" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowIntrusionPreventionSystem" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowOnAccessProtection" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowRealtimeMonitoring" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowScanningNetworkFiles" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowScriptScanning" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowUserUIAccess" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AvgCPULoadFactor" /v "value" /t REG_DWORD /d "50" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\CheckForSignaturesBeforeRunningScan" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\CloudBlockLevel" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\CloudExtendedTimeout" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\DaysToRetainCleanedMalware" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\DisableCatchupFullScan" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\DisableCatchupQuickScan" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\EnableControlledFolderAccess" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\EnableLowCPUPriority" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\EnableNetworkProtection" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\PUAProtection" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\RealTimeScanDirection" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\ScanParameter" /v "value" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\ScheduleScanDay" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\ScheduleScanTime" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\SignatureUpdateInterval" /v "value" /t REG_DWORD /d "24" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\SubmitSamplesConsent" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions" /v "DisableAutoExclusions" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" /v "MpEnablePus" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" /v "MpCloudBlockLevel" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" /v "MpBafsExtendedTimeout" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\MpEngine" /v "EnableFileHashComputation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\NIS\Consumers\IPS" /v "ThrottleDetectionEventsRate" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\NIS\Consumers\IPS" /v "DisableSignatureRetirement" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\NIS\Consumers\IPS" /v "DisableProtocolRecognition" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Policy Manager" /v "DisableScanningNetworkFiles" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRealtimeMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableBehaviorMonitoring" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableOnAccessProtection" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableScanOnRealtimeEnable" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIOAVProtection" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "LocalSettingOverrideDisableOnAccessProtection" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "LocalSettingOverrideRealtimeScanDirection" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "LocalSettingOverrideDisableIOAVProtection" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "LocalSettingOverrideDisableBehaviorMonitoring" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "LocalSettingOverrideDisableIntrusionPreventionSystem" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "LocalSettingOverrideDisableRealtimeMonitoring" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "RealtimeScanDirection" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "IOAVMaxSize" /t REG_DWORD /d "1298" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableInformationProtectionControl" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableIntrusionPreventionSystem" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v "DisableRawWriteNotification" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "LowCpuPriority" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableRestorePoint" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableArchiveScanning" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableScanningNetworkFiles" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableCatchupFullScan" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableCatchupQuickScan" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableEmailScanning" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableHeuristics" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableReparsePointScanning" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "SignatureDisableNotification" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "RealtimeSignatureDelivery" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ForceUpdateFromMU" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "DisableScheduledSignatureUpdateOnBattery" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "UpdateOnStartUp" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "SignatureUpdateCatchupInterval" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "DisableUpdateOnStartupWithoutEngine" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "ScheduleTime" /t REG_DWORD /d "5184" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates" /v "DisableScanOnUpdate" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "DisableBlockAtFirstSeen" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "LocalSettingOverrideSpynetReporting" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SpynetReporting" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v "SubmitSamplesConsent" /t REG_DWORD /d "2" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\UX Configuration" /v "SuppressRebootNotification" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Controlled Folder Access" /v "EnableControlledFolderAccess" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection" /v "EnableNetworkProtection" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\WOW6432Node\Policies\Microsoft\Windows Defender" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Microsoft Antimalware" /v "ServiceKeepAlive" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Microsoft Antimalware" /v "AllowFastServiceStartup" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Microsoft Antimalware" /v "DisableRoutinelyTakingAction" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Microsoft Antimalware" /v "DisableAntiSpyware" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Microsoft Antimalware" /v "DisableAntiVirus" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Microsoft Antimalware\SpyNet" /v "SpyNetReporting" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Microsoft Antimalware\SpyNet" /v "LocalSettingOverrideSpyNetReporting" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableEnhancedNotifications" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "DisableGenericRePorts" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "WppTracingLevel" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Reporting" /v "WppTracingComponents" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy" /v "VerifiedAndReputablePolicyState" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "RunAsPPL" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "restrictanonymous" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "everyoneincludesanonymous" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "restrictanonymoussam" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "SCENoApplyLegacyAuditPolicy" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "TurnOffAnonymousBlock" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "LsaConfigFlags" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "RunAsPPL" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v "RunAsPPLBoot" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v "VulnerableDriverBlocklistEnable" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v "EnabledV9" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.microsoftedge_8wekyb3d8bbwe\MicrosoftEdge\PhishingFilter" /v "PreventOverride" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Edge" /v "SmartScreenEnabled" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Edge\SmartScreenEnabled" /ve /t REG_DWORD /d "0" /f >nul 2>&1
REM ; disable SmartScreen in File Explorer and Windows Shell
cls
echo   %COL%[37m████████ 40%
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "SmartScreenEnabled" /t REG_SZ /d "off" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableSmartScreen" /t REG_DWORD /d "0" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "ShellSmartScreenLevel" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Browser\AllowSmartScreen" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\SmartScreen\EnableSmartScreenInShell" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\SmartScreen\EnableAppInstallControl" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\SmartScreen\PreventOverrideForFilesInShell" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
REM ;disable SmartScreen for Microsoft Store Apps
cls
echo   %COL%[37m████████ 42%
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" /v "EnableWebContentEvaluation" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost" /v "PreventOverride" /t REG_DWORD /d "0" /f >nul 2>&1
REM ; Configure App Install Control
cls
echo   %COL%[37m█████████ 43%
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControlEnabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen" /v "ConfigureAppInstallControl" /t REG_SZ /d "Anywhere" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\WindowsMitigation" /v "UserPreference" /t REG_DWORD /d "2" /f
REM ;In-kernel Mitigations
cls
echo   %COL%[37m██████████ 45%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationAuditOptions" /t REG_BINARY /d "000000000000202200000000000000200000000000000000" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /t REG_BINARY /d "002222202220222220000000002000200000000000000000" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "KernelSEHOPEnabled" /t REG_DWORD /d "0" /f
REM ; Disable Spectre & Meltdown Mitigations
cls
echo   %COL%[37m███████████ 47%
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettings" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d "3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d "3" /f >nul 2>&1
REM ;Services Mitigations
REM ; Remove Defender's Tamper Protection
cls
echo   %COL%[37m████████████ 50%
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "MpPlatformKillbitsFromEngine" /t REG_BINARY /d "0000000000000000" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtectionSource" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "MpCapability" /t REG_BINARY /d "0000000000000000" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v "TamperProtection" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\DisableAccountProtectionUI" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device performance and health" /v "UILockdown" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Device security" /v "UILockdown" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\DisableAccountProtectionUI" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\DisableAppBrowserUI" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\DisableClearTpmButton" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\DisableDeviceSecurityUI" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\DisableFamilyUI" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\DisableHealthUI" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\DisableTpmFirmwareUpdateWarning" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\DisableVirusUI" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\DisallowExploitProtectionOverride" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\EnableCustomizedToasts" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\EnableInAppCustomization" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\HideRansomwareDataRecovery" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\HideSecureBoot" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WindowsDefenderSecurityCenter\HideTPMTroubleshooting" /v "value" /t REG_DWORD /d "1" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsRuntime\Server\WebThreatDefSvc" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\webthreatdefsvc" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\webthreatdefusersvc" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost\WebThreatDefense" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost" /v "WebThreatDefense" /f >nul 2>&1
REM ; From Disabler
cls
echo   %COL%[37m█████████████ 60%
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WebThreatDefense" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WebThreatDefense\AuditMode" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WebThreatDefense\NotifyUnsafeOrReusedPassword" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WebThreatDefense\ServiceEnabled" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WTDS" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components" /v "NotifyPasswordReuse" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WTDS\Components" /v "NotifyMalicious" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WebThreatDefense\AuditMode" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WebThreatDefense\NotifyUnsafeOrReusedPassword" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\WebThreatDefense\ServiceEnabled" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\webthreatdefsvc" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\webthreatdefusersvc" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost\WebThreatDefense" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost" /v "WebThreatDefense" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Svchost" /f >nul 2>&1
reg delete "HKCR\AppX1sy7rwrc20ggq97a6x1mgmjat0rthy51" /f >nul 2>&1
reg delete "HKCR\AppXb5yxv86nkhp530y0y50yxe69c1qwad1x" /f >nul 2>&1
reg delete "HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage\microsoft.sechealthui_8wekyb3d8bbwe" /f >nul 2>&1
reg delete "HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\PackageRepository\Extensions\ProgIDs\AppX1sy7rwrc20ggq97a6x1mgmjat0rthy51" /f >nul 2>&1
reg delete "HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\PackageRepository\Extensions\ProgIDs\AppXb5yxv86nkhp530y0y50yxe69c1qwad1x" /f >nul 2>&1
reg delete "HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\PackageRepository\Extensions\windows.fileTypeAssociation\.all\AppXb5yxv86nkhp530y0y50yxe69c1qwad1x" /f >nul 2>&1
reg delete "HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\PackageRepository\Extensions\windows.protocol\windowsdefender\AppX1sy7rwrc20ggq97a6x1mgmjat0rthy51d" /f >nul 2>&1
reg delete "HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\PolicyCache\Microsoft.SecHealthUI_8wekyb3d8bbwe" /f >nul 2>&1
reg delete "HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\Microsoft.SecHealthUI_8wekyb3d8bbwe" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\MrtCache\C:%%5CWindows%%5CSystemApps%%5CMicrosoft.Windows.AppRep.ChxApp_cw5n1h2txyewy%%5Cresources.pri" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\PackageRepository\Extensions\windows.protocol\windowsdefender" /f >nul 2>&1
reg delete "HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\PackageRepository\Extensions\windows.protocol\windowsdefender" /f >nul 2>&1
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{2781761E-28E0-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{2781761E-28E2-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{195B4D07-3DE2-4744-BBF2-D90121AE785B}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{361290c0-cb1b-49ae-9f3e-ba1cbe5dab35}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{45F2C32F-ED16-4C94-8493-D72EF93A051B}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{6CED0DAA-4CDE-49C9-BA3A-AE163DC3D7AF}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{8a696d12-576b-422e-9712-01b9dd84b446}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{8C9C0DB7-2CBA-40F1-AFE0-C55740DD91A0}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{A2D75874-6750-4931-94C1-C99D3BC9D0C7}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{A7C452EF-8E9F-42EB-9F2B-245613CA0DC9}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{DACA056E-216A-4FD1-84A6-C306A017ECEC}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{E3C9166D-1D39-4D4E-A45D-BC7BE9B00578}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\WOW6432Node\CLSID\{F6976CF5-68A8-436C-975A-40BE53616D59}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{2781761E-28E0-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{2781761E-28E2-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{195B4D07-3DE2-4744-BBF2-D90121AE785B}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{361290c0-cb1b-49ae-9f3e-ba1cbe5dab35}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{45F2C32F-ED16-4C94-8493-D72EF93A051B}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{6CED0DAA-4CDE-49C9-BA3A-AE163DC3D7AF}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{8a696d12-576b-422e-9712-01b9dd84b446}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{8C9C0DB7-2CBA-40F1-AFE0-C55740DD91A0}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{A2D75874-6750-4931-94C1-C99D3BC9D0C7}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{A7C452EF-8E9F-42EB-9F2B-245613CA0DC9}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{DACA056E-216A-4FD1-84A6-C306A017ECEC}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{E3C9166D-1D39-4D4E-A45D-BC7BE9B00578}" /f >nul 2>&1
reg delete "HKLM\Software\Classes\CLSID\{F6976CF5-68A8-436C-975A-40BE53616D59}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{2781761E-28E0-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{2781761E-28E2-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{195B4D07-3DE2-4744-BBF2-D90121AE785B}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{361290c0-cb1b-49ae-9f3e-ba1cbe5dab35}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{45F2C32F-ED16-4C94-8493-D72EF93A051B}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{6CED0DAA-4CDE-49C9-BA3A-AE163DC3D7AF}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{8a696d12-576b-422e-9712-01b9dd84b446}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{8C9C0DB7-2CBA-40F1-AFE0-C55740DD91A0}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{A2D75874-6750-4931-94C1-C99D3BC9D0C7}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{A7C452EF-8E9F-42EB-9F2B-245613CA0DC9}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{DACA056E-216A-4FD1-84A6-C306A017ECEC}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{E3C9166D-1D39-4D4E-A45D-BC7BE9B00578}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{F6976CF5-68A8-436C-975A-40BE53616D59}" /f >nul 2>&1
reg delete "HKCR\CLSID\{2781761E-28E0-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKCR\CLSID\{2781761E-28E2-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKCR\CLSID\{195B4D07-3DE2-4744-BBF2-D90121AE785B}" /f >nul 2>&1
reg delete "HKCR\CLSID\{361290c0-cb1b-49ae-9f3e-ba1cbe5dab35}" /f >nul 2>&1
reg delete "HKCR\CLSID\{45F2C32F-ED16-4C94-8493-D72EF93A051B}" /f >nul 2>&1
reg delete "HKCR\CLSID\{6CED0DAA-4CDE-49C9-BA3A-AE163DC3D7AF}" /f >nul 2>&1
reg delete "HKCR\CLSID\{8a696d12-576b-422e-9712-01b9dd84b446}" /f >nul 2>&1
reg delete "HKCR\CLSID\{8C9C0DB7-2CBA-40F1-AFE0-C55740DD91A0}" /f >nul 2>&1
reg delete "HKCR\CLSID\{A2D75874-6750-4931-94C1-C99D3BC9D0C7}" /f >nul 2>&1
reg delete "HKCR\CLSID\{A7C452EF-8E9F-42EB-9F2B-245613CA0DC9}" /f >nul 2>&1
reg delete "HKCR\CLSID\{DACA056E-216A-4FD1-84A6-C306A017ECEC}" /f >nul 2>&1
reg delete "HKCR\CLSID\{E3C9166D-1D39-4D4E-A45D-BC7BE9B00578}" /f >nul 2>&1
reg delete "HKCR\CLSID\{F6976CF5-68A8-436C-975A-40BE53616D59}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\MitigationOptions" /v "MitigationOptions_FontBocking" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\MitigationOptions" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v "DisableScanningMappedNetworkDrivesForFullScan" /f >nul 2>&1
REM ; Defender Loggers
cls
echo   %COL%[37m██████████████ 70% 
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderAuditLogger" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DefenderApiLogger" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\Defender\AllowIOAVProtection" /v "value" /t REG_DWORD /d "0" /f >nul 2>&1
reg delete "HKCR\CLSID\{05F3561D-0358-4687-8ACD-A34D24C488DF}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{05F3561D-0358-4687-8ACD-A34D24C488DF}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{05F3561D-0358-4687-8ACD-A34D24C488DF}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{05F3561D-0358-4687-8ACD-A34D24C488DF}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\AppUserModelId\Windows.Defender.SecurityCenter" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup\Windows.Defender.SecurityCenter" /f >nul 2>&1
reg delete "HKCR\AppUserModelId\Windows.SystemToast.SecurityAndMaintenance" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.SecurityCenter.SecurityAppBroker" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.SecurityCenter.WscBrokerManager" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.SecurityCenter.WscCloudBackupProvider" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Windows.SecurityCenter.WscDataProtection" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Security Center\Provider\Av" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Security Center\Provider\SecurityApp" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\QuietHours\AlwaysAllowedApps" /v "WindowsSecurity" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\QuietHours\AlwaysAllowedApps" /v "WindowsSystemToastSecurity" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\QuietHours\AlwaysAllowedApps" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\ImmutableMuiCache\Strings\52C64B7E" /v "@C:\WINDOWS\System32\ActionCenterCPL.dll,-1#immutable1" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\ImmutableMuiCache\Strings\52C64B7E" /v "@C:\WINDOWS\System32\ActionCenterCPL.dll,-2#immutable1" /f >nul 2>&1
reg add "HKCU\Software\Classes\Local Settings\ImmutableMuiCache\Strings\52C64B7E" /f >nul 2>&1
reg delete "HKCU\Software\Classes\Local Settings\MuiCache\6\52C64B7E" /v "@ActionCenterCPL.dll,-1" /f >nul 2>&1
reg add "HKCU\Software\Classes\Local Settings\MuiCache\6\52C64B7E" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{01afc156-f2eb-4c1c-a722-8550417d396f}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{a3b3c46c-05d8-429b-bf66-87068b4ce563}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{F56F6FDD-AA9D-4618-A949-C1B91AF43B1A}" /f >nul 2>&1
reg delete "HKCR\CLSID\{a3b3c46c-05d8-429b-bf66-87068b4ce563}" /f >nul 2>&1
reg delete "HKCR\CLSID\{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}" /f >nul 2>&1
reg delete "HKCR\CLSID\{F56F6FDD-AA9D-4618-A949-C1B91AF43B1A}" /f >nul 2>&1
reg delete "HKCR\CLSID\{01afc156-f2eb-4c1c-a722-8550417d396f}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{01afc156-f2eb-4c1c-a722-8550417d396f}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{a3b3c46c-05d8-429b-bf66-87068b4ce563}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{F56F6FDD-AA9D-4618-A949-C1B91AF43B1A}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{01afc156-f2eb-4c1c-a722-8550417d396f}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{a3b3c46c-05d8-429b-bf66-87068b4ce563}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{F56F6FDD-AA9D-4618-A949-C1B91AF43B1A}" /f >nul 2>&1
REM ;remove Security Center and Maintenance from Control Panel
cls
echo   %COL%[37m███████████████ 78%
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}" /f >nul 2>&1
reg delete "HKCR\Local Settings\ImmutableMuiCache\Strings\52C64B7E" /v "@C:\WINDOWS\System32\ActionCenterCPL.dll,-1#immutable1" /f >nul 2>&1
reg delete "HKCR\Local Settings\ImmutableMuiCache\Strings\52C64B7E" /v "@C:\WINDOWS\System32\ActionCenterCPL.dll,-2#immutable1" /f >nul 2>&1
reg add "HKCR\Local Settings\ImmutableMuiCache\Strings\52C64B7E" /f >nul 2>&1
reg delete "HKCR\Local Settings\MuiCache\6\52C64B7E" /v "@ActionCenterCPL.dll,-1" /f >nul 2>&1
reg add "HKCR\Local Settings\MuiCache\6\52C64B7E" /f >nul 2>&1
reg delete "HKCR\CLSID\{01afc156-f2eb-4c1c-a722-8550417d396f}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\AppID\{7eaae8b9-e33f-4b4f-bb40-9ada6beec764}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\AppID\{97a3a7e6-bb30-46b4-ae18-76729fa5ab56}" /f >nul 2>&1
reg delete "HKCR\AppID\{7eaae8b9-e33f-4b4f-bb40-9ada6beec764}" /f >nul 2>&1
reg delete "HKCR\AppID\{97a3a7e6-bb30-46b4-ae18-76729fa5ab56}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\AppID\{2781761E-28E2-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKCR\AppID\{2781761E-28E2-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{2781761E-28E2-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{2781761E-28E2-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKCR\CLSID\{2781761E-28E2-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{2781761E-28E2-4109-99FE-B9D127C57AFE}" /f >nul 2>&1
reg delete "HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\PackageRepository\Extensions\windows.fileTypeAssociation\.all\AppXb5yxv86nkhp530y0y50yxe69c1qwad1x" /f >nul 2>&1
reg add "HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\PackageRepository\Extensions\ProgIDs\AppXb5yxv86nkhp530y0y50yxe69c1qwad1x" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks\{0ACC9108-2000-46C0-8407-5FD9F89521E8}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks\{1D77BCC8-1D07-42D0-8C89-3A98674DFB6F}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks\{4A9233DB-A7D3-45D6-B476-8C7D8DF73EB5}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks\{B05F34EE-83F2-413D-BC1D-7D5BD6E98300}" /f >nul 2>&1
reg delete "HKCR\CLSID\{01afc156-f2eb-4c1c-a722-8550417d396f}" /f >nul 2>&1
reg delete "HKCR\CLSID\{a3b3c46c-05d8-429b-bf66-87068b4ce563}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{01afc156-f2eb-4c1c-a722-8550417d396f}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{a3b3c46c-05d8-429b-bf66-87068b4ce563}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{01afc156-f2eb-4c1c-a722-8550417d396f}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{a3b3c46c-05d8-429b-bf66-87068b4ce563}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{01afc156-f2eb-4c1c-a722-8550417d396f}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{a3b3c46c-05d8-429b-bf66-87068b4ce563}" /f >nul 2>&1
reg delete "HKCR\CLSID\{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}" /f >nul 2>&1
reg delete "HKCR\CLSID\{F56F6FDD-AA9D-4618-A949-C1B91AF43B1A}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{F56F6FDD-AA9D-4618-A949-C1B91AF43B1A}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{F56F6FDD-AA9D-4618-A949-C1B91AF43B1A}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{BB64F8A7-BEE7-4E1A-AB8D-7D8273F7FDB6}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{F56F6FDD-AA9D-4618-A949-C1B91AF43B1A}" /f >nul 2>&1
REM ; Remove Defender and Windows Security Services
cls
echo   %COL%[37m████████████████ 85%
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\MsSecCore" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\wscsvc" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WdNisDrv" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WdNisSvc" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WdFiltrer" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WdBoot" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SecurityHealthService" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SgrmAgent" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SgrmBroker" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\WinDefend" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" /v "DisallowExploitProtectionOverride" /t REG_DWORD /d "1" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\windowsdefender" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\AppUserModelId\Windows.Defender" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\AppUserModelId\Microsoft.Windows.Defender" /f >nul 2>&1
reg delete "HKCR\AppX9kvz3rdv8t7twanaezbwfcdgrbg3bck0" /f >nul 2>&1
reg delete "HKCU\Software\Classes\ms-cxh" /f >nul 2>&1
reg delete "HKCR\Local Settings\MrtCache\C:%%5CWindows%%5CSystemApps%%5CMicrosoft.Windows.AppRep.ChxApp_cw5n1h2txyewy%%5Cresources.pri" /f >nul 2>&1
reg delete "HKCR\WindowsDefender" /f >nul 2>&1
reg delete "HKCU\Software\Classes\AppX9kvz3rdv8t7twanaezbwfcdgrbg3bck0" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\WindowsDefender" /f >nul 2>&1
reg delete "HKLM\SYSTEM\ControlSet001\Control\Ubpm" /v "CriticalMaintenance_DefenderCleanup" /f >nul 2>&1
reg delete "HKLM\SYSTEM\ControlSet001\Control\Ubpm" /v "CriticalMaintenance_DefenderVerification" /f >nul 2>&1
reg add "HKLM\SYSTEM\ControlSet001\Control\Ubpm" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Ubpm" /v "CriticalMaintenance_DefenderCleanup" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Ubpm" /v "CriticalMaintenance_DefenderVerification" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Ubpm" /f >nul 2>&1
reg delete "HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-1" /f >nul 2>&1
reg delete "HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-2" /f >nul 2>&1
reg delete "HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-3" /f >nul 2>&1
reg add "HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-1" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-2" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WindowsDefender-3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "Windows Defender" /f >nul 2>&1
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "Windows Defender" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /v "SecurityHealth" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "WindowsDefender" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "SecurityHealth" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_In" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Allow_Out" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_In" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /v "WebThreatDefSvc_Block_Out" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Configurable\System" /v "{2A5FE97D-01A4-4A9C-8241-BB3755B65EE0}" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Configurable\System" /v "72e33e44-dc4c-40c5-a688-a77b6e988c69" /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Configurable\System" /v "b23879b5-1ef3-45b7-8933-554a4303d2f3" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Configurable\System" /f >nul 2>&1
reg delete "HKCR\CLSID\{E48B2549-D510-4A76-8A5F-FC126A6215F0}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{E48B2549-D510-4A76-8A5F-FC126A6215F0}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{E48B2549-D510-4A76-8A5F-FC126A6215F0}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{E48B2549-D510-4A76-8A5F-FC126A6215F0}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.OneCore.WebThreatDefense.Service.UserSessionServiceManager" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.OneCore.WebThreatDefense.ThreatExperienceManager.ThreatExperienceManager" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.OneCore.WebThreatDefense.ThreatResponseEngine.ThreatDecisionEngine" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.OneCore.WebThreatDefense.Configuration.WTDUserSettings" /f >nul 2>&1
reg delete "HKCR\CLSID\{E48B2549-D510-4A76-8A5F-FC126A6215F0}" /f >nul 2>&1
reg delete "HKCR\WOW6432Node\CLSID\{E48B2549-D510-4A76-8A5F-FC126A6215F0}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\CLSID\{E48B2549-D510-4A76-8A5F-FC126A6215F0}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Classes\WOW6432Node\CLSID\{E48B2549-D510-4A76-8A5F-FC126A6215F0}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.OneCore.WebThreatDefense.Service.UserSessionServiceManager" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.OneCore.WebThreatDefense.ThreatExperienceManager.ThreatExperienceManager" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.OneCore.WebThreatDefense.ThreatResponseEngine.ThreatDecisionEngine" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.OneCore.WebThreatDefense.Configuration.WTDUserSettings" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects\{900c0763-5cad-4a34-bc1f-40cd513679d5}" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ShellServiceObjects\{900c0763-5cad-4a34-bc1f-40cd513679d5}" /f >nul 2>&1
REM ; Remove Scan with Defender Context Menu...
cls
echo   %COL%[37m█████████████████ 95%
reg delete "HKLM\SOFTWARE\Microsoft\Windows Defender" /f >nul 2>&1
reg delete "HKCR\Folder\shell\WindowsDefender" /f >nul 2>&1
reg delete "HKCR\DesktopBackground\Shell\WindowsSecurity" /f >nul 2>&1
reg delete "HKCR\Folder\shell\WindowsDefender\Command" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Microsoft\Windows Security Health" /f >nul 2>&1
reg delete "HKCU\Software\Microsoft\Windows Security Health" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows Security Health\State" /v "Disabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Security Health\Platform" /v "Registered" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Security Health\Health Advisor" /v "UIReportingDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Security Health\Health Advisor\Battery" /v "UIReportingDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Security Health\Health Advisor\Device Driver" /v "UIReportingDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Security Health\Health Advisor\Reliability" /v "UIReportingDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Security Health\Health Advisor\Status Codes" /v "UIReportingDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Security Health\Health Advisor\Storage Health" /v "UIReportingDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Security Health\Health Advisor\Storage Health Metrics" /v "UIReportingDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Security Health\Health Advisor\Time Service" /v "UIReportingDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows Security Health\Health Advisor\Update Monitor" /v "UIReportingDisabled" /t REG_DWORD /d "1" /f >nul 2>&1
cls
echo   %COL%[37m█████████████████ 95%
REM ; Remove Data...
rmdir /s /q "%AllUsersProfile%\Microsoft\Windows Defender" >nul 2>&1
rmdir /s /q "%AllUsersProfile%\Microsoft\Windows Defender Advanced Threat Protection" >nul 2>&1
rmdir /s /q "%AllUsersProfile%\Microsoft\Windows Security Health" >nul 2>&1
rmdir /s /q "%AllUsersProfile%\Microsoft\Storage Health" >nul 2>&1
rem SystemDrive - Program Files
rmdir /s /q "%SystemDrive%\Program Files\Windows Defender" >nul 2>&1
rmdir /s /q "%SystemDrive%\Program Files\Windows Defender Sleep" >nul 2>&1
rmdir /s /q "%SystemDrive%\Program Files\Windows Defender Advanced Threat Protection" >nul 2>&1
rmdir /s /q "%SystemDrive%\Program Files\Windows Security" >nul 2>&1
rmdir /s /q "%SystemDrive%\Program Files\PCHealthCheck" >nul 2>&1
rmdir /s /q "%SystemDrive%\Program Files\Microsoft Update Health Tools" >nul 2>&1


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
cls
echo   %COL%[37m██████████████████ 100%