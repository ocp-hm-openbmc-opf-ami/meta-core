FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/ocp-hm-openbmc-opf-ami/libpeci.git;branch=main;protocol=https" 

SRC_URI += " \
        file://99-peci.rules \
"

do_install:append() {
    install -d ${D}${libdir}/udev/rules.d
    install -m 0644 ${UNPACKDIR}/99-peci.rules ${D}${libdir}/udev/rules.d
}

PACKAGECONFIG:append:intel = " dbus-raw-peci"
