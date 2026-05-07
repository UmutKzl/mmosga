#!/usr/bin/env bash
set -euo pipefail

if ! command -v brew >/dev/null; then
  echo "Install homebrew and rerun this command."
  exit 1
fi

if ! command -v gum >/dev/null; then
  echo "Installing gum."
  brew install gum
fi

next() {
  sleep 0.5
  clear
}

install_category() {
  local header="$1"
  local apps="$2"

  local selection
  selection=$(gum choose --no-limit $apps \
    --header "$header")

  if [ -n "$(echo "$selection" | tr -d ' ')" ]; then
    echo "Installing: $selection"
    brew install $selection
  else
    echo "No apps selected, skipping..."
  fi
}

next

if ! gum confirm "Do you want to proceed?"; then
  exit 1
fi

if [ "${1:-}" == "--force" ]; then
  force="true"
else
  force="false"
fi

brewprefix="$(brew --prefix)"

next

# Dock
if gum confirm "Do you want to enable magnification?"; then
  defaults write com.apple.dock magnification -bool true
  defaults write com.apple.dock largesize -int 80
else
  defaults write com.apple.dock magnification -bool false
fi

if gum confirm "Do you want to disable recent apps from dock?"; then
  defaults write com.apple.dock show-recents -bool false
else
  defaults write com.apple.dock show-recents -bool true
fi

if gum confirm "Do you want to autohide dock?"; then
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock autohide-time-modifier -float 0.5
  defaults write com.apple.dock autohide-delay -float 0
else
  defaults write com.apple.dock autohide -bool false
fi
echo "Dock settings are finished..."
next

# Finder
if gum confirm "Do you want to see hidden files by default?"; then
  defaults write com.apple.finder AppleShowAllFiles -bool true
else
  defaults write com.apple.finder AppleShowAllFiles -bool false
fi

if gum confirm "Do you want to enable path bar and status bar?"; then
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true
else
  defaults write com.apple.finder ShowPathbar -bool false
  defaults write com.apple.finder ShowStatusBar -bool false
fi

finder_view_choice=$(gum choose list icon)
case "$finder_view_choice" in
list)
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
  ;;
icon)
  defaults write com.apple.finder FXPreferredViewStyle -string "icnv"
  ;;
esac

if gum confirm "Do you want to start finder from $HOME folder?"; then
  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
fi

if gum confirm "Do you want to enable text selection in Quick Look?"; then
  defaults write com.apple.finder QLEnableTextSelection -bool true
else
  defaults write com.apple.finder QLEnableTextSelection -bool false
fi

if gum confirm "Do you want to disable storing DS_Store files on network?"; then
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
else
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool false
fi
echo "Finder settings are finished..."
next

# Keyboard
if gum confirm "Do you want to disable automatic periods, capitalization, spelling, and quotes?"; then
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
else
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool true
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool true
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool true
fi
echo "Keyboard settings are finished..."
next

# Trackpad
if gum confirm "Do you want to disable natural scroll?"; then
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
else
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true
fi
echo "Trackpad settings are finished..."
next

# Kill services
killall Dock SystemUIServer Finder || true
next

# App categories
TERMINAL_DEV="neovim helix tmux zellij fzf ripgrep bat eza zoxide gh lazygit python node llama.cpp"
GUI_DEV="visual-studio-code zed neovide-app emacs cursor windsurf wezterm alacritty kitty ghostty"
AI_TOOLS="lm-studio ollama claude claude-code opencode chatgpt chatgpt-atlas"
BROWSERS="google-chrome ungoogled-chromium firefox vivaldi"
GAMES="steam epic-games gog-galaxy crossover heroic luanti supertuxkart godot antigravity"
VIRTUALIZATION="utm parallels"
PRODUCTIVITY="raycast mac-mouse-fix betterdisplay wallspace caffeine rectangle obs spotify"
ALL_APPS="$TERMINAL_DEV $GUI_DEV $AI_TOOLS $BROWSERS $GAMES $VIRTUALIZATION $PRODUCTIVITY"

selected_templates=$(gum choose --no-limit \
  "Terminal Development" \
  "GUI Development" \
  "AI & LLM Tools" \
  "Browsers" \
  "Games" \
  "Virtualization" \
  "Productivity & Utilities" \
  "Custom" \
  --header "Select app templates to install (space to select, enter to confirm)")

if echo "$selected_templates" | grep -q "Terminal Development"; then
  install_category "Terminal development" "$TERMINAL_DEV"
fi

if echo "$selected_templates" | grep -q "GUI Development"; then
  install_category "GUI development" "$GUI_DEV"
fi

if echo "$selected_templates" | grep -q "AI & LLM Tools"; then
  install_category "AI & LLM Tools" "$AI_TOOLS"
fi

if echo "$selected_templates" | grep -q "Browsers"; then
  install_category "Browsers" "$BROWSERS"
fi

if echo "$selected_templates" | grep -q "Games"; then
  install_category "Games" "$GAMES"
fi

if echo "$selected_templates" | grep -q "Virtualization"; then
  install_category "Virtualization" "$VIRTUALIZATION"
fi

if echo "$selected_templates" | grep -q "Productivity & Utilities"; then
  install_category "Productivity & Utilities" "$PRODUCTIVITY"
fi

if echo "$selected_templates" | grep -q "Custom"; then
  install_category "Custom: select individual apps" "$ALL_APPS"
fi

next

# Rosetta 2
if ! pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto >/dev/null &&
  gum confirm "Do you want to install Rosetta 2?"; then
  softwareupdate --install-rosetta --agree-to-license
