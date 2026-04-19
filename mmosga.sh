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

clear

if ! gum confirm "Do you want to proceed?" ; then
  exit 1
fi

clear
# Dock
defaults write com.apple.dock magnification -bool true # enable magnification
defaults write com.apple.dock largesize -int 80 # set magnification level
defaults write com.apple.dock autohide -bool true # enable autohide
defaults write com.apple.dock autohide-time-modifier -float 0.5 # speed up autohide animation
defaults write com.apple.dock autohide-delay -float 0 # remove autohide delay
echo "Dock settings are finished."

# Finder
defaults write com.apple.finder AppleShowAllFiles -bool true # enable hidden files
defaults write com.apple.finder ShowPathbar -bool true # enable path bar
defaults write com.apple.finder ShowStatusBar -bool true # enable status bar
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # set list view default
defaults write com.apple.finder NewWindowTarget -string "PfHm" # set new finder windows to open in home
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/" # set Finder home path to user's home folder
defaults write com.apple.finder QLEnableTextSelection -bool true # enable text selection in quick look
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true # don't store DS_Store files on network
echo "Finder settings are finished."

# Keyboard
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false # disable automatic spelling
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false # disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false # disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false # disable automatic quote substitution defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false # disable automatic dash substitution
echo "Keyboard settings are finished."

# Trackpad
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false # disable natural scrolling in trackpad
echo "Trackpad settings are finished."

# Accent color (purple)
defaults write -g AppleAccentColor -int 5
defaults write -g AppleColorPreferences -dict AccentColor -int 5
defaults write -g AppleHighlightColor -string "0.968627 0.831373 1.000000 Purple"
echo "Accent color has been set up to purple."

# Quarantine settings
defaults write com.apple.LaunchServices LSQuarantine -bool false # less Are you sure? prompts
echo "Quarantine settings are finished."

# Kill services
killall Dock SystemUIServer Finder TextEdit

clear

# Choose apps and install them
apps="spotify google-chrome ungoogled-chromium firefox vivaldi \
  lazygit visual-studio-code zed neovim neovide-app emacs helix godot antigravity \
  cursor windsurf tmux zellij fzf ripgrep bat eza zoxide gh python node wezterm \
  alacritty kitty ghostty utm raycast mac-mouse-fix betterdisplay caffeine rectangle \
  steam epic-games gog-galaxy parallels crossover heroic luanti supertuxkart obs \
  lm-studio ollama claude claude-code opencode chatgpt chatgpt-atlas llama.cpp"

app_selection=$(gum choose --no-limit $apps --header "Select apps to install")

if [ -n "$app_selection" ]; then
  brew install $app_selection
else
  echo "No package selected, continuing..."
fi

# Rosetta 2
if ! pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto >/dev/null && gum confirm "Do you want to install Rosetta 2?" ; then
  softwareupdate --install-rosetta --agree-to-license
else
  echo "Skipping Rosetta 2 because you already have it."
fi

# Neovim
if command -v nvim >/dev/null; then
  if [ ! -d "$HOME/.config/nvim" ] && gum confirm "Do you want to install a Neovim config?"; then
    distro=$(gum choose --header "Neovim distro" nvchad lazyvim astronvim)

    command -v node >/dev/null || brew install node || true
    command -v tree-sitter >/dev/null || brew install tree-sitter-cli || true
    command -v rg >/dev/null || brew install ripgrep || true

    case "$distro" in
      nvchad)
        git clone --depth 1 https://github.com/NvChad/starter ~/.config/nvim
        rm -rf ~/.config/nvim/.git
        echo "Don't forget to read wiki https://nvchad.com/docs/quickstart/install"
        ;;
      lazyvim)
        git clone --depth 1 https://github.com/LazyVim/starter ~/.config/nvim
        rm -rf ~/.config/nvim/.git
        ;;
      astronvim)
        git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
        rm -rf ~/.config/nvim/.git
        echo "Don't forget to read wiki https://docs.astronvim.com/#-setup"
        ;;
    esac
  else
    echo "Skipping Neovim config section because you already have a Neovim config."
  fi
fi

# Emacs
if command -v emacs >/dev/null; then
  if [ ! -d "$HOME/.emacs.d" ] && [ ! -d "$HOME/.config/emacs" ] && gum confirm "Do you want to install a Emacs config?"; then
    distro=$(gum choose --header "Emacs distro" spacemacs doom-emacs)

    case "$distro" in
      doom-emacs)
        git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
        ~/.config/emacs/bin/doom install
        ;;
      spacemacs)
        git clone --depth 1 https://github.com/syl20bnr/spacemacs ~/.emacs.d
        ;;
    esac
  else
    echo "Skipping Emacs config section because you already have a Emacs config."
  fi
fi

# Zsh
if command -v zsh >/dev/null; then
  if [ ! -f "$HOME/.zshrc" ] && gum confirm "Do you want to configure Zsh?"; then
    if gum confirm "Do you want to use zsh-syntax-highlighting?"; then
      brew install zsh-syntax-highlighting
      echo "source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc # enable autosyntax
    fi
    if gum confirm "Do you want to use zsh-autosuggestions?"; then
      brew install zsh-autosuggestions
      echo "source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc # enable autosuggestions
    fi
    if gum confirm "Do you want to use a custom prompt?"; then
      echo "export PS1='%B%F{Cyan}%~%b%F{white} $ '" >> ~/.zshrc # a better prompt
    fi
    if gum confirm "Do you want to have a better tab selection?"; then
      echo "autoload -Uz compinit" >> ~/.zshrc
      echo "compinit" >> ~/.zshrc # modern zsh autocomplete system
      echo "zstyle ':completion:*' menu select" >> ~/.zshrc # use arrow keys
    fi
  else
    echo "Skipping Zsh config section because you already have a Zsh config."
  fi
fi

# Ghostty
if command -v ghostty >/dev/null; then
  if [ ! -f "$HOME/.config/ghostty/config" ] && [ ! -f "$HOME/.config/ghostty/config.ghostty" ] && gum confirm "Do you want to configure Ghostty?"; then
    [[ ! -d ~/.config/ghostty ]] && mkdir -p ~/.config/ghostty # create config folder if doesn't exist
    echo "background-opacity = $(gum input --placeholder 'Transparency (between 0.0 and 1.0)')" >> ~/.config/ghostty/config.ghostty
    gum confirm "Do you want to use Option key as Alt?" && echo "macos-option-as-alt = left" >> ~/.config/ghostty/config.ghostty
    scheme=$(ghostty +list-themes | sed 's/ (.*)//' | gum choose --header "Select a color scheme")
    echo "theme = $scheme" >> ~/.config/ghostty/config.ghostty
  else
    echo "Skipping Ghostty config section because you already have a Ghostty config."
  fi
fi

echo "Everything is got finished. Good luck!"
