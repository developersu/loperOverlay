# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit toolchain-funcs xdg-utils eutils

DESCRIPTION="Convert HTML pages into a PDF document"
HOMEPAGE="https://michaelrsweet.github.io/htmldoc/"
SRC_URI="https://github.com/michaelrsweet/${PN}/releases/download/v${PV}/${P}-source.tar.gz"
IUSE="fltk cyrillic-fonts"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="alpha amd64 ~arm ~hppa ia64 ppc ppc64 sparc x86"
RESTRICT="strip"	# Not sure

DEPEND=">=media-libs/libpng-1.4:0=
	virtual/jpeg:0
	fltk? ( x11-libs/fltk:1 )"
RDEPEND="${DEPEND}"

S="${WORKDIR}"


src_prepare() {
	default

	if use cyrillic-fonts; then
	# Taken already prepared fonts, created from GPL Cyrillic fonts available at ftp://ftp.gnome.ru/fonts/ by Sergei Kolodka (sergei@kolodka.com).
		cp ${FILESDIR}/fonts/* fonts
	fi

	# Patch .desktop file to remove Appllication declaration, that is incorrect.
	sed -i -e 's/Application;//' desktop/htmldoc.desktop || die 'failed to patch .desktop file'

	# make sure not to use the libs htmldoc ships with
	rm -r jpeg png zlib || die 'failed to unbundle jpeg, png, and zlib'

	# Fix the documentation path in a few places. Some Makefiles aren't
	# autotoolized =(
	for file in configure doc/Makefile doc/htmldoc.man; do
		sed -i "${file}" \
			-e "s:/doc/htmldoc:/doc/${PF}/html:g" \
			|| die "failed to fix documentation path in ${file}"
	done
}

src_configure() {
	CC=$(tc-getCC) CXX=$(tc-getCXX)	DSTROOT="${D}" econf $(use_with fltk gui)
}

src_install() {
	emake DSTROOT="${D}" install
}

pkg_postinst() {
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_mimeinfo_database_update
}
