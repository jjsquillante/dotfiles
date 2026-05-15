#!/usr/bin/env bash
#
# macos-defaults.sh — opinionated macOS system defaults.
# Run via `./install.sh --macos` or directly.
# Re-runnable. Most changes require a logout or app restart to take effect.

set -euo pipefail

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

# Close any open System Settings panes so we don't override edits.
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

log "Keyboard: fast key repeat, short delay until repeat"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

log "Trackpad: tap to click"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

log "Finder: show hidden files, all extensions, path bar, status bar"
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

log "Screenshots: PNG, no shadow, save to ~/Screenshots"
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

log "Dock: always visible, no recents"
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock show-recents -bool false

log "Safari + Misc: show full URLs, expanded save dialogs"
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true 2>/dev/null || true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

log "Restart affected apps"
for app in Dock Finder SystemUIServer; do
  killall "$app" >/dev/null 2>&1 || true
done

log "Done. Some changes (key repeat) need a logout to fully apply."
