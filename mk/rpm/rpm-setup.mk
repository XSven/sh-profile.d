# If not already included, include the 'Common' makefile.
ifeq ($(filter %common.mk,$(MAKEFILE_LIST)),)
  include ../common.mk
endif

RPM_COMMAND := $(shell which rpm 2>/dev/null)

# The top-level directory of rpm's build area has to be an absolute path.
RPM_TOP_DIR    := $(HOME)/rpmbuild
RPM_MACRO_FILE := $(HOME)/.rpmmacros
$(RPM_TOP_DIR):
	@mkdir $@
	@$(TO_STDOUT) '%_topdir  $@' > $(RPM_MACRO_FILE)
	@$(TO_STDOUT) "'$(RPM_TOP_DIR)' is top-level directory of rpm's build area."

RPM_BUILD_DIR := $(RPM_TOP_DIR)/BUILD
$(RPM_BUILD_DIR): | $(RPM_TOP_DIR)
	@mkdir $@

RPM_RPM_DIR := $(RPM_TOP_DIR)/RPMS
$(RPM_RPM_DIR): | $(RPM_TOP_DIR)
	@mkdir $@

RPM_SOURCE_DIR := $(RPM_TOP_DIR)/SOURCES
$(RPM_SOURCE_DIR): | $(RPM_TOP_DIR)
	@mkdir $@

RPM_SPEC_DIR := $(RPM_TOP_DIR)/SPECS
$(RPM_SPEC_DIR): | $(RPM_TOP_DIR)
	@mkdir $@

RPM_SRPM_DIR := $(RPM_TOP_DIR)/SRPMS
$(RPM_SRPM_DIR): | $(RPM_TOP_DIR)
	@mkdir $@

# The rpm's database directory has to be an absolute path.
RPM_DATABASE_DIR := $(HOME)/rpmdb
$(RPM_DATABASE_DIR):
	@$(RPM_COMMAND) --dbpath $@ --initdb
	@$(TO_STDOUT) "'$@' contains the rpm database."

.PHONY: setup-rpm-db
setup-rpm-db: | $(RPM_DATABASE_DIR) # Creates the rpm database defined by the 'RPM_DATABASE_DIR' macro.

.PHONY: clean-rpm-db
clean-rpm-db: # Removes the rpm database defined by the 'RPM_DATABASE_DIR' macro. Set the 'FORCE' command-line macro to 'true' to enforce the removal.
	@( $(FORCE) || [ -z "$$($(RPM_COMMAND) --dbpath $(RPM_DATABASE_DIR) -qa)" ] ) || \
	 { $(TO_STDERR) "rpm database '$(RPM_DATABASE_DIR)' is not empty."; return 2; }
	@rm -fr $(RPM_DATABASE_DIR)

.PHONY: setup-rpm-build-area
setup-rpm-build-area: $(RPM_BUILD_DIR) $(RPM_RPM_DIR) $(RPM_SOURCE_DIR) $(RPM_SPEC_DIR) $(RPM_SRPM_DIR) # Creates rpm's build area defined by the 'RPM_TOP_DIR' macro.

.PHONY: clean-rpm-build-area
clean-rpm-build-area: # Removes rpm's build area defined by the 'RPM_TOP_DIR' macro.
	@rm -fr $(RPM_TOP_DIR)
	@rm -f  $(RPM_MACRO_FILE)

