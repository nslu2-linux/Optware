###########################################################
#
# py-yaml
#
###########################################################

#
# PY-YAML_VERSION, PY-YAML_SITE and PY-YAML_SOURCE define
# the upstream location of the source code for the package.
# PY-YAML_DIR is the directory which is created when the source
# archive is unpacked.
# PY-YAML_UNZIP is the command used to unzip the source.
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
PY-YAML_SITE=http://pyyaml.org/download/pyyaml
PY-YAML_VERSION=3.04
PY-YAML_SOURCE=PyYAML-$(PY-YAML_VERSION).tar.gz
PY-YAML_DIR=PyYAML-$(PY-YAML_VERSION)
PY-YAML_UNZIP=zcat
PY-YAML_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-YAML_DESCRIPTION=YAML parser and emitter for Python.
PY-YAML_SECTION=misc
PY-YAML_PRIORITY=optional
PY-YAML_DEPENDS=python
PY-YAML_CONFLICTS=

#
# PY-YAML_IPK_VERSION should be incremented when the ipk changes.
#
PY-YAML_IPK_VERSION=1

#
# PY-YAML_CONFFILES should be a list of user-editable files
#PY-YAML_CONFFILES=/opt/etc/py-yaml.conf /opt/etc/init.d/SXXpy-yaml

#
# PY-YAML_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-YAML_PATCHES=$(PY-YAML_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-YAML_CPPFLAGS=
PY-YAML_LDFLAGS=

#
# PY-YAML_BUILD_DIR is the directory in which the build is done.
# PY-YAML_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-YAML_IPK_DIR is the directory in which the ipk is built.
# PY-YAML_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-YAML_BUILD_DIR=$(BUILD_DIR)/py-yaml
PY-YAML_SOURCE_DIR=$(SOURCE_DIR)/py-yaml
PY-YAML_IPK_DIR=$(BUILD_DIR)/py-yaml-$(PY-YAML_VERSION)-ipk
PY-YAML_IPK=$(BUILD_DIR)/py-yaml_$(PY-YAML_VERSION)-$(PY-YAML_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-YAML_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-YAML_SITE)/$(PY-YAML_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-yaml-source: $(DL_DIR)/$(PY-YAML_SOURCE) $(PY-YAML_PATCHES)

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
$(PY-YAML_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-YAML_SOURCE) $(PY-YAML_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-YAML_DIR) $(PY-YAML_BUILD_DIR)
	$(PY-YAML_UNZIP) $(DL_DIR)/$(PY-YAML_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-YAML_PATCHES)"; then \
	    cat $(PY-YAML_PATCHES) | patch -d $(BUILD_DIR)/$(PY-YAML_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-YAML_DIR) $(PY-YAML_BUILD_DIR)
	(cd $(PY-YAML_BUILD_DIR); \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	touch $(PY-YAML_BUILD_DIR)/.configured

py-yaml-unpack: $(PY-YAML_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-YAML_BUILD_DIR)/.built: $(PY-YAML_BUILD_DIR)/.configured
	rm -f $(PY-YAML_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-YAML_BUILD_DIR)
	(cd $(PY-YAML_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 setup.py build)
	touch $(PY-YAML_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-yaml: $(PY-YAML_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-YAML_BUILD_DIR)/.staged: $(PY-YAML_BUILD_DIR)/.built
	rm -f $(PY-YAML_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-YAML_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-YAML_BUILD_DIR)/.staged

py-yaml-stage: $(PY-YAML_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-yaml
#
$(PY-YAML_IPK_DIR)/CONTROL/control:
	@install -d $(PY-YAML_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-yaml" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-YAML_PRIORITY)" >>$@
	@echo "Section: $(PY-YAML_SECTION)" >>$@
	@echo "Version: $(PY-YAML_VERSION)-$(PY-YAML_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-YAML_MAINTAINER)" >>$@
	@echo "Source: $(PY-YAML_SITE)/$(PY-YAML_SOURCE)" >>$@
	@echo "Description: $(PY-YAML_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-YAML_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-YAML_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-YAML_IPK_DIR)/opt/sbin or $(PY-YAML_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-YAML_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-YAML_IPK_DIR)/opt/etc/py-yaml/...
# Documentation files should be installed in $(PY-YAML_IPK_DIR)/opt/doc/py-yaml/...
# Daemon startup scripts should be installed in $(PY-YAML_IPK_DIR)/opt/etc/init.d/S??py-yaml
#
# You may need to patch your application to make it use these locations.
#
$(PY-YAML_IPK): $(PY-YAML_BUILD_DIR)/.built
	rm -rf $(PY-YAML_IPK_DIR) $(BUILD_DIR)/py-yaml_*_$(TARGET_ARCH).ipk
	(cd $(PY-YAML_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 -c "import setuptools; execfile('setup.py')" install --root=$(PY-YAML_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY-YAML_IPK_DIR)/CONTROL/control
#	echo $(PY-YAML_CONFFILES) | sed -e 's/ /\n/g' > $(PY-YAML_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-YAML_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-yaml-ipk: $(PY-YAML_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-yaml-clean:
	-$(MAKE) -C $(PY-YAML_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-yaml-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-YAML_DIR) $(PY-YAML_BUILD_DIR) $(PY-YAML_IPK_DIR) $(PY-YAML_IPK)