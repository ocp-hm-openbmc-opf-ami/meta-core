FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/ocp-hm-openbmc-opf-ami/libpeci.git;branch=main;protocol=https"

SRCREV = "c0d6ef4402d7421f1138e5fec48b18732c3303e4"

SRC_URI += " \
        file://99-peci.rules \
"

do_install:append() {
    install -d ${D}${libdir}/udev/rules.d
    install -m 0644 ${UNPACKDIR}/99-peci.rules ${D}${libdir}/udev/rules.d
}

PACKAGECONFIG:append:intel = " dbus-raw-peci"
