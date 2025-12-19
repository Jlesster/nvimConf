#!/usr/bin/env bash

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/quickshell"
LAZYGIT_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit"
COLOR_FILE="$STATE_DIR/user/generated/material_colors.scss"

mkdir -p "$LAZYGIT_CONFIG_DIR"

# Parse colors from SCSS
declare -A colors
while IFS=': ' read -r name value; do
  name="${name#\$}"
  value="${value%;}"
  value="${value# }"
  colors[$name]="$value"
done < <(grep '^\$' "$COLOR_FILE")

# Use generated LazyGit colors with dark fallbacks
selectedLineBg="${colors[lazygit_selectedLineBg]:-#1a0f2e}"
selectedRangeBg="${colors[lazygit_selectedRangeBg]:-#2a1a3e}"
inactiveBorder="${colors[lazygit_inactiveBorder]:-#3d2a4f}"
activeBorder="${colors[lazygit_activeBorder]:-${colors[primary]:-#9d7dce}}"
optionsText="${colors[lazygit_optionsText]:-${colors[primaryContainer]:-#b8a8d8}}"
defaultFg="${colors[lazygit_defaultFg]:-${colors[onSurface]:-#e0e0e0}}"
cherryPickedBg="${colors[lazygit_cherryPickedBg]:-#2d1b4e}"
cherryPickedFg="${colors[lazygit_cherryPickedFg]:-#ffffff}"
unstagedChanges="${colors[lazygit_unstagedChanges]:-${colors[error]:-#f07178}}"

# Generate LazyGit config with dynamic colors
cat > "$LAZYGIT_CONFIG_DIR/config.yml" << EOF
gui:
  theme:
    selectedLineBgColor:
      - '$selectedLineBg'
    selectedRangeBgColor:
      - '$selectedRangeBg'
    activeBorderColor:
      - '$activeBorder'
      - bold
    inactiveBorderColor:
      - '$inactiveBorder'
    optionsTextColor:
      - '$optionsText'
      - bold
    cherryPickedCommitBgColor:
      - '$cherryPickedBg'
    cherryPickedCommitFgColor:
      - '$cherryPickedFg'
      - bold
    defaultFgColor:
      - '$defaultFg'
    unstagedChangesColor:
      - '$unstagedChanges'
      - bold
EOF

echo "LazyGit colors updated with darker theme!"
