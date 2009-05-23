SPECIFIC_PACKAGES = \
	ipkg-opt libiconv uclibc-opt \
	$(PERL_PACKAGES) \
	binutils libc-dev \

# iptraf: sys/types.h and linux/types.h conflicting
BROKEN_PACKAGES = \
	buildroot \
	$(UCLIBC_BROKEN_PACKAGES) \
	bluez-hcidump \
	ficy \
	fuppes \
	gcc \
	gtmess \
	inferno \
	\
	microdc2 \
	mod-python \
	rssh \
	taged \
	transcode \
	util-linux \
	slimserver \

PERL_MAJOR_VER=5.10
