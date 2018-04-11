# featureProximity.pl version 3

Robert W. Leach

Created: 11/2/2011

## SUMMARY

* **WHAT IS THIS**: This script takes an input data file with chromosomal coordinates and a feature file also with chromosomal coordinates (and optional sample IDs) and reports the closest feature to each pair of input coordinates.  Both the input file and feature file are optionally allowed to have multiple pairs of coordinates (e.g. structural variant coordinates that have been narrowed down to a region identifying a breakpoint).  Breakpoints come in pairs, hence multiple allowed regions.  You can either input the structural variants as the feature file or input data file.  The input data file coordinates will be output with the closest feature to each region.  Sample information is only used in the feature file to report how many samples have structural variant breakpoints near the input coordinate pairs.

* **INPUT FORMAT**: Tab-delimited text file.

* **FEATURE FILE FORMAT**: Tab-delimited text file.

* **OUTPUT FORMAT**: Tab-delimited text file.  Columns from the input data file and feature file are all reported in the same order unless otherwise specified by the -m or -w options respectively.  Intervening columns indicating feature distances of closest features among samples are reported.  If -u, -d, -v, -x, or -t are supplied, the feature column set specified by -w and associated intervening columns are multiplied.  See column headers to know which columns contain features associated to which samples, regions, and orientations.  Column headers in the input files will be re-used if they can be identified.  Otherwise, columns from the input data files will have headers formatted as 'datcol(#)' and columns from the feature file will be formatted as 'ftcol(#)' where '#' indicates column number from the original input/feature file.  Here is an example of a full column header and what it means.  Note, not all column headers are this complex.

    Smpl-abc-ftcol(2)[1]{over,opp}

This column contains features that were part of sample "abc" (parsed from the sample column in a feature file).  The feature file did not have a column header for this column, thus it was designated "ftcol", and it was the second "(2)" column in the feature file.  It contains features that were found close to the first ("1") series of chr/start/stop columns in the input data file (note, there may be multiple such columns in the input file - e.g. structural variation break points).  It also only contains features that "over"lap the input data coordinates on the "opp"osite strand.


