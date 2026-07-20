# Base image class extension, inlined into every image.

# Phosphor image types
#
# New image types based on DTS partition information
#

# Image composition
FLASH_FULL_IMAGE ?= "fitImage-rootfs-${MACHINE}.bin"


IMAGE_BASETYPE ?= "squashfs-xz"
OVERLAY_BASETYPE ?= "jffs2"

IMAGE_TYPES += "mtd-auto"

IMAGE_TYPEDEP:mtd-auto = "${IMAGE_BASETYPE}"
IMAGE_TYPES_MASKED += "mtd-auto"
FLASH_UBOOT_SPL_IMAGE ?= "u-boot-spl"
FLASH_UBOOT_IMAGE ?= "u-boot"

mk_nor_image() {
        image_dst="$1"
        image_size_kb=$2
        dd if=/dev/zero bs=1k count=$image_size_kb \
                | tr '\000' '\377' > $image_dst
}

#·Assemble·fitImage¬with ATF, OPTEE and u-boot
uboot_fitimage_assemble() {
    local its_file="$1"
    local image_file="$2"
    local return_dir=$(pwd)

    cd ${DEPLOY_DIR_IMAGE}
    rm -f "$its_file" "$image_file"

    cat << EOF >> "$its_file"
/dts-v1/;

/ {
    description = "${UBOOT_FIT_DESC}";
    #address-cells = <${UBOOT_FIT_ADDRESS_CELLS}>;

    images {
        uboot {
            description = "U-Boot image";
            data = /incbin/("${UBOOT_NODTB_BINARY}");
            type = "standalone";
            os = "u-boot";
            arch = "${UBOOT_ARCH}";
            compression = "none";
            load = <${UBOOT_LOADADDRESS}>;
            entry = <${UBOOT_ENTRYPOINT}>;
        };

        fdt {
            description = "U-Boot FDT";
            data = /incbin/("${UBOOT_DTB_BINARY}");
            type = "flat_dt";
            arch = "${UBOOT_ARCH}";
            compression = "none";
        };

        atf {
            description = "ARM Trusted Firmware";
            type = "firmware";
            data = /incbin/("${ATF_BINARY}");
            arch = "${UBOOT_ARCH}";
            os = "arm-trusted-firmware";
            load = <${ATF_LOADADDRESS}>;
            entry = <${ATF_ENTRYPOINT}>;
            compression = "none";
       };

        optee {
            description = "OP-TEE Secure OS";
            data = /incbin/("${OPTEE_BINARY}");
            type = "tee";
            arch = "${UBOOT_ARCH}";
            os = "tee";
            load = <${OPTEE_LOADADDRESS}>;
            entry = <${OPTEE_ENTRYPOINT}>;
            compression = "none";
        };
    };

    configurations {
        default = "conf";
        conf {
            description = "Boot with signed U-Boot FIT";
            firmware = "atf";
            loadables = "uboot\0optee";
            fdt = "fdt";
        };
    };
};
EOF

    # run mkimage to create fitimage
    ${UBOOT_MKIMAGE} -f "$its_file" "$image_file"
    cd $return_dir
}

do_generate_bootloaders() {
    uboot_fitimage_assemble "${DEPLOY_DIR_IMAGE}/${FLASH_UBOOT_IMAGE}.its" \
                             "${DEPLOY_DIR_IMAGE}/fitImage-u-boot"

    mk_nor_image ${DEPLOY_DIR_IMAGE}/${FLASH_UBOOT_IMAGE} ${FLASH_BOOT_PART_SIZE}

    dd bs=1k conv=notrunc \
       if=${DEPLOY_DIR_IMAGE}/${FLASH_UBOOT_SPL_IMAGE}.${UBOOT_SUFFIX} \
       of=${DEPLOY_DIR_IMAGE}/${FLASH_UBOOT_IMAGE}

    dd bs=1k conv=notrunc seek=${FLASH_BOOT_PART_UBOOT_OFFSET} \
        if=${DEPLOY_DIR_IMAGE}/fitImage-u-boot \
        of=${DEPLOY_DIR_IMAGE}/${FLASH_UBOOT_IMAGE}
}
# generate bootloaders before do_image_fitimage_rootfs which prepares update tarball
addtask do_generate_bootloaders before do_image_fitimage_rootfs
do_generate_bootloaders[depends] += " \
        u-boot:do_deploy \
        trusted-firmware-a:do_deploy \
        optee-os:do_deploy \
        "

do_generate_auto() {
    bbdebug 1 "do_generate_auto IMAGE_TYPES=${IMAGE_TYPES} size=${FLASH_SIZE}KB (${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.auto.mtd)"
    # Assemble the flash image
    mk_nor_image ${IMGDEPLOYDIR}/${IMAGE_NAME}.auto.mtd ${FLASH_SIZE}
 
    # BMCU FW
    dd bs=1k conv=notrunc seek=${FLASH_BMCU_RAM_OFFSET} \
        if=${DEPLOY_DIR_IMAGE}/${BMCU_RAM_BINARY} \
        of=${IMGDEPLOYDIR}/${IMAGE_NAME}.auto.mtd

    # u-boot SPL, u-boot fitImage (u-boot, ATF, OPTEE)
    dd bs=1k conv=notrunc seek=${FLASH_BOOT_PART_OFFSET} \
        if=${DEPLOY_DIR_IMAGE}/${FLASH_UBOOT_IMAGE} \
        of=${IMGDEPLOYDIR}/${IMAGE_NAME}.auto.mtd

    # fitImage kernel and rootfs
    dd bs=1k conv=notrunc seek=${FLASH_FITIMAGE_OFFSET} \
        if=${DEPLOY_DIR_IMAGE}/${FLASH_FULL_IMAGE} \
        of=${IMGDEPLOYDIR}/${IMAGE_NAME}.auto.mtd

   ln ${IMGDEPLOYDIR}/${IMAGE_NAME}.auto.mtd \
       ${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.auto.mtd
   ln -sf ${IMAGE_NAME}.auto.mtd ${DEPLOY_DIR_IMAGE}/image-mtd
   ln -sf ${IMAGE_NAME}.auto.mtd ${DEPLOY_DIR_IMAGE}/OBMC-${@ do_get_version(d)}.ROM
}

do_generate_auto[dirs] = "${S}/auto"
do_generate_auto[depends] += " \
        ${PN}:do_image_${@d.getVar('IMAGE_BASETYPE', True).replace('-', '_')} \
        virtual/kernel:do_deploy \
        u-boot:do_populate_sysroot \
        "

python() {
    types = d.getVar('IMAGE_FSTYPES', True).split()

    if 'mtd-auto' in types:
        bb.build.addtask(# task, depends_on_task, task_depends_on, d )
                'do_generate_auto',
                'do_build',
                'do_image_complete', d)
}

