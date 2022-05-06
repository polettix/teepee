# NAME

teepee - extract data from structures

# HURRY UP!

Get the bundled version like this:

    curl -LO https://github.com/polettix/teepee/raw/master/bundle/teepee

or this

    wget https://github.com/polettix/teepee/raw/master/bundle/teepee

or just click here:
[https://github.com/polettix/teepee/raw/master/bundle/teepee](https://github.com/polettix/teepee/raw/master/bundle/teepee).

For way more than you want to know about `teepee` visit also
[http://github.polettix.it/teepee/](http://github.polettix.it/teepee/).

# USAGE

    teepee [--usage] [--help] [--man] [--version]

    teepee [-A|--auto-key]
           [-P|--auto-key-prefix string]
           [-S|--auto-key-suffix string]
           [-b|--binmode setting]
           [-K|--default-key string]
           [-d|--define key=value]
           [-f|--format input-format]
           [-F|--function spec]
           [-I|--immediate text]
           [-i|--input filename]
           [-j|--jsn|--json filename]
           [-J|--json-s text]
           [-l|--lib|--include dirname]
           [-M|--module module-spec]
           [-n|--newline|--no-newline]
           [-N|--no-input]
           [-o|--output filename]
           [-t|--template filename]
           [-T|--text string]
           [-v|--variable string]
           [-y|--yml|--yaml filename]
           [   --yaml-1 filename]
           [-Y|--yaml-s text]
           [   --yaml-s1 text]

# EXAMPLES

    # suppose to start from this data structure in JSON inside data.json,
    # YAML works much in the same way.
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

    # get a few variables:
    # -n prints a newline at theend
    # -i indicates the input file to use
    # -v indicates the "path" into the data structure, can include
    #    indexes in arrays
    $ teepee -ni data.json -v name
    Flavio
    $ teepee -ni data.json -v cpan.favoritex.JSON.id
    MAKAMAKA
    $ teepee -ni data.json -v cpan.using.JSON.id
    https://metacpan.org/release/JSON
    $ teepee -ni data.json -v cpan.latest.1
    Template::Perlish

    # pretty-print in JSON or YAML, output to /dev/null (useful, uh?)
    $ teepee -i data.json -FJSON -o /dev/null
    $ teepee -i data.json -FYAML -o /dev/null

    # input might be available directly on the command line, just use
    # the uppercase variant
    $ data=$(< data.json)
    $ teepee -nI "$data" -v cpan.id
    POLETTIX

    # you can format your output using templates, e.g. from command line
    $ teepee -nI "$data" -T 'Hello, [% name %] [% surname %]!'
    Hello, Flavio Poletti!

    # templates can be read from files. Lowercase option means file
    $ teepee -nI "$data" -t template.txt -o /dev/null

    # To see how you can write templates, please look at the
    # documentation for Template::Perlish at
    # https://metacpan.org/pod/Template::Perlish

    # you can set some values in the data structure from the command
    # line, just use option -d
    $ teepee -nI "$data" -d name=FLAVIO
       \ -T 'Hello, [% name %] [% surname %]!'
    Hello, FLAVIO Poletti!

    # no need for the key/index to already exist when using -d
    $ teepee -nI "$data" -d github.id=polettix \
       -T '[% cpan.id %]@CPAN is [% github.id %]@GitHub'
    POLETTIX@CPAN is polettix@GitHub

    # there is actually no need to read any data structure at all
    # but this has to be indicated using -N
    $ teepee -nN -d github.id=polettix -d cpan.id=POLETTIX \
       -T '[% cpan.id %]@CPAN is [% github.id %]@GitHub'
    POLETTIX@CPAN is polettix@GitHub

# DESCRIPTION

`teepee` allows you to generate data according to a template. Data is
extracted from data structures available in JSON or YAML format, read
from files or from standard input. This should make it easy to extract
the needed data e.g. out of the output from some tool that provides you
structured JSON or YAML text in output.

## Options Overview

Input data structures can be provided via option [-i ](https://metacpan.org/pod/&#x20;--input). You
can provide more than one input; in this case, they will be read in
order and merged together. Merging in this case means that whatever is
present in a file provided later in the command line supersedes
whatevever was previously available. If you set the input filename as
`-`, the input will be read from standard input.

You can provide input definitions from the command line too, via option
["--define"](#define). In this case, you can provide the "path" into the
data structure separating items with a dot `.`. Any key part that
resembles an integer index starting from 0 will be interpreted as an
array index, otherwise it will be considered a hash key. Definitions
with this options always supersede those read from input files.

The input format can be either specified explicitly via option
["--format"](#format) or deduced implicitly. The heuristic will first check the
file name, then the contents. Suggestion is to specify it if you happen
to know, expecially for programmatic usage.

The template to be expanded can be provided either from a file (via
option ["--template"](#template)) or from the command-line directly (via option
["--text"](#text)). Templates can be written according to what
[Template::Perlish](https://metacpan.org/pod/Template::Perlish) provides. As quick, specialized alternatives to
["--text"](#text), you can also use ["--function"](#function) and ["--variable"](#variable).

All files are supposed to be UTF-8 encoded. When the template is
provided from the command line, module [I18N::Langinfo](https://metacpan.org/pod/I18N::Langinfo) is used to
auto-detect the terminal setting and try to do the right things. If in
doubt, just use a UTF-8 encoded file for your template.

Output is sent to either standard output (by default or if you set the
filename to `-`) or to the filename specified via option `/--output`.
Output will be printed assuming that the receiving end is UTF-8 capable.

As of version `0.7.0`, it is possible to also pre-load modules in the
_right_ package where the templates are expanded, with a simple syntax
that leverages on options ["-M"](#m)/["--module"](#module) (for importing modules) and
["-l"](#l)/["--lib"](#lib)/["--include"](#include) (for adding directories to the module search
path).

## Reading Inputs

It's worth noting that input data might come into three forms,
independently of the input format: _hash_ (i.e. _object_ in JSON),
_array_ or _scalar_. Whatever the input, a big _hash_/_object_ is
built and eventually consumed by the templates; every time the top-level
element in the input is not a _hash_, the following applies:

- a (hopefully) unique key is generated joining ["--auto-key-prefix"](#auto-key-prefix), an
increasing integer number starting from `0`, and [--auto-key-suffix](https://metacpan.org/pod/--auto-key-suffix).
The value is associated to this key in the top level hash.
- the last value read in this way is always associated to key
["--default-key"](#default-key).

By default, the three options are set to the string `_` (one single
underscore).

For example, if you have two input files with two arrays inside:

    # first input, JSON format
    [ "one", "two", "three" ]

    # second input, JSON format
    [ 1, 2, 3 ]

the resulting overall hash read will be the following when the two
inputs are read in the order above:

    {
       _0_ => [ 'one', 'two', 'three' ],
       _1_ => [ 1, 2, 3 ],
       _   => [ 1, 2, 3 ],
    }

You can change the different options to be able to mix the input arrays
with hashes and preserve key uniqueness.

If you specify input option [--auto-key](https://metacpan.org/pod/--auto-key), the above algorithm will
always be applied, also for hash inputs. This allows you get input from
multiple sources without the risk of having keys trump on each other
(which might be or not what you want).

## Writing Templates

Templates for extracting data are written according to what
Template::Perlish provides. You should take a look at its documentation
at [https://metacpan.org/pod/Template::Perlish](https://metacpan.org/pod/Template::Perlish). Only a few tricks will
be reported here, just to get your feet wet.

We will suppose to have the following data, represented as YAML:

    ---
    key1: value1
    key2: value2
    array:
       - first
       - second
       - third
       -
          k1: v1
          k2: v2
    hash:
       one: two
       three: four
       five:
          - a
          - b
          - 'see...'
       'complex key': whatever

Values that are neither hashes/objects nor arrays will be called
_scalars_.

So, we have a hash at the top level, with four keys (`key1`, `key2`,
`array` and `hash`), two of which are scalars, one is an array and one
is a hash. The array contains four items, the last of which is a hash
with two keys (`k1` and `k2`). The hash contains three keys, the first
two (`one` and `three`) associated to a scalar value, the last one
being an array with three strings inside.

If you want to just access scalar variable pointed by key `three`
inside `hash`, it is sufficient to provide the _path_ to that value as
a sequence of keys starting from the top level and separated by a dot,
like this:

    [% hash.three %]

If you want to access an array's element, the trick is similar but you
will have to use the index (starting from 0) instead of the key. So, for
example, the `b` in the second array would be accessed like this:

    [% hash.five.1 %]

and the `v1` like this:

    [% array.3.k1 %]

Please note that, by default, the keys that you can concatenate can only
contain alphanumeric values, plus the underscore. What if you want to
access `whatever` then? You can insert non-alphanumeric characters
using quotes, like this:

    [% hash.'complex key' %]

As you can imagine, there are ways to also cope with keys that have
quotes inside, so refer to Template::Perlish if you need to know more.

Besides just accessing scalar values, you might want to add some logic
to your templates. You can do this by simply writing Perl code, because
whatever is not recognised as a valid _path of keys_ is considered Perl
code and evaluated accordingly:

    current time: [% print scalar localtime() %]

There is even a shortcut to just print the output of an expression, so
the above example can be written like this:

    current time: [%= scalar localtime() %]

(note that there is an equal sign just after the template opening).

When you are writing Perl code, you can access the data structure
through the hash variable `%variables`, so the following are
equivalent:

    [% hash.'complex key' %]
    [%= $variables{hash}{'complex key'} %]

but of course you can do fancier things with the second one, like this:

    uppercase: [%= uc $variables{hash}{'complex key'} %]

Accessing variables like this can be boring if you have a deeply nested
data structure, because it's a lot of typing and a lot of curly
brackets. To save typing and time, you can use the shortcut function
`V`, so the following are equivalent:

    [%  hash.'complex key' %]
    [%= $variables{hash}{'complex key'} %]
    [%= V("hash.'complex key'") %]

As you are probably guessing, `V` uses the same algorithm as just
putting a plain sequence of path elements, including its restrictions on
non-alphanumeric characters. This is considered a feature, because it
adds consistency.

Just like you can access any variable with `V`, you also have a few
additional functions at your disposal for some common tasks. For
example, sometimes you will want to iterate over an array and find just
those elements that have some characteristics, e.g. restricting only to
elements that are hashes containing the `k1` key. The long version is
this, of course:

    [%
       for my $item (@{$variables{array}}) {
          next unless ref($item) eq 'HASH';
          next unless exists $item->{k1};
          print $item->{k1};
          last;
       }
    %]

You can use the `V` shortcut, of course:

    [%
       for my $item (@{V('array')}) {
          next unless ref($item) eq 'HASH';
          next unless exists $item->{k1};
          print $item->{k1};
          last;
       }
    %]

although in this case you would probably use `A` instead:

    [%
       for my $item (A 'array') {
          next unless ref($item) eq 'HASH';
          next unless exists $item->{k1};
          print $item->{k1};
          last;
       }
    %]

This takes the element at path `array` from `%variables`, expands it
as an array and... well, what you do with it is completely up to you, of
course.

## Pretty Printing

Sometimes, especially in an interactive session, you might just want to
take a look at the data structure you have to traverse; this is where
_pretty-printing_ comes handy.

YAML is already quite readable by its own, so chances are that you might
want to have some pretty-printing when your data is represented in
campact JSON format.

There are two functions for pretty-printing: ["YAML"](#yaml) and ["JSON"](#json). As
you might have guessed, they print out the input data structure
respectively as YAML and JSON (so they can also be used to transform one
into the other, of course). It suffices to use the `/-F` option to get
their services:

    # pretty-print JSON as JSON
    $ teepee -FJSON <input.json

    # just dump as YAML
    $ teepee -FYAML <input.whatever

Note that if your input is not an hash, or you are using ["--auto-key"](#auto-key),
your data structure will contain multiple references to the same
objects, which by default is considered a _circular data reference_.
`teepee` solves this problem by eliminating the ["--default-key"](#default-key) from
the input hash before doing the pretty-printing.

This will anyway give you something that is different from the real
input data, because of the embedding into the top-level hash.  If you
just want the original data, you can do as follows (this will work only
for the last read input data of course):

    # pretty-print JSON as JSON
    $ teepee -F'JSON(V("_"))' <input.json

    # just dump as YAML
    $ teepee -F'YAML(V("_"))' <input.whatever

This isolates the last read input with an auto-generated key (with
`V("_")`) and pretty-prints that (passing to the relevant function,
i.e. either `JSON` or `YAML`).

## Feeling Better With `grep`?

If you're not very comfortable with Perl... you should. There are a lot
of very good resources out there to learn it, the most outstanding
and readily available example is probably Modern Perl
([http://onyxneon.com/books/modern\_perl/index.html](http://onyxneon.com/books/modern_perl/index.html), look for both the
printed and online version).

Anyway, if you're in a hurry and you prefer to use `grep`/`sed` and
all other classical Unix tools, you can turn on _crumbr_ mode and play
with its output.

To understand what crumbr does, let's start from an example, i.e. let's
see what this does when applied to the example data structure described
in ["Writing Templates"](#writing-templates). The template is quite straightforward in this
case:

    $ teepee -T '[%= crumbr(); %]' -i data.yml

and the output is the following:

    array/0 "first"
    array/1 "second"
    array/2 "third"
    array/3/k1 "v1"
    array/3/k2 "v2"
    hash/complex%20key "whatever"
    hash/five/0 "a"
    hash/five/1 "b"
    hash/five/2 "see..."
    hash/one "two"
    hash/three "four"
    key1 "value1"
    key2 "value2"

Every leaf node is represented on a single line of its own. Each line
contains a URI-shaped path, a space, and a JSON-encoded representation
of the value. Hash keys are sorted lexicographically, array keys are
sorted numerically.

So, are we still looking at the values pointed by key `k1` inside any
hash under the top-level array? This is how you do it:

    $ teepee -T '[%= crumbr(); %]' -i data.yml \
      | grep '^array/[0-9][0-9]*/k1 '

You get the idea. Typing (or even remembering) that template might be
cumbersome, which is why there is a shorthand option ["-F"](#f) that lets
you just write this instead:

    $ teepee -Fcrumbr -i data.yml | grep '^array/[0-9][0-9]*/k1'

See ["--function"](#function)/["-F"](#f) for the available functions in addition to
`crumbr`. We will use this short form from now on.

Why the JSON encoding in the output? Aren't those double quotes
annoying? The answer is probably yes, but they are also needed. In fact,
there are a few cases where you will _not_ see them, namely:

- **empty arrays**

    are represented as `[]`, without quotes

- **empty hashes**

    are represented as `{}`, without quotes

- **null/undefined values**

    are represented as _null_, without quotes (as opposed to
    the string _"null"_, that has the quotes).

Example:

    $ cat sample.yaml
    ---
    'plain-value': ciao
    'null-value': ~
    'empty-array': []
    'empty-hash': {}

    $ teepee -Fcrumbr <sample.yaml
    empty-array []
    empty-hash {}
    null-value null
    plain-value "ciao"

You have probably noticed that this does not allow you to clearly
distinguish between hash/object keys and array indexes. Hopefully this
does not concern you because you have a sane input data structure, but
in case you want to remove any space for misunderstanding, you can use
`exact_crumbr` instead:

    $ teepee -Fexact_crumbr -i data.yml
    {"array"}[0]:"first"
    {"array"}[1]:"second"
    {"array"}[2]:"third"
    {"array"}[3]{"k1"}:"v1"
    {"array"}[3]{"k2"}:"v2"
    {"hash"}{"complex key"}:"whatever"
    {"hash"}{"five"}[0]:"a"
    {"hash"}{"five"}[1]:"b"
    {"hash"}{"five"}[2]:"see..."
    {"hash"}{"one"}:"two"
    {"hash"}{"three"}:"four"
    {"key1"}:"value1"
    {"key2"}:"value2"

If you like, or need, to play with _JSON subsets_ instead, you might
find `json_crumbr` interesting:

    $ teepee -Fjson_crumbr -i data.yml
    {"array":["first"]}
    {"array":["second"]}
    {"array":["third"]}
    {"array":[{"k1":"v1"}]}
    {"array":[{"k2":"v2"}]}
    {"hash":{"complex key":"whatever"}}
    {"hash":{"five":["a"]}}
    {"hash":{"five":["b"]}}
    {"hash":{"five":["see..."]}}
    {"hash":{"one":"two"}}
    {"hash":{"three":"four"}}
    {"key1":"value1"}
    {"key2":"value2"}

In this case, each line is a valid JSON data structure with one single
leaf value only.

# OPTIONS

- -A
- --auto-key
- --no-auto-key

        -A
        --auto-key
        --no-auto-key

    When set (first two options), every input is put into its own sub-value
    inside the top-level hash. See ["--auto-key-prefix"](#auto-key-prefix),
    [--auto-key-suffix](https://metacpan.org/pod/--auto-key-suffix) and ["default-key"](#default-key) for options related to
    automatic keys generation.

    Defaults to a false value, i.e. hashes will be merged together in the
    top level hash, and only array/scalar values will get an automatically
    generated key.

- -P
- --auto-key-prefix

        -P ITEM-
        --auto-key-prefix ITEM-

    Prefix to be applied when auto-generating a key for inserting an input
    into the top-level hash. This applies to input top-level arrays/scalars,
    unless when `--auto-key` is set in which case it applies to all
    top-level inputs.

    Defaults to the single underscore character `_`.

- -S
- --auto-key-suffix

        -S _mine
        --auto-key-suffix _mine

    Suffix to be applied when auto-generating a key for inserting an input
    into the top-level hash. This applies to input top-level arrays/scalars,
    unless when `--auto-key` is set in which case it applies to all
    top-level inputs.

    Defaults to the single underscore character `_`.

- -b
- --binmode

        -b setting
        --binmode setting

    set the output encoding using the same rules as Perl's `binmode`
    function. Defaults to `:encoding(UTF-8)`. When left empty, it is
    considered equivalent to `:raw`.

- -K
- --default-key

        -K mykey
        --default-key mykey

    Key associated to the last top-level input that needs key
    auto-generation (depends on ["--auto-key"](#auto-key)).

    Defaults to the single underscore character `_`.

- -d
- --define

        -d key=value
        --define key=value

    add the definition of an element in the input data. The following
    algorithm applies:

    - input definition `key=value` is split at the first `=` sign found.
    This means that the `key` cannot contain `=` signs, while the value
    can;
    - the `key` part is divided into sub-keys splitting using the `.` dot
    character. This means that sub-keys cannot contain dots.
    - each sub-key is used to traverse the input data, with auto-vivification
    when necessary.
    - sub-keys that are non-negative integers (i.e. either 0 or any positive
    integer) are regarded as array indexes. Otherwise, the sub-key is
    regarded as a hash key.
    - the `value` part is assigned as the element _pointed_ by the last
    sub-key.

- -f
- --format

        -f <yaml|yml|json|jsn>
        --format <yaml|yml|json|jsn>

    set the (default) format for input data files. It can be one of `yml`,
    `yaml`, `json` or `jsn` in whatever case. You can also set the format
    in a fine-grained way using either ["--json"](#json) or ["--yaml"](#yaml) options.

- -F
- --function

        -F spec
        --function spec

    set template to a function. This is equivalent to specifying:

        -T '[%= spec %]'

    except that it is more concise. You can of course put whatever in
    `spec`, so you are not constrained on using a single function.

    Currently available functions are:

    - `base64`

        encode the argument with RFC 2045 base64 algorithm, use it like this:

            base64('text') # "dGV4dA=="

    - `indent`

        indent the argument, 4 blanks by default. Use it like this:

            indent('whatever')  #  "    whatever"
            indent('xxx', 7)    #  "       xxx"
            indent('X', '  ')   #  "  X"

    - `slurp`

        read a whole file, optionally setting the encoding via `binmode` (defaults
        to `:raw`, i.e. no reading tricks applied). Use it like this:

            slurp('/path/to/filen.ame');

    - `urlenc`

        encode a string in a form suitable for inclusion in a URL. All characters
        that are not in ` a-z A-Z 0-9 - ~ _ . ` are transformed into their
        percent-encoded counterparts.

    - `xmlenc`

        encode a string in a form suitable for use as XML text. Characters
        `< > & ' "` are transformed (in numeric form).

    - `xmltxt`

        encode a string in a form suitable for use as XML text. Only characters
        `< &` are transformed (in numeric form).

    - `crumbr_as(type)`

        where `type` can be `URI`, `Default` or `JSON`;

    - `crumbr`

        alias to `uri_crumbr`

    - `uri_crumbr`

        use crumbr with the `URI` alternative

    - `exact_crumbr`

        use crumbr with the _exact_ `Default` alternative

    - `json_crumbr`

        use crumbr with the `JSON` alternative

    - `JSON`

        dumps the input as pretty-printed JSON (so this is more readable)

    - `YAML`

        dumps the input as YAML (so this is more readable)

    The functions above work, by default, on the overall input data, unless
    indicated otherwise. You can pass an optional (additional) parameter with
    the data structure you want it to work upon, e.g. if you just want to
    pretty-print an item you can do this:

        $ teepee -i input.json -F'YAML(V("some.inner.hash"))'

    Note that you can use `slurp`, `base64` and `indent` to read in any
    file, encode it and possibly put it as content inside a YAML file. E.g.
    you might do this to pass a generic file via cloud-init:

        #cloud-config
        write_files:
        - encoding: base64
          path: /etc/whatever
          owner: root:root
          permissions: '0644'
          content: |
        [%= indent(base64(slurp(V 'filename')), 5) %]

- --help

    print a somewhat more verbose help, showing usage, this description of
    the options and some examples from the synopsis.

- -I
- --immediate

        -I '{"ciao":"a tutti"}'
        --immediate '{"hey":"joe"}'

    immediate input, whose content is directly in the command line
    parameter. Does auto-detection and complies with ["--format"](#format) as
    ["--input"](#input).

- -i
- --input

        -i filename
        --input filename

    an input file carrying data for expansion. This option can be set
    multiple times, which will trigger (shallow) merging of the data
    structures.

    If set as `-`, standard input will be read.

    Note: only allowed data structures are hashes at the top level.

- -j
- --jsn
- --json

        -j input.json
        --jsn some.json
        --json other.json

    add an input file indicating that its format is JSON.

- -J
- --json-s

        -J '{"ciao":"a tutti"}'
        --json-s '{"hey":"joe"}'

    immediate input, whose content is directly in the command line
    parameter, read as JSON.

    Note that the case of the lowercase option is uppercase.

    This can come handy when you have read your data structure in a shell
    variable, and don't want to do tricks with redirections.

- -l
- --lib
- --include

        -l lib
        --lib /path/to/local/lib
        --include /from/other/perl/lib

    add a path to the array `@INC` where modules are looked for. This
    actually applies only to items loaded via ["-M"](#m)/["--module"](#module) below,
    because the inclusion of the directories happens at runtime.

- --man

    print out the full documentation for the script.

- -M
- --module

        -M Digest::MD5=md5_hex
        --module 'Log::Log4perl::Tiny qw< :easy >'

    import a module and its functions. The first flavor has a
    specification where you can put `Module::Name=func1,func2,...`,
    otherwise you can specify a line that will `eval`ed like
    `use $your_line;`.

- -n
- --newline
- --no-newline

    the first two forms set `teepee` to always print a newline at the end.
    This should make it easier to use in the command line, especially for
    casually printing variables on the shell.

    The last form is the negation, i.e. newline printing is disabled. This
    can come handy when you set the environment variable ["TEEPEE\_NEWLINE"](#teepee_newline)
    to a non-false value, but you want to disable the newline printing in
    one call.

- -N
- --no-input

        -N
        --no-input

    boolean option to signal that there is no input at all. This is handy if
    you just want to expand a template based on a few variables set directly
    on the command line, for example:

        # both "n" for newline and "N" for no-input, then multiple defines
        $ teepee -nN -d a=b -d c=d -T '[% a %] -> [% c %]'
        b -> d

- -o 
- --output

        -o filename
        --output filename

    set the output channel where data will be sent. By default it is set to
    `-`, which means standard output.

    Data will be printed assuming the channel is UTF-8 capable.

- -t 
- --template

        -t filename
        --template filename

    set the input template filename. The input file is assumed to be UTF-8
    encoded.

    Templates are assumed to be valid [Template::Perlish](https://metacpan.org/pod/Template::Perlish) template files,
    see that module's documentation for additional help. The default opener
    and closer are assumed.

- -T 
- --text

    set the template to expand directly on the command line.

- --usage

    print a concise usage line and exit.

- -v string
- --variable string

        -v some.data.inside
        --variable some.data.inside

    expand a variable directly. This is equivalent to specifying:

        -T '[% some.data.inside %]'

    but more concise.

- --version

    print the version of the script.

- -y
- --yml
- --yaml

        -y input.yaml
        --yml some.yaml
        --yaml other.yaml

    add an input file indicating that its format is YAML.

- --yaml-1

        --yaml-1 file-with-yaml-frontmatter.md

    add an input file which has an initial header that is formatted in YAML.
    This is useful for reading the _front matter_ from a Markdown file, if
    present, like in the following example:

        ---
        title: My shiny post
        type: post
        date: 2022-05-06 07:00:00 +0200
        ---

        # Post title

        This is a post about...

- -Y
- --yaml-s

        -Y '"ciao": "a tutti"'
        --yaml-s '"hi": "there"'

    immediate input, whose content is provided directly in the command line
    parameter, read as YAML.

    Note that the case of the short option is uppercase.

    This can come handy when you have read your data structure in a shell
    variable, and don't want to do tricks with redirections.

- --yaml-s1

        --yaml-s1 "$string_with_yaml_frontmatter"

    immediate input, whose content is provided directly in the command line
    parameter, which starts with valid YAML.

    This can be handy to parse the YAML _front matter_ from a string that
    contains a whole Markdown document that contains one. See ["--yaml-1"](#yaml-1)
    for an example.

# DIAGNOSTICS

- `output open('%s'): %s`

    errors while opening the output channel, second placeholder carries the
    error from the operating system.

- `undefined input format`

    auto-detection of input format failed. You can use option ["--format"](#format)
    to specify the input format.

- `cannot read input format %s`

    the provided input format is not recognised, see ["--format"](#format) for the
    allowed values.

- `undefined filename`

    the filename provided for input reading is not defined. This applies
    both to data and template inputs.

- `input open('%s'): %s`

    errors while opening an input file, second placeholder carries the
    error from the operating system.

- `cannot infer format for file '%s'`

    heuristic to infer the format of the file failed. You can specify the
    format to be used using ["--format"](#format)

# CONFIGURATION AND ENVIRONMENT

teepee requires no configuration files.

The following environment variables are supported:

- **TEEPEE\_NEWLINE**

    when set to a true value, it has the same effect of option
    ["--newline"](#newline). Anyway, the command line always overrides the environment
    variable, so if option ["--no-newline"](#no-newline) is set, the newline printig will
    be disabled anyway.

# DEPENDENCIES

- [Data::Crumbr](https://metacpan.org/pod/Data::Crumbr) (and sons)
- [JSON::PP](https://metacpan.org/pod/JSON::PP) (with [JSON::PP::Boolean](https://metacpan.org/pod/JSON::PP::Boolean))
- [Mo](https://metacpan.org/pod/Mo) (with [Mo::default](https://metacpan.org/pod/Mo::default) and [Mo::coerce](https://metacpan.org/pod/Mo::coerce))
- [Template::Perlish](https://metacpan.org/pod/Template::Perlish)
- [YAML::Tiny](https://metacpan.org/pod/YAML::Tiny)

The bundled version contains all the needed modules, without
documentation. The following licensing terms apply to the included
modules:

- [Data::Crumbr](https://metacpan.org/pod/Data::Crumbr)

    Copyright (C) 2015 by Flavio Poletti <polettix@cpan.org>

    This module is free software. You can redistribute it and/or modify it
    under the terms of the Artistic License 2.0.

    This program is distributed in the hope that it will be useful, but
    without any warranty; without even the implied warranty of
    merchantability or fitness for a particular purpose.

- [JSON::PP](https://metacpan.org/pod/JSON::PP)

    Copyright 2007-2014 by Makamaka Hannyaharamitu

    This library is free software; you can redistribute it and/or modify it
    under the same terms as Perl itself.

- [Mo](https://metacpan.org/pod/Mo)

    Copyright (c) 2011-2013. Ingy döt Net.

    This program is free software; you can redistribute it and/or modify it
    under the same terms as Perl itself.

    See http://www.perl.com/perl/misc/Artistic.html

- [Template::Perlish](https://metacpan.org/pod/Template::Perlish)

    Copyright (c) 2008-2015 by Flavio Poletti polettix@cpan.org.

    This module is free software. You can redistribute it and/or modify it
    under the terms of the Artistic License 2.0.

    This program is distributed in the hope that it will be useful, but
    without any warranty; without even the implied warranty of
    merchantability or fitness for a particular purpose.

- [YAML::Tiny](https://metacpan.org/pod/YAML::Tiny)

    Copyright 2006 - 2013 Adam Kennedy.

    This program is free software; you can redistribute it and/or modify it
    under the same terms as Perl itself.

    The full text of the license can be found in the LICENSE file available
    at https://metacpan.org/source/ETHER/YAML-Tiny-1.69/LICENSE.

# BUGS AND LIMITATIONS

No bugs have been reported. Auto-detection of locale should probably
extend to output encoding when printing to standard output, as opposed
to assuming UTF-8 is fine.

Please report any bugs or feature requests through http://rt.cpan.org/

# AUTHOR

Flavio Poletti `polettix@cpan.org`

# LICENCE AND COPYRIGHT

Copyright (c) 2015, 2017 Flavio Poletti `polettix@cpan.org`.

This module is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.
