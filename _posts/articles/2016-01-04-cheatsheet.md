---
layout: post
title: Cheatsheet
categories: articles
excerpt: "A few (more) hints on how to use teepee"
permalink: /cheatsheet/
thin_site_title: true
---

A few (more) hints on how to use `teepee`.

1. TOC
{:toc}

## Assumptions

We will assume to have the following [`filename.json`]({{ site.baseurl
}}/assets/filename.json) JSON file lying around:

{% highlight json %}
{
    "name": "Flavio",
    "surname": "Poletti",
    "cpan": {
        "metacpan": "https://metacpan.org/author/POLETTIX",
        "latest": [
            "Data::Crumbr",
            "Template::Perlish",
            "Graphics::Potrace",
            "Log::Log4perl::Tiny"
        ],
        "favorites": {
            "JSON":   { "id": "MAKAMAKA" },
            "Dancer": { "id": "YANICK"   },
            "Moo":    { "id": "HAARG"    }
        },
        "using": {
            "JSON": { "id": "https://metacpan.org/release/JSON" }
        },
        "id": "POLETTIX"
    }
}
{% endhighlight %}

and the corresponding [`filename.yaml`]({{ site.baseurl
}}/assets/filename.yaml) too.

## Input

### Input from File or Standard Input

Reading from a file while auto-detecting the format:

{% highlight bash %}
$ teepee -i filename.json ...
$ teepee -i filename.yaml ...
{% endhighlight %}

Force reading as JSON:

{% highlight bash %}
$ teepee -j filename.json ...
$ teepee -j filename.json -f json ...
{% endhighlight %}

Force reading as YAML:

{% highlight bash %}
$ teepee -y filename.yaml ...
$ teepee -y filename.yaml -f yaml ...
{% endhighlight %}

Input comes from standard input by default, no need to specify anything
in this case (although you can be explicit and use filename `-`):

{% highlight bash %}
# auto-detect
$ cat filename.json | teepee ...
$ cat filename.json | teepee -i - ...

# force reading as JSON
$ cat filename.json | teepee -f json ...
$ cat filename.json | teepee -j - ...

# force reading as YAML
$ cat filename.yaml | teepee -f yaml ...
$ cat filename.yaml | teepee -y - ...
{% endhighlight %}

### Input from Text on Command Line

You can specify input text with a shell trick (using `<<<`) and what
explained before, or using the following options directly:

{% highlight bash %}
$ teepee -I '{"some":"json"}' ...

$ some_json=$(< filename.json)
$ teepee -J "$some_json" ...

$ some_yaml=$(< filename.yaml)
$ teepee -Y "$some_yaml" ...
{% endhighlight %}

### No Input

Sometimes you don't need to read an input data structure (e.g. when you
define variable's values using `-d`/`--define`):

{% highlight bash %}
$ teepee -N ...
{% endhighlight %}

## Output

Output is sent to standard output by default. You can either
redirect/pipe it, or use option `-o` to save to a file:

{% highlight bash %}
$ teepee -o output-file ...
{% endhighlight %}

Many options/tricks specify how the output is generated, so read on! One
option is described here, though: if you want to add a newline at the
very end of the input, pass option `-n`:

{% highlight bash %}
$ teepee -n ...
{% endhighlight %}

## Templates Handling

