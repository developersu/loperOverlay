# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
"

RUST_MIN_VER="1.85.0"

declare -A GIT_CRATES=(
        [isakmp]='https://github.com/ancwrd1/isakmp;77601eaa22f01fa6bf87cff0d0eb08dc3f75d0c5;isakmp-%commit%'
)

inherit desktop cargo systemd

DESCRIPTION="Open Source Linux Client For Check Point VPN Tunnels"
HOMEPAGE="https://github.com/ancwrd1/snx-rs"

SRC_URI="
	https://github.com/ancwrd1/snx-rs/archive/refs/tags/v${PV}.tar.gz
	${CARGO_CRATE_URIS}
"
if [[ ${PKGBUMPING} != ${PVR} ]]; then
	SRC_URI+="
		https://redrise.ru/builds/gentoo/${P}-crates.tar.xz
	"
fi

LICENSE="AGPL-3"
# Dependent crate licenses
LICENSE+="
	Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD ISC MIT MPL-2.0
	Unicode-3.0 WTFPL-2
"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	dev-libs/openssl
	virtual/pkgconfig
"

RDEPEND="
	dev-libs/libayatana-appindicator
	sys-apps/iproute2
	sys-apps/dbus
	x11-libs/gtk+:3
"

DEPEND="${RDEPEND}"

src_prepare() {
	default
}

src_install() {
	dobin target/release/{snx-rs,snxctl,snx-rs-gui}

	insinto /usr/share/snx-rs/
	doins assets/snx-rs.conf
	fperms 0644 /usr/share/snx-rs/snx-rs.conf

	sed -i  -re 's/\/opt\/snx-rs\///g' assets/snx-rs.service
	systemd_dounit assets/snx-rs.service

	sed -i  -re 's/\/opt\/snx-rs\///g' assets/snx-rs-gui.desktop

	domenu assets/snx-rs-gui.desktop

	newconfd "${FILESDIR}"/conf.d.snx-rs snx-rs
	newinitd "${FILESDIR}"/init.d.snx-rs snx-rs
}

pkg_postinst() {
	elog "To use snx-rs, the snx-rs daemon must be running. To automatically start at boot:"
	if systemd_is_booted || has_version sys-apps/systemd; then
		elog "  systemctl enable snx-rs.service"
	else
		elog "  rc-update add snx-rs default"
	fi
}
