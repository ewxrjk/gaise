#! /bin/sh
#
# This file is part of Gaise
# Copyright © 2011 Richard Kettlewell
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
# USA
#
set -e

case "$1" in
-h | --help )
  echo "Gaise VERSION"
  echo
  echo "Usage:"
  echo
  echo "  noipv6 [--] COMMAND ARGS..."
  echo
  exit 0
  ;;
-V | --version )
  echo "Gaise VERSION"
  exit 0
  ;;
-- )
  shift
  ;;
-* )
  echo "unknown option '$1'" 1>&2
  exit 1
  ;;
esac

GAISE_PATH=${GAISE_PATH:-__pkglibdir__}

if test "x$__variable__" = "x"; then
  __variable__=pkglibdir/__module__
else
  __variable__="pkglibdir/__module__:$__VARIABLE__"
fi
export __variable__
DYLD_FORCE_FLAT_NAMESPACE=yes
export DYLD_FORCE_FLAT_NAMESPACE
export GAISE_REMOVE_IPV6=yes
exec "$@"
