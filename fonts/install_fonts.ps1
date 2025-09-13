# PowerShell: install programming fonts on Windows
$ErrorActionPreference = "Stop"

function Have($cmd) { Get-Command $cmd -ErrorAction SilentlyContinue | Out-Null }

if (Have "winget") {
  winget install -e --id NerdFonts.JetBrainsMono --accept-source-agreements --accept-package-agreements
  winget install -e --id NerdFonts.FiraCode      --accept-source-agreements --accept-package-agreements
  winget install -e --id NerdFonts.CascadiaCode  --accept-source-agreements --accept-package-agreements
  Write-Host "✅ Installed Nerd Fonts (JetBrains Mono / Fira Code / Cascadia Code) via winget."
}
elseif (Have "choco") {
  choco install nerd-fonts-jetbrainsmono -y
  choco install nerd-fonts-fira-code -y
  choco install cascadia-code-nerd-font -y
  Write-Host "✅ Installed Nerd Fonts via Chocolatey."
}
else {
  Write-Warning "winget/choco not found. You can manually install TTFs by right-clicking 'Install'."
}

# CJK は Windows 既定の 'Yu Gothic UI' を wide 用に使えるので追加インストールは必須ではありません。
Write-Host "ℹ️  For CJK wide font, 'Yu Gothic UI' is used by default in Vim (guifontwide)."
