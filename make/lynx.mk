###########################################################
#
# lynx
#
###########################################################

LYNX_SITE=http://lynx.isc.org/release
LYNX_VERSION=2.8.5
LYNX_SOURCE=lynx$(LYNX_VERSION).tar.bz2
LYNX_DIR=lynx2-8-5
LYNX_UNZIP=bzcat

LYNX_IPK_VERSION=2

LYNX_CONFFILES=/opt/etc/lynx.cfg

LYNX_BUILD_DIR=$(BUILD_DIR)/lynx
LYNX_SOURCE_DIR=$(SOURCE_DIR)/lynx
LYNX_IPK_DIR=$(BUILD_DIR)/lynx-$(LYNX_VERSION)-ipk
LYNX_IPK=$(BUILD_DIR)/lynx_$(LYNX_VERSION)-$(LYNX_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(LYNX_SOURCE):
	$(WGET) -P $(DL_DIR) $(LYNX_SITE)/$(LYNX_SOURCE)

lynx-source: $(DL_DIR)/$(LYNX_SOURCE) $(LYNX_PATCHES)

$(LYNX_BUILD_DIR)/.configured: $(DL_DIR)/$(LYNX_SOURCE) $(LYNX_PATCHES)
	$(MAKE) ncurses-stage openssl-stage bzip2-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(LYNX_DIR) $(LYNX_BUILD_DIR)
	$(LYNX_UNZIP) $(DL_DIR)/$(LYNX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LYNX_DIR) $(LYNX_BUILD_DIR)
	(cd $(LYNX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="-I$(LYNX_BUILD_DIR)/src/chrtrans $(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--libdir=/opt/etc \
		--without-libiconv-prefix \
		--with-ssl=$(STAGING_DIR) \
		--with-screen=ncurses \
		--with-curses-dir=$(STAGING_DIR) \
		--with-bzlib \
		--with-zlib \
		--disable-nls \
	)
	touch $(LYNX_BUILD_DIR)/.configured

lynx-unpack: $(LYNX_BUILD_DIR)/.configured

$(LYNX_BUILD_DIR)/.built: $(LYNX_BUILD_DIR)/.configured
	rm -f $(LYNX_BUILD_DIR)/.built
	$(MAKE) -C $(LYNX_BUILD_DIR)/src/chrtrans makeuctb CC=$(HOSTCC) LIBS=""
	$(MAKE) -C $(LYNX_BUILD_DIR)
	touch $(LYNX_BUILD_DIR)/.built

lynx: $(LYNX_BUILD_DIR)/.built

$(LYNX_IPK): $(LYNX_BUILD_DIR)/.built
	rm -rf $(LYNX_IPK_DIR) $(BUILD_DIR)/lynx_*_armeb.ipk
	$(MAKE) -j1 -C $(LYNX_BUILD_DIR) DESTDIR=$(LYNX_IPK_DIR) install
	$(STRIP_COMMAND) $(LYNX_IPK_DIR)/opt/bin/*
	install -d $(LYNX_IPK_DIR)/CONTROL
	install -m 644 $(LYNX_SOURCE_DIR)/control $(LYNX_IPK_DIR)/CONTROL/control
	echo $(LYNX_CONFFILES) | sed -e 's/ /\n/g' > $(LYNX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LYNX_IPK_DIR)

lynx-ipk: $(LYNX_IPK)

lynx-clean:
	-$(MAKE) -C $(LYNX_BUILD_DIR) clean

lynx-dirclean:
	rm -rf $(BUILD_DIR)/$(LYNX_DIR) $(LYNX_BUILD_DIR) $(LYNX_IPK_DIR) $(LYNX_IPK)
