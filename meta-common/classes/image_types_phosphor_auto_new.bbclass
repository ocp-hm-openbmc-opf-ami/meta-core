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
image_dst ?= "image-u-boot"

# Flash characteristics in KB unless otherwise noted
FLASH_SIZE ?= "262144"
IMAGE_ALERT_SIZE ?= "8192"
UBOOT_SEC_SIZE ?= "4194304"
FIT_SECTOR_SIZE ?= "64880640"
DTB_FULL_FIT_IMAGE_OFFSETS ?= "0x420000"

python() {
    fitImage_offsets = d.getVar('DTB_FULL_FIT_IMAGE_OFFSETS', True)
    FIT_IMAGE_OFFSETS = [int(fitImage_offsets, 16)]
    d.setVar('FLASH_RUNTIME_OFFSETS', ' '.join(
        [str(int(x/1024)) for x in FIT_IMAGE_OFFSETS]
        )
    )
}

mk_nor_image() {
        image_dst="$1"
        image_size_kb=$2
        dd if=/dev/zero bs=1k count=$image_size_kb \
                | tr '\000' '\377' > $image_dst
}

do_generate_auto() {
    bbdebug 1 "do_generate_auto IMAGE_TYPES=${IMAGE_TYPES} size=${FLASH_SIZE}KB (${DEPLOY_DIR_IMAGE}/${IMAGE_NAME}.auto.mtd)"
    # Assemble the flash image
    mk_nor_image ${IMGDEPLOYDIR}/${IMAGE_NAME}.auto.mtd ${FLASH_SIZE}

    uboot_offset=${FLASH_UBOOT_OFFSET}

    if [ ! -z ${CALIPTRA_FW_BINARY} ]; then
        # Check Caliptra size
        imgpath_calip=${DEPLOY_DIR_IMAGE}/${CALIPTRA_FW_BINARY}
        imgsize_calip=$(wc -c < "$imgpath_calip")
        maxsize_calip=$(expr ${FLASH_CALIPTRA_SIZE} \* 1024)
        if [ "$imgsize_calip" -gt "$maxsize_calip" ]; then
            echo "Error: CALIPTRA_FW $imgpath_calip size ($imgsize_calip bytes) exceeds $maxsize_calip."
            exit 1
        fi

        # Check bootmcu size
        imgpath_bmcu=${DEPLOY_DIR_IMAGE}/${BOOTMCU_FW_BINARY}
        imgsize_bmcu=$(wc -c < "$imgpath_bmcu")
        maxsize_bmcu=$(expr ${FLASH_BMCU_SIZE} \* 1024)
        if [ "$imgsize_bmcu" -gt "$maxsize_bmcu" ]; then
            echo "Error: BOOTMCU $imgpath_bmcu size ($imgsize_bmcu bytes) exceeds $maxsize_bmcu."
            exit 1
        fi

        empty_image_size=$(expr ${FLASH_CALIPTRA_SIZE} + ${FLASH_BMCU_SIZE})
        mk_empty_image_zeros ${DEPLOY_DIR_IMAGE}/${image_dst} ${empty_image_size}

        uboot_offset=0

        # Caliptra
        dd bs=1k conv=notrunc seek=${uboot_offset} if=${DEPLOY_DIR_IMAGE}/${CALIPTRA_FW_BINARY} \
            of=${DEPLOY_DIR_IMAGE}/${image_dst}
        uboot_offset=$(expr ${uboot_offset} + ${FLASH_CALIPTRA_SIZE})

        # BootMCU
        dd bs=1k conv=notrunc seek=${uboot_offset} if=${DEPLOY_DIR_IMAGE}/${BOOTMCU_FW_BINARY} \
            of=${DEPLOY_DIR_IMAGE}/${image_dst}
        uboot_offset=$(expr ${uboot_offset} + ${FLASH_BMCU_SIZE})

        # UBoot
        dd bs=1k seek=${uboot_offset} if=${DEPLOY_DIR_IMAGE}/${UBOOT_BINARY} \
            of=${DEPLOY_DIR_IMAGE}/${image_dst}

        # Write to final image
        dd bs=1k conv=notrunc seek=${FLASH_UBOOT_OFFSET} if=${DEPLOY_DIR_IMAGE}/${image_dst} \
            of=${IMGDEPLOYDIR}/${IMAGE_NAME}.auto.mtd

        FLASH_UBOOT_IMAGE_NAME=${DEPLOY_DIR_IMAGE}/${image_dst}
    elif [ ! -z ${SPL_BINARY} ]; then
        dd bs=1k conv=notrunc seek=${FLASH_UBOOT_OFFSET} \
            if=${DEPLOY_DIR_IMAGE}/${FLASH_UBOOT_SPL_IMAGE}.${UBOOT_SUFFIX} \
            of=${DEPLOY_DIR_IMAGE}/${image_dst}
        uboot_offset=${FLASH_UBOOT_SPL_SIZE}
        dd bs=1k conv=notrunc seek=${uboot_offset} \
            if=${DEPLOY_DIR_IMAGE}/${UBOOT_BINARY} \
            of=${DEPLOY_DIR_IMAGE}/${image_dst}
        dd bs=1k conv=notrunc seek=${FLASH_UBOOT_OFFSET} \
            if=${DEPLOY_DIR_IMAGE}/${image_dst} \
            of=${IMGDEPLOYDIR}/${IMAGE_NAME}.auto.mtd
        FLASH_UBOOT_IMAGE_NAME=${DEPLOY_DIR_IMAGE}/${image_dst}
    else
        dd bs=1k conv=notrunc seek=${FLASH_UBOOT_OFFSET} \
            if=${DEPLOY_DIR_IMAGE}/${UBOOT_BINARY} \
            of=${IMGDEPLOYDIR}/${IMAGE_NAME}.auto.mtd
        FLASH_UBOOT_IMAGE_NAME=${DEPLOY_DIR_IMAGE}/${UBOOT_BINARY}
    fi

    UBOOT_IMAGE_SIZE=$(du --apparent-size --block-size=1  \
           $(readlink -f "${FLASH_UBOOT_IMAGE_NAME}") \
          | awk '{ print $1}')

    if [ ${UBOOT_SEC_SIZE}  -gt $UBOOT_IMAGE_SIZE ]; then
        free_space=$(expr ${UBOOT_SEC_SIZE} - $UBOOT_IMAGE_SIZE)
        if [ $free_space -lt ${IMAGE_ALERT_SIZE} ] ; then
            bbwarn "u-boot sector free space $free_space bytes is less than the threshold ${IMAGE_ALERT_SIZE} bytes"
        fi
    else
        bberror "u-boot sector size ${UBOOT_SEC_SIZE} bytes is smaller than image size ${UBOOT_IMAGE_SIZE} bytes"
        exit 1
    fi

    FIT_IMAGE_SIZE=$(du --apparent-size --block-size=1  \
           $(readlink -f "${DEPLOY_DIR_IMAGE}/${FLASH_FULL_IMAGE}") \
          | awk '{ print $1}')

    FIT_FREE_SPACE=$(expr ${FIT_SECTOR_SIZE} - ${FIT_IMAGE_SIZE})
    bbplain "FIT SECTOR SIZE ${FIT_SECTOR_SIZE} bytes"
    bbplain "FIT IMAGE SIZE ${FIT_IMAGE_SIZE} bytes"
    bbplain "FIT SECTOR FREE SPACE ${FIT_FREE_SPACE} bytes"

    if [ ${FIT_SECTOR_SIZE}  -gt $FIT_IMAGE_SIZE ]; then
        free_space=$(expr ${FIT_SECTOR_SIZE} - $FIT_IMAGE_SIZE)
        if [ $free_space -lt ${IMAGE_ALERT_SIZE} ] ; then
            bbwarn "FIT Image sector free space $free_space bytes is less than the threshold ${IMAGE_ALERT_SIZE} bytes"
        fi
    else
        bberror "FIT Image sector size ${FIT_SECTOR_SIZE} bytes is smaller than image size ${FIT_IMAGE_SIZE} bytes"
        exit 1
    fi

    for OFFSET in ${FLASH_RUNTIME_OFFSETS}; do
        dd bs=1k conv=notrunc seek=${OFFSET} \
            if=${DEPLOY_DIR_IMAGE}/${FLASH_FULL_IMAGE} \
            of=${IMGDEPLOYDIR}/${IMAGE_NAME}.auto.mtd
    done

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