## USAGE:

     featureProximity.pl -i "input file(s)" [options]

     -i|--data-file*      REQUIRED Space-separated tab-delimited data file(s)
        --input-file               which contain a unique data ID for each row,
                                   a sequence ID, and a start and stop
                                   coordinate.  When used with input on
                                   standard-in, the value of this paramter is
                                   used as a file name stub for naming the
                                   output files).  Note, -o can be  used to
                                   append to what is supplied here to form new
                                   output file names.  The script will expand
                                   BSD glob characters such as '*', '?', and
                                   '[...]' (e.g. -i "*.txt *.text").  See
                                   --help for a description of the input file
                                   format.  See --help for advanced usage.
                                   *No flag required.
     -f|--feature-file    REQUIRED Space-separated tab-delimited feature
                                   file(s) which contain a unique feature ID
                                   for each row, a sequence ID, and a start and
                                   stop coordinate.  The script will expand BSD
                                   glob characters such as '*', '?', and
                                   '[...]' (e.g. -i "*.txt *.text").  See
                                   --help for a description of the feature file
                                   format.  See --help for advanced usage.
     -r|--search-range    OPTIONAL [-1] The maximum distance of reported
                                   features.  Features further away will not be
                                   output.  A negative value means no limit.  A
                                   0 value means only report overlapping
                                   features.
     -c|--data-seq-id-col REQUIRED [0] The column number where the sequence ID
                                   for the start and stop can be found in the
                                   data file (see -i).  This can be a
                                   chromosome number, a GI number, or any
                                   identifier of a single contiguous sequence.
                                   This identifier must match a sequence
                                   identifier in the feature file.  More than 1
                                   may be provided (e.g. to denote structural
                                   variants).
     -b|--data-start-col  REQUIRED [0] The column number where the start
                                   coordinate can be found in the data file
                                   (see -i).  The value in the column may be
                                   two numbers separated by non-numbers as long
                                   as the start is first and the stop is last
                                   (e.g. 1..526 where start=1 and stop=526).
                                   More than 1 may be provided (e.g. to denote
                                   structural variants).
     -e|--data-stop-col   REQUIRED [0] The column number where the stop
                                   coordinate can be found in the data file
                                   (see -i).  The value in the column may be
                                   two numbers separated by non-numbers as long
                                   as the start is first and the stop is last
                                   (e.g. 1..526 where start=1 and stop=526).
                                   More than 1 may be provided (e.g. to denote
                                   structural variants).
     -p|--data-strand-col OPTIONAL [0] The column number where the strand
                                   can be found in the data file (see -i).
                                   Note, this script is smart enough to
                                   interpret strandedness when combined with
                                   coordinate columns.  You may re-use a
                                   coordinate column to supply here as the
                                   strand column.  Here are example patterns
                                   are matched: {+,-,plus,minus,1234c,
                                   comp(1234..5678),for,rev}.  As long as a
                                   portion of the string is matched, strand
                                   will be saved.  Required if -u, -d, or -t is
                                   supplied.
     -m|--data-out-cols   OPTIONAL [all] The column number(s) (separated by
                                   non-numbers (e.g. commas)) in the data file
                                   (see -i) that are to be used in the output
                                   table (in the supplied order).  You may re-
                                   use column numbers.
     -s|--feat-sample-col OPTIONAL [0] The column number where a sample ID can
                                   be found in the feature file (see -f).  For
                                   every row of output, the samples that have
                                   features close to the coordinates in the
                                   input file will be added as a separate
                                   sample column.  '0' means there is no sample
                                   data.  Note, sample data in the data file is
                                   not supported.
     -a|--feat-seq-id-col REQUIRED [0] The column number where the sequence ID
                                   for the start and stop coordinates can be
                                   found in the feature file (see -f).  This
                                   can be a chromosome number, a GI number, or
                                   any identifier of a single contiguous
                                   sequence.  This identifier must match a
                                   sequence identifier in the data file.  More
                                   than 1 may be provided (e.g. to denote
                                   structural variants).
     -j|--feat-start-col  REQUIRED [0] The column number where the start
                                   coordinate can be found in the feature file
                                   (see -f).  The value in the column may be
                                   two numbers separated by non-numbers as long
                                   as the start is first and the stop is last
                                   (e.g. 1..526 where start=1 and stop=526).
                                   More than 1 may be provided (e.g. to denote
                                   structural variants).
     -k|--feat-stop-col   REQUIRED [0] The column number where the stop
                                   coordinate can be found in the feature file
                                   (see -f).  The value in the column may be
                                   two numbers separated by non-numbers as long
                                   as the start is first and the stop is last
                                   (e.g. 1..526 where start=1 and stop=526).
                                   More than 1 may be provided (e.g. to denote
                                   structural variants).
     -n|--feat-strand-col OPTIONAL [0] The column number where the strand
                                   can be found in the data file (see -i).
                                   Note, this script is smart enough to
                                   interpret strandedness when combined with
                                   coordinate columns.  You may re-use a
                                   coordinate column to supply here as the
                                   strand column.  Here are example patterns
                                   are matched: {+,-,plus,minus,1234c,
                                   comp(1234..5678),for,rev}.  As long as a
                                   portion of the string is matched, strand
                                   will be saved.  Required if -t is supplied.
     -w|--feat-out-cols   OPTIONAL [all] The column number or numbers
                                   (separated by non-numbers (e.g. commas)) in
                                   the feature file (supplied with -f) that are
                                   to be included in the output table (in the
                                   order supplied).  You may re-use column
                                   numbers.
     -u|--search-upstream OPTIONAL [Off] Search upstream of the input data
                                   coordinates and report closest single
                                   feature (or multiple equidistant features)
                                   found there.  Default behavior is to search
                                   upstream, downstream, and overlap and report
                                   the single closest feature (or multiple
                                   equidistant features).  Requires -p.
     -d|--search-         OPTIONAL [Off] Search downstream of the input data
        downstream                 coordinates and report the closest single
                                   feature (or multiple equidistant features)
                                   found there.  Default behavior is to search
                                   upstream, downstream, and overlap and report
                                   the single closest feature (or multiple
                                   equidistant features).  Requires -p.
     -l|--search-left     OPTIONAL [Off] Search left of the input data
                                   coordinates (i.e. feature coordinates are
                                   lesser than data input coordinates) and
                                   report closest single feature (or multiple
                                   equidistant features) found there.  Default
                                   behavior is to search upstream, downstream,
                                   and overlap and report the single closest
                                   feature (or multiple equidistant features).
     -g|--search-right    OPTIONAL [Off] Search right of the input data
                                   coordinates (i.e. feature coordinates are
                                   greater than data input coordinates) and
                                   report closest single feature (or multiple
                                   equidistant features) found there.  Default
                                   behavior is to search upstream, downstream,
                                   and overlap and report the single closest
                                   feature (or multiple equidistant features).
     -v|--search-overlap  OPTIONAL [Off] Search for overlap of the input data
                                   coordinates and report features found there.
                                   All overlapping features will be reported,
                                   even if they overlap by a single base.
                                   Default behavior is to search upstream,
                                   downstream, and overlap and report the
                                   single closest feature (or multiple
                                   equidistant features).
     -x|--search-         OPTIONAL [Off] Search upstream and downstream of the
        nonoverlap                 input data coordinates and report the
                                   closest single feature (or multiple
                                   equidistant features) found in one of the
                                   two regions.  All overlapping features will
                                   be ignored, even if they overlap by a single
                                   base.  Default behavior is to search
                                   upstream, downstream, and overlap and report
                                   the single closest feature (or multiple
                                   equidistant features).
     -z|--search-any      OPTIONAL [Off] Search upstream, downstream, and the
                                   overlapping region of the input data
                                   coordinates and report the closest single
                                   feature (or multiple equidistant features)
                                   found in any of the regions.  All
                                   overlapping features will be considered
                                   equivalently closest, even if they overlap
                                   by a single base.  This is the default
                                   behavior if -u, -d, -v, -x, and -z are not
                                   supplied.
     -t|--feat-           OPTIONAL [any] {any,plus,minus,+,-,same,opposite,
        orientation                away,toward,upstream,downstream} Report
                                   features in the supplied orientation.
                                   Default behavior is to report the closest
                                   feature in any orientation and does not
                                   require -p or -n.  Plus & minus (or + & -)
                                   require -n.  Orientations relative to the
                                   input data coordinates (same, opposite,
                                   away, toward, upstream, downstream) require
                                   -p and -n.  Away (same as upstream) means
                                   that the feature's upstream region is closer
                                   to the input data coordinates.  Toward (same
                                   as downstream) means that the feature's
                                   downstream region is closer.  If there is
                                   any overlap, the feature is considered
                                   neither 'away' nor 'toward', but rather
                                   'overlapping'.  So if overlaps are included
                                   in the search (i.e. -d, -u, -v, and -x are
                                   not provided), overlapping features,
                                   regardless of orientation, will be reported
                                   instead of non-overlapping features in the
                                   away/toward orientation because the overlaps
                                   are 'closer'.  To use away/toward and ignore
                                   overlapping features, use -x.  To always
                                   report both non-overlapping away/toward
                                   features and overlapping features
                                   separately, supply both -v and -x.  You may
                                   supply multiple orientations separated by
                                   non-alphanumeric (including '_') characters.
                                   Each orientation supplied here will cause
                                   multiple sets of feature columns (specified
                                   by -w) to be reported.  This is compounded
                                   by the multiple column sets generated by -u,
                                   -d, -v, and -x.
     -o|--outfile-suffix  OPTIONAL [nothing] This suffix is added to the input
                                   file names to use as output files.
                                   Redirecting a file into this script will
                                   result in the output file name to be "STDIN"
                                   with your suffix appended.  See --help for a
                                   description of the output file format.
     --outdir             OPTIONAL [input file location] Supply a directory to
                                   put output files.  When supplied without -o,
                                   the output file names will be the same as
                                   the input file names.  See --help for
                                   advanced usage.
     --force|--overwrite  OPTIONAL Force overwrite of existing output files.
                                   Only used when the -o option is supplied.
     --ignore             OPTIONAL Ignore critical errors & continue
                                   processing.  (Errors will still be
                                   reported.)  See --force to not exit when
                                   existing output files are found.
     --verbose            OPTIONAL Verbose mode.  Cannot be used with the quiet
                                   flag.  Verbosity level can be increased by
                                   supplying a number (e.g. --verbose 2) or by
                                   supplying the --verbose flag multiple times.
     --quiet              OPTIONAL Quiet mode.  Suppresses warnings and errors.
                                   Cannot be used with the verbose or debug
                                   flags.
     --help               OPTIONAL Print an explanation of the script and its
                                   input/output files.
     --version            OPTIONAL Print software version number.  If verbose
                                   mode is on, it also prints the template
                                   version used to standard error.
     --debug              OPTIONAL Debug mode.  Adds debug output to STDERR and
                                   prepends trace information to warning and
                                   error messages.  Cannot be used with the
                                   --quiet flag.  Debug level can be increased
                                   by supplying a number (e.g. --debug 2) or by
                                   supplying the --debug flag multiple times.
     --noheader           OPTIONAL Suppress commented header output.  Without
                                   this option, the script version, date/time,
                                   and command-line information will be printed
                                   at the top of all output files commented
                                   with '#' characters.

## INSTALLATION

To install this module type the following:

    perl Makefile.PL
    make
    make install

And optionally (to remove unnecessary files):

    make clean

## RUNNING

To get the usage:

    featureProximity.pl

To get a detailed usage:

    featureProximity.pl --extended

To get help:

    featureProximity.pl --help

## DEPENDENCIES

This module comes with a pre-release version of a perl module called "CommandLineInterface".  CommandLineInterface requires these other modules and libraries:

  Getopt::Long
  File::Glob

## COPYRIGHT AND LICENCE

See LICENSE
