#!/bin/bash
ME=$(readlink -f "$0")
MYDIR=$(dirname "$ME")
LDIR="$MYDIR/_local"

# when present, it can do location-specific stuff, e.g. setting variable
# MOBUNDLE_LOCAL_PARAMETERS to customize invocation to mobundle
[ -r "$LDIR/update-local.sh" ] && source "$LDIR/update-local.sh"

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
   -n Data::Crumbr/Default/URI.pm     \
   $MOBUNDLE_LOCAL_PARAMETERS
chmod +x "$MYDIR/bundle/teepee"

pod2markdown "$MYDIR/teepee" > "$MYDIR/README.md"
