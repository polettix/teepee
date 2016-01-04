---
layout: page
title: Code
permalink: /code/
---

Using `teepee` will be difficult without getting the code... here's
a few hints on what you can do.

## Installation

If you just want to use `teepee`, the suggested way is to download the
*bundled* version, set the execution bit and put it somewhere in the
`PATH`, like this:

{% highlight bash %}
curl -LO https://github.com/polettix/teepee/raw/master/bundle/teepee
#   wget https://github.com/polettix/teepee/raw/master/bundle/teepee
chmod +x teepee
sudo mv teepee /usr/local/bin
{% endhighlight %}

Your mileage may vary with the last command, ranging from whether you
actually want to install in `/usr/local/bin` to whether you're allowed
to do that. You can choose any directory in the `PATH` of course, or use
any other trick.

As an alternative, you can just *get the code* and take care to install
support modules by yourself, like this:

{% highlight bash %}
# Install a few pre-requisite modules
cpanm Cpanel::JSON::XS YAML::XS Data::Crumbr Template::Perlish

curl -LO https://github.com/polettix/teepee/raw/master/teepee
#   wget https://github.com/polettix/teepee/raw/master/teepee
chmod +x teepee
sudo mv teepee /usr/local/bin
{% endhighlight %}

`teepee` is capable of using different modules for JSON and YAML, if
you're installing them yourself I'd just suggest to use the best around.

## Hacking

The [main repository](https://github.com/polettix/teepee) is hosted on
[GitHub](https://github.com/) and is there to be forked! It is licensed
under [The Artistic License
2.0](http://www.perlfoundation.org/artistic_license_2_0) so it should be
pretty easy for you to do whatever you want with it.

The main script is `teepee` and it is located in the root directory of
the project. There is also a *bundled* version available at
`bundle/teepee`, including all dependencies inside the file itself and
ready for installing around.

### Dependencies

You will need to install dependencies, which are the following modules:

- something to deal with JSON. Any of the following will do, although
  I'd suggest to go for the first one if possible:
    - [Cpanel::JSON::XS](https://metacpan.org/pod/Cpanel::JSON::XS)
    - [JSON::XS](https://metacpan.org/pod/JSON::XS)
    - [JSON::PP](https://metacpan.org/pod/JSON::PP) - this does not
      require a compiler, and it should be already available with
      a fairly recent standard Perl installation
- something to deal with YAML. Any of the following will do, although
  I'd suggest to go for the first one if possible:
    - [YAML::XS](https://metacpan.org/pod/YAML::XS)
    - [YAML::Syck](https://metacpan.org/pod/YAML::Syck)
    - [YAML::Tiny](https://metacpan.org/pod/YAML::Tiny) - this does not
      require a compiler
- [Data::Crumbr](https://metacpan.org/pod/Data::Crumbr)
- [Template::Perlish](https://metacpan.org/pod/Template::Perlish)

If you're planning on re-generating the bundled version, you should
install [YAML::Tiny](https://metacpan.org/pod/YAML::Tiny) and
[JSON::PP](https://metacpan.org/pod/JSON::PP), as they are the ones used
in the bundling process.

The dependencies might be installed with the Perl you are using, or
locally using any mechanism (e.g.
a [local::lib](https://metacpan.org/pod/local::lib) of some sort).
I usually install dependencies for bundling using
[epan](https://github.com/polettix/epan) with the following command:

{% highlight bash %}
mkdir _local
cd _local
epan add Data::Crumbr Template::Perlish YAML::Tiny JSON::PP
cd ..
{% endhighlight %}

### Bundle Generation

The script `update.sh` will update the bundled version stored at
`bundle/teepee`. It requires the dependencies to be available, see
previous section for them.

The bundling script used `mobundle` from
[deployable](http://repo.or.cz/deployable.git). You can get it directly
like this:

{% highlight bash %}
# mobundle has its own dependencies too...
cpanm File::Slurp Template::Perlish Path::Class

curl -LO http://repo.or.cz/w/deployable.git/blob_plain/HEAD:/mobundle
#   wget http://repo.or.cz/w/deployable.git/blob_plain/HEAD:/mobundle
chmod +x mobundle
sudo mv mobundle /usr/local/bin
{% endhighlight %}

Think of `mobundle` as
a [fatpacker](https://metacpan.org/pod/App::FatPacker) that exists since
2007...

If you installed your dependency modules for `teepee` in a place where
Perl does not normally look for, you have a few options. One, of course,
is to fiddle with environment variable `PERL5LIB`. If you feel more like
something less invasive for your environment, you can set up some
localization via file `_local/update-local.sh`. For example, after I set
up the local modules with [epan](https://github.com/polettix/epan) as
described in the previous section, I use the following localization
script:

{% highlight bash %}
__update_local__() {
    declare ME=$(readlink -f "${BASH_SOURCE[0]}")
    declare MD=$(dirname "$ME")
    printf -v BASEDIR '%q' "$MD"
    MOBUNDLE_LOCAL_PARAMETERS="-I $BASEDIR/epan/local/lib/perl5"
}
__update_local__
unset -f __update_local__
{% endhighlight %}

It takes care to properly set environment variable
`MOBUNDLE_LOCAL_PARAMETERS`, that is eventually used by `update.sh` when
calling `mobundle`. You can find a commented version of the above script
inside `eg/update-local.sh`, so if you're following the hints on using
`epan` you can just copy this file in `_local`.


