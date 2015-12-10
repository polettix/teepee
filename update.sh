#!/bin/bash
ME=$(readlink -f "$0")
MYDIR=$(dirname "$ME")

[ -r "$MYDIR/update-local.sh" ] && source "$MYDIR/update-local.sh"

mobundle -PB "$MYDIR/teepee"          \
   -o "$MYDIR/bundle/teepee"          \
   -n Template::Perlish               \
   -n YAML::Tiny                      \
   -n JSON::PP                        \
   -n JSON::PP::Boolean               \
   -n Mo -n Mo::default -n Mo::coerce \
   -n Data::Crumbr.pm                 \
   -n Data::Crumbr/Default.pm         \
   -n Data::Crumbr/Util.pm            \
   -n Data::Crumbr/Default/JSON.pm    \
   -n Data::Crumbr/Default/Default.pm \
   -n Data::Crumbr/Default/URI.pm
chmod +x "$MYDIR/bundle/teepee"

pod2markdown "$MYDIR/teepee" > "$MYDIR/README.md"
