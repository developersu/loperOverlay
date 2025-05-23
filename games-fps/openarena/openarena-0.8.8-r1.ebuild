# Copyright 2020-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=8

inherit flag-o-matic desktop

DESCRIPTION="Open-source replacement for Quake 3 Arena"
HOMEPAGE="http://openarena.ws/"
SRC_URI="
	https://downloads.sourceforge.net/oarena/openarena-0.8.8.zip
	https://downloads.sourceforge.net/oarena/files/src/${PN}-engine-source-${PV}.tar.bz2
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+curl +openal +vorbis"

RDEPEND="virtual/opengl
	media-libs/libsdl[joystick,opengl,video]
	media-libs/speex
	virtual/jpeg:0
	x11-libs/libXext
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXdmcp
	curl? ( net-misc/curl )
	openal? ( media-libs/openal )
	vorbis? ( media-libs/libvorbis )"
DEPEND="${RDEPEND}
	app-arch/unzip"

MY_S=${WORKDIR}/${PN}-engine-source-${PV}
BUILD_DIR=${PN}-build
DIR="/usr/share/${PN}"

src_prepare() {
	cd "${WORKDIR}"
	PATCHES=(
		"${FILESDIR}"/${P}-makefile.patch
	)
	cd "${MY_S}"
	touch jpegint.h
	default
}

src_compile() {
	local myopts

	# enable voip, disable mumble
	# also build always server and use smp by default
	myopts="USE_INTERNAL_SPEEX=0 USE_VOIP=1 USE_MUMBLE=0
		BUILD_SERVER=1 BUILD_CLIENT_SMP=1 USE_LOCAL_HEADERS=0"
	use curl || myopts="${myopts} USE_CURL=0"
	use openal || myopts="${myopts} USE_OPENAL=0"
	use vorbis || myopts="${myopts} USE_CODEC_VORBIS=0"

	cd "${MY_S}"
	emake \
		V=1 \
		DEFAULT_BASEDIR="${DIR}" \
		BR="${BUILD_DIR}" \
		${myopts} \
		OPTIMIZE=
}

src_install() {
	cd "${MY_S}"/"${BUILD_DIR}"
	newbin openarena-smp.* "${PN}"
	newbin oa_ded.* "${PN}-ded"
	cd "${S}"

	insinto "${DIR}"
	doins -r baseoa missionpack

	dodoc CHANGES CREDITS LINUXNOTES README
	newicon "${MY_S}"/misc/quake3.png ${PN}.png
	make_desktop_entry ${PN} "OpenArena"

#	prepgamesdirs
}
