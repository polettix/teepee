# NAME

teepee - extract data from structures

# USAGE

    teepee [--usage] [--help] [--man] [--version]

    teepee [-d|--define key=value]
           [-f|--format input-format]
           [-i|--input filename]
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
option ["--text"](#text)).

All files are supposed to be UTF-8 encoded. When the template is
provided from the command line, module [I18N::Langinfo](https://metacpan.org/pod/I18N::Langinfo) is used to
auto-detect the terminal setting and try to do the right things. If in
doubt, just use a UTF-8 encoded file for your template.

Output is sent to either standard output (by default or if you set the
filename to `-`) or to the filename specified via option `/--output`.
Output will be printed assuming that the receiving end is UTF-8 capable.

# OPTIONS

- -d
- --define

        -d key=value
        --define key=value

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

teepee requires no configuration files or environment variables.

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
