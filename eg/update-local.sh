#!/bin/bash

# This is an example update-local.sh to set MOBUNDLE_LOCAL_PARAMETERS
# to a local directory instead of relying on widely installed modules.
# You can e.g. use this to point to a local::lib of modules (e.g.
# created using epan).

# To use it, copy into the main directory and modify to suit your needs.

# We wrap all operations inside a function, in order to limit our
# footprint. Using `declare` inside the function ensures that the
# variables are localized to the function and don't clobber any existing
# one.
__update_local__() {

    # Using `declare` inside the function ensures that the variables are
    # localized to the function and don't clobber any existing one.
    declare ME=$(readlink -f "${BASH_SOURCE[0]}")
    declare MD=$(dirname "$ME")

    # This escapes special characters in MD
    printf -v BASEDIR '%q' "$MD"

    # This variable IS NOT `declare`d but is the external one!
    MOBUNDLE_LOCAL_PARAMETERS="-I $BASEDIR/epan/local/lib/perl5"
}

# After defining the function, we call it and then immediately remove it
# from the scope, to limit the footprint
__update_local__
unset -f __update_local__
