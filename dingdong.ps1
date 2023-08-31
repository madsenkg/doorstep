#Copyrights CGI Demnark A/S
#See Source : https://stackoverflow.com/questions/63506725/using-powershell-to-download-file-from-private-github-repository-using-oauth
#Requires -RunAsAdministrator

  Clear-Host
  Set-Location $env:TEMP
  $ScriptFileName = ("{0}.ps1" -f [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName()))

#Load Assembly
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

#Dialog
  $d_credentials = [Microsoft.VisualBasic.Interaction]::InputBox("Github Token", "Enter your GitHub Token","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")
  $d_repo = [Microsoft.VisualBasic.Interaction]::InputBox("Github repro", "Enter the name of the private GitHub Repro <User/Repro>","madsenkg/Tokentest")
  $d_file = [Microsoft.VisualBasic.Interaction]::InputBox("Run this file", "Enter the filename", "install.ps1")
 
  New-item -Name $ScriptFileName -ItemType File -Force | Out-Null
  Add-Content -Path $ScriptFileName -Value 'Set-Location C:\Temp'
  Add-Content -Path $ScriptFileName -Value ('$credentials="{0}"' -f $d_credentials)
  Add-Content -Path $ScriptFileName -Value ('$repo = "{0}"' -f $d_repo)
  Add-Content -Path $ScriptFileName -Value ('$file = "{0}"' -f $d_file)
  Add-Content -Path $ScriptFileName -Value '$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"'
  Add-Content -Path $ScriptFileName -Value '$headers.Add("Authorization", "token $credentials")'
  Add-Content -Path $ScriptFileName -Value '$headers.Add("Accept", "application/json")'
  Add-Content -Path $ScriptFileName -Value '$download = "https://raw.githubusercontent.com/$repo/main/$file"'
  Add-Content -Path $ScriptFileName -Value 'Invoke-WebRequest -Uri $download -Headers $headers -OutFile $file'
    
  if (Test-Path -Path $ScriptFileName -PathType Leaf) {

    Start-Process -Wait "C:\Program Files\PowerShell\7\pwsh.exe" -Verb runAs -ArgumentList ".\$ScriptFileName" -WindowStyle Normal
    If (Test-Path -Path $ScriptFileName) {
        Start-Process -Wait "C:\Program Files\PowerShell\7\pwsh.exe" -Verb runAs -ArgumentList ".\$d_file" -WindowStyle Normal
        Remove-item .\$d_file -Force
    }

    Remove-Item .\$ScriptFileName -Force
  }
