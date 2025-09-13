#!/usr/bin/env bash
set -euo pipefail

# macOS: Homebrew で Nerd Fonts / CJK を導入
if [[ "$(uname -s)" == "Darwin" ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Install from https://brew.sh/"; exit 1
  fi
  brew tap homebrew/cask-fonts || true
  brew install --cask font-jetbrains-mono-nerd-font
  brew install --cask font-fira-code-nerd-font
  brew install --cask font-caskaydia-mono-nerd-font || true
  brew install --cask font-noto-sans-cjk-jp || true
  echo "✅ macOS fonts installed (JetBrainsMono NF / FiraCode NF / Cascadia Mono NF / Noto CJK JP)."
  exit 0
fi

# Linux: ローカル同梱フォントがあればコピー、なければ既存環境を優先
FONT_DIR="${HOME}/.local/share/fonts"
mkdir -p "${FONT_DIR}"

shopt -s nullglob
copied=0
for f in ./JetBrainsMonoNerdFont-*.ttf ./FiraCodeNerdFont-*.ttf ./CascadiaCodeNF-*.ttf ./NotoSansCJK*.otf; do
  cp -f "$f" "${FONT_DIR}/" && copied=1
done

if [[ "${copied}" -eq 1 ]]; then
  fc-cache -f -v >/dev/null || true
  echo "✅ Linux: copied bundled fonts and refreshed cache."
else
  echo "ℹ️  No bundled TTF/OTF found. If needed, place font files next to this script and re-run."
  echo "   (Or install via your distro packages: e.g., 'sudo pacman -S ttf-jetbrains-mono-nerd ttf-fira-code-nfp noto-fonts-cjk' etc.)"
fi
