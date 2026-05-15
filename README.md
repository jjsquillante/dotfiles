# dotfiles

Personal macOS environment, bootstrapped in one command.

## Bootstrap a new machine

```bash
git clone https://github.com/jjsquillante/dotfiles.git ~/Development/dotfiles
cd ~/Development/dotfiles
./install.sh --macos
```

After it finishes:

1. Restart the terminal (`exec zsh`).
2. Fill in secrets at `~/.zshrc.local` (gitignored, not in this repo).
3. Restart iTerm2 so it picks up prefs from this repo.
4. In Cursor: command palette → **Install cursor command** to put `cursor` on PATH.

## What gets installed

| Group               | Source                                  |
| ------------------- | --------------------------------------- |
| CLIs + GUIs         | `Brewfile` (`brew bundle`)              |
| Claude Code CLI     | `curl https://claude.ai/install.sh`     |
| Codex CLI           | `npm install -g @openai/codex`          |
| Cursor CLI          | bundled with the Cursor.app cask        |
| oh-my-zsh + plugins | upstream install script + `zplug`       |

## What gets symlinked

| Repo path                  | Linked to                                       |
| -------------------------- | ----------------------------------------------- |
| `zsh/zshrc`                | `~/.zshrc`                                      |
| `zsh/zprofile`             | `~/.zprofile`                                   |
| `zsh/zplug.sh`             | `~/.zplug.sh`                                   |
| `git/gitconfig`            | `~/.gitconfig` (personal identity by default)   |
| `git/gitconfig-work`       | `~/.gitconfig-work` (loaded for assured-dev)    |
| `git/ignore`               | `~/.config/git/ignore`                          |
| `tmux/tmux.conf`           | `~/.tmux.conf`                                  |
| `psql/psqlrc`              | `~/.psqlrc`                                     |
| `ghostty/config`           | `~/.config/ghostty/config`                      |
| `nvim/`                    | `~/.config/nvim`                                |
| `cursor/settings.json`     | `~/Library/Application Support/Cursor/User/...` |
| `cursor/keybindings.json`  | `~/Library/Application Support/Cursor/User/...` |
| `iterm2/`                  | iTerm2 reads prefs from here directly           |

Existing files are backed up to `~/.dotfiles-backup/<timestamp>/` before being replaced.

## Secrets

`~/.zshrc.local` is sourced at the end of `~/.zshrc` and is intentionally **not** part of this repo. A template lives at `zsh/zshrc.local.example` and is copied on first run.

## Re-running

Every step is idempotent:

```bash
./install.sh                  # everything except macOS defaults
./install.sh --skip-brew      # just refresh symlinks
./install.sh --macos          # also apply system defaults
```

## Updating the Brewfile from the current machine

```bash
brew bundle dump --file=~/Development/dotfiles/Brewfile --force
```

Review the diff before committing — `brew bundle dump` includes everything currently installed, including transitive deps that shouldn't be tracked.
