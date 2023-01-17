
$labFilesFolder = 'C:\AllFiles\Labs\03'
New-Item -ItemType Directory -Path $labFilesFolder

$webClient = New-Object System.Net.WebClient
$wvdAgentInstallerURL = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv'
$wvdAgentInstallerName = 'WVD-Agent.msi'
$webClient.DownloadFile($wvdAgentInstallerURL,"$labFilesFolder/$wvdAgentInstallerName")
$wvdBootLoaderInstallerURL = 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrxrH'
$wvdBootLoaderInstallerName = 'WVD-BootLoader.msi'
$webClient.DownloadFile($wvdBootLoaderInstallerURL,"$labFilesFolder/$wvdBootLoaderInstallerName")

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-Module -Name PowerShellGet -Force -SkipPublisherCheck

Install-Module -Name Az.DesktopVirtualization -AllowClobber -Force
Install-Module -Name Az -AllowClobber -Force

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force
Connect-AzAccount


$resourceGroupName = 'az140-11-RG'
$hostPoolName = 'az140-21-hp1'
$registrationInfo = New-AzWvdRegistrationInfo -ResourceGroupName $resourceGroupName -HostPoolName $hostPoolName -ExpirationTime $((get-date).ToUniversalTime().AddDays(1).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))
$registrationInfo
$registrationInfo.Token

Set-Location -Path $labFilesFolder
Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $WVDAgentInstallerName", "/quiet", "/qn", "/norestart", "/passive", "REGISTRATIONTOKEN=$($registrationInfo.Token)", "/l* $labFilesFolder\AgentInstall.log" | Wait-Process

Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $wvdBootLoaderInstallerName", "/quiet", "/qn", "/norestart", "/passive", "/l* $labFilesFolder\BootLoaderInstall.log" | Wait-process

Write-Host Lab Pre-requisite Task Completed Successfully -ForegroundColor Green

