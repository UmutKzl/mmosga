#!/usr/bin/env bash

if ! command -v brew >/dev/null; then
  echo "Install homebrew and rerun this command."
fi

clear
if ! gum confirm "Do you want to proceed?" ; then
  exit 1
fi

if ! command -v gum >/dev/null; then
  echo "Installing gum."
  brew install gum
fi

clear
# Dock
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 80
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.5
defaults write com.apple.dock autohide-delay -float 0
echo "Dock settings are finished."

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
defaults write com.apple.finder QLEnableTextSelection -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
echo "Finder settings are finished."

# Keyboard
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
echo "Keyboard settings are finished."

# Trackpad
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
echo "Trackpad settings are finished."

# Accent color (purple)
defaults write -g AppleAccentColor -int 5
defaults write -g AppleColorPreferences -dict AccentColor -int 5
defaults write -g AppleHighlightColor -string "0.968627 0.831373 1.000000 Purple"
echo "Accent color has been set up to purple."

# Launch services
defaults write com.apple.LaunchServices LSQuarantine -bool false
echo "Launch services settings are finished."

# Kill services
killall Dock
killall SystemUIServer
killall Finder
killall TextEdit
echo "Restarted services."

clear

# Choose apps and install them
apps="spotify google-chrome ungoogled-chromium firefox vivaldi \
  lazygit visual-studio-code zed neovim neovide-app emacs helix godot antigravity \
  cursor windsurf tmux zellij fzf ripgrep bat eza zoxide gh python node wezterm \
  alacritty kitty ghostty raycast mac-mouse-fix betterdisplay caffeine rectangle \
  steam epic-games gog-galaxy parallels crossover heroic luanti supertuxkart obs \
  lm-studio ollama claude claude-code opencode chatgpt chatgpt-atlas llama.cpp"
brew install $(gum choose --no-limit $apps --header "Select apps to install")

# Rosetta 2
if gum confirm "Do you want to install Rosetta 2?" ; then
  softwareupdate --install-rosetta --agree-to-license
fi

# LazyVim
if command -v nvim >/dev/null; then
  if [ ! -d "$HOME/.config/nvim" ] && gum confirm "Do you want to install a Neovim config?"; then
    distro=$(gum choose --header "Neovim distro" nvchad lazyvim)

    command -v node >/dev/null || brew install node
    command -v tree-sitter >/dev/null || brew install tree-sitter-cli

    case "$distro" in
      nvchad)
        git clone https://github.com/NvChad/starter ~/.config/nvim
        rm -rf ~/.config/nvim/.git
        echo "Don't forget to read wiki https://nvchad.com/docs/quickstart/install"
        ;;
      lazyvim)
        git clone https://github.com/LazyVim/starter ~/.config/nvim
        rm -rf ~/.config/nvim/.git
        ;;
    esac
  fi
else
  echo "Skipping LazyVim section because you already have a Neovim config."
fi

echo "Everything is got finished. Good luck!"
