# Maintainer: Mandy <mandytapi@gmail.com>
pkgname=guhshot
pkgver=2.1.0
pkgrel=1
pkgdesc="Guh?? Take a Screenshot!"
arch=('x86_64')
url="https://github.com/Tapi-Mandy/guhShot"
license=('MIT')
depends=('grim' 'slurp' 'wl-clipboard' 'libnotify' 'swappy')
makedepends=('gcc' 'make')

source=("config.h"
        "guhshot.c"
        "Makefile"
        "guhshot.png")

sha256sums=('971ad255b1dedd42975c0629f893eefb6eed028a295250692d8df69229c48840'
            '1e846c868c7b51f983806035cf88ba9b97758835b22ee84d7e7c8cd788463f93'
            '76384170f9752f1ff232169a618c688978c2e4b398de2e0e7447668cfe4350a8'
            '5f4cf86e81390dae9775025d9e8341f0af9e3ab72bf7a063938769586842764b')

build() {
  cd "$srcdir"
  make
}

package() {
  cd "$srcdir"
  # 1. Install the binary
  make DESTDIR="$pkgdir" install
  
  # 2. Install the icon
  install -Dm644 guhshot.png "${pkgdir}/usr/share/pixmaps/guhshot.png"
}
