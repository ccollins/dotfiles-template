# User scripts (stowed from the `bin` package) — needed so `reconcile-managed`
# and friends resolve.
export PATH="$HOME/.local/bin:$PATH"

# =============================================================================
# dotfiles-update plugin config — MUST come before `source $ZSH/oh-my-zsh.sh`
# =============================================================================
export DOTFILES="$HOME/dotfiles"          # adjust if you clone elsewhere
DOTFILES_PACKAGES=(shell git bin)         # keep in sync with PACKAGES in bootstrap.sh
# Dirs holding vendored (pinned) copies with a <name>/.vendor file, so
# `dotfiles vendored` can check them for upstream updates. Uncomment / adjust:
# DOTFILES_VENDORED_DIRS=("$DOTFILES/skills")

# prompt (default) | auto | reminder | disabled
zstyle ':dotfiles:update' mode      prompt    # pulling remote updates
zstyle ':dotfiles:apply'  mode      prompt    # restowing after HEAD moves
zstyle ':dotfiles:plugin' mode      reminder  # the plugin's own self-update
zstyle ':dotfiles:update' frequency 1         # days between remote update checks

# Post-apply hook (runs after `stow --restow`): reconcile app-managed config files
# from their tracked bases. Edit the list in bin/.local/bin/reconcile-managed.
dotfiles-apply-hook() { reconcile-managed; }

# --- Oh My Zsh ---------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git dotfiles-update)
source "$ZSH/oh-my-zsh.sh"

# =============================================================================
# Your shell config below
# =============================================================================
export EDITOR="${EDITOR:-vim}"

# Machine-local overrides / secrets (git-ignored, optional — see bootstrap.sh)
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
