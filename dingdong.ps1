#Copyrights CGI Demnark A/S
#See Source : https://stackoverflow.com/questions/63506725/using-powershell-to-download-file-from-private-github-repository-using-oauth
#Requires -RunAsAdministrator

Clear-Host

# Making sure .NET 4.8.x is installed
$DotNetVersion = Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse | Get-ItemProperty -Name version -EA 0 | Where { $_.PSChildName -Match '^(?!S)\p{L}'} | Select PSChildName, version

if ($DotNetVersion.version.Item(0) -gt 4.8) {
    Write-output ".NET version is good !"
    $DotNetVersion
    Write-output "----------------------"
    
    # Create Tmp folder for the script
    $TmpFolder      = ("C:\Temp\{0}.tmp"     -f [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName()))
    New-Item -Path $TmpFolder -ItemType "directory" -Force -Confirm:$false | Out-Null
    Set-Location $TmpFolder

    # start a log
    Start-Transcript -Append -Path ("_{0}_{1}.log" -f $env:COMPUTERNAME,(Get-Date -format yyyyMMdd))
    Write-output ("Temp-folder is : {0}" -f $TmpFolder)

    $TmpFileName    = [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName())
    $ScriptFileName = ("{0}.ps1" -f $TmpFileName)
    $LogFileName    = ("{0}.log" -f $TmpFileName)
    $ZipFileName    = ("{0}.zip" -f [System.IO.Path]::GetFileNameWithoutExtension([System.IO.Path]::GetRandomFileName()))

    #Load Assembly
    [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

    #Dialog
    $d_token = [Microsoft.VisualBasic.Interaction]::InputBox("Github Token", "Enter your GitHub Token","<paste token here>") 
    $d_repo  = [Microsoft.VisualBasic.Interaction]::InputBox("Github repo", "Enter the name of the private GitHub Repository <User>/<repo>","<paste repo here>")
    $d_file  = [Microsoft.VisualBasic.Interaction]::InputBox("Run this file", "Enter the filename", 'Install.ps1')

    Write-output "Validating input..."
    # Testing format of repo
    if (!($d_repo -match "[a-zA-Z0-9]\/[a-zA-Z0-9]" )) {
        Write-Output "Repo string is not valid please use <user>/<repo>"
        Start-Sleep -Seconds 5
        exit
    }

    # Testing format of file
    if (!($d_file -match "[a-zA-Z0-9].ps1" )) {
        Write-Output "file string is not valid please use <filename>.ps1"
        Start-Sleep -Seconds 5
        exit
    }
    # Validating 
    if (!$d_token -or !$d_repo -or !$d_file) {
        Write-Output ("Missing some info - aborting script")
        Start-Sleep -Seconds 5
        exit   
    }
    Write-output "Validation - OK !"
    
    # Install git
    Write-output "Installing Chocolatey and GIT... please wait !"
    Install-PackageProvider -Name NuGet -Scope CurrentUser -Confirm:$false -Force
    Invoke-Expression (new-object net.webclient).DownloadString("https://chocolatey.org/install.ps1") -WarningAction SilentlyContinue
    $env:Path += ";%PROGRAMDATA%\chocolatey\bin"
    choco install git -y -v -acceptlicens

    # Creating script
    Write-output "Now creating script..."
    New-item -Name $ScriptFileName -ItemType File -Force | Out-Null
    Add-Content -Path $ScriptFileName -Value ('Start-Transcript {0} -force' -f $LogFileName)
    Add-Content -Path $ScriptFileName -Value ('Set-Location {0}' -f $TmpFolder)
    Add-Content -Path $ScriptFileName -Value 'md zipfolder' 
    Add-Content -Path $ScriptFileName -Value 'md gitrepo'
    Add-Content -Path $ScriptFileName -Value ('git config --global --add safe.directory {0}/gitrepo' -f $TmpFolder)
    Add-Content -Path $ScriptFileName -Value ('git clone --bare https://{0}:{1}@github.com/{2}.git gitrepo' -f $d_repo.split('/')[0], $d_token, $d_repo)
    Add-Content -Path $ScriptFileName -Value 'cd gitrepo'
    Add-Content -Path $ScriptFileName -Value ('git archive -o {0} HEAD' -f $ZipFileName)
    Add-Content -Path $ScriptFileName -Value ('Expand-Archive {0} -DestinationPath ..\zipfolder' -f $ZipFileName)
    Add-Content -Path $ScriptFileName -Value 'cd ..'
    Add-Content -Path $ScriptFileName -Value 'Remove-Item gitrepo -force -recurse -Confirm:$false -verbose'
    Add-Content -Path $ScriptFileName -Value 'Stop-Transcript'

    # Check if script file exists
    if (Test-Path $ScriptFileName -PathType Leaf) {
        # Run Script file and remove it afterwards
        Write-Output ("Running script : {0} " -f $ScriptFileName)
        Start-Process "powershell.exe" -Verb runAs -ArgumentList .\$ScriptFileName -WindowStyle Normal -Wait
        Remove-Item .\$ScriptFileName -Force -Confirm:$true

        #Find the selected file in Zipfolder and Run the selected file
        $filename = Get-Childitem -Path .\zipfolder -Recurse | Where-Object {($_.name -eq $d_file)} | ForEach-Object{$_.FullName}
        Write-Output ("Execute Install script : {0} " -f $filename)        
        If (Test-Path $filename -PathType Leaf) {
            Start-Process "powershell.exe" -Verb runAs -ArgumentList $filename -WindowStyle Normal -Wait
        }

        # Cleaning up files
        Remove-item .\zipfolder -Recurse -Force -Confirm:$true
    }

} else {
    Write-Output "-- REQUIRED INSTALLATION OF .NET 4.8 - Start Installing --"
    Write-Output "-- THIS MIGHT TAKE A MOMENT - PLEASE WAIT 5 min or more --"
    $DotNetVersion
    Write-Output "-----------------------------------------------------------"
    Write-Output "-- Download .NET 4.8 Package ------------------------------"
    Invoke-WebRequest https://go.microsoft.com/fwlink/?linkid=2088631 -OutFile $env:temp\dotnet.4.8.exe
    Write-Output "-- Installing .NET 4.8 Package ----------------------------"    
    Start-Process $env:temp\dotnet.4.8.exe -ArgumentList "/norestart" -Wait
    Write-Output "-----------------------------------------------------------"
    Write-Output "After Installing .NET 4.8 - It's required to restart the VM"
    Write-Output "Restarting in 10 Sec"
    Write-Output "-----------------------------------------------------------"
    Write-Output "** !!!! please rerun the script again after restart !!!! **"
    Write-Output "-----------------------------------------------------------"
    Stop-Transcript

    Start-Sleep -Seconds 10
    Restart-Computer -Force 
}

Stop-Transcript