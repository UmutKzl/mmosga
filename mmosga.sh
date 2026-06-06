#!/usr/bin/env bash

red() {
  printf "\e[1;31m$1\e[0m\n"
}

green() {
  printf "\e[0;92m$1\e[0m\n"
}

checkexec() {
  if command -v "$1" >/dev/null; then
    green "$1 installed already!"
  else
    red "$1 is not installed."
    return 1
  fi
}

checkexec gum

TWEAK_LIST=(
  "Disable recent apps from Dock"
  "Autohide Dock"
)

echo "Which tweaks do you want?"
TWEAKS=$(gum choose --no-limit --cursor="--> " "${TWEAK_LIST[@]}")

if echo "$TWEAKS" | fgrep -q "Disable recent apps from Dock"; then
  green "Disabling recent apps from Dock"
  defaults write com.apple.dock show-recents -bool false
fi

if echo "$TWEAKS" | fgrep -q "Autohide Dock"; then
  green "Autohiding Dock"
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock autohide-time-modifier -float 0.5
  defaults write com.apple.dock autohide-delay -float 0
fi

killall Dock Finder
