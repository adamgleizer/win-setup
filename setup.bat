@echo off
ECHO Administrative permissions required. Detecting permissions...

net session >nul 2>&1
IF %errorLevel% == 0 (
    ECHO Success: Administrative permissions confirmed.
) ELSE (
    ECHO Failure: Current permissions inadequate. Run setup as Admin.
    PAUSE
    EXIT
)

:: Get the drive and path of the current script
SET "script_path=%~dp0"

:: Remove the trailing backslash if it exists
IF "%script_path:~-1%" == "\" (
    SET "script_path=%script_path:~0,-1%"
)

ECHO installing chocolatey...
@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
:: install and update without confirmation prompts
choco feature enable -n allowGlobalConfirmation

call RefreshEnv.cmd
 
ECHO installing default apps...
choco install "%script_path%\apps\default.config"

ECHO installing communication apps...
choco install "%script_path%\apps\communication.config"

ECHO installing dev apps...
choco install "%script_path%\apps\dev.config"

call RefreshEnv.cmd

ECHO setting up node...
nvm install lts
nvm use lts

ECHO adding windows terminal as default batfile application...
ftype batfile="C:\Users\%USERNAME%\AppData\Local\Microsoft\WindowsApps\wt.exe" -p "Command Prompt" "%1" %*

ECHO running shutup10 to disable windows invasive policies...
oosu10 "%script_path%\ooshutup\ooshutup10.cfg" /quiet

ECHO disabling interactive login....
regedit /s "%script_path%\registry\editregistry.reg"

ECHO setup complete, please reboot to finish changes to settings
PAUSE