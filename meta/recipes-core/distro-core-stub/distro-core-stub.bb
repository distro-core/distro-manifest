DESCRIPTION = "DISTRO Core Stub"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PR = "r0"

SRC_URI = "file://stub.txt"

do_compile () {
    bbnote "do_compile of distro-sub"
}

do_install () {
    bbnote "do_install of distro-stub"
}

ALLOW_EMPTY:${PN} = "1"

FILES:${PN} = ""
