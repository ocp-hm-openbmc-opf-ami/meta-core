inherit uboot-sign

DEPENDS += "external-signing-utility-native secureboot-config"

# Create a ITS entry for runtime firmware
uboot_fitimage_ibexfw() {
	cat << EOF >> ${UBOOT_ITS}
        ibexfw {
            description = "Ibex Firmware";
            data = /incbin/("${UBOOT_FIT_IBEXFW_IMAGE}");
            type = "firmware";
            arch = "${UBOOT_FIT_IBEXFW_ARCH}";
            os = "${UBOOT_FIT_IBEXFW_OS}";
            load = <${UBOOT_FIT_IBEXFW_LOADADDRESS}>;
            entry = <${UBOOT_FIT_IBEXFW_ENTRYPOINT}>;
            compression = "none";
EOF
	if [ "${SPL_SIGN_ENABLE}" = "1" ] ; then
		cat << EOF >> ${UBOOT_ITS}
            signature {
                algo = "${UBOOT_FIT_HASH_ALG},${UBOOT_FIT_SIGN_ALG}";
                key-name-hint = "${SPL_SIGN_KEYNAME}";
            };
EOF
	fi

	cat << EOF >> ${UBOOT_ITS}
        };
EOF
}

# Create a ITS entry for ATF
uboot_fitimage_atf() {
        cat << EOF >> ${UBOOT_ITS}
        atf {
            description = "Arm Trusted Firmware";
            data = /incbin/("${UBOOT_FIT_ARM_TRUSTED_FIRMWARE_IMAGE}");
            type = "firmware";
            arch = "${UBOOT_ARCH}";
            os = "arm-trusted-firmware";
            load = <${UBOOT_FIT_ARM_TRUSTED_FIRMWARE_LOADADDRESS}>;
            entry = <${UBOOT_FIT_ARM_TRUSTED_FIRMWARE_ENTRYPOINT}>;
            compression = "none";
EOF
        if [ "${SPL_SIGN_ENABLE}" = "1" ] ; then
                cat << EOF >> ${UBOOT_ITS}
            signature {
                algo = "${UBOOT_FIT_HASH_ALG},${UBOOT_FIT_SIGN_ALG}";
                key-name-hint = "${SPL_SIGN_KEYNAME}";
            };
EOF
        fi

        cat << EOF >> ${UBOOT_ITS}
        };
EOF
}


# Create a ITS entry for OPTEE
uboot_fitimage_tee() {
        cat << EOF >> ${UBOOT_ITS}
        tee {
            description = "Trusted Execution Environment";
            data = /incbin/("${UBOOT_FIT_TEE_IMAGE}");
            type = "tee";
            arch = "${UBOOT_ARCH}";
            os = "tee";
            load = <${UBOOT_FIT_TEE_LOADADDRESS}>;
            entry = <${UBOOT_FIT_TEE_ENTRYPOINT}>;
            compression = "none";
EOF
        if [ "${SPL_SIGN_ENABLE}" = "1" ] ; then
                cat << EOF >> ${UBOOT_ITS}
            signature {
                algo = "${UBOOT_FIT_HASH_ALG},${UBOOT_FIT_SIGN_ALG}";
                key-name-hint = "${SPL_SIGN_KEYNAME}";
            };
EOF
        fi

        cat << EOF >> ${UBOOT_ITS}
        };
EOF
}

# Create a ITS file for the U-boot FIT, for use when
# we want to sign it so that the SPL can verify it
uboot_fitimage_assemble() {
	conf_loadables="\"uboot\""
	rm -f ${UBOOT_ITS} ${UBOOT_FITIMAGE_BINARY}

	# First we create the ITS script
	cat << EOF >> ${UBOOT_ITS}
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
            load = <${UBOOT_FIT_UBOOT_LOADADDRESS}>;
            entry = <${UBOOT_FIT_UBOOT_ENTRYPOINT}>;
EOF

	if [ "${SPL_SIGN_ENABLE}" = "1" ] ; then
		cat << EOF >> ${UBOOT_ITS}
            signature {
                algo = "${UBOOT_FIT_HASH_ALG},${UBOOT_FIT_SIGN_ALG}";
                key-name-hint = "${SPL_SIGN_KEYNAME}";
                external-signing-script = "${UBOOT_EXTERNAL_SIGNING_SCRIPT}";
            };
EOF
	fi

	cat << EOF >> ${UBOOT_ITS}
        };
        fdt {
            description = "U-Boot FDT";
            data = /incbin/("${UBOOT_DTB_BINARY}");
            type = "flat_dt";
            arch = "${UBOOT_ARCH}";
            compression = "none";
EOF

	if [ "${SPL_SIGN_ENABLE}" = "1" ] ; then
		cat << EOF >> ${UBOOT_ITS}
            signature {
                algo = "${UBOOT_FIT_HASH_ALG},${UBOOT_FIT_SIGN_ALG}";
                key-name-hint = "${SPL_SIGN_KEYNAME}";
                external-signing-script = "${UBOOT_EXTERNAL_SIGNING_SCRIPT}";
            };
EOF
	fi

	cat << EOF >> ${UBOOT_ITS}
        };
EOF
	if [ -n "${UBOOT_FIT_IBEXFW_IMAGE}" ] ; then
		uboot_fitimage_ibexfw
	fi

	if [ -n "${UBOOT_FIT_ARM_TRUSTED_FIRMWARE_IMAGE}" ] ; then
		conf_loadables="\"atf\", ${conf_loadables}"
		uboot_fitimage_atf
	fi

	if [ -n "${UBOOT_FIT_TEE_IMAGE}" ] ; then
		conf_loadables="\"tee\", ${conf_loadables}"
		uboot_fitimage_tee
	fi

	cat << EOF >> ${UBOOT_ITS}
    };

    configurations {
        default = "conf";
        conf {
            description = "Boot with signed U-Boot FIT";
            loadables = ${conf_loadables};
            fdt = "fdt";
EOF
        if [ -n "${UBOOT_FIT_IBEXFW_IMAGE}" ] ; then
                cat << EOF >> ${UBOOT_ITS}
            firmware = "ibexfw";
EOF
        fi

        cat << EOF >> ${UBOOT_ITS}
        };
    };
};
EOF

	#
	# Assemble the U-boot FIT image
	#
	${UBOOT_MKIMAGE} \
		${@'-D "${SPL_MKIMAGE_DTCOPTS}"' if len('${SPL_MKIMAGE_DTCOPTS}') else ''} \
		-f ${UBOOT_ITS} \
		${UBOOT_FITIMAGE_BINARY}

	if [ "${SPL_SIGN_ENABLE}" = "1" ] ; then
		#
		# Sign the U-boot FIT image and add public key to SPL dtb
		#
		${UBOOT_MKIMAGE_SIGN} \
			${@'-D "${SPL_MKIMAGE_DTCOPTS}"' if len('${SPL_MKIMAGE_DTCOPTS}') else ''} \
			-F -k "${SPL_SIGN_KEYDIR}" \
			-K "${SPL_DIR}/${SPL_DTB_BINARY}" \
			-r ${UBOOT_FITIMAGE_BINARY} \
			${SPL_MKIMAGE_SIGN_ARGS}
	fi

        if [ -e "${SPL_DIR}/${SPL_DTB_BINARY}" ]; then
                cp ${SPL_DIR}/${SPL_DTB_BINARY} ${SPL_DIR}/${SPL_DTB_SIGNED}
        fi
}

do_uboot_assemble_fitimage[network] = "1"
do_uboot_assemble_fitimage[depends] += " \
                         external-signing-utility-native:do_populate_sysroot \
                        "

