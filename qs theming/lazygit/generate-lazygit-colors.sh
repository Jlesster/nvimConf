#!/usr/bin/env bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
STATE_DIR="$XDG_STATE_HOME/quickshell"
LAZYGIT_CONFIG="$XDG_CONFIG_HOME/lazygit/config.yml"

# Read colors from generated material colors
COLORS_FILE="$STATE_DIR/user/generated/material_colors.scss"

if [ ! -f "$COLORS_FILE" ]; then
    echo "Material colors file not found: $COLORS_FILE"
    exit 1
fi

# Extract LazyGit colors
selectedLineBg=$(grep 'lazygit_selectedLineBg' "$COLORS_FILE" | cut -d: -f2 | cut -d' ' -f2 | cut -d';' -f1)
selectedRangeBg=$(grep 'lazygit_selectedRangeBg' "$COLORS_FILE" | cut -d: -f2 | cut -d' ' -f2 | cut -d';' -f1)
inactiveBorder=$(grep 'lazygit_inactiveBorder' "$COLORS_FILE" | cut -d: -f2 | cut -d' ' -f2 | cut -d';' -f1)
activeBorder=$(grep 'lazygit_activeBorder' "$COLORS_FILE" | cut -d: -f2 | cut -d' ' -f2 | cut -d';' -f1)
optionsText=$(grep 'lazygit_optionsText' "$COLORS_FILE" | cut -d: -f2 | cut -d' ' -f2 | cut -d';' -f1)
defaultFg=$(grep 'lazygit_defaultFg' "$COLORS_FILE" | cut -d: -f2 | cut -d' ' -f2 | cut -d';' -f1)
cherryPickedFg=$(grep 'lazygit_cherryPickedFg' "$COLORS_FILE" | cut -d: -f2 | cut -d' ' -f2 | cut -d';' -f1)
cherryPickedBg=$(grep 'lazygit_cherryPickedBg' "$COLORS_FILE" | cut -d: -f2 | cut -d' ' -f2 | cut -d';' -f1)
unstagedChanges=$(grep 'lazygit_unstagedChanges' "$COLORS_FILE" | cut -d: -f2 | cut -d' ' -f2 | cut -d';' -f1)
stagedChanges=$(grep 'lazygit_stagedChanges' "$COLORS_FILE" | cut -d: -f2 | cut -d' ' -f2 | cut -d';' -f1)
searchMatching=$(grep 'lazygit_searchMatching' "$COLORS_FILE" | cut -d: -f2 | cut -d' ' -f2 | cut -d';' -f1)

# Create LazyGit config directory if it doesn't exist
mkdir -p "$(dirname "$LAZYGIT_CONFIG")"

# Backup existing config if it exists and isn't already a backup
if [ -f "$LAZYGIT_CONFIG" ] && [ ! -f "$LAZYGIT_CONFIG.backup" ]; then
    cp "$LAZYGIT_CONFIG" "$LAZYGIT_CONFIG.backup"
fi

# Generate LazyGit config with dynamic colors
cat > "$LAZYGIT_CONFIG" << EOF
# Auto-generated LazyGit config with Catppuccin-harmonized Material You colors
# Original config backed up to config.yml.backup

gui:
  theme:
    activeBorderColor:
      - '$activeBorder'
      - bold
    inactiveBorderColor:
      - '$inactiveBorder'
    optionsTextColor:
      - '$optionsText'
    selectedLineBgColor:
      - '$selectedLineBg'
    selectedRangeBgColor:
      - '$selectedRangeBg'
    cherryPickedCommitBgColor:
      - '$cherryPickedBg'
    cherryPickedCommitFgColor:
      - '$cherryPickedFg'
    unstagedChangesColor:
      - '$unstagedChanges'
    defaultFgColor:
      - '$defaultFg'
    searchingActiveBorderColor:
      - '$activeBorder'
      - bold

  # Enhanced UI settings
  showFileTree: true
  showListFooter: true
  showRandomTip: false
  showCommandLog: false
  showBottomLine: true
  showIcons: true
  nerdFontsVersion: "3"

git:
  paging:
    colorArg: always
    pager: delta --dark --paging=never

refresher:
  refreshInterval: 10
  fetchInterval: 60

update:
  method: never

notARepository: 'skip'

# Keybindings - keep your existing ones or customize
keybinding:
  universal:
    quit: 'q'
    quit-alt1: '<c-c>'
    return: '<esc>'
    quitWithoutChangingDirectory: 'Q'
    togglePanel: '<tab>'
    prevItem: '<up>'
    nextItem: '<down>'
    prevItem-alt: 'k'
    nextItem-alt: 'j'
    prevPage: ','
    nextPage: '.'
    scrollLeft: 'H'
    scrollRight: 'L'
    gotoTop: '<'
    gotoBottom: '>'
    prevBlock: '<left>'
    nextBlock: '<right>'
    prevBlock-alt: 'h'
    nextBlock-alt: 'l'
    nextMatch: 'n'
    prevMatch: 'N'
    startSearch: '/'
    optionMenu: 'x'
    optionMenu-alt1: '?'
    select: '<space>'
    goInto: '<enter>'
    confirm: '<enter>'
    remove: 'd'
    new: 'n'
    edit: 'e'
    openFile: 'o'
    scrollUpMain: '<pgup>'
    scrollDownMain: '<pgdown>'
    scrollUpMain-alt1: 'K'
    scrollDownMain-alt1: 'J'
    scrollUpMain-alt2: '<c-u>'
    scrollDownMain-alt2: '<c-d>'
    executeCustomCommand: ':'
    createRebaseOptionsMenu: 'm'
    pushFiles: 'P'
    pullFiles: 'p'
    refresh: 'R'
    createPatchOptionsMenu: '<c-p>'
    nextTab: ']'
    prevTab: '['
    nextScreenMode: '+'
    prevScreenMode: '_'
    undo: 'z'
    redo: '<c-z>'
    filteringMenu: '<c-s>'
    diffingMenu: 'W'
    diffingMenu-alt: '<c-e>'
    copyToClipboard: '<c-o>'
    openRecentRepos: '<c-r>'
    submitEditorText: '<enter>'
    extrasMenu: '@'
    toggleWhitespaceInDiffView: '<c-w>'
    increaseContextInDiffView: '}'
    decreaseContextInDiffView: '{'
EOF

echo "LazyGit colors updated with Catppuccin-harmonized Material You theme!"
