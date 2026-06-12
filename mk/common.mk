.DEFAULT_GOAL := all
# Enforces among other things that the shell that processes the recipes had
# been passed the -e switch (-o errexit).
.POSIX:

# Tell gmake not to export variables by default to sub-gmake.
unexport

# Common macro and target definitions.
FORCE     := false
GNU_TAR   := /opt/freeware/bin/tar
TO_STDERR := printf 1>&2 '%b\n'
TO_STDOUT := printf '%b\n'
SHELL     := /usr/bin/sh

.PHONY: all
all: # Default target, if 'gmake' is invoked without a target.
	@$(TO_STDERR) "Hello '$(LOGNAME)', nothing to do by default. Try 'make help'."

.PHONY: help
help: # Displays all targets scanning the make files defined by the 'MAKEFILE_LIST' macro.
	@perl -e " \
	   use strict; \
	   use warnings FATAL => q(all); \
	   our \$$phony; \
	   my \$$maxLength = 0; \
	   my %description; \
	   my %isPhony; \
	   while(<>) { \
	     if ((my \$$target) = m/^.PHONY:\s*([^#]+)/) { \
	       chomp(\$$target); \
	       \$$isPhony{\$$target} = 1; \
	     } \
	     if ((my \$$target, my \$$description) = m/^([^#.:]+):[^#]*#\s*(.+)/) { \
		if (\$$phony) { \
	          next unless \$$isPhony{\$$target}; \
	        } \
	       \$$description{\$$target} = \$$description; \
	       \$$maxLength = length(\$$target) \
	         if length(\$$target) > \$$maxLength; \
	     } \
	   } \
	   print qq(Available targets:\n); \
	   printf(qq(%-\$${maxLength}s - %s\n), \$$_, \$$description{\$$_}) \
	     for sort keys(%description); \
	 " -s -- -phony $(MAKEFILE_LIST)
#	 " -s -- $(MAKEFILE_LIST)

.PHONY: show
show: # Shows a macro value, enclosed in angle brackets '<...>', for a given macro name. Use the 'MACRO' command-line macro to specify the macro name.
	@$(TO_STDOUT) "<$($(MACRO))>"

