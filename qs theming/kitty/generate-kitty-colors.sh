#!/usr/bin/env bash

QUICKSHELL_CONFIG_NAME="ii"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
STATE_DIR="$XDG_STATE_HOME/quickshell"
KITTY_CONFIG_DIR="$XDG_CONFIG_HOME/kitty"

# Read the generated material colors
COLORS_FILE="$STATE_DIR/user/generated/material_colors.scss"

if [ ! -f "$COLORS_FILE" ]; then
    echo "Colors file not found: $COLORS_FILE"
    exit 1
fi

# Create kitty theme directory if it doesn't exist
mkdir -p "$KITTY_CONFIG_DIR"

# Parse colors and generate Kitty config
{
    echo "# Auto-generated Kitty theme - $(date)"
    echo "# Generated from: $COLORS_FILE"
    echo ""

    # Extract kitty colors from the SCSS file
    while IFS= read -r line; do
        if [[ "$line" =~ ^\$kitty_([^:]+):[[:space:]]*([^;]+); ]]; then
            color_name="${BASH_REMATCH[1]}"
            color_value="${BASH_REMATCH[2]}"

            # Map to kitty format
            echo "$color_name $color_value"
        fi
    done < "$COLORS_FILE"

    # Add opacity if needed
    term_alpha=$(grep '^\$transparent:' "$COLORS_FILE" | cut -d: -f2 | tr -d ' ;')
    if [ "$term_alpha" = "true" ]; then
        echo ""
        echo "background_opacity 0.95"
    else
        echo ""
        echo "background_opacity 1.0"
    fi

} > "$KITTY_CONFIG_DIR/current-theme.conf"

# Reload all Kitty instances
if command -v kitty &>/dev/null; then
    killall -SIGUSR1 kitty 2>/dev/null || true
fi

echo "Kitty theme generated at: $KITTY_CONFIG_DIR/current-theme.conf"
