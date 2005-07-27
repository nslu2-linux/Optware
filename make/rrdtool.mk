###########################################################
#
# rrdtool
#
###########################################################

# You must replace "rrdtool" and "RRDTOOL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# RRDTOOL_VERSION, RRDTOOL_SITE and RRDTOOL_SOURCE define
# the upstream location of the source code for the package.
# RRDTOOL_DIR is the directory which is created when the source
# archive is unpacked.
# RRDTOOL_UNZIP is the command used to unzip the source.
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
#http://people.ee.ethz.ch/~oetiker/webtools/rrdtool/pub/rrdtool-1.2.8.tar.gz
RRDTOOL_SITE=http://people.ee.ethz.ch/~oetiker/webtools/rrdtool/pub/
RRDTOOL_VERSION=1.2.11
RRDTOOL_SOURCE=rrdtool-$(RRDTOOL_VERSION).tar.gz
RRDTOOL_DIR=rrdtool-$(RRDTOOL_VERSION)
RRDTOOL_UNZIP=zcat
RRDTOOL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RRDTOOL_DESCRIPTION=Round-Robin Database tool. Database collator and plotter
RRDTOOL_SECTION=misc
RRDTOOL_PRIORITY=optional
RRDTOOL_DEPENDS=zlib, libpng, freetype, libart
RRDTOOL_SUGGESTS=
RRDTOOL_CONFLICTS=

#
# RRDTOOL_IPK_VERSION should be incremented when the ipk changes.
#
RRDTOOL_IPK_VERSION=1

#
# RRDTOOL_CONFFILES should be a list of user-editable files
#RRDTOOL_CONFFILES=/opt/etc/rrdtool.conf /opt/etc/init.d/SXXrrdtool

#
# RRDTOOL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifeq ($(OPTWARE_TARGET),wl500g)
RRDTOOL_PATCHES=$(RRDTOOL_SOURCE_DIR)/rrd_gfx.c.wiley.patch
endif
#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RRDTOOL_CPPFLAGS= -I$(STAGING_INCLUDE_DIR)/libart-2.0 -I$(STAGING_INCLUDE_DIR)/freetype2
RRDTOOL_LDFLAGS=

