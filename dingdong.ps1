#Copyrights CGI Demnark A/S
#See Source : https://stackoverflow.com/questions/63506725/using-powershell-to-download-file-from-private-github-repository-using-oauth
#Requires -RunAsAdministrator
    Clear-Host
    Set-Location $env:TEMP

    $ScriptFileName = ("{0}.ps1" -f [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName()))
    $ZipFileName    = ("{0}.zip" -f [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName()))
    $ZipFolder      = ("{0}"     -f [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName()))

    if (!$ScriptFileName -or !$ZipFileName -or !$ZipFolder) {
        Write-Output ("Missing info - aborting script")
        Start-Sleep -Seconds 5
        exit   
    }

    #Load Assembly
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

    #Dialog
    $d_credentials = [Microsoft.VisualBasic.Interaction]::InputBox("Github Token", "Enter your GitHub Token","<paste token here>")
    $d_repo        = [Microsoft.VisualBasic.Interaction]::InputBox("Github repo", "Enter the name of the private GitHub Repo <User/Repo>","<paste repo here>")
    $d_file        = [Microsoft.VisualBasic.Interaction]::InputBox("Run this file", "Enter the filename", "Install.ps1")

    # start a log
    Start-Transcript -Append -Path ("{0}_{1}.log" -f $env:COMPUTERNAME,(Get-Date -format yyyyMMdd))

    New-item -Name $ScriptFileName -ItemType File -Force | Out-Null
    Add-Content -Path $ScriptFileName -Value 'Set-Location $env:TEMP'
    Add-Content -Path $ScriptFileName -Value '$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"'
    Add-Content -Path $ScriptFileName -Value ('$headers.Add("Authorization", "Bearer {0}")' -f $d_credentials)
    Add-Content -Path $ScriptFileName -Value '$headers.Add("Accept", "application/vnd.github+json")'
    Add-Content -Path $ScriptFileName -Value ('$download = "https://api.github.com/repos/{0}/zipball"' -f $d_repo)
    Add-Content -Path $ScriptFileName -Value ('Invoke-RestMethod -Uri $download -Headers $headers -Method Get -OutFile {0}' -f $ZipFileName)
  
    if (Test-Path -Path .\$ScriptFileName -PathType Leaf) {
        # Run Script file and remove it afterwards
        Start-Process "C:\Program Files\PowerShell\7\pwsh.exe" -Verb runAs -ArgumentList ".\$ScriptFileName" -Wait
        #Remove-Item .\$ScriptFileName -Force

        #Unzip repo file and remove it
        Expand-Archive $ZipFileName -DestinationPath $ZipFolder
        #Remove-Item .\$ZipFileName -Force

        #Find the selected file in Zipfolder 
        $filename = Get-Childitem -Path $ZipFolder -Recurse |Where-Object {($_.name -eq $d_file)}| ForEach-Object{$_.FullName}
        Write-Output ("Executing following file : {0} " -f $filename)
        
        # Run the selected file
        If (Test-Path -Path $filename) {
            Start-Process "C:\Program Files\PowerShell\7\pwsh.exe" -Verb runAs -ArgumentList "$filename" -WindowStyle Normal -Wait
            #Remove-item $filename -Force
        }

        # Cleaning up files
        Set-Location $env:TEMP
        #Remove-item -Path $ZipFolder -Recurse -Force 
    }

    Stop-Transcript