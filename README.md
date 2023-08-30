# doorstep
Doorstep is a powershell script to access your private repro in GitHub.

To kickoff the script - open a powershell (as admin) and copy/paste following command;

`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; invoke-expression((New-Object System.Net.WebClient).DownloadString('https://github.com/madsenkg/doorstep/raw/main/dingdong.ps1'))`

When asked fill in the GitHub Token and then name of the Repro. 

The script will now call your private repro using the token given. Mandatory file in your repro must be 'install.ps1'. 
