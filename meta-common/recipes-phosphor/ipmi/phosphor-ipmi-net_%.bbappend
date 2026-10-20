inherit useradd

USERADD_PACKAGES = "${PN}"
# add a group called ipmi
GROUPADD_PARAM:${PN} = "ipmi "

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Enable downstream autobump to fix sync build, can be removed later
# The URI is required for the autobump script but keep it commented
# to not override the upstream value
# SRC_URI += "git://github.com/openbmc/phosphor-net-ipmid;branch=master;protocol=https"
# Todo: Commented out to avoid build failure
# SRCREV = "36e3c539df647d579f00f1cba6b482692a4ed634"
