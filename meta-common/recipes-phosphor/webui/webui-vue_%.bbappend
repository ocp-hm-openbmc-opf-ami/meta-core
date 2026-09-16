# Enable downstream autobump
# # The URI is required for the autobump script but keep it commented
# to not override the upstream value
# SRC_URI = "git://github.com/openbmc/webui-vue.git;branch=master;protocol=https"
SRCREV = "d8fa6273b3a500ea7f398e8323979b5699c0a28d"

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
