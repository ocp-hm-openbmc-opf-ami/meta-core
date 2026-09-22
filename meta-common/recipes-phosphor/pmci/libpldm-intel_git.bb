SUMMARY = "libpldm_intel"
DESCRIPTION = "Provides encode/decode APIs for PLDM specifications"

SRC_URI = "git://git@github.com/ocp-hm-openbmc-opf-ami/libpldm.git;protocol=https;branch=main"
SRCREV = "c7c674df099ca487acc3886a34141f270214f14c"

S = "${UNPACKDIR}/git"

PV = "1.0+git${SRCPV}"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=86d3f3a95c324c9479bd8986968f4327"

inherit cmake

DEPENDS += " \
    gtest \
    "
