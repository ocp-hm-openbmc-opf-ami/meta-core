FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS:append = " virtual/phosphor-led-manager-config-native"

RDEPENDS:${PN}:remove = "clear-once"

do_compile:prepend(){
         if [ -f "${STAGING_DATADIR_NATIVE}/${PN}/led-group-config.json" ]; then
                 install -m 0644 ${STAGING_DATADIR_NATIVE}/${PN}/led-group-config.json ${S}/led-group-config.json
         elif [ -f "${STAGING_DATADIR_NATIVE}/${PN}/led.yaml" ]; then
                 install -m 0644 ${STAGING_DATADIR_NATIVE}/${PN}/led.yaml ${S}/led.yaml
         fi

}

do_install:append(){
    install -d ${D}${datadir}/phosphor-led-manager
    if [ -f "${STAGING_DATADIR_NATIVE}/${PN}/led-group-config.json" ]; then
        install -m 0644 ${STAGING_DATADIR_NATIVE}/${PN}/led-group-config.json ${D}${datadir}/phosphor-led-manager/led-group-config.json
    elif [ -f "${STAGING_DATADIR_NATIVE}/${PN}/led.yaml" ]; then
        install -m 0644 ${STAGING_DATADIR_NATIVE}/${PN}/led.yaml ${D}${datadir}/phosphor-led-manager/led.yaml
    fi
}
