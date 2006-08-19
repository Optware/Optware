###########################################################
#
# perl-business-isbn-data
#
###########################################################

PERL-BUSINESS-ISBN-DATA_SITE=http://search.cpan.org/CPAN/authors/id/B/BD/BDFOY
PERL-BUSINESS-ISBN-DATA_VERSION=1.11
PERL-BUSINESS-ISBN-DATA_SOURCE=Business-ISBN-Data-$(PERL-BUSINESS-ISBN-DATA_VERSION).tar.gz
PERL-BUSINESS-ISBN-DATA_DIR=Business-ISBN-Data-$(PERL-BUSINESS-ISBN-DATA_VERSION)
PERL-BUSINESS-ISBN-DATA_UNZIP=zcat
PERL-BUSINESS-ISBN-DATA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-BUSINESS-ISBN-DATA_DESCRIPTION=Business-ISBN-Data - <module_description>
PERL-BUSINESS-ISBN-DATA_SECTION=util
PERL-BUSINESS-ISBN-DATA_PRIORITY=optional
PERL-BUSINESS-ISBN-DATA_DEPENDS=perl
PERL-BUSINESS-ISBN-DATA_SUGGESTS=
PERL-BUSINESS-ISBN-DATA_CONFLICTS=

PERL-BUSINESS-ISBN-DATA_IPK_VERSION=1

PERL-BUSINESS-ISBN-DATA_CONFFILES=

PERL-BUSINESS-ISBN-DATA_BUILD_DIR=$(BUILD_DIR)/perl-business-isbn-data
PERL-BUSINESS-ISBN-DATA_SOURCE_DIR=$(SOURCE_DIR)/perl-business-isbn-data
PERL-BUSINESS-ISBN-DATA_IPK_DIR=$(BUILD_DIR)/perl-business-isbn-data-$(PERL-BUSINESS-ISBN-DATA_VERSION)-ipk
PERL-BUSINESS-ISBN-DATA_IPK=$(BUILD_DIR)/perl-business-isbn-data_$(PERL-BUSINESS-ISBN-DATA_VERSION)-$(PERL-BUSINESS-ISBN-DATA_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-BUSINESS-ISBN-DATA_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-BUSINESS-ISBN-DATA_SITE)/$(PERL-BUSINESS-ISBN-DATA_SOURCE)

perl-business-isbn-data-source: $(DL_DIR)/$(PERL-BUSINESS-ISBN-DATA_SOURCE) $(PERL-BUSINESS-ISBN-DATA_PATCHES)

$(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-BUSINESS-ISBN-DATA_SOURCE) $(PERL-BUSINESS-ISBN-DATA_PATCHES)
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(PERL-BUSINESS-ISBN-DATA_DIR) $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)
	$(PERL-BUSINESS-ISBN-DATA_UNZIP) $(DL_DIR)/$(PERL-BUSINESS-ISBN-DATA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-BUSINESS-ISBN-DATA_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-BUSINESS-ISBN-DATA_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-BUSINESS-ISBN-DATA_DIR) $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)
	(cd $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.configured

perl-business-isbn-data-unpack: $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.configured

$(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.built: $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.configured
	rm -f $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.built

perl-business-isbn-data: $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.built

$(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.staged: $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.built
	rm -f $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.staged

perl-business-isbn-data-stage: $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.staged

$(PERL-BUSINESS-ISBN-DATA_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-BUSINESS-ISBN-DATA_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-business-isbn-data" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-BUSINESS-ISBN-DATA_PRIORITY)" >>$@
	@echo "Section: $(PERL-BUSINESS-ISBN-DATA_SECTION)" >>$@
	@echo "Version: $(PERL-BUSINESS-ISBN-DATA_VERSION)-$(PERL-BUSINESS-ISBN-DATA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-BUSINESS-ISBN-DATA_MAINTAINER)" >>$@
	@echo "Source: $(PERL-BUSINESS-ISBN-DATA_SITE)/$(PERL-BUSINESS-ISBN-DATA_SOURCE)" >>$@
	@echo "Description: $(PERL-BUSINESS-ISBN-DATA_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-BUSINESS-ISBN-DATA_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-BUSINESS-ISBN-DATA_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-BUSINESS-ISBN-DATA_CONFLICTS)" >>$@

$(PERL-BUSINESS-ISBN-DATA_IPK): $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR)/.built
	rm -rf $(PERL-BUSINESS-ISBN-DATA_IPK_DIR) $(BUILD_DIR)/perl-business-isbn-data_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR) DESTDIR=$(PERL-BUSINESS-ISBN-DATA_IPK_DIR) install
	find $(PERL-BUSINESS-ISBN-DATA_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-BUSINESS-ISBN-DATA_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-BUSINESS-ISBN-DATA_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-BUSINESS-ISBN-DATA_IPK_DIR)/CONTROL/control
	echo $(PERL-BUSINESS-ISBN-DATA_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-BUSINESS-ISBN-DATA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-BUSINESS-ISBN-DATA_IPK_DIR)

perl-business-isbn-data-ipk: $(PERL-BUSINESS-ISBN-DATA_IPK)

perl-business-isbn-data-clean:
	-$(MAKE) -C $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR) clean

perl-business-isbn-data-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-BUSINESS-ISBN-DATA_DIR) $(PERL-BUSINESS-ISBN-DATA_BUILD_DIR) $(PERL-BUSINESS-ISBN-DATA_IPK_DIR) $(PERL-BUSINESS-ISBN-DATA_IPK)
