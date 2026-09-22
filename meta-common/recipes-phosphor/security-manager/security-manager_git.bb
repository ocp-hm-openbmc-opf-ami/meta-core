SUMMARY = "Security Manager daemon to detect the security violation- ASD/ user management"
DESCRIPTION = "Daemon check for Remote debug enable and user account violation"

PV = "1.0+git${SRCPV}"

S = "${UNPACKDIR}/git"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"
inherit cmake pkgconfig systemd

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI = "git://git@github.com/intel-bmc/firmware.bmc.openbmc.applications.security-manager.git;protocol=ssh;branch=main"
SRCREV = "af25029381024495109cdfc61fa89b0f20b4447f"

SYSTEMD_SERVICE:${PN} += "xyz.openbmc_project.SecurityManager.service"

DEPENDS += " \
    systemd \
    sdbusplus \
    libgpiod \
    phosphor-logging \
    boost \
    "

SRC_URI:append = " \
		  file://0001-Remove-Wnull-dereference-flag-to-fix-boost-warnings.patch \
		  file://0002-Fix-for-2700dcscm-build-error.patch \
                  "
