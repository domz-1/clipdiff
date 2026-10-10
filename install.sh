#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}   ⚖️ Installing ClipDiff Linux          ${NC}"
echo -e "${BLUE}=========================================${NC}"

mkdir -p "$HOME/.local/bin"
cp -f "$(dirname "$0")/bin/clipdiff" "$HOME/.local/bin/clipdiff"
chmod +x "$HOME/.local/bin/clipdiff"
ln -sf "$HOME/.local/bin/clipdiff" "$HOME/.local/bin/diffview"

mkdir -p "$HOME/.local/share/applications"
cp -f "$(dirname "$0")/assets/clipdiff.desktop" "$HOME/.local/share/applications/clipdiff.desktop"
command -v update-desktop-database &>/dev/null && update-desktop-database "$HOME/.local/share/applications" || true

# Setup GNOME Shortcuts (Alt+1 for Text A, Alt+2 for Compare)
if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ] || [ "$DESKTOP_SESSION" = "ubuntu" ] || [ "$DESKTOP_SESSION" = "gnome" ]; then
    echo -e "${YELLOW}Configuring GNOME global shortcuts (Alt+1 and Alt+2)...${NC}"
    EXISTING=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings | tr -d '@as ' | sed 's/\[//;s/\]//')
    
    KEY_PATH1="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/clipdiff1/"
    KEY_PATH2="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/clipdiff2/"
    
    NEW_LIST="$EXISTING"
    if [[ ! "$NEW_LIST" =~ "clipdiff1" ]]; then
        if [ -z "$NEW_LIST" ]; then NEW_LIST="['$KEY_PATH1', '$KEY_PATH2']"
        else NEW_LIST="[$(echo "$NEW_LIST" | sed "s/]$//"), '$KEY_PATH1', '$KEY_PATH2']"
        fi
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$NEW_LIST" || true
    fi

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH1 name "ClipDiff - Set Text A (Alt+1)" || true
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH1 command "$HOME/.local/bin/clipdiff 1" || true
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH1 binding "<Alt>1" || true

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH2 name "ClipDiff - Compare with Text B (Alt+2)" || true
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH2 command "$HOME/.local/bin/clipdiff 2" || true
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH2 binding "<Alt>2" || true
fi

echo -e "\n${GREEN}=========================================${NC}"
echo -e "${GREEN}   ✅ ClipDiff Installed Successfully!   ${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "1. Highlight Text A and press ${YELLOW}Alt + 1${NC}."
echo -e "2. Highlight Text B and press ${YELLOW}Alt + 2${NC} to view side-by-side diff!"
