SUMMARY = "MCTP Daemon"
DESCRIPTION = "Implementation of MCTP (DTMF DSP0236)"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

SRC_URI = "git://git@github.com/intel-bmc/firmware.bmc.openbmc.applications.mctpd.git;protocol=ssh;branch=main"
SRCREV = "18a51b335cba79a36065ce4533487482e1c7f8f5"

S = "${UNPACKDIR}/git"

PV = "1.0+git${SRCPV}"

OECMAKE_SOURCEPATH:bhs-features = "${S}"

INHERITMCTPD = " meson pkgconfig systemd "

INHERITMCTPD:bhs-features = " cmake pkgconfig systemd "

inherit ${INHERITMCTPD}

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

RDEPENDS:${PN} += "rsyslog"

DEPENDS += " \
    libmctp-intel \
    systemd \
    sdbusplus \
    phosphor-logging \
    boost \
    i2c-tools \
    cli11 \
    nlohmann-json \
    gtest \
    phosphor-dbus-interfaces \
    udev \
    libspdm \
    "

EXTRA_OEMESON = "-Dyocto_dep='enabled'"

CXXFLAGS:append = " -Wno-error=null-dereference"

FILES:${PN} += "${systemd_system_unitdir}/xyz.openbmc_project.mctpd@.service"
FILES:${PN} += "/usr/share/mctp/mctp_config.json"
