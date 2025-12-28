#!/bin/bash

# --- Configuration ---
BASE_URL="https://raw.githubusercontent.com/Tapi-Mandy/guhShot/main"
SCRIPT_URL="$BASE_URL/guhshot"
ICON_URL="$BASE_URL/icon.svg"

INSTALL_DIR="/usr/local/bin"
DESKTOP_DIR="/usr/share/applications"
ICON_DIR="/usr/share/icons/hicolor/scalable/apps"

echo "----------------------------------------"
echo "Starting guhShot Installer"
echo "----------------------------------------"

# --- 1. Install Dependencies ---
echo "Checking and installing dependencies..."

if command -v pacman &> /dev/null; then
    # Arch Linux / Manjaro
    sudo pacman -S --needed --noconfirm grim slurp wl-clipboard libnotify curl

elif command -v apt-get &> /dev/null; then
    # Debian / Ubuntu
    sudo apt-get update
    sudo apt-get install -y grim slurp wl-clipboard libnotify-bin curl

elif command -v dnf &> /dev/null; then
    # Fedora
    sudo dnf install -y grim slurp wl-clipboard libnotify curl

elif command -v zypper &> /dev/null; then
    # OpenSUSE
    sudo zypper install -y grim slurp wl-clipboard libnotify curl
else
    echo "Warning: Package manager not detected. Ensure 'grim slurp wl-clipboard libnotify curl' are installed."
fi

# --- 2. Download Main Script ---
echo "Downloading guhShot executable..."
if sudo curl -fsSL "$SCRIPT_URL" -o "$INSTALL_DIR/guhshot"; then
    sudo chmod +x "$INSTALL_DIR/guhshot"
    echo "Executable installed."
else
    echo "Error: Failed to download guhshot script. Check URL or internet."
    exit 1
fi

# --- 3. Download Icon ---
echo "Downloading application icon..."

# Ensure the icon directory exists
sudo mkdir -p "$ICON_DIR"

# Download icon.svg and save it as guhshot.svg so the desktop entry finds it
if sudo curl -fsSL "$ICON_URL" -o "$ICON_DIR/guhshot.svg"; then
    echo "Icon installed."
else
    echo "Warning: Failed to download icon.svg. The app will work but might lack an icon."
fi

# --- 4. Create Desktop Entry ---
echo "Creating desktop entry..."
cat <<EOF | sudo tee "$DESKTOP_DIR/guhshot.desktop" > /dev/null
[Desktop Entry]
Type=Application
Name=guhShot
Comment=Wayland screenshot utility
Exec=$INSTALL_DIR/guhshot
Icon=guhshot
Terminal=false
Categories=Utility;
Keywords=screenshot;capture;grim;guh;
EOF

# --- 5. Refresh Icon Cache ---
if command -v gtk-update-icon-cache &> /dev/null; then
    sudo gtk-update-icon-cache /usr/share/icons/hicolor/
fi

echo "----------------------------------------"
echo "Installation complete!"
echo "1. Run 'guhshot' in terminal to test."
echo "2. Look for the 'guhShot' icon in Rofi."
echo "3. Add these bindings to mangowc config:"
echo "   bind=NONE,Print,spawn,guhshot --full"
echo "   bind=SHIFT,Print,spawn,guhshot --select"
echo "----------------------------------------"