#
# RRDTOOL_BUILD_DIR is the directory in which the build is done.
# RRDTOOL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RRDTOOL_IPK_DIR is the directory in which the ipk is built.
# RRDTOOL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RRDTOOL_BUILD_DIR=$(BUILD_DIR)/rrdtool
RRDTOOL_SOURCE_DIR=$(SOURCE_DIR)/rrdtool
RRDTOOL_IPK_DIR=$(BUILD_DIR)/rrdtool-$(RRDTOOL_VERSION)-ipk
RRDTOOL_IPK=$(BUILD_DIR)/rrdtool_$(RRDTOOL_VERSION)-$(RRDTOOL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RRDTOOL_SOURCE):
	$(WGET) -P $(DL_DIR) $(RRDTOOL_SITE)/$(RRDTOOL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rrdtool-source: $(DL_DIR)/$(RRDTOOL_SOURCE) $(RRDTOOL_PATCHES)

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
$(RRDTOOL_BUILD_DIR)/.configured: $(DL_DIR)/$(RRDTOOL_SOURCE) $(RRDTOOL_PATCHES)
	$(MAKE) zlib-stage libpng-stage freetype-stage libart-stage
	rm -rf $(BUILD_DIR)/$(RRDTOOL_DIR) $(RRDTOOL_BUILD_DIR)
	$(RRDTOOL_UNZIP) $(DL_DIR)/$(RRDTOOL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
ifeq ($(OPTWARE_TARGET),wl500g)
	cat $(RRDTOOL_PATCHES) | patch -d $(BUILD_DIR)/$(RRDTOOL_DIR) -p1
endif
	mv $(BUILD_DIR)/$(RRDTOOL_DIR) $(RRDTOOL_BUILD_DIR)
	(cd $(RRDTOOL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RRDTOOL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RRDTOOL_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		rd_cv_ieee_works=yes \
		rd_cv_null_realloc=nope \
		ac_cv_func_mmap_fixed_mapped=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-rrdcgi \
		--disable-nls \
		--disable-tcl \
		--disable-perl \
		--disable-python \
		--disable-static \
		--program-prefix="" \
	)
	$(PATCH_LIBTOOL) $(RRDTOOL_BUILD_DIR)/libtool
	touch $(RRDTOOL_BUILD_DIR)/.configured

rrdtool-unpack: $(RRDTOOL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RRDTOOL_BUILD_DIR)/.built: $(RRDTOOL_BUILD_DIR)/.configured
	rm -f $(RRDTOOL_BUILD_DIR)/.built
	$(MAKE) -C $(RRDTOOL_BUILD_DIR)
	touch $(RRDTOOL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
rrdtool: $(RRDTOOL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RRDTOOL_BUILD_DIR)/.staged: $(RRDTOOL_BUILD_DIR)/.built
	rm -f $(RRDTOOL_BUILD_DIR)/.staged
	$(MAKE) -C $(RRDTOOL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/librrd.la
	rm -f $(STAGING_LIB_DIR)/librrd_th.la
	touch $(RRDTOOL_BUILD_DIR)/.staged

rrdtool-stage: $(RRDTOOL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rrdtool
#
$(RRDTOOL_IPK_DIR)/CONTROL/control:
	@install -d $(RRDTOOL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: rrdtool" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RRDTOOL_PRIORITY)" >>$@
	@echo "Section: $(RRDTOOL_SECTION)" >>$@
	@echo "Version: $(RRDTOOL_VERSION)-$(RRDTOOL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RRDTOOL_MAINTAINER)" >>$@
	@echo "Source: $(RRDTOOL_SITE)/$(RRDTOOL_SOURCE)" >>$@
	@echo "Description: $(RRDTOOL_DESCRIPTION)" >>$@
	@echo "Depends: $(RRDTOOL_DEPENDS)" >>$@
	@echo "Suggests: $(RRDTOOL_SUGGESTS)" >>$@
	@echo "Conflicts: $(RRDTOOL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RRDTOOL_IPK_DIR)/opt/sbin or $(RRDTOOL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RRDTOOL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RRDTOOL_IPK_DIR)/opt/etc/rrdtool/...
# Documentation files should be installed in $(RRDTOOL_IPK_DIR)/opt/doc/rrdtool/...
# Daemon startup scripts should be installed in $(RRDTOOL_IPK_DIR)/opt/etc/init.d/S??rrdtool
#
# You may need to patch your application to make it use these locations.
#
$(RRDTOOL_IPK): $(RRDTOOL_BUILD_DIR)/.built
	rm -rf $(RRDTOOL_IPK_DIR) $(BUILD_DIR)/rrdtool_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RRDTOOL_BUILD_DIR) DESTDIR=$(RRDTOOL_IPK_DIR) install-strip
	rm -f $(RRDTOOL_IPK_DIR)/opt/lib/librrd.la
	rm -f $(RRDTOOL_IPK_DIR)/opt/lib/librrd_th.la
#	install -d $(RRDTOOL_IPK_DIR)/opt/etc/
#	install -m 644 $(RRDTOOL_SOURCE_DIR)/rrdtool.conf $(RRDTOOL_IPK_DIR)/opt/etc/rrdtool.conf
#	install -d $(RRDTOOL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(RRDTOOL_SOURCE_DIR)/rc.rrdtool $(RRDTOOL_IPK_DIR)/opt/etc/init.d/SXXrrdtool
	$(MAKE) $(RRDTOOL_IPK_DIR)/CONTROL/control
#	install -m 755 $(RRDTOOL_SOURCE_DIR)/postinst $(RRDTOOL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(RRDTOOL_SOURCE_DIR)/prerm $(RRDTOOL_IPK_DIR)/CONTROL/prerm
	echo $(RRDTOOL_CONFFILES) | sed -e 's/ /\n/g' > $(RRDTOOL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RRDTOOL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rrdtool-ipk: $(RRDTOOL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rrdtool-clean:
	-$(MAKE) -C $(RRDTOOL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rrdtool-dirclean:
	rm -rf $(BUILD_DIR)/$(RRDTOOL_DIR) $(RRDTOOL_BUILD_DIR) $(RRDTOOL_IPK_DIR) $(RRDTOOL_IPK)
