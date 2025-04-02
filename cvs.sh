#!/usr/bin/env sh

# In the following assignment of the CVSROOT environment variable the port
# number is not specified explicitly. This approach is on purpose. It allows us
# to change the default port number 2401 using the CVS_CLIENT_PORT environment
# variable.
CVSROOT=${CVSROOT:-:pserver:$(echo "${FULL_NAME}" | sed 's/ /./')@cvsserver.int.kn:/dataio/cvs/IB}
export CVSROOT

cvs() {
  # The "command" utility allows functions that have the same name as an
  # executable file to call the executable file (instead of a recursive call to
  # the function).
  command cvs -d "${CVSROOT}" "$@"
}

