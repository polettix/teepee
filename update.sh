#!/bin/bash
ME=$(readlink -f "$0")
MYDIR=$(dirname "$ME")
mobundle -PB "$MYDIR/../teepee"  \
   -o "$MYDIR/teepee"            \
   -m Template::Perlish          \
   -m YAML::Tiny                 \
   -m JSON::PP                   \
   -m JSON::PP::Boolean
chmod +x "$MYDIR/teepee"
