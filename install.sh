#!/usr/bin/env bash
#
# install.sh — bootstrap a fresh macOS machine from this dotfiles repo.
# Safe to re-run: every step is idempotent.
#
# Usage:
#   ./install.sh                  # run everything except macOS defaults
#   ./install.sh --macos          # also apply macOS system defaults
#   ./install.sh --skip-brew      # skip Homebrew + Brewfile
#   ./install.sh --skip-symlinks  # skip dotfile symlinks
#   ./install.sh --skip-clis      # skip AI CLI installers

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

DO_MACOS=0
DO_BREW=1
DO_SYMLINKS=1
DO_CLIS=1
for arg in "$@"; do
  case "$arg" in
    --macos) DO_MACOS=1 ;;
    --skip-brew) DO_BREW=0 ;;
    --skip-symlinks) DO_SYMLINKS=0 ;;
    --skip-clis) DO_CLIS=0 ;;
    -h|--help) sed -n '3,16p' "$0"; exit 0 ;;
    *) echo "unknown flag: $arg" >&2; exit 1 ;;
  esac
done

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()  { printf '   \033[0;32m✓\033[0m %s\n' "$*"; }
warn(){ printf '   \033[1;33m!\033[0m %s\n' "$*"; }

# --- Homebrew ---------------------------------------------------------------
ensure_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    ok "Homebrew already installed"
  fi
}

run_brew_bundle() {
  log "Running brew bundle"
  # Cache sudo up-front so cask adoption (chmod on existing /Applications/*) works non-interactively.
  if ! sudo -n true 2>/dev/null; then
    log "Caching sudo credentials for cask adoption"
    sudo -v
  fi
  ( while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done ) &
  local sudo_keepalive=$!
  trap 'kill $sudo_keepalive 2>/dev/null || true' EXIT

  brew update
  brew bundle --file="$DOTFILES_DIR/Brewfile"
  brew cleanup

  kill "$sudo_keepalive" 2>/dev/null || true
  trap - EXIT
}

# --- oh-my-zsh --------------------------------------------------------------
ensure_omz() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Installing oh-my-zsh"
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    ok "oh-my-zsh already installed"
  fi
}

# --- AI CLIs (not in brew) --------------------------------------------------
install_ai_clis() {
  if ! command -v claude >/dev/null 2>&1; then
    log "Installing Claude Code CLI"
    curl -fsSL https://claude.ai/install.sh | bash
  else
    ok "claude CLI present ($(claude --version 2>/dev/null | head -1))"
  fi

  if ! command -v codex >/dev/null 2>&1; then
    log "Installing Codex CLI (npm global)"
    if command -v npm >/dev/null 2>&1; then
      npm install -g @openai/codex
    else
      warn "npm not on PATH yet — install Node via nvm, then re-run with --skip-brew --skip-symlinks"
    fi
  else
    ok "codex CLI present ($(codex --version 2>/dev/null | head -1))"
  fi

  # Cursor CLI ships with the Cursor.app cask; reminder only.
  if [ -d "/Applications/Cursor.app" ] && ! command -v cursor >/dev/null 2>&1; then
    warn "Open Cursor and run the 'Shell Command: Install cursor command' from the command palette"
  fi
}

# --- Symlinks ---------------------------------------------------------------
backup_and_link() {
  local src="$1" dest="$2"
  if [ -L "$dest" ]; then
    local current
    current="$(readlink "$dest")"
    if [ "$current" = "$src" ]; then
      ok "linked: $dest"
      return
    fi
    rm "$dest"
  elif [ -e "$dest" ]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dest" "$BACKUP_DIR/"
    warn "backed up existing $dest → $BACKUP_DIR/"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  ok "linked: $dest → $src"
}

link_all() {
  log "Linking dotfiles"

  # zsh
  backup_and_link "$DOTFILES_DIR/zsh/zshrc"    "$HOME/.zshrc"
  backup_and_link "$DOTFILES_DIR/zsh/zprofile" "$HOME/.zprofile"
  backup_and_link "$DOTFILES_DIR/zsh/zplug.sh" "$HOME/.zplug.sh"

  # git
  backup_and_link "$DOTFILES_DIR/git/gitconfig"      "$HOME/.gitconfig"
  backup_and_link "$DOTFILES_DIR/git/gitconfig-work" "$HOME/.gitconfig-work"
  backup_and_link "$DOTFILES_DIR/git/ignore"         "$HOME/.config/git/ignore"

  # tmux
  backup_and_link "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

  # psql
  backup_and_link "$DOTFILES_DIR/psql/psqlrc" "$HOME/.psqlrc"

  # ghostty
  backup_and_link "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

  # nvim
  backup_and_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

  # cursor
  local cursor_user="$HOME/Library/Application Support/Cursor/User"
  if [ -d "/Applications/Cursor.app" ]; then
    backup_and_link "$DOTFILES_DIR/cursor/settings.json"    "$cursor_user/settings.json"
    backup_and_link "$DOTFILES_DIR/cursor/keybindings.json" "$cursor_user/keybindings.json"
  else
    warn "Cursor.app not found — skipping Cursor symlinks (re-run after installing)"
  fi

  # zshrc.local — bootstrap a stub once, never overwrite
  if [ ! -f "$HOME/.zshrc.local" ]; then
    cp "$DOTFILES_DIR/zsh/zshrc.local.example" "$HOME/.zshrc.local"
    chmod 600 "$HOME/.zshrc.local"
    warn "created ~/.zshrc.local from template — fill in secrets manually"
  fi
}

# --- iTerm2: load prefs from this repo --------------------------------------
configure_iterm2() {
  if [ -d "/Applications/iTerm.app" ]; then
    log "Pointing iTerm2 at $DOTFILES_DIR/iterm2"
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iterm2"
    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    ok "iTerm2 prefs folder set (restart iTerm to take effect)"
  else
    warn "iTerm.app not found — skipping iTerm2 prefs"
  fi
}

# --- macOS defaults ---------------------------------------------------------
run_macos_defaults() {
  if [ -x "$DOTFILES_DIR/scripts/macos-defaults.sh" ]; then
    log "Applying macOS defaults"
    "$DOTFILES_DIR/scripts/macos-defaults.sh"
  fi
}

# --- main -------------------------------------------------------------------
main() {
  log "Dotfiles bootstrap from $DOTFILES_DIR"
  if [ "$DO_BREW" -eq 1 ]; then
    ensure_homebrew
    run_brew_bundle
  fi
  ensure_omz
  if [ "$DO_CLIS" -eq 1 ]; then
    install_ai_clis
  fi
  if [ "$DO_SYMLINKS" -eq 1 ]; then
    link_all
    configure_iterm2
  fi
  if [ "$DO_MACOS" -eq 1 ]; then
    run_macos_defaults
  else
    warn "Skipped macOS defaults — re-run with --macos to apply"
  fi

  log "Done."
  cat <<EOF

Next steps:
  1. Restart your terminal (or 'exec zsh') to pick up the new shell config.
  2. Fill in secrets at ~/.zshrc.local (Auth0, NEW_RELIC, etc.).
  3. Restart iTerm2 so it loads prefs from the dotfiles repo.
  4. In Cursor: open the command palette → "Install cursor command" if the CLI is missing.

EOF
}

main "$@"
