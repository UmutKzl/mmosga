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

if [ "${1:-}" == "--force" ]; then
  force="true"
else
  force="false"
fi

brewprefix="$(brew --prefix)"

clear
# Dock
if gum confirm "Do you want to enable magnification?"; then
  defaults write com.apple.dock magnification -bool true # enable magnification
  defaults write com.apple.dock largesize -int 80 # set magnification level
else
  defaults write com.apple.dock magnification -bool false # disable magnification
fi

if gum confirm "Do you want to disable recent apps from dock?"; then
  defaults write com.apple.dock show-recents -bool false # disable recent apps
else
  defaults write com.apple.dock show-recents -bool true # enable recent apps
fi

if gum confirm "Do you want to autohide dock?"; then
  defaults write com.apple.dock autohide -bool true # enable autohide
  defaults write com.apple.dock autohide-time-modifier -float 0.5 # speed up autohide animation
  defaults write com.apple.dock autohide-delay -float 0 # remove autohide delay
else
  defaults write com.apple.dock autohide -bool false # disable autohide
fi
echo "Dock settings are finished..."

# Finder
if gum confirm "Do you want to see hidden files by default?"; then
  defaults write com.apple.finder AppleShowAllFiles -bool true # enable hidden files
else
  defaults write com.apple.finder AppleShowAllFiles -bool false # disable hidden files
fi

if gum confirm "Do you want to enable path bar and status bar?"; then
  defaults write com.apple.finder ShowPathbar -bool true # enable path bar
  defaults write com.apple.finder ShowStatusBar -bool true # enable status bar
else
  defaults write com.apple.finder ShowPathbar -bool false # disable path bar
  defaults write com.apple.finder ShowStatusBar -bool false # disable status bar
fi

finder_view_choice=$(gum choose list icon)
case "$finder_view_choice" in
  list)
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # set list view default
    ;;
  icon)
    defaults write com.apple.finder FXPreferredViewStyle -string "icnv" # set icon view default
    ;;
esac

if gum confirm "Do you want to start finder from $HOME folder?"; then
  defaults write com.apple.finder NewWindowTarget -string "PfHm" # set new finder windows to open in home
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/" # set Finder home path to user's home folder
fi

if gum confirm "Do you want to enable text selection in Quick look?"; then
  defaults write com.apple.finder QLEnableTextSelection -bool true # enable text selection in quick look
else
  defaults write com.apple.finder QLEnableTextSelection -bool false # disable text selection in quick look
fi

if gum confirm "Do you want to disable storing DS_Store files on network?"; then
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true # don't store DS_Store files on network
else
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool false # store DS_Store files on network
fi

echo "Finder settings are finished..."

# Keyboard
if gum confirm "Do you want automatic periods, capitalization, spelling, quotes to get disabled in your keyboard?"; then
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false # disable automatic spelling
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false # disable automatic capitalization
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false # disable automatic period substitution
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false # disable automatic quote substitution
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false # disable automatic dash substitution
else
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool true # enable automatic spelling
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true # enable automatic capitalization
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true # enable automatic period substitution
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool true # enable automatic quote substitution
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool true # enable automatic dash substitution
fi
echo "Keyboard settings are finished..."

# Trackpad
if gum confirm "Do you want to disable natural scroll?"; then
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false # disable natural scrolling in trackpad
else
  defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true # enable natural scrolling in trackpad
fi
echo "Trackpad settings are finished..."

# Kill services
killall Dock SystemUIServer Finder TextEdit || true

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
  echo "Skipping Rosetta 2..."
fi

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
    echo "Skipping Neovim config section..."
  fi
fi

# Emacs
if command -v emacs >/dev/null; then
  [[ "$force" == "true" ]] && rm -rf ~/.config/emacs || true
  if [ ! -d "$HOME/.emacs.d" ] && [ ! -d "$HOME/.config/emacs" ] && gum confirm "Do you want to install a Emacs config?"; then
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
  else
    echo "Skipping Emacs config section..."
  fi
fi

# Zsh
if command -v zsh >/dev/null; then
  [[ "$force" == "true" ]] && rm -rf ~/.zshrc || true
  if [ ! -f "$HOME/.zshrc" ] && gum confirm "Do you want to configure Zsh?"; then
    if gum confirm "Do you want to use zsh-syntax-highlighting?"; then
      [[ ! -f "$brewprefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && brew install zsh-syntax-highlighting
      echo "source $brewprefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc # enable autosyntax
    fi
    if gum confirm "Do you want to use zsh-autosuggestions?"; then
      [[ ! -f "$brewprefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && brew install zsh-autosuggestions
      echo "source $brewprefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc # enable autosuggestions
    fi
    if gum confirm "Do you want to use a custom prompt?"; then
      echo "export PS1='%B%F{Cyan}%~%b%F{white} $ '" >> ~/.zshrc # a better prompt
    fi
    if gum confirm "Do you want to have a better tab selection?"; then
      echo "autoload -Uz compinit" >> ~/.zshrc
      echo "compinit" >> ~/.zshrc # modern zsh autocomplete system
      echo "zstyle ':completion:*' menu select" >> ~/.zshrc # use arrow keys
    fi
    if gum confirm "Do you want to use eza (ls alternative)?"; then
      command -v eza >/dev/null || brew install eza || true
      echo 'alias ls="eza"' >> ~/.zshrc
      echo 'alias la="eza -a"' >> ~/.zshrc
      echo 'alias tree="eza -T"' >> ~/.zshrc
    fi
  else
    echo "Skipping Zsh config section..."
  fi
fi

# Ghostty
if command -v ghostty >/dev/null; then
  [[ "$force" == "true" ]] && rm -rf ~/.config/ghostty || true
  if [ ! -f "$HOME/.config/ghostty/config" ] && [ ! -f "$HOME/.config/ghostty/config.ghostty" ] && gum confirm "Do you want to configure Ghostty?"; then
    [[ ! -d ~/.config/ghostty ]] && mkdir -p ~/.config/ghostty # create config folder if doesn't exist
    echo "background-opacity = $(gum input --header 'Transparency (between 0.0 and 1.0)' --value '1.0')" >> ~/.config/ghostty/config.ghostty
    gum confirm "Do you want to use Option key as Alt?" && echo "macos-option-as-alt = left" >> ~/.config/ghostty/config.ghostty
    scheme=$(ghostty +list-themes | sed -E 's/ \(resources\)$//' | gum choose --header "Select a color scheme")
    echo "theme = $scheme" >> ~/.config/ghostty/config.ghostty
  else
    echo "Skipping Ghostty config section..."
  fi
fi

echo "Everything is got finished. Good luck!"
