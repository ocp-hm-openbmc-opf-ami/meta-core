# Enable downstream autobump
# # The URI is required for the autobump script but keep it commented
# to not override the upstream value
# SRC_URI = "git://github.com/openbmc/webui-vue.git;branch=master;protocol=https"
SRCREV = "ad043f50047fc4af5c46480ebf04b7be5d9d4bc0"

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
