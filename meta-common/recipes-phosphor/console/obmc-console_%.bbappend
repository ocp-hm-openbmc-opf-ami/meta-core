# Enable downstream autobump - this can be removed after upstream sync
# The URI is required for the autobump script but keep it commented
# to not override the upstream value
# SRC_URI = "git://github.com/openbmc/obmc-console;branch=master;protocol=https"
SRCREV = "4d62cad00d7aca9543dcf6eb6fb6e6744c404bcd"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
OBMC_CONSOLE_HOST_TTY = "ttyS2"
SRC_URI += "file://sol-configure.sh \
            file://pre-post-routing.conf \
            file://server.ttyS2.conf \
            file://0001-Use-sol-configure.sh-to-configure-UART-routing.patch \
           "

do_install:append() {
    install -d ${D}${bindir}
    install -m 0755 ${UNPACKDIR}/sol-configure.sh ${D}${bindir}

    local drop_in=${D}${sysconfdir}/systemd/system/${PN}@${OBMC_CONSOLE_HOST_TTY}
    local service_drop_in=${drop_in}.service.d

    # Install service drop-in override to add UART routing and baud configuration
    install -d $service_drop_in
    install -m 0644 ${UNPACKDIR}/pre-post-routing.conf $service_drop_in
}
