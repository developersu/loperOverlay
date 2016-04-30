# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2
inherit eutils

DESCRIPTION="An unofficial client of Skype for Linux, running on top of Node Webkit."
HOMEPAGE="https://github.com/haskellcamargo/skype-unofficial-client"
EGIT_REPO_URI="https://github.com/haskellcamargo/skype-unofficial-client.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

DEPEND="dev-vcs/git"
RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_prepare(){
	cp ${WORKDIR}/src/package.json ${WORKDIR}/bin/linux_x64 || die "SRC prepare failed!"
	chmod 755 -R ${WORKDIR}/bin/linux_x64/* || die "Install failed!"
	chmod +x ${WORKDIR}/src/skype-desktop  || die "Install failed!"
}

src_configure() {
        :;
}

src_compile() {
		:;
}

src_install() {
	dodir /opt/skype_unofficial_client || die "Install failed!"
	insinto  /opt/skype_unofficial_client || die "Install failed!"
	doins -r ${WORKDIR}/bin/linux_x64/* || die "Install failed!"

	exeinto  /opt/skype_unofficial_client || die "Install failed!"
	doexe ${WORKDIR}/bin/linux_x64/skype || die "Install failed!"

	exeinto /usr/bin || die "Install failed!"
	doexe ${WORKDIR}/src/skype-desktop || die "Install failed!"
	doicon -s 512 ${WORKDIR}/resource/skype.png || die "Install failed!"
	domenu ${WORKDIR}/src/Skype.desktop || die "Install failed!"
}
