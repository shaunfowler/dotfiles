#!/usr/bin/env bash
set -euo pipefail

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: GNU Stow is required but was not found in PATH." >&2
  echo "Install it first, then rerun this script." >&2
  exit 1
fi

target_dir="${TARGET_DIR:-$HOME}"
packages=()

if [ "$#" -eq 0 ]; then
  while IFS= read -r package; do
    case "$package" in
      docs|scripts)
        continue
        ;;
    esac

    packages+=("$package")
  done < <(find . -mindepth 1 -maxdepth 1 -type d ! -name '.*' | sed 's|^\./||' | sort)
else
  packages=("$@")
fi

if [ "${#packages[@]}" -eq 0 ]; then
  echo "Error: no stow packages found." >&2
  echo "Add top-level package directories (for example: bash/.bashrc) or pass package names explicitly." >&2
  exit 1
fi

stow --target="$target_dir" --restow "${packages[@]}"
