# Maintainer: Mandy <mandytapi@gmail.com>
pkgname=guhshot
pkgver=1.0.0
pkgrel=1
pkgdesc="Guh?? Take a Screenshot!"
arch=('any')
url="https://github.com/Tapi-Mandy/guhShot"
license=('MIT')
depends=('grim' 'slurp' 'wl-clipboard' 'libnotify' 'gtk3' 'python-gobject' 'swappy' 'ttf-jetbrains-mono-nerd')
source=(
  "guhshot::https://raw.githubusercontent.com/Tapi-Mandy/guhShot/main/guhShot"
  "guhshot.png::https://raw.githubusercontent.com/Tapi-Mandy/guhShot/main/assets/guhshot.png"
)
sha256sums=('68f5c62eb1241e5425148333d89c09556dc5331f7247282d62d8c5f13c0e8714'
            '5f4cf86e81390dae9775025d9e8341f0af9e3ab72bf7a063938769586842764b')

package() {
  # 1. Install the executable
  install -Dm755 "${srcdir}/guhshot" "${pkgdir}/usr/bin/guhshot"

  # 2. Install the icon
  install -Dm644 "${srcdir}/guhshot.png" "${pkgdir}/usr/share/icons/hicolor/scalable/apps/guhshot.png"

  # 3. Create and install the Desktop Entry
  mkdir -p "${pkgdir}/usr/share/applications"
  cat <<EOF > "${pkgdir}/usr/share/applications/guhshot.desktop"
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
}
