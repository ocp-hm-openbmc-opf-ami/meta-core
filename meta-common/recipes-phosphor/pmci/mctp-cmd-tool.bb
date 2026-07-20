SUMMARY = "MCTP command line tool"
DESCRIPTION = "Implementation of MCTP command line tool"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

SRC_URI += "git://git@github.com/intel-collab/firmware.bmc.openbmc.applications.mctp-tools.git;protocol=ssh;branch=main"
SRCREV = "da69da59a815d4e5a38145b6d61f92e6ea7c70d7"

S = "${UNPACKDIR}/git"

PV = "1.0+git${SRCPV}"

inherit meson pkgconfig

DEPENDS += " \
	cli11 \
	boost \
	sdbusplus \
        mctpwplus \
        gtest \
	"
