###########################################################
#
# joe
#
###########################################################

# JOE_VERSION, JOE_SITE and JOE_SOURCE define
# the upstream location of the source code for the package.
# JOE_DIR is the directory which is created when the source
# archive is unpacked.
# JOE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
JOE_SITE=http://dl.sf.net/sourceforge/joe-editor
JOE_VERSION=3.1
JOE_SOURCE=joe-$(JOE_VERSION).tar.gz
JOE_DIR=joe-$(JOE_VERSION)
JOE_UNZIP=zcat

#
# JOE_IPK_VERSION should be incremented when the ipk changes.
#
JOE_IPK_VERSION=1

#
# JOE_CONFFILES should be a list of user-editable files
#JOE_CONFFILES=/opt/etc/joe/*

#
# JOE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#JOE_PATCHES=$(JOE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
JOE_CPPFLAGS=
JOE_LDFLAGS=

#
# JOE_BUILD_DIR is the directory in which the build is done.
# JOE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# JOE_IPK_DIR is the directory in which the ipk is built.
# JOE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
JOE_BUILD_DIR=$(BUILD_DIR)/joe
JOE_SOURCE_DIR=$(SOURCE_DIR)/joe
JOE_IPK_DIR=$(BUILD_DIR)/joe-$(JOE_VERSION)-ipk
JOE_IPK=$(BUILD_DIR)/joe_$(JOE_VERSION)-$(JOE_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(JOE_SOURCE):
	$(WGET) -P $(DL_DIR) $(JOE_SITE)/$(JOE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
joe-source: $(DL_DIR)/$(JOE_SOURCE) $(JOE_PATCHES)

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
$(JOE_BUILD_DIR)/.configured: $(DL_DIR)/$(JOE_SOURCE) $(JOE_PATCHES)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(JOE_DIR) $(JOE_BUILD_DIR)
	$(JOE_UNZIP) $(DL_DIR)/$(JOE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(JOE_DIR) $(JOE_BUILD_DIR)
	(cd $(JOE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(JOE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(JOE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(JOE_BUILD_DIR)/.configured

joe-unpack: $(JOE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(JOE_BUILD_DIR)/.built: $(JOE_BUILD_DIR)/.configured
	rm -f $(JOE_BUILD_DIR)/.built
	$(MAKE) -C $(JOE_BUILD_DIR)
	touch $(JOE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
joe: $(JOE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(JOE_BUILD_DIR)/.staged: $(JOE_BUILD_DIR)/.built
	rm -f $(JOE_BUILD_DIR)/.staged
	$(MAKE) -C $(JOE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(JOE_BUILD_DIR)/.staged

joe-stage: $(JOE_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(JOE_IPK_DIR)/opt/sbin or $(JOE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(JOE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(JOE_IPK_DIR)/opt/etc/joe/...
# Documentation files should be installed in $(JOE_IPK_DIR)/opt/doc/joe/...
# Daemon startup scripts should be installed in $(JOE_IPK_DIR)/opt/etc/init.d/S??joe
#
# You may need to patch your application to make it use these locations.
#
$(JOE_IPK): $(JOE_BUILD_DIR)/.built
	rm -rf $(JOE_IPK_DIR) $(BUILD_DIR)/joe_*_armeb.ipk
	$(MAKE) -C $(JOE_BUILD_DIR) DESTDIR=$(JOE_IPK_DIR) install-strip
	install -d $(JOE_IPK_DIR)/opt/etc/
	install -d $(JOE_IPK_DIR)/CONTROL
	install -m 644 $(JOE_SOURCE_DIR)/control $(JOE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(JOE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
joe-ipk: $(JOE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
joe-clean:
	-$(MAKE) -C $(JOE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
joe-dirclean:
	rm -rf $(BUILD_DIR)/$(JOE_DIR) $(JOE_BUILD_DIR) $(JOE_IPK_DIR) $(JOE_IPK)
