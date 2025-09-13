Microsoft Windows [Version 10.0.26100.6584]
(c) Microsoft Corporation. All rights reserved.

C:\Windows\System32>powershell
Windows PowerShell
Copyright (C) Microsoft Corporation. All rights reserved.

新機能と改善のために最新の PowerShell をインストールしてください!https://aka.ms/PSWindows

PS C:\Windows\System32>
PS C:\Windows\System32>
PS C:\Windows\System32> Set-ExecutionPolicy Bypass -Scope Process -Force; `
>> [System.Net.ServicePointManager]::SecurityProtocol = `
>> [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
>> iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
警告: An existing Chocolatey installation was detected. Installation will not continue. This script will not overwrite
existing installations.
If there is no Chocolatey installation at 'C:\ProgramData\chocolatey', delete the folder and attempt the installation
again.

Please use choco upgrade chocolatey to handle upgrades of Chocolatey itself.
If the existing installation is not functional or a prior installation did not complete, follow these steps:
 - Backup the files at the path listed above so you can restore your previous installation if needed.
 - Remove the existing installation manually.
 - Rerun this installation script.
 - Reinstall any packages previously installed, if needed (refer to the lib folder in the backup).

Once installation is completed, the backup folder is no longer needed and can be deleted.
PS C:\Windows\System32>

PS C:\Windows\System32> choco --version
2.5.1

PS C:\Windows\System32> choco install nerd-fonts-jetbrainsmono -y
Chocolatey v2.5.1
Installing the following packages:
nerd-fonts-jetbrainsmono
By installing, you accept licenses for the packages.
Downloading package from source 'https://community.chocolatey.org/api/v2/'
Progress: Downloading chocolatey-font-helpers.extension 0.0.4... 100%

chocolatey-font-helpers.extension v0.0.4 [Approved]
chocolatey-font-helpers.extension package files install completed. Performing other installation steps.
 Installed/updated chocolatey-font-helpers extensions.
 The install of chocolatey-font-helpers.extension was successful.
  Deployed to 'C:\ProgramData\chocolatey\extensions\chocolatey-font-helpers'
Downloading package from source 'https://community.chocolatey.org/api/v2/'
Progress: Downloading nerd-fonts-JetBrainsMono 3.4.0... 100%

nerd-fonts-JetBrainsMono v3.4.0 [Approved]
nerd-fonts-JetBrainsMono package files install completed. Performing other installation steps.
Downloading nerd-fonts-JetBrainsMono
  from 'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip'
Progress: 100% - Completed download of C:\Users\hmukai\AppData\Local\Temp\chocolatey\nerd-fonts-JetBrainsMono\3.4.0\JetBrainsMono.zip (123.13 MB).
Download of JetBrainsMono.zip (123.13 MB) completed.
Hashes match.
Extracting C:\Users\hmukai\AppData\Local\Temp\chocolatey\nerd-fonts-JetBrainsMono\3.4.0\JetBrainsMono.zip to C:\ProgramData\chocolatey\lib\nerd-fonts-JetBrainsMono\tools...
C:\ProgramData\chocolatey\lib\nerd-fonts-JetBrainsMono\tools
96 fonts installed
 The install of nerd-fonts-JetBrainsMono was successful.
  Deployed to 'C:\ProgramData\chocolatey\lib\nerd-fonts-JetBrainsMono\tools'

Chocolatey installed 2/2 packages.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).
PS C:\Windows\System32>
PS C:\Windows\System32>
PS C:\Windows\System32> choco install nerd-fonts-fira-code -y
Chocolatey v2.5.1
Installing the following packages:
nerd-fonts-fira-code
By installing, you accept licenses for the packages.
nerd-fonts-fira-code not installed. The package was not found with the source(s) listed.
 Source(s): 'https://community.chocolatey.org/api/v2/'
 NOTE: When you specify explicit sources, it overrides default sources.
If the package version is a prerelease and you didn't specify `--pre`,
 the package may not be found.
Please see https://docs.chocolatey.org/en-us/troubleshooting for more
 assistance.

Chocolatey installed 0/1 packages. 1 packages failed.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).

Failures
 - nerd-fonts-fira-code - nerd-fonts-fira-code not installed. The package was not found with the source(s) listed.
 Source(s): 'https://community.chocolatey.org/api/v2/'
 NOTE: When you specify explicit sources, it overrides default sources.
If the package version is a prerelease and you didn't specify `--pre`,
 the package may not be found.
Please see https://docs.chocolatey.org/en-us/troubleshooting for more
 assistance.
PS C:\Windows\System32> choco install cascadia-code-nerd-font -y
Chocolatey v2.5.1
Installing the following packages:
cascadia-code-nerd-font
By installing, you accept licenses for the packages.
Downloading package from source 'https://community.chocolatey.org/api/v2/'
Progress: Downloading cascadia-code-nerd-font 2.1.0... 100%

cascadia-code-nerd-font v2.1.0 [Approved]
cascadia-code-nerd-font package files install completed. Performing other installation steps.
Downloading cascadia-code-nerd-font
  from 'https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/CascadiaCode.zip'
Progress: 100% - Completed download of C:\Users\hmukai\AppData\Local\Temp\chocolatey\cascadia-code-nerd-font\2.1.0\CascadiaCode.zip (1.97 MB).
Download of CascadiaCode.zip (1.97 MB) completed.
Hashes match.
Extracting C:\Users\hmukai\AppData\Local\Temp\chocolatey\cascadia-code-nerd-font\2.1.0\CascadiaCode.zip to C:\ProgramData\chocolatey\lib\cascadia-code-nerd-font\tools...
C:\ProgramData\chocolatey\lib\cascadia-code-nerd-font\tools
0
0
0
0
 The install of cascadia-code-nerd-font was successful.
  Deployed to 'C:\ProgramData\chocolatey\lib\cascadia-code-nerd-font\tools'

Chocolatey installed 1/1 packages.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).
PS C:\Windows\System32>
