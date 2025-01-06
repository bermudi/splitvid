# Maintainer: Daniel Bermudez <bermudi@gmail.com>
pkgname=splitvid
pkgver=1.0.0
pkgrel=1
pkgdesc="A command-line utility to split videos into equal halves or segments"
arch=('any')
url="https://github.com/bermudi/splitvid"
license=('MIT')
depends=('bash' 'ffmpeg' 'bc')
source=("git+https://github.com/bermudi/splitvid.git")
sha256sums=('SKIP')

package() {
    cd "$srcdir/$pkgname"
    install -Dm755 splitvid.sh "$pkgdir/usr/bin/splitvid"
    install -Dm644 README.md "$pkgdir/usr/share/doc/$pkgname/README.md"
}
