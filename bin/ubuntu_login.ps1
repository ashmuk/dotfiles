# ubuntu-login.ps1
$Distro = "Ubuntu-22.04"
Write-Host "Launching $Distro on WSL..."
wsl -d $Distro -- bash -c "cd ~; exec bash" 