else
  echo "Skipping Rosetta 2..."
fi
next

# Neovim
if command -v nvim >/dev/null; then
  [[ "$force" == "true" ]] && rm -rf ~/.config/nvim ~/.local/share/nvim || true
  if [ ! -d "$HOME/.config/nvim" ] && gum confirm "Do you want to install a Neovim config?"; then
    distro=$(gum choose --header "Neovim distro" nvchad lazyvim astronvim)

    command -v node >/dev/null || brew install node || true
    command -v tree-sitter >/dev/null || brew install tree-sitter-cli || true
    command -v rg >/dev/null || brew install ripgrep || true

    case "$distro" in
    nvchad)
      git clone --depth 1 https://github.com/NvChad/starter ~/.config/nvim
      rm -rf ~/.config/nvim/.git
      echo "Don't forget to read the wiki: https://nvchad.com/docs/quickstart/install"
      ;;
    lazyvim)
      git clone --depth 1 https://github.com/LazyVim/starter ~/.config/nvim
      rm -rf ~/.config/nvim/.git
      ;;
    astronvim)
      git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
      rm -rf ~/.config/nvim/.git
      echo "Don't forget to read the wiki: https://docs.astronvim.com/#-setup"
      ;;
    esac
    echo "Configured Neovim!"
  else
    echo "Skipping Neovim config section..."
  fi
fi
next

# Emacs
if command -v emacs >/dev/null; then
  [[ "$force" == "true" ]] && rm -rf ~/.config/emacs || true
  if [ ! -d "$HOME/.emacs.d" ] && [ ! -d "$HOME/.config/emacs" ] &&
    gum confirm "Do you want to install an Emacs config?"; then
    distro=$(gum choose --header "Emacs distro" spacemacs doom-emacs)

    case "$distro" in
    doom-emacs)
      git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
      ~/.config/emacs/bin/doom install
      ;;
    spacemacs)
      git clone --depth 1 https://github.com/syl20bnr/spacemacs ~/.config/emacs
      ;;
    esac
    echo "Configured Emacs!"
  else
    echo "Skipping Emacs config section..."
  fi
fi
next

# Zsh
if command -v zsh >/dev/null; then
  [[ "$force" == "true" ]] && rm -rf ~/.zshrc || true
  if [ ! -f "$HOME/.zshrc" ] && gum confirm "Do you want to configure Zsh?"; then
    if gum confirm "Do you want to use zsh-syntax-highlighting?"; then
      [[ ! -f "$brewprefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
        brew install zsh-syntax-highlighting
      echo "source $brewprefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >>~/.zshrc
    fi
    if gum confirm "Do you want to use zsh-autosuggestions?"; then
      [[ ! -f "$brewprefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
        brew install zsh-autosuggestions
      echo "source $brewprefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >>~/.zshrc
    fi
    if gum confirm "Do you want to use a custom prompt?"; then
      echo "export PS1='%B%F{Cyan}%~%b%F{white} $ '" >>~/.zshrc
    fi
    if gum confirm "Do you want to have a better tab completion?"; then
      echo "autoload -Uz compinit" >>~/.zshrc
      echo "compinit" >>~/.zshrc
      echo "zstyle ':completion:*' menu select" >>~/.zshrc
    fi
    if gum confirm "Do you want to use eza (ls alternative)?"; then
      command -v eza >/dev/null || brew install eza || true
      echo 'alias ls="eza"' >>~/.zshrc
      echo 'alias la="eza -a"' >>~/.zshrc
      echo 'alias tree="eza -T"' >>~/.zshrc
    fi
    echo "Configured Zsh!"
  else
    echo "Skipping Zsh config section..."
  fi
fi
next

# Ghostty
if command -v ghostty >/dev/null; then
  [[ "$force" == "true" ]] && rm -rf ~/.config/ghostty || true
  if [ ! -f "$HOME/.config/ghostty/config" ] && [ ! -f "$HOME/.config/ghostty/config.ghostty" ] &&
    gum confirm "Do you want to configure Ghostty?"; then
    [[ ! -d ~/.config/ghostty ]] && mkdir -p ~/.config/ghostty
    echo "background-opacity = $(gum input --header 'Transparency (between 0.0 and 1.0)' --value '1.0')" \
      >>~/.config/ghostty/config.ghostty
    gum confirm "Do you want to use Option key as Alt?" &&
      echo "macos-option-as-alt = left" >>~/.config/ghostty/config.ghostty
    scheme=$(ghostty +list-themes | sed -E 's/ \(resources\)$//' | gum choose --header "Select a color scheme")
    echo "theme = $scheme" >>~/.config/ghostty/config.ghostty
    echo "Configured Ghostty!"
  else
    echo "Skipping Ghostty config section..."
  fi
fi
next

# TextEdit
if gum confirm "Do you want to start blank when using TextEdit?"; then
  defaults write com.apple.TextEdit NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false
else
  defaults write com.apple.TextEdit NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool true
fi
if gum confirm "Do you want to disable ruler in TextEdit?"; then
  defaults write com.apple.TextEdit ShowRuler -bool false
else
  defaults write com.apple.TextEdit ShowRuler -bool true
fi
fontsize=$(gum input --header 'Font size for TextEdit' --value '20')
if [ -n "$fontsize" ]; then
  defaults write com.apple.TextEdit "NSFixedPitchFontSize" -int "$fontsize"
  defaults write com.apple.TextEdit "NSFontSize" -int "$fontsize"
fi
killall TextEdit || true
echo "Configured TextEdit!"
next

echo "Everything is finished. Good luck!"
