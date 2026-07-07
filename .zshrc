
# ── Environment ───────────────────────────────────────────────────────────────
export EDITOR="nano"
export VISUAL="code --wait"

# RVM (keep last so it wins over system ruby)
export PATH="$PATH:$HOME/.rvm/bin"

# ── History ───────────────────────────────────────────────────────────────────
setopt HIST_IGNORE_SPACE      # commands prefixed with a space are not saved
setopt HIST_REDUCE_BLANKS     # strip extra whitespace before saving
setopt HIST_VERIFY            # expand history substitution before executing
setopt EXTENDED_HISTORY       # save timestamp + duration in history file
setopt INC_APPEND_HISTORY     # append immediately, not on shell exit
setopt NO_SHARE_HISTORY       # don't merge history across sessions (required for folder-scoped history)

# ── Completion ────────────────────────────────────────────────────────────────
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/compcache"

# ── Shell behaviour ───────────────────────────────────────────────────────────
setopt AUTO_CD                # type a directory name to cd into it
setopt PUSHD_IGNORE_DUPS      # no duplicate entries in the dir stack
setopt NO_NOMATCH             # don't error on unmatched globs, pass them through
setopt INTERACTIVE_COMMENTS   # allow # comments in interactive shells

# Bracketed paste — remove this line if you see literal escape sequences on paste
unset zle_bracketed_paste

# ── Aliases: system ───────────────────────────────────────────────────────────
alias df='df -h'
alias jour='journalctl -ef'
alias feh='feh -F -. -Z'

# ── Aliases: NixOS ────────────────────────────────────────────────────────────
alias nixswitch='sudo nixos-rebuild --flake /home/vboysepe/.config/nixos switch'
alias nixtest='sudo nixos-rebuild --flake /home/vboysepe/.config/nixos test'
alias nixupgrade='sudo nix flake update --flake /home/vboysepe/.config/nixos && nixswitch'
alias nixpurge='sudo nix-collect-garbage --delete-older-than 3d'
alias nixgens='sudo nix-env -p /nix/var/nix/profiles/system --list-generations'

# ── Aliases: dotfile config ───────────────────────────────────────────────────
# Bare-repo git wrapper for dotfiles tracked in ~/.cfg
alias config='/run/current-system/sw/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Fast completion for config: set git dir env vars so _git doesn't scan $HOME for files
_config_complete() {
  local -x GIT_DIR="$HOME/.cfg"
  local -x GIT_WORK_TREE="$HOME"
  _git
}
compdef _config_complete config

# Convenience shortcuts for opening NixOS configs in editors
alias chpkg='${EDITOR:-nano} ~/.config/nixos/programs.nix'
alias chcfg='${EDITOR:-nano} ~/.config/nixos/configuration.nix'
alias confignix='GIT_WORK_TREE=$HOME GIT_DIR=$HOME/.cfg code ~/.config/nixos'
alias configcode='GIT_WORK_TREE=$HOME GIT_DIR=$HOME/.cfg code ~/.config'

# ── Functions ─────────────────────────────────────────────────────────────────

# Create a directory and cd into it
mkcd() { mkdir -p "$1" && cd "$1" }

# Quick nix shell with a package (e.g. nixrun cowsay)
nixrun() { nix shell "nixpkgs#$1" --command "${@:2:-${1}}" }

# Show which nix package provides a binary
nixfind() { nix-locate --whole-name --top-level "bin/$1" }

# ── Folder-specific history ───────────────────────────────────────────────────
# Directories that get their own isolated history file
FOLDER_HISTORY_DIRS=(
  "/home/vboysepe/baseball-tracker"
  "/home/vboysepe/.config/nixos"
  "/home/vboysepe/.config"
)

chpwd() {
  # Save and pop the current history stack entry before switching
  fc -P 2>/dev/null

  for dir in $FOLDER_HISTORY_DIRS; do
    if [[ "$PWD" == "$dir" || "$PWD" == "$dir/"* ]]; then
      HISTFILE="$dir/.zsh_history"
      fc -p "$HISTFILE"
      return
    fi
  done

  # Default history when outside all watched folders
  HISTFILE="$HOME/.zsh_history"
  fc -p "$HISTFILE"
}
