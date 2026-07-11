SUMMARY = "generic watchdog"
DESCRIPTION = "BMC hardware watchdog service that is used to reset BMC \
               when unrecoverable events occurs"

inherit allarch
inherit obmc-phosphor-systemd

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/Apache-2.0;md5=89aea4e17d99a7cacdbeed46a0096b10"

SYSTEMD_SERVICE:${PN} += "system-watchdog.service"
SYSTEMD_ENVIRONMENT_FILE:${PN} += "obmc/system-watchdog/system-watchdog.conf"
