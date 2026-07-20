# The 'settings' recipe (recipes-phosphor/settings) replaces
# phosphor-settings-manager, which is excluded from the image via
# BAD_RECOMMENDATIONS in obmc-phosphor-image-common.bbclass.
#
# The upstream packagegroup-obmc-apps-settings still hard-requires
# phosphor-settings-manager, so do_rootfs (dnf) fails with the package being
# "filtered out by exclude filtering". Swap the dependency to match the rest
# of meta-core (see the phosphor-ipmi-host and phosphor-time-manager appends).
RDEPENDS:${PN}-settings:remove = "phosphor-settings-manager"
RDEPENDS:${PN}-settings:append = " settings"
