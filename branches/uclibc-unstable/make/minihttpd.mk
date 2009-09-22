###########################################################
#
# minihttpd
#
###########################################################

#
# MINIHTTPD_VERSION, MINIHTTPD_SITE and MINIHTTPD_SOURCE define
# the upstream location of the source code for the package.
# MINIHTTPD_DIR is the directory which is created when the source
# archive is unpacked.
# MINIHTTPD_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
MINIHTTPD_SITE=http://www.acme.com/software/minihttpd
MINIHTTPD_VERSION=1.19
MINIHTTPD_SOURCE=mini_httpd-$(MINIHTTPD_VERSION).tar.gz
MINIHTTPD_DIR=mini_httpd-$(MINIHTTPD_VERSION)
MINIHTTPD_UNZIP=zcat
MINIHTTPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MINIHTTPD_DESCRIPTION=small HTTP server
MINIHTTPD_SECTION=web
MINIHTTPD_PRIORITY=optional
MINIHTTPD_DEPENDS=
MINIHTTPD_SUGGESTS=
MINIHTTPD_CONFLICTS=

#
# MINIHTTPD_IPK_VERSION should be incremented when the ipk changes.
#
MINIHTTPD_IPK_VERSION=2

#
# MINIHTTPD_CONFFILES should be a list of user-editable files
#MINIHTTPD_CONFFILES=/opt/etc/minihttpd.conf /opt/etc/init.d/SXXminihttpd

#
# MINIHTTPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MINIHTTPD_PATCHES=$(MINIHTTPD_SOURCE_DIR)/Makefile.patch \
		$(MINIHTTPD_SOURCE_DIR)/port.h.patch \
		$(MINIHTTPD_SOURCE_DIR)/scripts.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MINIHTTPD_CPPFLAGS=
MINIHTTPD_LDFLAGS=

