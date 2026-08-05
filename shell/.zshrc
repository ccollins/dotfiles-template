# =============================================================================
# dotfiles-update plugin config — MUST come before `source $ZSH/oh-my-zsh.sh`
# =============================================================================
export DOTFILES="$HOME/dotfiles"          # adjust if you clone elsewhere
DOTFILES_PACKAGES=(shell git)             # keep in sync with PACKAGES in bootstrap.sh

# prompt (default) | auto | reminder | disabled
zstyle ':dotfiles:update' mode      prompt   # pulling remote updates
zstyle ':dotfiles:apply'  mode      prompt   # restowing after HEAD moves
zstyle ':dotfiles:update' frequency 1        # days between remote update checks

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
