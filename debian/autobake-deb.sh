#!/bin/bash
#
# Build MariaDB .deb packages for test and release at mariadb.org
#

# Exit immediately on any error
set -e

# On Buildbot, don't run the mysql-test-run test suite as part of build.
# It takes a lot of time, and we will do a better test anyway in
# Buildbot, running the test suite from installed .debs on a clean VM.
# On Travis-CI we want to simulate the full build, including tests.
# Also on Travis-CI it is useful not to override the DEB_BUILD_OPTIONS
# at this stage at all.
if [[ ! $TRAVIS ]]
then
  export DEB_BUILD_OPTIONS="nocheck"
fi

# Look up distro-version specific stuff
#
# Always keep the actual packaging as up-to-date as possible following the latest
# Debian policy and targetting Debian Sid. Then case-by-case run in autobake-deb.sh
# tests for backwards compatibility and strip away parts on older builders.

# Adjust changelog, add new version
echo "Incrementing changelog and starting build scripts"

# Find major.minor version
source ./VERSION
UPSTREAM="${MYSQL_VERSION_MAJOR}.${MYSQL_VERSION_MINOR}.${MYSQL_VERSION_PATCH}${MYSQL_VERSION_EXTRA}"
PATCHLEVEL="+maria"
LOGSTRING="MariaDB build"
CODENAME="$(lsb_release -sc)"

dch -b -D ${CODENAME} -v "${UPSTREAM}${PATCHLEVEL}~${CODENAME}" "Automatic build with ${LOGSTRING}."

echo "Creating package version ${UPSTREAM}${PATCHLEVEL}~${CODENAME} ... "

# Build the package
# Pass -I so that .git and other unnecessary temporary and source control files
# will be ignored by dpkg-source when creating the tar.gz source package.
# Use -b to build binary only packages as there is no need to waste time on
# generating the source package.
fakeroot dpkg-buildpackage -us -uc -I -b

# Don't log package contents on Travis-CI to save time and log size
if [[ ! $TRAVIS ]]
then
  echo "List package contents ..."
  cd ..
  for package in `ls *.deb`
  do
    echo $package | cut -d '_' -f 1
    dpkg-deb -c $package | awk '{print $1 " " $2 " " $6}' | sort -k 3
    echo "------------------------------------------------"
  done
fi

echo "Build complete"
