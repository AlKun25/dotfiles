# Interactive-shell config: prompt, completion, aliases, tool init.
# PATH/env setup that only needs to run once per login lives in .zprofile.

# pyenv: manages installed Python interpreter versions.
# uv handles per-project venvs and package installs on top of whichever
# interpreter is active.
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# pnpm, via corepack (bundled with Node, enabled in install.sh). PNPM_HOME
# just needs to be on PATH so the content-addressable store resolves
# consistently across projects; corepack's shim picks the pnpm version from
# each repo's "packageManager" field.
export PNPM_HOME="$HOME/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

source /opt/homebrew/opt/spaceship/spaceship.zsh

fpath+=~/.zfunc
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

alias ls='lsd'
alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'
alias vim='nvim'

# Machine-specific config that shouldn't be tracked in dotfiles: API keys,
# one-off SDK paths (Java/Android/GCP), etc. Not part of this repo.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