#
# MINIHTTPD_BUILD_DIR is the directory in which the build is done.
# MINIHTTPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MINIHTTPD_IPK_DIR is the directory in which the ipk is built.
# MINIHTTPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MINIHTTPD_BUILD_DIR=$(BUILD_DIR)/minihttpd
MINIHTTPD_SOURCE_DIR=$(SOURCE_DIR)/minihttpd
MINIHTTPD_IPK_DIR=$(BUILD_DIR)/minihttpd-$(MINIHTTPD_VERSION)-ipk
MINIHTTPD_IPK=$(BUILD_DIR)/minihttpd_$(MINIHTTPD_VERSION)-$(MINIHTTPD_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MINIHTTPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(MINIHTTPD_SITE)/$(MINIHTTPD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
minihttpd-source: $(DL_DIR)/$(MINIHTTPD_SOURCE) $(MINIHTTPD_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(MINIHTTPD_BUILD_DIR)/.configured: $(DL_DIR)/$(MINIHTTPD_SOURCE) $(MINIHTTPD_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MINIHTTPD_DIR) $(MINIHTTPD_BUILD_DIR)
	$(MINIHTTPD_UNZIP) $(DL_DIR)/$(MINIHTTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MINIHTTPD_PATCHES)" ; \
		then cat $(MINIHTTPD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MINIHTTPD_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MINIHTTPD_DIR)" != "$(MINIHTTPD_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MINIHTTPD_DIR) $(MINIHTTPD_BUILD_DIR) ; \
	fi
#	(cd $(MINIHTTPD_BUILD_DIR); \
#		$(TARGET_CONFIGURE_OPTS) \
#		CPPFLAGS="$(STAGING_CPPFLAGS) $(MINIHTTPD_CPPFLAGS)" \
#		LDFLAGS="$(STAGING_LDFLAGS) $(MINIHTTPD_LDFLAGS)" \
#		./configure \
#		--build=$(GNU_HOST_NAME) \
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
#		--prefix=/opt \
#		--disable-nls \
#		--disable-static \
#	)
#	$(PATCH_LIBTOOL) $(MINIHTTPD_BUILD_DIR)/libtool
#	touch $(MINIHTTPD_BUILD_DIR)/.configured

minihttpd-unpack: $(MINIHTTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MINIHTTPD_BUILD_DIR)/.built: $(MINIHTTPD_BUILD_DIR)/.configured
	rm -f $(MINIHTTPD_BUILD_DIR)/.built
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(MINIHTTPD_BUILD_DIR)
	touch $(MINIHTTPD_BUILD_DIR)/.built

#
# This is the build convenience target.
#
minihttpd: $(MINIHTTPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MINIHTTPD_BUILD_DIR)/.staged: $(MINIHTTPD_BUILD_DIR)/.built
	rm -f $(MINIHTTPD_BUILD_DIR)/.staged
	$(MAKE) -C $(MINIHTTPD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MINIHTTPD_BUILD_DIR)/.staged

minihttpd-stage: $(MINIHTTPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/minihttpd
#
$(MINIHTTPD_IPK_DIR)/CONTROL/control:
	@install -d $(MINIHTTPD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: minihttpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MINIHTTPD_PRIORITY)" >>$@
	@echo "Section: $(MINIHTTPD_SECTION)" >>$@
	@echo "Version: $(MINIHTTPD_VERSION)-$(MINIHTTPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MINIHTTPD_MAINTAINER)" >>$@
	@echo "Source: $(MINIHTTPD_SITE)/$(MINIHTTPD_SOURCE)" >>$@
	@echo "Description: $(MINIHTTPD_DESCRIPTION)" >>$@
	@echo "Depends: $(MINIHTTPD_DEPENDS)" >>$@
	@echo "Suggests: $(MINIHTTPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(MINIHTTPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MINIHTTPD_IPK_DIR)/opt/sbin or $(MINIHTTPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MINIHTTPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MINIHTTPD_IPK_DIR)/opt/etc/minihttpd/...
# Documentation files should be installed in $(MINIHTTPD_IPK_DIR)/opt/doc/minihttpd/...
# Daemon startup scripts should be installed in $(MINIHTTPD_IPK_DIR)/opt/etc/init.d/S??minihttpd
#
# You may need to patch your application to make it use these locations.
#
$(MINIHTTPD_IPK): $(MINIHTTPD_BUILD_DIR)/.built
	rm -rf $(MINIHTTPD_IPK_DIR) $(BUILD_DIR)/minihttpd_*_$(TARGET_ARCH).ipk
	install -d $(MINIHTTPD_IPK_DIR)/opt/sbin
	install -m 755 $(MINIHTTPD_BUILD_DIR)/mini_httpd $(MINIHTTPD_IPK_DIR)/opt/sbin
	install -m 755  $(MINIHTTPD_BUILD_DIR)/scripts/mini_httpd_wrapper $(MINIHTTPD_IPK_DIR)/opt/sbin
	install -d $(MINIHTTPD_IPK_DIR)/opt/bin
	install -m 755 $(MINIHTTPD_BUILD_DIR)/htpasswd	$(MINIHTTPD_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(MINIHTTPD_IPK_DIR)/opt/sbin/mini_httpd
	$(STRIP_COMMAND) $(MINIHTTPD_IPK_DIR)/opt/bin/htpasswd
	install -d $(MINIHTTPD_IPK_DIR)/opt/etc/init.d
	install -m 755  $(MINIHTTPD_BUILD_DIR)/scripts/mini_httpd.sh $(MINIHTTPD_IPK_DIR)/opt/etc/init.d/S80mini_httpd
	$(MAKE)	$(MINIHTTPD_IPK_DIR)/CONTROL/control
#	echo $(MINIHTTPD_CONFFILES) | sed -e 's/ /\n/g' > $(MINIHTTPD_IPK_DIR)/CONTROL/conffiles
#	install -m 755 $(MINIHTTPD_SOURCE_DIR)/postinst $(MINIHTTPD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MINIHTTPD_SOURCE_DIR)/prerm $(MINIHTTPD_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD)		$(MINIHTTPD_IPK_DIR)
	install -d $(MINIHTTPD_IPK_DIR)/opt/etc/
	install -m 644 $(MINIHTTPD_SOURCE_DIR)/mini_httpd.conf $(MINIHTTPD_IPK_DIR)/opt/etc
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MINIHTTPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
minihttpd-ipk: $(MINIHTTPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
minihttpd-clean:
	rm -f $(MINIHTTPD_BUILD_DIR)/.built
	-$(MAKE) -C $(MINIHTTPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
minihttpd-dirclean:
	rm -rf $(BUILD_DIR)/$(MINIHTTPD_DIR) $(MINIHTTPD_BUILD_DIR) $(MINIHTTPD_IPK_DIR) $(MINIHTTPD_IPK)