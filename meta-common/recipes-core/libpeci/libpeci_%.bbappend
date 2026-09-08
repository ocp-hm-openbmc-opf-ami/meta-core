FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/ocp-hm-openbmc-opf-ami/libpeci.git;branch=integrate-onetree-3.1.1;protocol=https"

SRCREV = "00c2ddea67a427b63bd6e51e6bab42a7356669a9"

SRC_URI += " \
        file://99-peci.rules \
"

do_install:append() {
    install -d ${D}${libdir}/udev/rules.d
    install -m 0644 ${UNPACKDIR}/99-peci.rules ${D}${libdir}/udev/rules.d
}

PACKAGECONFIG:append:intel = " dbus-raw-peci"
