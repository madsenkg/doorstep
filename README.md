# doorstep
Doorstep is a powershell script to access your private repro in GitHub.

To kickoff the script - open a powershell (as admin) and copy/paste following command;

`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; invoke-expression((New-Object System.Net.WebClient).DownloadString('https://github.com/madsenkg/doorstep/raw/main/dingdong.ps1'))`

When asked - paste in your PAT and the name of the repository (<user>/<repo>), please . 

The script will now clone your private repo and execute a seleted file. Default file to execute is 'install.ps1'.

# How to use the this script
Run the script - first.. and it will check to see if .NET 4.8 is installed.. (properbly not) it will install the the .Net version 4.8 then it will restart the VM .. after that, log on to the VM and open the PowerShell (asAdmin) again .. and rerun the script .. (use the arrow keys, Powershell remembers commands) - when asked for the Token and the path to the repo, just copy/paste in the needed information
