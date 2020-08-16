# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit cmake-utils

DESCRIPTION="A lightweight, multi-platform, multi-architecture CPU emulator framework based on QEMU."
HOMEPAGE="https://github.com/unicorn-engine/unicorn"
MY_SHA="3134f3302981298e8c53ef6b000959c31c6818af"
SRC_URI="https://github.com/unicorn-engine/unicorn/archive/${MY_SHA}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cpu-x86 +cpu-arm +cpu-aarch64 cpu-m68k cpu-mips cpu-sparc"

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/${PN}-${MY_SHA}"

PATCHES=( "${FILESDIR}/${PN}-yuzu-reg_esr.patch" )

src_configure() {
	local archs=()
	use cpu-x86 && archs+=( x86 )
	use cpu-arm && archs+=( arm )
	use cpu-aarch64 && archs+=( aarch64 )
	use cpu-m68k && archs+=( m68k )
	use cpu-mips && arch+=( mips )
	use cpu-sparc && arch+=( sparc )
	local mycmakeargs=( -DUNICORN_ARCH=${archs[*]} -DBUILD_SHARED_LIBS=OFF )
	cmake-utils_src_configure
}
