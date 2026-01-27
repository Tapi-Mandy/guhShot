#!/usr/bin/env bash

# Exit on error, undefined vars, and pipe failures
set -euo pipefail

# --- Colors ---
YLW=$'\033[1;33m' # Primary Yellow
GRA=$'\033[1;30m' # Dark Gray
RED=$'\033[0;31m' # Red
NC=$'\033[0m'     # No Color

# --- Configuration ---
BASE_URL="https://raw.githubusercontent.com/Tapi-Mandy/guhShot/main"
SCRIPT_URL="$BASE_URL/guhShot"
ICON_URL="$BASE_URL/icon.svg"

INSTALL_DIR="/usr/bin"
DESKTOP_DIR="/usr/share/applications"
ICON_DIR="/usr/share/icons/hicolor/scalable/apps"

# Helper for sudo
SUDO_CMD=""
if [[ $EUID -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO_CMD="sudo"
    else
        echo -e "${RED}[!] Error: This script requires sudo.${NC}"
        exit 1
    fi
fi

# ASCII Art
echo -e "${YLW}"
echo " /\_/\\"
echo "( o.o )"
echo " > \` <"
echo -e "${NC}"
echo -e "${YLW}--- Installing guhShot ---${NC}"

# 1. Install Dependencies
while [ -f /var/lib/pacman/db.lck ]; do
    echo -e "${GRA}Waiting for pacman lock...${NC}"
    sleep 1
done

echo -e "${YLW}--> Installing dependencies...${NC}"
$SUDO_CMD pacman -S --needed --noconfirm \
    grim \
    slurp \
    wl-clipboard \
    libnotify \
    gtk3 \
    python-gobject \
    swappy

# 2. Install System Files
echo -e "${YLW}--> Downloading executable and icon...${NC}"
$SUDO_CMD mkdir -p "$INSTALL_DIR" "$ICON_DIR" "$DESKTOP_DIR"

# Note: Downloading from 'guhShot' but saving as 'guhshot' for terminal ease
$SUDO_CMD curl -fsSL "$SCRIPT_URL" -o "$INSTALL_DIR/guhshot"
$SUDO_CMD chmod +x "$INSTALL_DIR/guhshot"
$SUDO_CMD curl -fsSL "$ICON_URL" -o "$ICON_DIR/guhshot.svg"

# 3. Create Desktop Entry
echo -e "${YLW}--> Creating desktop entry...${NC}"
cat <<EOF | $SUDO_CMD tee "$DESKTOP_DIR/guhshot.desktop" > /dev/null
[Desktop Entry]
Type=Application
Name=guhShot
Comment=Guh?? Take a Screenshot!
Exec=guhshot
Icon=guhshot
Terminal=false
Categories=Utility;
Keywords=screenshot;capture;grim;guh;
StartupWMClass=com.tapi.guhShot
EOF

# 5. Refresh Icon Cache
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    $SUDO_CMD gtk-update-icon-cache -qtf /usr/share/icons/hicolor/
fi
