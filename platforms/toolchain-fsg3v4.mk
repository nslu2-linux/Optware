TARGET_ARCH=armeb
TARGET_OS=linux
LIBC_STYLE=glibc

HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
GNU_TARGET_NAME = armeb-none-linux-gnueabi
TARGET_CROSS_TOP = /opt/crosstool/gcc-2005q3-glibc-2.3.5
TARGET_CROSS = $(TARGET_CROSS_TOP)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TARGET_CROSS_TOP)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS = 
TARGET_CUSTOM_FLAGS= -pipe -I$(TARGET_CROSS_TOP)/sys-include
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)

#
## Installation instructions for the binary toolchain ...
#

# Download the toolchains from here:
TOOLCHAIN_SITE = http://www.openfsg.com/download/

# Install this one in /opt/crosstool/gcc-2005q3-glibc-2.3.5/
TOOLCHAIN_SOURCE = arm-eabi-lebe.tar.bz2

# Install /usr/local/arm-linux/sys-include from this one into
# /opt/crosstool/gcc-2005q3-glibc-2.3.5/sys-include
TOOLCHAIN_SOURCE = arm-arm-linux-tools-20031127.tar.gz

toolchain:
