# The URI is required for the autobump script but keep it commented
# to not override the upstream value
# SRC_URI = "git://github.com/openbmc/bmcweb.git;branch=master;protocol=https"
# SRCREV = "a88942019fdd3d8fc366999f7c178f3e1c18b2fe"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Enable new power and thermal subsystem
EXTRA_OEMESON += " -Dredfish-new-powersubsystem-thermalsubsystem=enabled"
EXTRA_OEMESON += " -Dredfish-allow-deprecated-power-thermal=disabled"

# Enable Content-Type validation
EXTRA_OEMESON += " -Dinsecure-ignore-content-type=disabled"

# Enable PFR support
EXTRA_OEMESON += "${@bb.utils.contains('IMAGE_FSTYPES', 'intel-pfr', '-Dredfish-provisioning-feature=enabled', '', d)}"

#Enable Secure boot support
EXTRA_OEMESON += "${@bb.utils.contains('IMAGE_FSTYPES', 'intel-secboot', '-Dredfish-provisioning-feature=enabled', '', d)}"

# Enable NBD proxy embedded in bmcweb
EXTRA_OEMESON += " -Dvm-nbdproxy=enabled"

# Disable dependency on external nbd-proxy application
EXTRA_OEMESON += " -Dvm-websocket=disabled"
EXTRA_OEMESON += " -Dredfish-host-logger=disabled"

# image-payload-limit will configure the max size of image file in MB which can be uploaded to bmcweb over https.
EXTRA_OEMESON += " -Dimage-payload-limit=129"
# http-body-limit will configure the max size of http request body in KB
EXTRA_OEMESON += " -Dhttp-body-limit=128"
EXTRA_OEMESON += " -Dimage-upload-dir=/tmp/images/"
RDEPENDS:${PN}:remove = " jsnbd"

do_install:append(){
	install -d ${D}/var/lib/bmcweb
}
