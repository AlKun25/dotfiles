# dotfiles

Personal macOS setup: TypeScript via pnpm (corepack), Python via uv + pyenv,
plus core CLI tooling and AI coding assistants. Built for bootstrapping a
fresh MacBook.

## Usage

```sh
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

Safe to re-run.

## What it does

1. Installs Xcode Command Line Tools and Homebrew if missing.
2. `brew bundle` installs everything in `Brewfile`: git tooling, shell/search
   utilities, neovim, node, uv, pyenv, pipx, opencode, cmux, ghostty.
3. Symlinks `zsh/` and `git/` into `$HOME` with [GNU Stow](https://www.gnu.org/software/stow/)
   (any pre-existing real files at those paths are moved to
   `~/.dotfiles_backup/<timestamp>/` first, not overwritten).
4. Prompts once for your git `user.name`/`user.email` and writes them to
   `~/.gitconfig.local` (untracked — lets the same repo be used with a
   different identity per machine).
5. Enables pnpm via corepack (no separate pnpm formula; corepack's shim
   resolves the version from each repo's `packageManager` field).
6. Installs Claude Code via its native installer (not brew/npm).
7. Sets zsh as the default shell if it isn't already.

## Layout

Each top-level directory under `zsh/` and `git/` is a Stow package: its
contents mirror `$HOME`. `Brewfile` and `install.sh` sit at the repo root
and aren't stowed.

```
zsh/.zprofile        # login shell: PATH / brew shellenv only
zsh/.zshrc            # interactive shell: prompt, aliases, pyenv/pnpm init
git/.gitconfig        # shared config; includes ~/.gitconfig.local for identity
git/.gitignore_global
```

## Python: uv + pyenv

pyenv installs and switches between Python interpreter versions
(`pyenv install 3.x`, `pyenv global 3.x`). uv handles everything on top of
that: per-project virtualenvs and package installs (`uv venv`, `uv sync`,
`uv run`).

## Node: pnpm via corepack

No global pnpm install. Corepack (bundled with Node) resolves the pnpm
version per project from that project's `package.json` `"packageManager"`
field, so different repos can pin different pnpm versions without conflict.

## Not included on purpose

Java/Android SDK, Google Cloud SDK, and conda are machine- or
project-specific rather than part of the core TS/Python setup, so they're
left out of this repo. For anything like that on a given machine, add it to
`~/.zshrc.local` (sourced automatically at the end of `zsh/.zshrc` if it
exists, and untracked) instead of editing the tracked `.zshrc`.

**Security note:** an earlier version of this machine's `.zshrc` had a live
API key hardcoded in plaintext. Don't do that here, in `.zshrc.local`, or
anywhere else in this repo — use a secrets manager or an untracked,
non-synced file instead.
