#! /bin/sh

set -e

case "$1" in
-h | --help )
  echo "Gaise VERSION"
  echo
  echo "Usage:"
  echo
  echo "  noipv4 [--] COMMAND ARGS..."
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

if test "x$__variable__" = "x"; then
  __variable__=pkglibdir/__module__
else
  __variable__="pkglibdir/__module__:$__VARIABLE__"
fi
export __variable__
DYLD_FORCE_FLAT_NAMESPACE=yes
export DYLD_FORCE_FLAT_NAMESPACE
export GAISE_REMOVE_IPV4=yes
exec "$@"
