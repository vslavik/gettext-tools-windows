#!/bin/sh
#
# This script prepares the MinGW environment to have everything necessary
# for building GNU gettext using these makefiles.
#

PACKAGES="msys-wget
          msys-tar
          msys-gzip
          msys-zip
          msys-patch
          autotools
          msys-make
          gcc
          g++
          mingw32-libz-dev
         "

mingw-get install $PACKAGES