Templates are generally written using rules of
[Template::Perlish](https://metacpan.org/pod/Template::Perlish):

- plain text is rendered as-is
- whatever is enclosed between a pair of `[%` and `%]` is considered
  *special*
    - if the pair contains a *path in the data*, the chunk is expanded
      with the value of the variable at the specific position in the
      input data
    - if the opening is immediately followed by an equal sign `=` (with
      no spaces), the chunk is interpreted as Perl code and the last
      value is substituted for the chunk
    - otherwise, the chunk is considered Perl code but nothing is
      printed by default
    - whatever is printed to standard output in the Perl code inside the
      chunks is expanded in place of the chunk.

A *path in the data* is something like `path.to.1.variable`. This
is split upon the the dots, and each section is used to traverse the
input data structure. So, if we had a reference `$V` to the data
structure, the example path would be resolved to
`$V->{path}{to}[1]{variable}` (assuming of course that there are hashes
and arrays at the right places).

### Text Templates

Templates can be taken from a file, for example `file1.tmpl`:

{% highlight text %}
    Hello [% cpan.id %] ([% name %] [% surname %])
{% endhighlight %}

Use option `-t` to load them:

{% highlight bash %}
$ teepee -j filename.json -t file1.tmpl
Hello POLETTIX (Flavio Poletti)
{% endhighlight %}

... or from a string on the command line:

{% highlight bash %}
$ teepee -nj filename.json -T 'Hello [% cpan.id %]!'
Hello POLETTIX!
{% endhighlight %}

We used option `-n` to add a newline to the output!

### Variables

Getting a single variable only has its own shortcut, i.e. the following
are equivalent:

{% highlight bash %}
$ teepee -nj filename.json -T '[% cpan.latest.1 %]'
Template::Perlish

$ teepee -nj filename.json -v cpan.latest.1
Template::Perlish
{% endhighlight %}

### Functions

Getting the output of a function only has its own shortcut, i.e. the
following are equivalent:

{% highlight bash %}
$ teepee -nj filename.json -T '[%= 2+2 %]'
4

$ teepee -nj filename.json -F 2+2
4
{% endhighlight %}

This comes handy for calling a few pre-defined functions as explained
below.

### Pretty-Printing

Pretty-printing (or converting!) in JSON:

{% highlight bash %}
$ teepee -y filename.yaml -FJSON
{
    "name" : "Flavio",
    "surname" : "Poletti",
    "cpan" : {
        "favorites" : {
            "Dancer" : {
                "id" : "YANICK"
            },
            "Moo" : {
                "id" : "HAARG"
            },
            "JSON" : {
                "id" : "MAKAMAKA"
            }
        },
        "metacpan" : "https://metacpan.org/author/POLETTIX",
        "latest" : [
            "Data::Crumbr",
            "Template::Perlish",
            "Graphics::Potrace",
            "Log::Log4perl::Tiny"
        ],
        "using" : {
            "JSON" : {
                "id" : "https://metacpan.org/release/JSON"
            }
        },
        "id" : "POLETTIX"
    }
}
{% endhighlight %}

Pretty-printing (or converting!) in YAML:

{% highlight bash %}
$ teepee -j filename.json -FYAML
---
cpan:
    favorites:
        Dancer:
        id: YANICK
        JSON:
        id: MAKAMAKA
        Moo:
        id: HAARG
    id: POLETTIX
    latest:
        - Data::Crumbr
        - Template::Perlish
        - Graphics::Potrace
        - Log::Log4perl::Tiny
    metacpan: https://metacpan.org/author/POLETTIX
    using:
        JSON:
        id: https://metacpan.org/release/JSON
name: Flavio
surname: Poletti
{% endhighlight %}

### Crumbr Mode

Crumbr mode allows you to expand the whole input data structure with one
line per leaf, so that you should be able to easily use `grep` and
`sed`.

{% highlight bash %}
$ teepee -j filename.json -Fcrumbr
cpan/favorites/Dancer/id "YANICK"
cpan/favorites/JSON/id "MAKAMAKA"
cpan/favorites/Moo/id "HAARG"
cpan/id "POLETTIX"
cpan/latest/0 "Data::Crumbr"
cpan/latest/1 "Template::Perlish"
cpan/latest/2 "Graphics::Potrace"
cpan/latest/3 "Log::Log4perl::Tiny"
cpan/metacpan "https:\/\/metacpan.org\/author\/POLETTIX"
cpan/using/JSON/id "https:\/\/metacpan.org\/release\/JSON"
name "Flavio"
surname "Poletti"
{% endhighlight %}

You can be *exact* in distinguishing between hash keys and array
indexes:

{% highlight bash %}
$ teepee -j filename.json -Fexact_crumbr
{"cpan"}{"favorites"}{"Dancer"}{"id"}:"YANICK"
{"cpan"}{"favorites"}{"JSON"}{"id"}:"MAKAMAKA"
{"cpan"}{"favorites"}{"Moo"}{"id"}:"HAARG"
{"cpan"}{"id"}:"POLETTIX"
{"cpan"}{"latest"}[0]:"Data::Crumbr"
{"cpan"}{"latest"}[1]:"Template::Perlish"
{"cpan"}{"latest"}[2]:"Graphics::Potrace"
{"cpan"}{"latest"}[3]:"Log::Log4perl::Tiny"
{"cpan"}{"metacpan"}:"https:\/\/metacpan.org\/author\/POLETTIX"
{"cpan"}{"using"}{"JSON"}{"id"}:"https:\/\/metacpan.org\/release\/JSON"
{"name"}:"Flavio"
{"surname"}:"Poletti"
{% endhighlight %}

You might want to get a JSON-compliant representation of each line:

{% highlight bash %}
$ teepee -j filename.json -Fjson_crumbr
{"cpan":{"favorites":{"Dancer":{"id":"YANICK"}}}}
{"cpan":{"favorites":{"JSON":{"id":"MAKAMAKA"}}}}
{"cpan":{"favorites":{"Moo":{"id":"HAARG"}}}}
{"cpan":{"id":"POLETTIX"}}
{"cpan":{"latest":["Data::Crumbr"]}}
{"cpan":{"latest":["Template::Perlish"]}}
{"cpan":{"latest":["Graphics::Potrace"]}}
{"cpan":{"latest":["Log::Log4perl::Tiny"]}}
{"cpan":{"metacpan":"https:\/\/metacpan.org\/author\/POLETTIX"}}
{"cpan":{"using":{"JSON":{"id":"https:\/\/metacpan.org\/release\/JSON"}}}}
{"name":"Flavio"}
{"surname":"Poletti"}
{% endhighlight %}

### Variables Accessors

Variables accessors are shortcut functions that allow expanding a
variable according to the (expected) type.

Scalar variables can be accessed via `V` (for Variable, not for
Scalar!):

{% highlight bash %}
# another alternative for -v...
$ teepee -nj filename.json -F 'V "cpan.favorites.Moo.id"'
HAARG

$ teepee -nj filename.json -F '"*" x length V "cpan.favorites.Moo.id"'
*****
{% endhighlight %}

Array references are de-referenced using `A`:

{% highlight bash %}
$ teepee -nj filename.json -F 'A "cpan.latest"'
4

$ teepee -j filename.json -F 'print "- $_\n" for A "cpan.latest"'
- Data::Crumbr
- Template::Perlish
- Graphics::Potrace
- Log::Log4perl::Tiny
{% endhighlight %}

Hashes can be dereferenced in three ways: directly with `H`, only keys
with `HK`, only values with `HV`:

{% highlight bash %}
$ teepee -nj filename.json -F 'my %favs = H "cpan.favorites"; $favs{JSON}{id}'
MAKAMAKA

$ teepee -j filename.json -F 'print "- $_\n" for HK "cpan.favorites"'
- Moo
- Dancer
- JSON

$ teepee -j filename.json -F 'print "- $_->{id}\n" for HV "cpan.favorites"'
- MAKAMAKA
- HAARG
- YANICK
{% endhighlight %}

### Loading Functions

If you want to load Perl functions from modules, as of version `0.7.0`
you can with options `-M` and `-l`.

The former (`-M`, alias `--module`) allows you to load modules and
functions from the command line, and consume those functions from inside
the template:

{% highlight bash %}
$ teepee -nj filename.json -M Digest::MD5=md5_hex -F 'md5_hex(V "name")'
e6a25ad746bb0923f593e94f5128d13d
{% endhighlight %}

You can import multiple functions separating their names with a comma:

{% highlight bash %}
$ teepee -nj filename.json -M Digest::MD5=md5_hex,md5_base64 \
    -F 'md5_hex(V "name") . " " . md5_base64(V "name")'
e6a25ad746bb0923f593e94f5128d13d 5qJa10a7CSP1k+lPUSjRPQ
{% endhighlight %}

Alternatively, you can just specify a line that will be `use`d:

{% highlight bash %}
$ teepee -nj filename.json -M 'Digest::MD5 qw< md5_hex md5_base64 >' \
    -F 'md5_hex(V "name") . " " . md5_base64(V "name")'
e6a25ad746bb0923f593e94f5128d13d 5qJa10a7CSP1k+lPUSjRPQ
{% endhighlight %}

In particular, whatever you pass as parameter will be `eval`ed like
follows:

{% highlight perl %}
# -M 'Digest::MD5 qw< md5_hex md5_base64 >'
use Digest::MD5 qw< md5_hex md5_base64 >;
{% endhighlight %}

If you want to load modules/functions that don't lie around in places
`perl` would normally look into, you can add places to the directory
search list using option `-l` (alias `--lib`, alias `--include`).
Suppose you have module `Foo::Bar` inside `lib/Foo/Bar.pm`:

{% highlight bash %}
$ teepee -nj filename.json -M 'Foo::Bar' -l lib -F 'foo(V "name")'
...
{% endhighlight %}

