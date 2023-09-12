#Copyrights CGI Demnark A/S
#See Source : https://stackoverflow.com/questions/63506725/using-powershell-to-download-file-from-private-github-repository-using-oauth
#Requires -RunAsAdministrator
    Clear-Host
    Set-Location $env:TEMP

    $TmpFileName    = [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName())
    $ScriptFileName = ("{0}.ps1" -f $TmpFileName)
    $LogFileName    = ("{0}.log" -f $TmpFileName)
    $ZipFileName    = ("{0}.zip" -f [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName()))
    $ZipFolder      = ("{0}"     -f [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName()))

    #Load Assembly
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

    #Dialog
    $d_token = [Microsoft.VisualBasic.Interaction]::InputBox("Github Token", "Enter your GitHub Token","<paste token here>") 
    $d_repo  = [Microsoft.VisualBasic.Interaction]::InputBox("Github repo", "Enter the name of the private GitHub Repository <User>/<repo>","<paste repo here>")
    $d_file  = [Microsoft.VisualBasic.Interaction]::InputBox("Run this file", "Enter the filename", 'Install.ps1')

    if (!$d_token -or !$d_repo -or !$d_file) {
        Write-Output ("Missing some info - aborting script")
        Start-Sleep -Seconds 5
        exit   
    }
    
    if (!($d_repo -match "[a-zA-Z0-9]\/[a-zA-Z0-9]" )) {
        Write-Output "Repo string is not valid please use <user>/<repo>"
        Start-Sleep -Seconds 5
        exit
    }
    
    # start a log
    Start-Transcript -Append -Path ("_{0}_{1}.log" -f $env:COMPUTERNAME,(Get-Date -format yyyyMMdd))
    
    New-item -Name $ScriptFileName -ItemType File -Force | Out-Null
    Add-Content -Path $ScriptFileName -Value ('Start-Transcript {0} -force' -f $LogFileName)
    Add-Content -Path $ScriptFileName -Value 'Invoke-Expression (new-object net.webclient).DownloadString("https://chocolatey.org/install.ps1") -WarningAction SilentlyContinue'
    Add-Content -Path $ScriptFileName -Value '$env:Path += ";%ALLUSERSPROFILE%\chocolatey\bin"'
    Add-Content -Path $ScriptFileName -Value 'choco install git -y -v -acceptlicens'
    Add-Content -Path $ScriptFileName -Value 'Set-Location $env:TEMP'
    Add-Content -Path $ScriptFileName -Value ('md {0}' -f $ZipFolder)
    Add-Content -Path $ScriptFileName -Value 'md gitrepo'
    Add-Content -Path $ScriptFileName -Value 'git config --global --add safe.directory $env:TEMP/gitrepo'
    Add-Content -Path $ScriptFileName -Value ('git clone --bare https://{0}:{1}@github.com/{2}.git gitrepo' -f $d_repo.split('/')[0], $d_token, $d_repo)
    Add-Content -Path $ScriptFileName -Value 'cd gitrepo'
    Add-Content -Path $ScriptFileName -Value 'git archive -o latest.zip HEAD'
    Add-Content -Path $ScriptFileName -Value ('Expand-Archive latest.zip -DestinationPath ..\{0}' -f $ZipFolder)
    Add-Content -Path $ScriptFileName -Value 'cd ..'
    Add-Content -Path $ScriptFileName -Value 'Remove-Item gitrepo -force -recurse -Confirm:$false -verbose'
    Add-Content -Path $ScriptFileName -Value 'Stop-Transcript'
    
    if (Test-Path -Path .\$ScriptFileName -PathType Leaf) {
        # Run Script file and remove it afterwards
        Write-Output ("1. Executing following file : {0} " -f $ScriptFileName)
        Start-Process "powershell.exe" -Verb runAs -ArgumentList ".\$ScriptFileName" -Wait
        Remove-Item .\$ScriptFileName -Force

        #Find the selected file in Zipfolder and Run the selected file
        $filename = Get-Childitem -Path $ZipFolder -Recurse |Where-Object {($_.name -eq $d_file)}| ForEach-Object{$_.FullName}
        If (Test-Path -Path $filename) {
            Write-Output ("2. Executing following file : {0} " -f $filename)            
            Start-Process "powershell" -Verb runAs -ArgumentList "$filename" -WindowStyle Normal -Wait
            Remove-item $filename -Force
        }

        # Cleaning up files
        Set-Location $env:TEMP
        Remove-item -Path $ZipFolder -Recurse -Force -Confirm:$false
    }

    Stop-Transcript

    Write-output "Closing session in 10 sec."
    Start-Sleep -Seconds 10
    exit
