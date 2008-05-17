TARGET_ARCH=arm
TARGET_OS=linux

# LIBSTDC++_VERSION=5.0.3
# LIBNSL_VERSION=2.2.5

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = arm-uclinux-elf
CROSS_CONFIGURATION = arm-uclinux-elf
TARGET_CROSS = /opt/arm-uclinux-tools/bin/${CROSS_CONFIGURATION}-
TARGET_LIBDIR = /opt/arm-uclinux-tools/$(CROSS_CONFIGURATION)/lib
TARGET_INCDIR = /opt/arm-uclinux-tools/$(CROSS_CONFIGURATION)/include
TARGET_LDFLAGS = -Wl,-elf2flt
TARGET_CUSTOM_FLAGS= -pipe -I${TARGET_INCDIR}
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
