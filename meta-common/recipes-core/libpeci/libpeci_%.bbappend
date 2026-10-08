FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git.ami.com/core/ami-bmc/one-tree/core/libpeci.git;branch=main;protocol=https"

SRCREV = "0ae39acf7712ec5b034837dcacef3a8ce6a8c803"

SRC_URI += " \
        file://99-peci.rules \
"

do_install:append() {
    install -d ${D}${libdir}/udev/rules.d
    install -m 0644 ${UNPACKDIR}/99-peci.rules ${D}${libdir}/udev/rules.d
}

PACKAGECONFIG:append:intel = " dbus-raw-peci"
