BOOTSTRAP_DIR         = $(PERL_LOCAL_LIBS_DIR)/local-lib
DOWNLOADS_DIR         = $(HOME)/Downloads
LOCAL_LIB_DIST        = local-lib-2.000029
LOCAL_LIB_MAIN_MODULE = local/lib.pm

$(DOWNLOADS_DIR)/$(LOCAL_LIB_DIST)/lib/$(LOCAL_LIB_MAIN_MODULE):
	mkdir -p $(DOWNLOADS_DIR)
	wget -O - https://cpan.metacpan.org/authors/id/H/HA/HAARG/$(LOCAL_LIB_DIST).tar.gz | gzip -cd | ( cd $(DOWNLOADS_DIR) && tar -xf - )

# No need to use an AND (&&) command list because the shell -e option is turned on
$(BOOTSTRAP_DIR)/lib/perl5/$(LOCAL_LIB_MAIN_MODULE): $(DOWNLOADS_DIR)/$(LOCAL_LIB_DIST)/lib/$(LOCAL_LIB_MAIN_MODULE)
	cd $(DOWNLOADS_DIR)/$(LOCAL_LIB_DIST); perl Makefile.PL --bootstrap=$(BOOTSTRAP_DIR); $(MAKE) test; $(MAKE) install

$(BOOTSTRAP_DIR)/bin/cpanm: $(BOOTSTRAP_DIR)/lib/perl5/$(LOCAL_LIB_MAIN_MODULE)
	PATH=$(PATH); tar --version 1>/dev/null 2>&1 && ( wget -O - https://cpanmin.us | perl - App::cpanminus ) || printf "%s\n" "Cannot install cpanm because GNU tar cannot be found in in $(PATH)!"

install-local-lib-dist: $(BOOTSTRAP_DIR)/lib/perl5/$(LOCAL_LIB_MAIN_MODULE)

install-cpanm: $(BOOTSTRAP_DIR)/bin/cpanm
