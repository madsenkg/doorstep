# doorstep
Doorstep is a powershell script to access your private repro in GitHub.

To kickoff the script - open a powershell (as admin) and copy/paste following command;

`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; invoke-expression((New-Object System.Net.WebClient).DownloadString('https://github.com/madsenkg/doorstep/raw/main/dingdong.ps1'))`

When asked - paste in your PAT and the name of the repository (<user>/<repo>), please . 

The script will now clone your private repo and execute a seleted file. Default file to execute is 'install.ps1'.

