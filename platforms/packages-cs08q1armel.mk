PERL_MAJOR_VER = 5.10

# Packages that *only* work for cs08q1armel - do not just put new packages here.
SPECIFIC_PACKAGES = \
	$(PERL_PACKAGES) \
	$(PACKAGES_REQUIRE_LINUX26) \
	cacao \
	ipkg-opt \
	mono \

# Packages that do not work for cs08q1armel.
BROKEN_PACKAGES = \
	$(PACKAGES_ONLY_WORK_ON_LINUX24) \
	bzflag \
	gift giftcurs gift-ares gift-fasttrack gift-gnutella gift-openft gift-opennap \
	icecast iptables iptraf ldconfig \
	monotone \
	nfs-utils puppy mod-python qemu \
	taged transcode \
