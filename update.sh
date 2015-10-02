#!/bin/bash
ME=$(readlink -f "$0")
MYDIR=$(dirname "$ME")

[ -r "$MYDIR/update-local.sh" ] && source "$MYDIR/update-local.sh"

mobundle -PB "$MYDIR/teepee"          \
   -o "$MYDIR/bundle/teepee"          \
   -m Template::Perlish               \
   -m YAML::Tiny                      \
   -m JSON::PP                        \
   -m JSON::PP::Boolean               \
   -m Mo -m Mo::default -m Mo::coerce \
   -m Data::Crumbr.pm                 \
   -m Data::Crumbr/Default.pm         \
   -m Data::Crumbr/Util.pm            \
   -m Data::Crumbr/Default/JSON.pm    \
   -m Data::Crumbr/Default/Default.pm \
   -m Data::Crumbr/Default/URI.pm
chmod +x "$MYDIR/bundle/teepee"

pod2markdown "$MYDIR/teepee" > "$MYDIR/README.md"
