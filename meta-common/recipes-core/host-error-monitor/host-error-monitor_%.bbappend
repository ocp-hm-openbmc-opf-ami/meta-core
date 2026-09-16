FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# The URI is required for the autobump script but keep it commented
# to not override the upstream value
# SRC_URI  = "git://github.com/openbmc/host-error-monitor;branch=master;protocol=https"
SRCREV = "1a5a6461a1e9bd551f8bebdb1d3051565dbc0581"
inherit pkgconfig
PACKAGECONFIG[send-to-logger] = ""
# PACKAGECONFIG:remove += "send-to-logger"
EXTRA_OECMAKE = "-DYOCTO=1 -DLIBPECI=1 -DCRASHDUMP=1"

# RAS Offload features:
SRC_URI += " \
    file://ras-offload/0001-Add-ERR0-monitor-for-RAS.patch \
    "
