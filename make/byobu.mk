###########################################################
#
# byobu
#
###########################################################

# You must replace "byobu" and "BYOBU" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# BYOBU_VERSION, BYOBU_SITE and BYOBU_SOURCE define
# the upstream location of the source code for the package.
# BYOBU_DIR is the directory which is created when the source
# archive is unpacked.
# BYOBU_UNZIP is the command used to unzip the source.
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
BYOBU_VERSION=5.94
BYOBU_MINOR_VERSION=.orig
BYOBU_SITE=http://byobu.co/download
BYOBU_SOURCE=byobu_$(BYOBU_VERSION)$(BYOBU_MINOR_VERSION).tar.gz
BYOBU_DIR=byobu-$(BYOBU_VERSION)
BYOBU_UNZIP=zcat
BYOBU_MAINTAINER=Eric McCann <nuclearmistake+osrc@gmail.com>
BYOBU_DESCRIPTION=powerful, text based window manager and shell multiplexer \
 Byobu is Ubuntu's text-based window manager based on GNU Screen. \
 Using Byobu, you can quickly create and move between different windows \
 over a single SSH connection or TTY terminal, monitor dozens of important \
 statistics about your system, detach and reattach to sessions later \
 while your programs continue to run in the background.
BYOBU_SECTION=util
BYOBU_PRIORITY=optional
BYOBU_DEPENDS=tmux screen readline ncurses
BYOBU_SUGGESTS=
BYOBU_CONFLICTS=

#
# BYOBU_IPK_VERSION should be incremented when the ipk changes.
#
BYOBU_IPK_VERSION=1

#
# BYOBU_CONFFILES should be a list of user-editable files
#BYOBU_CONFFILES=/opt/etc/byobu.conf /opt/etc/init.d/SXXbyobu

#
# BYOBU_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BYOBU_PATCHES=$(BYOBU_SOURCE_DIR)/timesys-allow-cross-compile-v2.patch \
 $(BYOBU_SOURCE_DIR)/timesys-dont-configure-testsuites.patch \
 $(BYOBU_SOURCE_DIR)/update-config.sub.patch \
 $(BYOBU_SOURCE_DIR)/Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BYOBU_CPPFLAGS=
BYOBU_LDFLAGS=

#
# BYOBU_BUILD_DIR is the directory in which the build is done.
# BYOBU_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BYOBU_IPK_DIR is the directory in which the ipk is built.
# BYOBU_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BYOBU_BUILD_DIR=$(BUILD_DIR)/byobu
BYOBU_SOURCE_DIR=$(SOURCE_DIR)/byobu
BYOBU_IPK_DIR=$(BUILD_DIR)/byobu-$(BYOBU_VERSION)-ipk
BYOBU_IPK=$(BUILD_DIR)/byobu_$(BYOBU_VERSION)-$(BYOBU_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: byobu-source byobu-unpack byobu byobu-stage byobu-ipk byobu-clean byobu-dirclean byobu-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BYOBU_SOURCE):
	$(WGET) -P $(@D) $(BYOBU_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
byobu-source: $(DL_DIR)/$(BYOBU_SOURCE) $(BYOBU_PATCHES)

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
$(BYOBU_BUILD_DIR)/.configured: $(DL_DIR)/$(BYOBU_SOURCE) $(BYOBU_PATCHES) make/byobu.mk
	$(MAKE) readline-stage ncurses-stage 
	rm -rf $(BUILD_DIR)/$(BYOBU_DIR) $(@D)
	$(BYOBU_UNZIP) $(DL_DIR)/$(BYOBU_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	if test -n "$(BYOBU_PATCHES)" ; \
		pwd; \
		then cat $(BYOBU_PATCHES) | \
		patch -b -d $(BUILD_DIR)/$(BYOBU_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(BYOBU_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(BYOBU_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BYOBU_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BYOBU_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $@

byobu-unpack: $(BYOBU_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BYOBU_BUILD_DIR)/.built: $(BYOBU_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
byobu: $(BYOBU_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BYOBU_BUILD_DIR)/.staged: $(BYOBU_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) INSTALL_ROOT=$(STAGING_DIR) STAGING_LIB_DIR=$(STAGING_LIB_DIR) install
	touch $@

byobu-stage: $(BYOBU_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/byobu
#
$(BYOBU_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: byobu" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BYOBU_PRIORITY)" >>$@
	@echo "Section: $(BYOBU_SECTION)" >>$@
	@echo "Version: $(BYOBU_VERSION)-$(BYOBU_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BYOBU_MAINTAINER)" >>$@
	@echo "Source: $(BYOBU_SITE)/$(BYOBU_SOURCE)" >>$@
	@echo "Description: $(BYOBU_DESCRIPTION)" >>$@
	@echo "Depends: $(BYOBU_DEPENDS)" >>$@
	@echo "Suggests: $(BYOBU_SUGGESTS)" >>$@
	@echo "Conflicts: $(BYOBU_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BYOBU_IPK_DIR)/opt/sbin or $(BYOBU_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BYOBU_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BYOBU_IPK_DIR)/opt/etc/byobu/...
# Documentation files should be installed in $(BYOBU_IPK_DIR)/opt/doc/byobu/...
# Daemon startup scripts should be installed in $(BYOBU_IPK_DIR)/opt/etc/init.d/S??byobu
#
# You may need to patch your application to make it use these locations.
#
$(BYOBU_IPK): $(BYOBU_BUILD_DIR)/.built
	rm -rf $(BYOBU_IPK_DIR) $(BUILD_DIR)/byobu_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BYOBU_BUILD_DIR) DESTDIR=$(BYOBU_IPK_DIR) INSTALL_ROOT=$(BYOBU_IPK_DIR) STAGING_LIB_DIR=$(STAGING_LIB_DIR) install
#	install -d $(BYOBU_IPK_DIR)/opt/etc/
#	install -m 644 $(BYOBU_SOURCE_DIR)/byobu.conf $(BYOBU_IPK_DIR)/opt/etc/byobu.conf
#	install -d $(BYOBU_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(BYOBU_SOURCE_DIR)/rc.byobu $(BYOBU_IPK_DIR)/opt/etc/init.d/SXXbyobu
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(BYOBU_IPK_DIR)/opt/etc/init.d/SXXbyobu
	$(MAKE) $(BYOBU_IPK_DIR)/CONTROL/control
#	install -m 755 $(BYOBU_SOURCE_DIR)/postinst $(BYOBU_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(BYOBU_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(BYOBU_SOURCE_DIR)/prerm $(BYOBU_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(BYOBU_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(BYOBU_IPK_DIR)/CONTROL/postinst $(BYOBU_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(BYOBU_CONFFILES) | sed -e 's/ /\n/g' > $(BYOBU_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BYOBU_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(BYOBU_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
byobu-ipk: $(BYOBU_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
byobu-clean:
	rm -f $(BYOBU_BUILD_DIR)/.built
	-$(MAKE) -C $(BYOBU_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
byobu-dirclean:
	rm -rf $(BUILD_DIR)/$(BYOBU_DIR) $(BYOBU_BUILD_DIR) $(BYOBU_IPK_DIR) $(BYOBU_IPK)
#
#
# Some sanity check for the package.
#
byobu-check: $(BYOBU_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
