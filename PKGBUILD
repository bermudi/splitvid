# Maintainer: Daniel Bermudez <bermudi@gmail.com>
pkgname=splitvid-git
pkgver=1.0.0.r9.gbaac0e1
pkgrel=1
pkgdesc="A command-line utility to split videos into equal halves or segments"
arch=('any')
url="https://github.com/bermudi/splitvid"
license=('MIT')
depends=('bash' 'ffmpeg' 'bc')
makedepends=('git')
provides=("${pkgname%-git}")
conflicts=("${pkgname%-git}")
source=("$pkgname::git+https://github.com/bermudi/splitvid.git")
sha256sums=('SKIP')

pkgver() {
    cd "$srcdir/$pkgname"
    printf "1.0.0.r%s.g%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

build() {
    true
}

package() {
    cd "$srcdir/$pkgname"
    install -Dm755 splitvid.sh "$pkgdir/usr/bin/${pkgname%-git}"
    install -Dm644 README.md "$pkgdir/usr/share/doc/${pkgname%-git}/README.md"
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/${pkgname%-git}/LICENSE"
}
