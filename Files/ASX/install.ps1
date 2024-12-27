# Скачивание и запуск файла
$DownloadUrl = "https://github.com/ALFiX01/ASX-Hub/releases/download/Stable/ASX.Hub.exe"
$Destination = "$env:USERPROFILE\Desktop\ASX.Hub.exe"

Invoke-WebRequest -Uri $DownloadUrl -OutFile $Destination
Start-Process -FilePath $Destination
