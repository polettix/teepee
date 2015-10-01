# NAME

teepee - extract data from structures

# HURRY UP!

Get the bundled version like this:

    curl -LO https://github.com/polettix/teepee/raw/master/bundle/teepee

or this

    wget https://github.com/polettix/teepee/raw/master/bundle/teepee

or just click here: [https://github.com/polettix/teepee/raw/master/bundle/teepee](https://github.com/polettix/teepee/raw/master/bundle/teepee)

# USAGE

    teepee [--usage] [--help] [--man] [--version]

    teepee [-d|--define key=value]
           [-f|--format input-format]
           [-i|--input filename]
           [-n|--newline|--no-newline]
           [-o|--output filename]
           [-t|--template filename]
           [-T|--text string]

# EXAMPLES

    shell$ teepee -i data.yml -t template.file -o generated
    
    shell$ teepee -i data.json -T 'hello [% customer.name %]'

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
option ["--template"](#template)) or from the command-line directly (via
option ["--text"](#text)). Templates can be written according to what
[Template::Perlish](https://metacpan.org/pod/Template::Perlish) provides.

All files are supposed to be UTF-8 encoded. When the template is
provided from the command line, module [I18N::Langinfo](https://metacpan.org/pod/I18N::Langinfo) is used to
auto-detect the terminal setting and try to do the right things. If in
doubt, just use a UTF-8 encoded file for your template.

Output is sent to either standard output (by default or if you set the
filename to `-`) or to the filename specified via option `/--output`.
Output will be printed assuming that the receiving end is UTF-8 capable.

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

    $ teepee -T '[% crumbr(); %]' -i data.yml

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

    $ teepee -T '[% crumbr(); %]' -i data.yml \
      | grep '^array/[0-9][0-9]*/k1 '

You get the idea.

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

    $ teepee -T '[% crumbr(); %]' <sample.yaml
    empty-array []
    empty-hash {}
    null-value null
    plain-value "ciao"

You have probably noticed that this does not allow you to clearly
distinguish between hash/object keys and array indexes. Hopefully this
does not concern you because you have a sane input data structure, but
in case you want to remove any space for misunderstanding, you can use
`exact_crumbr` instead:

    $ teepee -T '[% exact_crumbr(); %]' -i data.yml
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

    $ teepee -T '[% json_crumbr(); %]' -i data.yml
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

    set the format for input data files. It can be one of `yml`, `yaml`,
    `json` or `jsn` in whatever case.

- --help

    print a somewhat more verbose help, showing usage, this description of
    the options and some examples from the synopsis.

- -i
- --input

        -i filename
        --input filename

    an input file carrying data for expansion. This option can be set
    multiple times, which will trigger (shallow) merging of the data
    structures.

    If set as `-`, standard input will be read.

    Note: only allowed data structures are hashes at the top level.

- --man

    print out the full documentation for the script.

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

- --version

    print the version of the script.

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

- [JSON::PP](https://metacpan.org/pod/JSON::PP)
- [Template::Perlish](https://metacpan.org/pod/Template::Perlish)
- [YAML::Tiny](https://metacpan.org/pod/YAML::Tiny)

The bundled version contains all the needed modules.

# BUGS AND LIMITATIONS

No bugs have been reported. Auto-detection of local should probably
extend to output encoding when printing to standard output, as opposed
to assuming UTF-8 is fine.

Please report any bugs or feature requests through http://rt.cpan.org/

# AUTHOR

Flavio Poletti `polettix@cpan.org`

# LICENCE AND COPYRIGHT

Copyright (c) 2015, Flavio Poletti `polettix@cpan.org`.

This module is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.
