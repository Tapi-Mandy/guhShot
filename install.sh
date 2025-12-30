#!/usr/bin/env bash

# Exit on error, undefined vars, and pipe failures
set -euo pipefail

# --- Configuration ---
BASE_URL="https://raw.githubusercontent.com/Tapi-Mandy/guhShot/main"
SCRIPT_URL="$BASE_URL/guhshot"
ICON_URL="$BASE_URL/icon.svg"

# Arch standard is /usr/bin, but /usr/local/bin is safer for "manual" installs
INSTALL_DIR="/usr/bin"
DESKTOP_DIR="/usr/share/applications"
ICON_DIR="/usr/share/icons/hicolor/scalable/apps"

# Helper for sudo/root
SUDO_CMD=""
if [[ $EUID -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO_CMD="sudo"
    else
        echo "Error: This script requires root or sudo."
        exit 1
    fi
fi

echo ":: Starting guhShot Installation"

# 1. Dependency Check
echo ":: Checking dependencies..."
# Check for pacman lock to avoid conflict in scripts
while [ -f /var/lib/pacman/db.lck ]; do
    echo ":: Waiting for another pacman instance to finish..."
    sleep 1
done

$SUDO_CMD pacman -S --needed --noconfirm grim slurp wl-clipboard libnotify curl

# 2. Prepare Directories
$SUDO_CMD mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR" "$ICON_DIR"

# 3. Download Executable
echo ":: Downloading guhshot..."
$SUDO_CMD curl -fsSL "$SCRIPT_URL" -o "$INSTALL_DIR/guhshot"
$SUDO_CMD chmod +x "$INSTALL_DIR/guhshot"

# 4. Download Icon
echo ":: Downloading icon..."
$SUDO_CMD curl -fsSL "$ICON_URL" -o "$ICON_DIR/guhshot.svg"

# 5. Create Desktop Entry
echo ":: Generating desktop entry..."
cat <<EOF | $SUDO_CMD tee "$DESKTOP_DIR/guhshot.desktop" > /dev/null
[Desktop Entry]
Type=Application
Name=guhShot
Comment=Guh?? Look At This!
Exec=guhshot
Icon=guhshot
Terminal=false
Categories=Utility;
Keywords=screenshot;capture;grim;guh;
EOF

# 6. Refresh Icon Cache (Only if GUI tools exist)
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    echo ":: Refreshing icon cache..."
    $SUDO_CMD gtk-update-icon-cache -qtf /usr/share/icons/hicolor/
fi

echo ":: Installation Complete!"
