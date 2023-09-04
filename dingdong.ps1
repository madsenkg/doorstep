#Copyrights CGI Demnark A/S
#See Source : https://stackoverflow.com/questions/63506725/using-powershell-to-download-file-from-private-github-repository-using-oauth
#Requires -RunAsAdministrator
    Clear-Host
    Set-Location C:\temp
    $ScriptFileName = ("{0}.ps1" -f [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName()))

#Load Assembly
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

#Dialog
    $d_credentials = [Microsoft.VisualBasic.Interaction]::InputBox("Github Token", "Enter your GitHub Token","<paste token here>")
    $d_repo = [Microsoft.VisualBasic.Interaction]::InputBox("Github repro", "Enter the name of the private GitHub Repro <User/Repro>","madsenkg/Tokentest")
    $d_file = [Microsoft.VisualBasic.Interaction]::InputBox("Run this file", "Enter the filename", "install.zip")
 
    New-item -Name $ScriptFileName -ItemType File -Force | Out-Null
    Add-Content -Path $ScriptFileName -Value 'Set-Location C:\temp'
    Add-Content -Path $ScriptFileName -Value ('$credentials="{0}"' -f $d_credentials)
    Add-Content -Path $ScriptFileName -Value ('$repo = "{0}"' -f $d_repo)
    Add-Content -Path $ScriptFileName -Value ('$file = "{0}"' -f $d_file)
    Add-Content -Path $ScriptFileName -Value '$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"'
    Add-Content -Path $ScriptFileName -Value '$headers.Add("Authorization", "Bearer $credentials")'
    Add-Content -Path $ScriptFileName -Value '$headers.Add("Accept", "*/*")'
    #Add-Content -Path $ScriptFileName -Value '$download = "https://raw.githubusercontent.com/$repo/main/$file"'
    Add-Content -Path $ScriptFileName -Value '$download = "https://github.com/$repo/archive/refs/heads/main.zip"'
    
    Add-Content -Path $ScriptFileName -Value 'Invoke-RestMethod -Uri $download -Headers $headers -Method Get -OutFile $file'
<#  
    if (Test-Path -Path .\$ScriptFileName -PathType Leaf) {
        Start-Process "C:\Program Files\PowerShell\7\pwsh.exe" -Verb runAs -ArgumentList ".\$ScriptFileName" -Wait
        
        If (Test-Path -Path .\$d_file) {
            Start-Process "C:\Program Files\PowerShell\7\pwsh.exe" -Verb runAs -ArgumentList ".\$d_file" -WindowStyle Normal -Wait
            Remove-item .\$d_file -Force
        }
        Remove-Item .\$ScriptFileName -Force
       
    }  
#>    
