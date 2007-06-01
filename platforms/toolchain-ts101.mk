LIBC_STYLE=uclibc
TARGET_ARCH=powerpc
TARGET_OS=linux

GETTEXT_NLS=enable
NO_BUILTIN_MATH=true

CROSS_CONFIGURATION_GCC_VERSION=3.4.3
CROSS_CONFIGURATION_LIBC_VERSION=0.9.27
CROSS_CONFIGURATION_GCC=gcc-$(CROSS_CONFIGURATION_GCC_VERSION)
CROSS_CONFIGURATION_LIBC=uclibc-$(CROSS_CONFIGURATION_LIBC_VERSION)
CROSS_CONFIGURATION = $(CROSS_CONFIGURATION_GCC)-$(CROSS_CONFIGURATION_LIBC)

UCLIBC-OPT_VERSION=$(CROSS_CONFIGURATION_LIBC_VERSION)

GNU_TARGET_NAME = $(TARGET_ARCH)-$(TARGET_OS)

ifeq ($(HOST_MACHINE),ppc)
HOSTCC = $(TARGET_CC)
GNU_HOST_NAME = $(TARGET_ARCH)-linux
TARGET_CROSS = /opt/$(TARGET_ARCH)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = /opt/$(TARGET_ARCH)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS = -L/opt/lib
TARGET_CUSTOM_FLAGS=
TARGET_CFLAGS=-I/opt/include $(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain:
else
HOSTCC = gcc
GNU_HOST_NAME = $(HOST_MACHINE)-pc-linux-gnu
TARGET_CROSS = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/$(GNU_TARGET_NAME)-
TARGET_LIBDIR = $(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)/lib
TARGET_LDFLAGS =
TARGET_CUSTOM_FLAGS= -pipe
TARGET_CFLAGS=$(TARGET_OPTIMIZATION) $(TARGET_DEBUGGING) $(TARGET_CUSTOM_FLAGS)
toolchain: buildroot-toolchain 
endif
