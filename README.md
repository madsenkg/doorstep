#Doorstep
Doorstep is a repo that contains a varity of powershell scripts to that has the purpose to downloada private repro in GitHub.

#Purpose
The purpose of this script is to download a private repo, unpack it and run a script with in the repo.

#How-to-use
To run the script - open a powershell (as admin) and copy/paste following command;

`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; invoke-expression((New-Object System.Net.WebClient).DownloadString('https://github.com/madsenkg/doorstep/raw/main/dingdong.ps1'))`

When asked - paste in your PAT, the name of the repository ('<user>/<repo>') and the file you want to run.
The script will now download your private repo and execute a seleted powershell file. The default file is set to 'install.ps1'. if you don't want anything to be 'installed' you can leave your install.ps1-file blank!

# How to use the this script
Run the script - first.. and it will check to see if .NET 4.8 is installed.. (properbly not) it will install .Net v4.8 and then it will restart the VM .. after that, log on to the VM and open the PowerShell (asAdmin) again .. and rerun the script .. (use the arrow keys, Powershell remembers commands) - when asked for the Token and the path to the repo, just copy/paste in the needed information.
