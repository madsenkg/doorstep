#Copyrights CGI Demnark A/S
#Requires -RunAsAdministrator

  Clear-Host
  Set-Location $env:TEMP
  $file = "Install.ps1"

#Load Assembly
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

#Dialog
  $GitToken = [Microsoft.VisualBasic.Interaction]::InputBox("Github Token", "Enter your GitHub Token")
  $GitRepro = [Microsoft.VisualBasic.Interaction]::InputBox("Github repro", "Enter the name of the private GitHub Repro")

#See Source : https://stackoverflow.com/questions/63506725/using-powershell-to-download-file-from-private-github-repository-using-oauth
  $credentials="$GitToken"
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Authorization", "token $credentials")
  $headers.Add("Accept", "application/json")
  #$download = ("https://raw.githubusercontent.com/{0}/main/{1}" -f $GitRepro, $file)
  $download = ("https://github.com/{0}/raw/main/{1}" -f $GitRepro, $file)
  Write-Host Headers $headers
  Write-Host Downloading $download 
  Invoke-WebRequest -Uri $download -Headers $headers -OutFile $file
  Invoke-expression .\$file
