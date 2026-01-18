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
SCRIPT_URL="$BASE_URL/guhshot"
ICON_URL="$BASE_URL/icon.svg"

INSTALL_DIR="/usr/bin"
DESKTOP_DIR="/usr/share/applications"
ICON_DIR="/usr/share/icons/hicolor/scalable/apps"

# Identify the real user to find the correct home directory
REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
# config.conf Path
MANGO_CONFIG="$USER_HOME/.config/mango/config.conf"

# Helper for sudo/root
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
$SUDO_CMD pacman -S --needed --noconfirm grim slurp wl-clipboard libnotify

# 2. Install System Files
echo -e "${YLW}--> Downloading executable and icon...${NC}"
$SUDO_CMD mkdir -p "$INSTALL_DIR" "$ICON_DIR" "$DESKTOP_DIR"
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
EOF

# 4. Install guhShot Config
echo -e "${YLW}---> Installing guhShot config...${NC}"
MANGO_CONF_D="$USER_HOME/.config/mango/conf.d"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create conf.d directory if it doesn't exist
mkdir -p "$MANGO_CONF_D"

# Copy guhShot.conf to conf.d
if [ -f "$SCRIPT_DIR/guhShot.conf" ]; then
    cp "$SCRIPT_DIR/guhShot.conf" "$MANGO_CONF_D/guhShot.conf"
    chown "$REAL_USER":"$REAL_USER" "$MANGO_CONF_D/guhShot.conf"
    echo -e "${GRA}-> guhShot config installed to $MANGO_CONF_D/${NC}"
else
    echo -e "${RED}[!] Warning: guhShot.conf not found in script directory...${NC}"
fi

# 5. Refresh Icon Cache
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    $SUDO_CMD gtk-update-icon-cache -qtf /usr/share/icons/hicolor/
fi