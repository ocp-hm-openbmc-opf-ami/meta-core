SUMMARY = "Settings"

SRC_URI = "git://git@github.com/intel-bmc/firmware.bmc.openbmc.applications.settings-manager.git;protocol=ssh;branch=main"
SRCREV = "d80f44a1af1a786f83822a0f413fdf4f20888521"
PV = "0.1+git${SRCPV}"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"


SYSTEMD_SERVICE:${PN} = "xyz.openbmc_project.Settings.service"

DEPENDS = "boost \
           nlohmann-json \
           sdbusplus"

S = "${UNPACKDIR}/git"
inherit cmake pkgconfig systemd

EXTRA_OECMAKE = "-DYOCTO=1"

