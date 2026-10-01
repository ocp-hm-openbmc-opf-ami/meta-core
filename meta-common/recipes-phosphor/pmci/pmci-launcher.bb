SUMMARY = "PMCI Launcher"
DESCRIPTION = "Support to launch pmci services on-demand"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=e3fc50a88d0a364313df4b21ef20c29e"

SRC_URI = "git://git@github.com/intel-bmc/firmware.bmc.openbmc.applications.pmci-launcher.git;protocol=ssh;branch=main"
SRCREV = "2d14ec9114beb25d7b1ddc3a02c5a4f965435aa3"

S = "${UNPACKDIR}/git"

PV = "1.0+git${SRCPV}"

inherit meson pkgconfig systemd

DEPENDS += " \
    systemd \
    sdbusplus \
    phosphor-logging \
    boost \
    i2c-tools \
    "

FILES:${PN} += "${systemd_system_unitdir}/xyz.openbmc_project.pmci-launcher.service"
SYSTEMD_SERVICE:${PN} += "xyz.openbmc_project.pmci-launcher.service"

FILES:${PN} += "${systemd_system_unitdir}/xyz.openbmc_project.I3C.Hub.Detector.service"
SYSTEMD_SERVICE:${PN} += "xyz.openbmc_project.I3C.Hub.Detector.service"
