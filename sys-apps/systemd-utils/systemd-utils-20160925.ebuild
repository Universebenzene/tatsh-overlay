# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit multilib udev

DESCRIPTION="Random systemd utilities."
HOMEPAGE="https://github.com/kylemanna/systemd-utils"
MY_HASH="597ced328341d6741cc5768e568d64d516822ce6"
SRC_URI="https://github.com/kylemanna/systemd-utils/archive/${MY_HASH}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="amazon cmsis-dap bitcoind btrfs crashplan ipv6 rssh storj tahoe kodi youtube papertrail"

DEPEND=""
RDEPEND="${DEPEND}
	cmsis-dap? ( dev-embedded/openocd[cmsis-dap] )
	btrfs? ( sys-fs/btrfs-progs )
	kodi? ( media-tv/kodi )
	bitcoind? ( net-p2p/bitcoind )
	youtube? ( www-client/chromium )"
BDEPEND=""

DOCS=( LICENSE README.md )

S="${WORKDIR}/${PN}-${MY_HASH}"

src_prepare() {
	default
	sed -e '10s:.*:ExecStart=/usr/sbin/failure-monitor.py %i:' -i \
		failure-monitor/failure-monitor@.service || die
	sed -e '6s:.*:ExecStart=/usr/sbin/onfailure.sh %i:' -i \
		onfailure/failure-email@.service || die
	sed -e '38s/--user //' -i onfailure/onfailure.sh || die
	sed -e '12s/--user //' -i units/import-env.service || die
}

src_install() {
	insinto /$(get_libdir)/systemd/system
	use amazon && doins units/amazon-cloud-drive.service
	use bitcoind && doins units/bitcoind.service
	use btrfs && doins units/btrfs*
	use crashplan && doins units/crashplan.timer
	use ipv6 && doins units/ipv6*.service units/ping6*
	use papertrail && doins units/papertrail.service
	use rssh && doins units/rssh.service
	use storj && doins units/storj-dataserv-client.service
	use tahoe && doins units/tahoe*
	use kodi && doins units/wm.target units/xbmc.service
	use youtube && doins units/wm.target units/youtube-tv.service
	doins units/uber-fail.service \
		units/import-env.service \
		failure-monitor/failure-monitor@.service \
		onfailure/failure-email@.service

	if use cmsis-dap; then
		doins units/openocd-cmsis-dap*
		udev_dorules scripts/98-cmsis-dap.rules
	fi

	dosbin failure-monitor/failure-monitor.py onfailure/onfailure.sh
	dobin scripts/systemd-email

	einstalldocs
}
