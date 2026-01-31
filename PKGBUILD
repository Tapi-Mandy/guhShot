# Maintainer: Mandy <mandytapi@gmail.com>
pkgname=guhshot
pkgver=1.0.0
pkgrel=1
pkgdesc="Guh?? Take a Screenshot!"
arch=('any')
url="https://github.com/Tapi-Mandy/guhShot"
license=('MIT')
depends=('grim' 'slurp' 'wl-clipboard' 'libnotify' 'gtk3' 'python-gobject' 'swappy' 'ttf-jetbrains-mono-nerd')

source=("guhShot"
        "guhshot.png")

sha256sums=('e5f902986e7190fe70e08fe2aaf1c6c19e3a24efb4456f9bcaae2b2d17931584'
            '5f4cf86e81390dae9775025d9e8341f0af9e3ab72bf7a063938769586842764b')

package() {
  # 1. Install the executable
  install -Dm755 "${srcdir}/guhShot" "${pkgdir}/usr/bin/guhshot"

  # 2. Install the icon
  install -Dm644 "${srcdir}/guhshot.png" "${pkgdir}/usr/share/pixmaps/guhshot.png"

  # 3. Create and install the Desktop Entry
  mkdir -p "${pkgdir}/usr/share/applications"
  cat <<EOF > "${pkgdir}/usr/share/applications/guhshot.desktop"
[Desktop Entry]
Type=Application
Name=guhShot
Comment=Guh?? Take a Screenshot!
Exec=/usr/bin/guhshot
Icon=guhshot
Terminal=false
Categories=Utility;
Keywords=screenshot;capture;grim;guh;
EOF
}
