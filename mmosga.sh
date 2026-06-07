#!/usr/bin/env bash

# colors
red() { printf "\e[1;31m$1\e[0m\n"; }
green() { printf "\e[0;92m$1\e[0m\n"; }
blue() { printf "\e[1;34m$1\e[0m\n"; }

[[ "$(uname)" != "Darwin" ]] && red "This script only supports macOS" && exit 1

# check command exists
checkexec() {
  if ! command -v "$1" >/dev/null; then
    red "$1 is not installed."
    return 1
  fi
}

# check is gum installed
checkexec gum

# list of tweaks
# don't forget to add tweaks when you add them at the bottom using if's
TWEAK_LIST=(
  "Disable recent apps from Dock"
  "Autohide Dock"
  "Enable Dock magnification"
  "See hidden files by default"
  "Enable path bar"
  "Enable status bar"
  "Disable DS_Store files on network"
)

# format TWEAK_LIST as comma's
# because we'll need it to autoselect everything in gum
SELECTED_ALL=$(
  IFS=,
  echo "${TWEAK_LIST[*]}"
)

# welcome the user
blue "Which tweaks do you want?"
blue "If you don't select something, this script will disable it."
blue "If you select something, this script will enable it."
TWEAKS=$(gum choose --no-limit --selected="${SELECTED_ALL}" --cursor="> " "${TWEAK_LIST[@]}")

# check is something selected?
if [[ -z "$TWEAKS" ]]; then
  red "None selected. Quiting..."
  exit 0
fi

if echo "$TWEAKS" | grep -F -q "Disable recent apps from Dock"; then
  green "Disabling recent apps in Dock"
  defaults write com.apple.dock show-recents -bool false
else
  echo "Enabling recent apps in Dock."
  defaults write com.apple.dock show-recents -bool true
fi

if echo "$TWEAKS" | grep -F -q "Autohide Dock"; then
  green "Autohiding Dock"
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock autohide-time-modifier -float 0.5
  defaults write com.apple.dock autohide-delay -float 0
else
  echo "Showing Dock"
  defaults write com.apple.dock autohide -bool false
fi

if echo "$TWEAKS" | grep -F -q "Enable Dock magnification"; then
  green "Enabling Dock magnification"
  defaults write com.apple.dock magnification -bool true
  defaults write com.apple.dock largesize -int 80
else
  echo "Disabling Dock magnification"
  defaults write com.apple.dock magnification -bool false
fi

if echo "$TWEAKS" | grep -F -q "See hidden files by default"; then
  green "Showing hidden files"
  defaults write com.apple.finder AppleShowAllFiles -bool true
else
  echo "Hiding hidden files"
  defaults write com.apple.finder AppleShowAllFiles -bool false
fi

if echo "$TWEAKS" | grep -F -q "Enable path bar"; then
  green "Enabling path bar"
  defaults write com.apple.finder ShowPathbar -bool true
else
  echo "Hiding path bar"
  defaults write com.apple.finder ShowPathbar -bool false
fi

if echo "$TWEAKS" | grep -F -q "Enable status bar"; then
  green "Enabling status bar"
  defaults write com.apple.finder ShowStatusBar -bool true
else
  echo "Disabling status bar"
  defaults write com.apple.finder ShowStatusBar -bool false
fi

if echo "$TWEAKS" | grep -F -q "Disable DS_Store files on network"; then
  green "Disabling DS_Store files on network"
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
else
  echo "Enabling DS_Store files on network"
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool false
fi

green "Restarting Dock and Finder"
killall -q Dock Finder
