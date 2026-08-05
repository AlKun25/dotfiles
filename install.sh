#!/usr/bin/env bash
# Fresh-Mac bootstrap: Homebrew, core CLI tools, TypeScript (pnpm via
# corepack) and Python (uv + pyenv) toolchains, AI coding tools, and
# symlinked dotfiles. Safe to re-run.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$1"; }

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This install script targets macOS only." >&2
  exit 1
fi

# --- Xcode Command Line Tools ------------------------------------------------
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "Re-run this script once the Xcode Command Line Tools install finishes."
  exit 1
fi

# --- Homebrew -----------------------------------------------------------------
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

info "Installing packages from Brewfile..."
brew bundle --file="$DOTFILES_DIR/Brewfile"

# --- Symlink dotfiles via GNU Stow -----------------------------------------
# Each top-level dir (zsh/, git/, ...) is a Stow package mirroring $HOME.
STOW_PACKAGES=(zsh git)

# Stow refuses to link over a real (non-symlink) file, so anything already
# at the target path gets backed up first. Re-running is safe: correct
# symlinks are left alone, and --restow reconciles anything changed.
for pkg in "${STOW_PACKAGES[@]}"; do
  while IFS= read -r -d '' f; do
    rel="${f#"$DOTFILES_DIR"/"$pkg"/}"
    dst="$HOME/$rel"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
      mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
      mv "$dst" "$BACKUP_DIR/$rel"
      warn "Backed up existing $dst -> $BACKUP_DIR/$rel"
    fi
  done < <(find "$DOTFILES_DIR/$pkg" -type f -print0)
done

info "Linking dotfiles with stow..."
stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "${STOW_PACKAGES[@]}"

# --- git identity (untracked, per-machine) ---------------------------------
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  info "Setting up git identity (stored in ~/.gitconfig.local, not tracked)"
  read -rp "git user.name: " git_name
  read -rp "git user.email: " git_email
  cat > "$HOME/.gitconfig.local" <<-EOF
	[user]
		name = ${git_name}
		email = ${git_email}
	EOF
fi

# --- pnpm, via corepack (bundled with Node) --------------------------------
if command -v corepack &>/dev/null; then
  info "Enabling pnpm via corepack..."
  corepack enable
  corepack prepare pnpm@latest --activate
fi

# --- Claude Code (native installer, not brew) ------------------------------
if ! command -v claude &>/dev/null; then
  info "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
fi

# --- default shell ----------------------------------------------------------
if [[ "$SHELL" != *"zsh"* ]]; then
  info "Setting zsh as default shell..."
  chsh -s "$(command -v zsh)"
fi

echo
info "Done."
echo "  - Python interpreters: 'pyenv install 3.x && pyenv global 3.x' to pick a default."
echo "  - Project envs: 'uv venv' / 'uv sync' inside a project directory."
echo "  - Node: pnpm resolves per-project via each repo's \"packageManager\" field."
echo "  - Machine-specific env (API keys, one-off SDK paths): put them in ~/.zshrc.local (untracked)."
[[ -d "$BACKUP_DIR" ]] && echo "  - Pre-existing dotfiles were backed up to $BACKUP_DIR"
