#!/bin/bash

# Build MariaDB .deb packages.
# Based on OurDelta .deb packaging scripts, which are in turn based on Debian
# MySQL packages.

# Exit immediately on any error
set -e

# Debug script and command lines
#set -x

# Don't run the mysql-test-run test suite as part of build.
# It takes a lot of time, and we will do a better test anyway in
# Buildbot, running the test suite from installed .debs on a clean VM.
export DEB_BUILD_OPTIONS="nocheck"

export MARIADB_OPTIONAL_DEBS=""

# Find major.minor version.
#
source ./VERSION
UPSTREAM="${MYSQL_VERSION_MAJOR}.${MYSQL_VERSION_MINOR}.${MYSQL_VERSION_PATCH}${MYSQL_VERSION_EXTRA}"
RELEASE_EXTRA=""

RELEASE_NAME=""
PATCHLEVEL="+maria"
LOGSTRING="MariaDB build"

# Look up distro-version specific stuff.

CODENAME="$(lsb_release -sc)"

# Adjust changelog, add new version.
#
echo "Incrementing changelog and starting build scripts"

DEB_VERSION="${UPSTREAM}-${DEB_REVISION:-0}${PATCHLEVEL}-${RELEASE_NAME}${RELEASE_EXTRA:+-${RELEASE_EXTRA}}1~${CODENAME}"

dch -b --force-distribution -D "${CODENAME}" -v "${DEB_VERSION}" "Automatic build with ${LOGSTRING}."

echo "Creating package version ${DEB_VERSION} ... "

# Build the package.
# Pass -I so that .git and other unnecessary temporary and source control files
# will be ignored by dpkg-source when createing the tar.gz source package
fakeroot dpkg-buildpackage -us -uc -I

[ -e debian/autorm-file ] && rm -vf `cat debian/autorm-file`

echo "Build complete"

# end of autobake script
