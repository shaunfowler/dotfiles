# dotfiles

This repository is set up to manage dotfiles with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a stow package whose contents mirror the target path under your home directory.

For example:

```text
bash/.bashrc
nvim/.config/nvim/init.lua
```

## Install

1. Install GNU Stow.
2. Add your dotfiles as top-level package directories.
3. Run the installer from the repository root:

```bash
./install.sh
```

To install only specific packages, pass them as arguments:

```bash
./install.sh bash nvim
```

By default the script stows into `$HOME`. Set `TARGET_DIR` to use another destination.
