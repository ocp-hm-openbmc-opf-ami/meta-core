# Enable downstream autobump
# # The URI is required for the autobump script but keep it commented
# to not override the upstream value
# SRC_URI = "git://github.com/openbmc/webui-vue.git;branch=master;protocol=https"
SRCREV = "4976bc3a40f5743fa003c1b180447391a454b8f5"

FILESEXTRAPATHS:append := "${THISDIR}/${PN}:"
SRC_URI += " \
    file://login-company-logo.svg \
    file://logo-header.svg \
    file://0001-Change-loading-event-logs.patch \
    file://0002-Fix-CVEs.patch \
    "

do_compile:prepend() {
  cp -vf ${S}/.env.intel ${S}/.env
  cp -vf ${UNPACKDIR}/login-company-logo.svg ${S}/src/assets/images
  cp -vf ${UNPACKDIR}/logo-header.svg ${S}/src/assets/images
}
