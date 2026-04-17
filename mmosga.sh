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

# Trackpad
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
echo "Trackpad settings are finished."

# Accent color
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
echo "Restarted services."

clear
# Install apps
apps="spotify google-chrome ungoogled-chromium firefox \
lazygit neovim visual-studio-code godot zed emacs helix tmux \
zellij fzf ripgrep bat eza zoxide gh python \
wezterm alacritty kitty ghostty raycast mac-mouse-fix \
steam epic-games gog-galaxy heroic luanti supertuxkart"
brew install $(gum choose --no-limit $apps --header "Select apps to install")

# Rosetta 2
if gum confirm "Do you want to install Rosetta 2?" ; then
  softwareupdate --install-rosetta --agree-to-license
fi
