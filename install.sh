#!/usr/bin/env bash

# Exit on error, undefined vars, and pipe failures
set -euo pipefail

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
        echo "Error: This script requires root or sudo."
        exit 1
    fi
fi

echo "----------------------------------------"
echo "::        Installing guhShot            "
echo "----------------------------------------"

# 1. Install Dependencies
# Checks for pacman lock in case this is part of a larger installer script
while [ -f /var/lib/pacman/db.lck ]; do
    echo ":: Waiting for pacman lock..."
    sleep 1
done
$SUDO_CMD pacman -S --needed --noconfirm grim slurp wl-clipboard libnotify

# 2. Install System Files
echo ":: Downloading executable and icon..."
$SUDO_CMD mkdir -p "$INSTALL_DIR" "$ICON_DIR" "$DESKTOP_DIR"
$SUDO_CMD curl -fsSL "$SCRIPT_URL" -o "$INSTALL_DIR/guhshot"
$SUDO_CMD chmod +x "$INSTALL_DIR/guhshot"
$SUDO_CMD curl -fsSL "$ICON_URL" -o "$ICON_DIR/guhshot.svg"

# 3. Create Desktop Entry
echo ":: Creating desktop entry..."
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

# 4. Patch Mango Config
echo ":: Patching $MANGO_CONFIG..."
if [ -f "$MANGO_CONFIG" ]; then
    if grep -q "guhshot" "$MANGO_CONFIG"; then
        echo ":: guhShot binds already exist. Skipping patch."
    else
        # Define the lines to insert
        NEW_LINES="\n# Screenshot (guhShot)\nbind=NONE, Print, spawn, guhshot --full\nbind=SHIFT, Print, spawn, guhshot --select"
        
        # Look for SwayNC bind as the anchor
        TARGET="bind=ALT+SHIFT,A, spawn, swaync-client -t"
        
        if grep -qF "$TARGET" "$MANGO_CONFIG"; then
            echo ":: Anchor found. Injecting binds..."
            # Using sed to append after the specific SwayNC line
            sed -i "/$TARGET/a $NEW_LINES" "$MANGO_CONFIG"
        else
            echo ":: Anchor not found. Appending to end of file..."
            echo -e "$NEW_LINES" >> "$MANGO_CONFIG"
        fi
        # Reset ownership to the user (in case script ran as root)
        chown "$REAL_USER":"$REAL_USER" "$MANGO_CONFIG"
    fi
else
    echo ":: Warning: Config not found at $MANGO_CONFIG. Binds not added."
fi

# 5. Refresh Icon Cache
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    $SUDO_CMD gtk-update-icon-cache -qtf /usr/share/icons/hicolor/
fi

echo "----------------------------------------"
echo ":: Installation Complete!"
echo "----------------------------------------"
