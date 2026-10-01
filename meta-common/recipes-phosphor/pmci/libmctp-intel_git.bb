SUMMARY = "libmctp:intel"
DESCRIPTION = "Implementation of MCTP(DMTF DSP0236)"

SRC_URI = "git://git@github.com/intel-bmc/firmware.bmc.openbmc.libraries.libmctp.git;protocol=ssh;branch=main"
SRCREV = "823b18fbf9d9802a40e1a2800a9f14986209d5cc"

S = "${UNPACKDIR}/git"

PV = "1.0+git${SRCPV}"

LICENSE = "Apache-2.0 | GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://LICENSE;md5=0d30807bb7a4f16d36e96b78f9ed8fae"

inherit cmake

DEPENDS += "i2c-tools"
