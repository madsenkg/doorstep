#Copyrights CGI Demnark A/S
#See Source : https://stackoverflow.com/questions/63506725/using-powershell-to-download-file-from-private-github-repository-using-oauth
#Requires -RunAsAdministrator
# Switch to keep files
[CmdletBinding()]
    param(
        [switch]$keepfiles
    )

# Start
Clear-Host
    
if ($keepfiles.IsPresent) {
    Write-output "keepfiles is ON!"
}

# Making sure .NET 4.8.x is installed
$RequiredDotNetVersion = 4.8
$DotNetVersion = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name version -EA 0 | Where-Object { $_.PSChildName -Match '^(?!S)\p{L}'} | Select-Object PSChildName, version
$Latestversion = $DotNetVersion | Measure-Object -Property version -Maximum

if ($Latestversion.Maximum -gt $RequiredDotNetVersion) {
    Write-output ".NET version is good !"
    $DotNetVersion
    Write-output "----------------------"
    
    # Create Tmp folder for the script
    $TmpFolder = ("C:\Temp\{0}.tmp" -f [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName()))
    New-Item -Path $TmpFolder -ItemType "directory" -Force -Confirm:$false | Out-Null
    Set-Location $TmpFolder

    # Start a log
    Start-Transcript -Append -Path ("_{0}_{1}.log" -f $env:COMPUTERNAME,(Get-Date -format yyyyMMdd))
    Write-output ("Temp-folder is : {0}" -f $TmpFolder)
    
    # Set filenames
    $TmpFileName    = [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName())
    $ScriptFileName = ("{0}.ps1" -f $TmpFileName)
    $LogFileName    = ("{0}.log" -f $TmpFileName)
    $ZipFileName    = ("{0}.zip" -f [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName()))

    #Load Assembly for dialog
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

    #Dialog
    $d_token = [Microsoft.VisualBasic.Interaction]::InputBox("Github Token", "Enter your GitHub Token","<paste token here>") 
    # Testing if any token value is entered
    if ([string]::IsNullOrEmpty($d_token)) {
        exit
    }
    
    $d_repo  = [Microsoft.VisualBasic.Interaction]::InputBox("Github repo", "Enter the name of the private GitHub Repository <User>/<repo>","<paste repo here>")
    # Testing format of repo
    If ([string]::IsNullOrEmpty($d_repo)) {
        if (!($d_repo -match "[a-zA-Z0-9]\/[a-zA-Z0-9]" )) {
            Write-Output "Repo string is not valid please use <user>/<repo>"
            Start-Sleep -Seconds 5
        }
        exit
    }    

    $d_file  = [Microsoft.VisualBasic.Interaction]::InputBox("Run this file", "Enter the filename", 'Install.ps1')
    # Testing format of file
    if ([string]::IsNullOrEmpty($d_file)) {
        if (!($d_file -match "[a-zA-Z0-9].ps1" )) {
            Write-Output "file string is not valid please use <filename>.ps1"
            Start-Sleep -Seconds 5
        }            
        exit
    }
    
    Write-output "Validation - OK !"

    # Install module NuGet or PowerShellGet
    Install-PackageProvider -Name NuGet -Scope CurrentUser -Confirm:$false -Force -ErrorVariable errstat -ErrorAction SilentlyContinue
    if ($errstat) {
        Install-Module PowershellGet -Force -Confirm:$false        
    }
    
    # Install Chocolatey and git then refresh environment
    Write-output "Installing Chocolatey and GIT... please wait !"
    Invoke-Expression (new-object net.webclient).DownloadString("https://chocolatey.org/install.ps1") -WarningAction SilentlyContinue
    $env:Path += ";%PROGRAMDATA%\chocolatey\bin"
    choco install git -y -v -acceptlicens
    Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
    refreshenv
    
    # Creating script 
    Write-output "Now creating script..."
    $GitUrl = ("https://{0}:{1}@github.com/{2}.git" -f $d_repo.split('/')[0], $d_token, $d_repo)
    $fileContent = 
@"
Start-Transcript $LogFileName -force
Set-Location $TmpFolder
md zipfolder
md gitrepo
git config --global --add safe.directory $TmpFolder/gitrepo
git clone --bare $GitUrl gitrepo
cd gitrepo
git archive -o $ZipFileName HEAD
Expand-Archive $ZipFileName -DestinationPath ..\zipfolder
cd ..
Remove-Item gitrepo -force -recurse -Confirm:`$false -verbose
Stop-Transcript
"@
  
    Set-Content -Path $ScriptFileName -Value $fileContent
    
    # loop for 3 sek 3 times to make sure file is created
    if (!$ScriptFileName) {
        $maxAttempts = 3
        $retryIntervalSeconds = 3
        $attempts = 0
    
        if ($ScriptFileName) {
            while ($attempts -lt $maxAttempts) {
                if (Test-Path -Path $ScriptFileName -PathType Leaf) {
                    break
                } else {
                    $attempts++
                    Write-Host "File does not exist. Retry $attempts of $maxAttempts..."
                    Start-Sleep -Seconds $retryIntervalSeconds
                }
            }
            
            if ($attempts -eq $maxAttempts) {
                Write-Host "Max attempts reached. File not found. Please restart the script."
            }
        } else {
            Write-Host "Something went wrong - please run script again !"
        }
    }
    
    # Check if script file exists
    if (Test-Path -Path $ScriptFileName -PathType Leaf) {
        # Run Script file and remove it afterwards
        Write-Output ("1. Running script : {0} " -f $ScriptFileName)
        Start-Process "powershell.exe" -Verb runAs -ArgumentList .\$ScriptFileName -WindowStyle Normal -Wait
        
        if (!$keepfiles.isPresent) {
            Remove-Item .\$ScriptFileName -Force -Confirm:$false
        }            

        #Find the selected file in Zipfolder and Run the selected file
        $filename = Get-Childitem -Path .\zipfolder -Recurse | Where-Object {($_.name -eq $d_file)} | ForEach-Object{$_.FullName}
        # Find 
        Write-Output ("2. Trying to find the file : {0} " -f $d_file)
        If (Test-Path $filename -PathType Leaf) {
            Write-Output ("3. Executing script : {0} " -f $filename)
            Start-Process "powershell.exe" -Verb runAs -ArgumentList $filename -WindowStyle Normal -Wait
        }
        else {
            Write-Output ("3. Can't find script : {0} " -f $filename)
        }
        
        if (!$keepfiles.isPresent) {
            # Cleaning up files
            Remove-item .\zipfolder -Recurse -Force -Confirm:$false
        }            
    }

} else {
    Write-Output "-- REQUIRED INSTALLATION OF .NET 4.8 - Start Installing --"
    Write-Output "-- THIS MIGHT TAKE A MOMENT - PLEASE WAIT 5 min or more --"
    $DotNetVersion
    Write-Output "----------------------------------------------------------"
    Write-Output "-- Download and install the .NET 4.8 Package -------------"
    Write-Output "----------------------------------------------------------"
    Write-Output "-- After the install - It is required to restart the vm --"
    Invoke-WebRequest https://go.microsoft.com/fwlink/?linkid=2088631 -OutFile $env:temp\dotnet.4.8.exe
    Start-Process $env:temp\dotnet.4.8.exe -ArgumentList "/norestart /passive" -Wait
    Write-Output "----------------------------------------------------------"
    Write-Output "              ... Restarting in soon  ...                 "
    Uninstall-AzureRm -Force -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
    Write-Output "----------------------------------------------------------"
    Write-Output "** !!! PLEASE rerun the script again after restart. !!! **"
    Write-Output "----------------------------------------------------------"
    Start-Sleep -Seconds 10
    Restart-Computer -Force 
}

Stop-Transcript
cd..
exit
