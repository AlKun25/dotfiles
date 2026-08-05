# Login-shell setup: PATH only. Interactive-shell stuff (prompt, completion,
# aliases, pyenv/pnpm init) lives in .zshrc.

eval "$(/opt/homebrew/bin/brew shellenv)"

# pipx-installed CLI tools (e.g. poetry)
export PATH="$PATH:$HOME/.local/bin"
