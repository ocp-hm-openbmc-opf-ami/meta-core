SUMMARY = "MCTP Wrapper Library"
DESCRIPTION = "Implementation of MCTP Wrapper Library"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=3b83ef96387f14655fc854ddc3c6bd57"

SRC_URI = "git://git@github.com/ocp-hm-openbmc-opf-ami/mctp-wrapper.git;protocol=https;branch=main"
SRCREV = "7ec692749dbc0f43c97d7ec863042973a1cd11a5"

S = "${UNPACKDIR}/git"

PV = "1.0+git${SRCPV}"

inherit cmake systemd

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS += " \
    libmctp-intel \
    systemd \
    sdbusplus \
    phosphor-logging \
    gtest \
    boost \
    phosphor-dbus-interfaces \
    "

SRC_URI:append = " file://0001-Fix-For-LF-Sync-Build-Failure.patch "

EXTRA_OECMAKE += "-DYOCTO_DEPENDENCIES=ON"
