SPECIFIC_PACKAGES = \
	ipkg-opt \
	libiconv \
	py-ctypes \
	ts101-kernel-modules \
	$(PERL_PACKAGES) \

# samba34: smbd/trans2.c: In function `get_lanman2_dir_entry':./../lib/util/byteorder.h:114: error: inconsistent operand constraints in an `asm'
BROKEN_PACKAGES = \
	$(UCLIBC_BROKEN_PACKAGES) \
	ecl ficy \
	gift giftcurs \
	gift-ares gift-fasttrack gift-gnutella \
	gift-openft gift-opennap \
	gloox \
	golang \
	gtmess \
	hplip \
	iptraf \
	linphone \
	nfs-server nfs-utils \
	samba34 \
	sane-backends \
	sandbox \
	transcode \
	util-linux \
	\
	asterisk14 asterisk14-chan-capi asterisk16 asterisk16-addons \
	ts101-kernel-modules

E2FSPROGS_VERSION := 1.40.3
E2FSPROGS_IPK_VERSION := 5

RTORRENT_VERSION := 0.8.2
RTORRENT_IPK_VERSION := 2
