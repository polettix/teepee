#!/bin/bash
ME=$(readlink -f "$0")
MYDIR=$(dirname "$ME")

mobundle -PB "$MYDIR/teepee"  \
   -o "$MYDIR/bundle/teepee"  \
   -m Template::Perlish       \
   -m YAML::Tiny              \
   -m JSON::PP                \
   -m JSON::PP::Boolean
chmod +x "$MYDIR/bundle/teepee"

pod2markdown "$MYDIR/teepee" > "$MYDIR/README.md"
