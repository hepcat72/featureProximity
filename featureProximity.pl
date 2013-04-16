#!/usr/bin/perl -w

#Generated using perl_script_template.pl 1.43
#Robert W. Leach
#rwleach@ccr.buffalo.edu
#Center for Computational Research
#Copyright 2008

#These variables (in main) are used by getVersion() and usage()
my $software_version_number = '3.2';
my $created_on_date         = '11/2/2011';

##
## Start Main
##

use strict;
use Getopt::Long;
use File::Glob ':glob';

#Declare & initialize variables.  Provide default values here.
my($outfile_suffix); #Not defined so input can be overwritten
my @outdirs             = ();
my $current_output_file = '';

my @input_files         = ();
my @feature_files       = ();

my $help                = 0;
my $version             = 0;
my $overwrite           = 0;
my $noheader            = 0;

my $feat_sample_col     = 0;
my @feat_chr1_cols      = ();
my @feat_start1_cols    = ();
my @feat_end1_cols      = ();
my @feat_out_cols       = ();

my @data_chr1_cols      = ();
my @data_start1_cols    = ();
my @data_end1_cols      = ();
my @data_out_cols       = ();

my @data_strand_cols    = ();
my @feat_strand_cols    = ();
my $search_upstream     = 0;
my $search_downstream   = 0;
my $search_overlap      = 0;
my @feat_orientations   = ();

my $search_range        = -1;

#These variables (in main) are used by the following subroutines:
#verbose, error, warning, debug, getCommand, quit, and usage
my $preserve_args = [@ARGV];  #Preserve the agruments for getCommand
my $verbose       = 0;
my $quiet         = 0;
my $DEBUG         = 0;
my $ignore_errors = 0;

my $GetOptHash =
  {'i|data-file|input-file=s' => sub {push(@input_files,    #REQ'D unless
					   [sglob($_[1])])},#<> supplied
   '<>'                  => sub {push(@input_files,         #REQ'D unless
				      [sglob($_[0])])},     #-i supplied
   'f|feature-file=s'    => sub {push(@feature_files,       #REQ'D unless
				      [sglob($_[1])])},           #<> supplied
   'r|search-range=s'    => \$search_range,                 #OPTIONAL [-1]

   'c|data-seq-id-col=s' => sub {push(@data_chr1_cols,      #REQUIRED [0]
				      map {split(/\s+/,$_)}
				      sglob($_[1]))},
   'a|feat-seq-id-col=s' => sub {push(@feat_chr1_cols,      #REQUIRED [0]
				      map {split(/\s+/,$_)}
				      sglob($_[1]))},

   'b|data-start-col=s'  => sub {push(@data_start1_cols,    #REQUIRED [0]
				      map {split(/\D+/,$_)}
				      sglob($_[1]))},
   'j|feat-start-col=s'  => sub {push(@feat_start1_cols,    #REQUIRED [0]
				      map {split(/\D+/,$_)}
				      sglob($_[1]))},

   'e|data-stop-col=s'   => sub {push(@data_end1_cols,      #REQUIRED [0]
				      map {split(/\D+/,$_)}
				      sglob($_[1]))},
   'k|feat-stop-col=s'   => sub {push(@feat_end1_cols,      #REQUIRED [0]
				      map {split(/\D+/,$_)}
				      sglob($_[1]))},

   's|feat-sample-col=s' => \$feat_sample_col,              #OPTIONAL [0]

   'm|data-out-cols=s'   => sub {push(@data_out_cols,       #OPTIONAL [nothing]
				      grep {$_}
				      map {split(/\D+/,$_)}
				      sglob($_[1]))},
   'w|feat-out-cols=s'   => sub {push(@feat_out_cols,       #OPTIONAL [nothing]
				      grep {$_}
				      map {split(/\D+/,$_)} sglob($_[1]))},
   'p|data-strand-col=s' => sub {push(@data_strand_cols,    #OPTIONAL [0]
				      map {split(/\D+/,$_)} #  REQ if u,d,v, or
				      sglob($_[1]))},       #  t supplied
   'n|feat-strand-col=s' => sub {push(@feat_strand_cols,    #OPTIONAL [0]
				      map {split(/\D+/,$_)} #  REQ if u,d,v, or
				      sglob($_[1]))},       #  t supplied
   'u|search-upstream'   => \$search_upstream,              #OPTIONAL [Off]
   'd|search-downstream' => \$search_downstream,            #OPTIONAL [Off]
   'v|search-overlap'    => \$search_overlap,               #OPTIONAL [Off]
   't|feat-orientation=s'=> sub {push(@feat_orientations,   #OPTIONAL [any]
                                      map {split(/\W+/,$_)} #any,away,toward,
                                      sglob($_[1]))},       #same,opposite,+,-
                                                            #plus,minus,both
   'o|outfile-suffix=s'  => \$outfile_suffix,               #OPTIONAL [undef]
   'outdir=s'            => sub {push(@outdirs,             #OPTIONAL
				      [sglob($_[1])])},
   'force|overwrite'     => \$overwrite,                    #OPTIONAL [Off]
   'ignore'              => \$ignore_errors,                #OPTIONAL [Off]
   'verbose:+'           => \$verbose,                      #OPTIONAL [Off]
   'quiet'               => \$quiet,                        #OPTIONAL [Off]
   'debug:+'             => \$DEBUG,                        #OPTIONAL [Off]
   'help'                => \$help,                         #OPTIONAL [Off]
   'version'             => \$version,                      #OPTIONAL [Off]
   'noheader|no-header'  => \$noheader,                     #OPTIONAL [Off]
  };

#If there are no arguments and no files directed or piped in
if(scalar(@ARGV) == 0 && isStandardInputFromTerminal())
  {
    usage();
    quit(0);
  }

#Get the input options & catch any errors in option parsing
unless(GetOptions(%$GetOptHash))
  {
    #Try to guess which arguments GetOptions is complaining about
    my @possibly_bad = grep {!(-e $_)} map {@$_} @input_files;

    error('Getopt::Long::GetOptions reported an error while parsing the ',
	  'command line arguments.  The error should be above.  Please ',
	  'correct the offending argument(s) and try again.');
    usage(1);
    quit(-1);
  }

#Print the debug mode (it checks the value of the DEBUG global variable)
debug('Debug mode on.') if($DEBUG > 1);

#If the user has asked for help, call the help subroutine
if($help)
  {
    help();
    quit(0);
  }

#If the user has asked for the software version, print it
if($version)
  {
    print(getVersion($verbose),"\n");
    quit(0);
  }

#Check validity of verbosity options
if($quiet && ($verbose || $DEBUG))
  {
    $quiet = 0;
    error('You cannot supply the quiet and (verbose or debug) flags ',
	  'together.');
    quit(-2);
  }

#If standard input has been redirected in
my $outfile_stub = 'STDIN';
if(!isStandardInputFromTerminal())
  {
    #Don't need to use a 'stub' if the redirected input file is a feature file
    if(scalar(grep {$_ eq '-'} map {@$_} @feature_files) == 0)
      {
	debug("Feature files: [",join(',',map {@$_} @feature_files),"].")
	  if($DEBUG > 1);

	#If there's only one input file detected, use that input file as a stub
	#for the output file name construction
	if(scalar(grep {$_ ne '-'} map {@$_} @input_files) == 1)
	  {
	    $outfile_stub = (grep {$_ ne '-'} map {@$_} @input_files)[0];
	    @input_files = ();

	    #If $outfile_suffix has not been supplied, set it to an empty
	    #string so that the name of the output file will be what they
	    #supplied with -i
	    if(!defined($outfile_suffix))
	      {
		#Only allow this is the supplied the overwite flag
		if(-e $outfile_stub && !$overwrite)
		  {
		    error("File exists: [$outfile_stub]  Since you did not ",
			  "supply an outfile suffix, the input file name ",
			  "will be used as the output file.  However the ",
			  "input file is not a stub as expected.  It ",
			  "actually exists.  Use --outfile-suffix (-o) or ",
			  '--overwrite to continue.');
		    quit(-3);
		  }
		$outfile_suffix = '';
	      }
	  }
	#If standard input has been redirected in and there's more than 1 input
	#file detected
	elsif(scalar(grep {$_ ne '-'} map {@$_} @input_files) > 1)
	  {
	    #Warn the user about the naming of the outfile when using STDIN
	    if(defined($outfile_suffix))
	      {warning('Input on STDIN detected along with multiple other ',
		       'input files and an outfile suffix.  Your output file ',
		       'for the input on standard input will be named [',
		       $outfile_stub,$outfile_suffix,'].')}
	  }
      }

    #Unless the dash was supplied by the user on the command line, push it on
    unless(scalar(grep {$_ eq '-'} map {@$_} (@input_files,@feature_files)))
      {
	#If there are other input files present, push it
	if(scalar(@input_files))
	  {push(@{$input_files[-1]},'-')}
	#Else create a new input file set with it as the only file member
	else
	  {@input_files = (['-'])}
      }
  }

#Warn users when they turn on verbose and output is to the terminal
#(implied by no outfile suffix checked above) that verbose messages may be
#uncleanly overwritten
if($verbose && !defined($outfile_suffix) &&isStandardOutputToTerminal())
  {warning('You have enabled --verbose, but appear to possibly be ',
	   'outputting to the terminal.  Note that verbose messages can ',
	   'interfere with formatting of terminal output making it ',
	   'difficult to read.  You may want to either turn verbose off, ',
	   'redirect output to a file, or supply an outfile suffix (-o).')}

#Make sure there is input
if(scalar(@input_files) == 0)
  {
    error('No input files detected.');
    usage(1);
    quit(-4);
  }

#If output directories have been provided
if(scalar(@outdirs))
  {
    #If there are the same number of output directory sets as input file sets
    if(scalar(@outdirs) == scalar(@input_files))
      {
	#Unless all the output directory sets contain 1 specified directory
	unless(scalar(grep {scalar(@$_) == 1} @outdirs) ==
	       scalar(@input_files) ||
	       #Or each output directory set has the same number of directories
	       #as the corresponding input files
	       scalar(grep {scalar(@{$outdirs[$_]}) ==
			      scalar(@{$input_files[$_]})}
		      (0..$#{@input_files})) == scalar(@input_files))
	  {
	    error('The number of --outdir\'s is invalid.  You may either ',
		  'supply 1, 1 per input file set, 1 per input file, or ',
		  'where all sets are the same size, 1 per input file is a ',
		  'single input file set.  You supplied [',
		  join(',',map {scalar(@$_)} @outdirs),
		  '] output directories and [',
		  join(',',map {scalar(@$_)} @input_files),
		  '] input files.');
	    quit(-6);
	  }
      }
    elsif(scalar(@outdirs) == 1 && scalar(@{$outdirs[0]}) != 1)
      {
	#Unless all the input file sets are the same size as the single set of
	#output directories
	unless(scalar(grep {scalar(@$_) == scalar(@{$outdirs[0]})}
		      @input_files) == scalar(@input_files))
	  {
	    error('The number of --outdir\'s is invalid.  You may either ',
		  'supply 1, 1 per input file set, 1 per input file, or ',
		  'where all sets are the same size, 1 per input file is a ',
		  'single input file set.  You supplied [',
		  join(',',map {scalar(@$_)} @outdirs),
		  '] output directories and [',
		  join(',',map {scalar(@$_)} @input_files),
		  '] input files.');
	    quit(-7);
	  }
      }
  }

#Check to make sure previously generated output files won't be over-written
#Note, this does not account for output redirected on the command line
if(!$overwrite && defined($outfile_suffix))
  {
    my $existing_outfiles = [];
    my $set_num = 0;
    foreach my $input_file_set (@input_files)
      {
	my $file_num = 0;
	#For each output file *name* (this will contain the input file name's
	#path if it was supplied)
	foreach my $output_file (map {($_ eq '-' ? $outfile_stub : $_)
					. $outfile_suffix}
				 @$input_file_set)
	  {
	    #If at least 1 output directory was supplied
	    if(scalar(@outdirs))
	      {
		#Eliminate any path strings from the output file name that came
		#from the input file supplied
		$output_file =~ s/.*\///;

		#If there is the same number of output directory sets as input
		#file sets
		if(scalar(@outdirs) > 1 &&
		   scalar(@outdirs) == scalar(@input_files))
		  {
		    #If there's 1 directory per input file set
		    if(scalar(@{$outdirs[$set_num]}) == 1)
		      {
			#Each set of input files has 1 output directory

			$output_file = $outdirs[$set_num]->[0]
			  . ($outdirs[$set_num]->[0] =~ /\/$/ ? '' : '/')
			    . $output_file;
		      }
		    #Else there must be the same number of directories
		    elsif(scalar(@{$outdirs[$set_num]}) ==
			  scalar(@{$input_files[$set_num]}))
		      {
			#Each input file has its own output directory

			$output_file = $outdirs[$set_num]->[$file_num] .
			  ($outdirs[$set_num]->[$file_num] =~ /\/$/ ? '' : '/')
			    . $output_file;
		      }
		    #Else Error
		    else
		      {
			error("Cannot determine corresponding directory for ",
			      "$output_file.  Will output to current ",
			      "directory.");
		      }
		  }
		#There must be only 1 output directory set, so if it's more
		#than 1 directory and has the same number of directories as
		#each set of input files
		elsif(scalar(@{$outdirs[0]}) > 1 &&
		      scalar(grep {scalar(@{$outdirs[0]}) == scalar(@$_)}
			     @input_files) == scalar(@input_files))
		  {
		    #Each set of input files has the same number of input
		    #files (guaranteed in code above), so each one in series
		    #will output to the corresponding directory specified in
		    #the single output directory set

		    $output_file = $outdirs[0]->[$file_num]
		      . ($outdirs[0]->[$file_num] =~ /\/$/ ? '' : '/')
			. $output_file;
		  }
		#There must be only 1 output directory set, so if it's more
		#than 1 directory and has the same number of directories as the
		#number of input file sets
		elsif(scalar(@{$outdirs[0]}) > 1 &&
		      scalar(@{$outdirs[0]}) == scalar(@input_files))
		  {
		    #Each file set will output to the corresponding directory
		    #in the first set of directories in series.  Note, if the
		    #number of input files in each set and the number of sets
		    #is the same, the default mechanism is for a single set's
		    #files to go in the various directories in the single set
		    #of directories.  For now, this cannot be overridden.

		    $output_file = $outdirs[0]->[$set_num]
		      . ($outdirs[0]->[$set_num] =~ /\/$/ ? '' : '/')
			. $output_file;
		  }
		#It must be a single output directory
		else
		  {
		    #All input files have the same output directory

		    $output_file = $outdirs[0]->[0]
		      . ($outdirs[0]->[0] =~ /\/$/ ? '' : '/')
			. $output_file;
		  }
	      }

	    $file_num++;
	    push(@$existing_outfiles,$output_file) if(-e $output_file);
	  }
	$set_num++;
      }

    if(scalar(@$existing_outfiles))
      {
	error("Files exist: [@$existing_outfiles].  Use --overwrite to ",
	      "continue.  E.g.:\n",getCommand(1),' --overwrite');
	quit(-5);
      }
  }

#Create the output directories
if(scalar(@outdirs))
  {
    foreach my $dir_set (@outdirs)
      {
	foreach my $dir (@$dir_set)
	  {
	    if(-e $dir)
	      {
		warning('The --overwrite flag will not empty or delete ',
			'existing output directories.  If you wish to delete ',
			'existing output directories, you must do it ',
			'manually.') if($overwrite)
		}
	    else
	      {mkdir($dir)}
	  }
      }
  }

verbose('Run conditions: ',getCommand(1));

if(scalar(grep {$_ !~ /^\d+$/} @data_chr1_cols))
  {
    my @errs = grep {$_ !~ /^\d+$/} @data_chr1_cols;
    error("Invalid seq-id column number (-c): [",join(',',@errs),"] for ",
	  "input data file (-i).");
    quit(1);
  }

if(scalar(grep {$_ !~ /^\d+$/} @feat_chr1_cols))
  {
    my @errs = grep {$_ !~ /^\d+$/} @feat_chr1_cols;
    error("Invalid chromosome column number (-a): [",join(',',@errs),"] for ",
	  "feature file (-f).");
    quit(2);
  }

if(scalar(grep {$_ !~ /^\d+$/} @data_start1_cols))
  {
    my @errs = grep {$_ !~ /^\d+$/} @data_start1_cols;
    error("Invalid start column number (-s): [",join(',',@errs),"] for input ",
	  "data file (-i).");
    quit(3);
  }

if(scalar(grep {$_ !~ /^\d+$/} @feat_start1_cols))
  {
    my @errs = grep {$_ !~ /^\d+$/} @feat_start1_cols;
    error("Invalid start column number (-j): [",join(',',@errs),"] for ",
	  "feature file (-f).");
    quit(4);
  }

if(scalar(grep {$_ !~ /^\d+$/} @data_end1_cols))
  {
    my @errs = grep {$_ !~ /^\d+$/} @data_end1_cols;
    error("Invalid end column number (-e): [",join(',',@errs),"] for input ",
	  "data file (-i).");
    quit(5);
  }

if(scalar(grep {$_ !~ /^\d+$/} @feat_end1_cols))
  {
    my @errs = grep {$_ !~ /^\d+$/} @feat_end1_cols;
    error("Invalid end column number (-k): [",join(',',@errs),"] for ",
	  "feature file (-f).");
    quit(6);
  }

if((scalar(@data_chr1_cols) != scalar(@data_start1_cols)) ||
   (scalar(@data_start1_cols) != scalar(@data_end1_cols)) ||
   (scalar(@feat_chr1_cols) != scalar(@feat_start1_cols)) ||
   (scalar(@feat_start1_cols) != scalar(@feat_end1_cols)))
  {
    error("The number of seq-id, start, and end column numbers for the input ",
	  "data file (",join('/',(scalar(@data_chr1_cols),
				  scalar(@data_start1_cols),
				  scalar(@data_end1_cols))),
	  ") and feature file (",join('/',(scalar(@feat_chr1_cols),
					   scalar(@feat_start1_cols),
					   scalar(@feat_end1_cols))),
	  ") must be the same.");
    quit(7);
  }

if(scalar(grep {$_ !~ /^\d+$/} @data_out_cols))
  {
    error("Invalid out column number(s) (-m): [",
	  join(',',grep {$_ !~ /^\d+$/} @data_out_cols),
	  "] for input data file (-i).");
    quit(16);
  }

if(scalar(grep {$_ !~ /^\d+$/} @feat_out_cols))
  {
    error("Invalid out column number(s) (-w): [",
	  join(',',grep {$_ !~ /^\d+$/} @feat_out_cols),
	  "] for feature file (-f).");
    quit(17);
  }

if(scalar(grep {$_ !~ /^\d+$/} @data_strand_cols))
  {
    error("Invalid strand column number(s) (-t): [",
	  join(',',grep {$_ !~ /^\d+$/} @data_strand_cols),
	  "] for input data file (-i).");
    quit(18);
  }

if(scalar(grep {$_ !~ /^\d+$/} @feat_strand_cols))
  {
    error("Invalid out column number(s) (-n): [",
	  join(',',grep {$_ !~ /^\d+$/} @feat_out_cols),
	  "] for feature file (-f).");
    quit(19);
  }

if((scalar(@data_strand_cols) &&
    scalar(@data_chr1_cols) != scalar(@data_strand_cols)) ||
   (scalar(@feat_strand_cols) &&
    scalar(@feat_chr1_cols) != scalar(@feat_strand_cols)))
  {
    error("The number of seq-id and strand column numbers for the input ",
	  "data file (",join('/',(scalar(@data_chr1_cols),
				  scalar(@data_strand_cols))),
	  ") and feature file (",join('/',(scalar(@feat_chr1_cols),
					   scalar(@feat_strand_cols))),
	  ") must be the same.");
    quit(20);
  }

if(($search_upstream || $search_downstream) && scalar(@data_strand_cols) == 0)
  {
    error("--search-upstream or --search-downstream requires -t.");
    quit(21);
  }

my $search_streams = [];
push(@$search_streams,'any')  unless($search_upstream || $search_downstream ||
				     $search_overlap);
push(@$search_streams,'up')   if($search_upstream);
push(@$search_streams,'down') if($search_downstream);
push(@$search_streams,'over') if($search_overlap);

my $feat_orients = [];
push(@$feat_orients,'any')    if(scalar(@feat_orientations) == 0 ||
				 scalar(grep {/^an/i} @feat_orientations));
push(@$feat_orients,'+')      if(scalar(grep {/^(p|\+)/i} @feat_orientations));
push(@$feat_orients,'-')      if(scalar(grep {/^(m|-)/i} @feat_orientations));
push(@$feat_orients,'away')   if(scalar(grep {/^(aw|u)/i} @feat_orientations));
push(@$feat_orients,'toward') if(scalar(grep {/^(t|d)/i} @feat_orientations));
push(@$feat_orients,'same')   if(scalar(grep {/^s/i} @feat_orientations));
push(@$feat_orients,'opp')    if(scalar(grep {/^o/i} @feat_orientations));

if(scalar(grep {$_ ne 'any'} @$search_streams) ||
   scalar(grep {$_ ne 'any' && $_ ne 'away'} @$feat_orients))
  {
    my @untested_streams = grep {$_ ne 'any'} @$search_streams;
    error("The validity of the output using the -u -v, or -d options (e.g. ",
	  join(',',@untested_streams),") has not been tested.  Use at your ",
	  "own risk.  It is highly recommended that you check the output for ",
	  "correctness.") if(scalar(@untested_streams));
    my @untested_orients = grep {$_ ne 'any' && $_ ne 'away'} @$feat_orients;
    error("The validity of the output using the -t option with these values [",
	  join(',',@untested_orients),"] has not been tested.  Use at your ",
	  "own risk.  It is highly recommended that you check the output for ",
	  "correctness.") if(scalar(@untested_orients));
  }

my @bad_orients = grep {$_ !~ /^(an|p|m|\+|-|s|o|aw|t|u|d)/i}
  @feat_orientations;
if(scalar(@bad_orients))
  {
    error("Invalid feature orientation(s) supplied via -t: [",
	  join(' ',@bad_orients),"].");
    quit(22);
  }

if(scalar(grep {/\+|-|away|toward/} @$feat_orients) &&
   scalar(@feat_strand_cols) == 0)
  {
    error("-n is required when -t is 'plus', '+', 'minus', '-', 'away', or ",
	  "'toward'.");
    quit(23);
  }

if(scalar(grep {/same|opp/} @$feat_orients) &&
   (scalar(@feat_strand_cols) == 0 || scalar(@data_strand_cols) == 0))
  {
    error("-n and -p are both required when -t is 'same' or 'opposite'.");
    quit(24);
  }

#If output is going to STDOUT instead of output files with different extensions
#or if STDOUT was redirected, output run info once
verbose('[STDOUT] Opened for all output.') if(!defined($outfile_suffix));

#Store info. about the run as a comment at the top of the output file if
#STDOUT has been redirected to a file
if(!isStandardOutputToTerminal() && !$noheader)
  {print(getVersion(),"\n",
	 '#',scalar(localtime($^T)),"\n",
	 '#',getCommand(1),"\n");}

my $current_feature_file = '';
my $set_num              = 0;
my $feature_hash         = {};
my $max_feat_cols        = {};
my $feat_headers         = {};
my $pad_feat_outs        = 0;
my $sample_hash          = {};
my $current_sample_hash  = {};

#Create array indexes from the column numbers for the feature file columns
my @feat_out_inds     = map {$_ - 1} @feat_out_cols;
my @feat_chr1_inds    = map {$_ - 1} @feat_chr1_cols;
my @feat_start1_inds  = map {$_ - 1} @feat_start1_cols;
my @feat_end1_inds    = map {$_ - 1} @feat_end1_cols;
my @feat_strand_inds  = map {$_ - 1} @feat_strand_cols;
my $multiple_samples  = ($feat_sample_col ne '' && $feat_sample_col != 0);
my($feat_sample_ind);
$feat_sample_ind = $feat_sample_col - 1 if($multiple_samples);

#Create array indexes from the column numbers for the input data file columns
my @data_chr1_inds    = map {$_ - 1} @data_chr1_cols;
my @data_start1_inds  = map {$_ - 1} @data_start1_cols;
my @data_end1_inds    = map {$_ - 1} @data_end1_cols;
my @data_out_inds     = map {$_ - 1} @data_out_cols;
my @data_strand_inds  = map {$_ - 1} @data_strand_cols;

#Keep track of whether we will need to pad the feature out columns to
#ensure a consistent number of columns.  Note, if the user supplied specific
#columns for the feature output, then this will be unnecessary.  Padding will
#also only eventually be done if the number of columns is uneven.
$pad_feat_outs = scalar(@feat_out_inds);

#Keep track of the largest feature (to be added to the search range in order to
#create a hash of feature regions to speed up the search).  The script will
#jump to the regions nearest the input coordinates.
my $largest_range = 0;
my $region_size   = 1;

my $first_loop = 1;

#For each input file set
foreach my $input_file_set (@input_files)
  {
    my $file_num = 0;
    #For each output file *name* (this will contain the input file name's
    #path if it was supplied)

    #For each input file
    foreach my $input_file (@$input_file_set)
      {
	my $file_num = 0;

	##
	## Determine the current feature file
	##

	#If there are the same number of feature file sets as input
	#file sets
	if(scalar(@feature_files) == scalar(@input_files))
	  {
	    #If there's 1 feature file per input file set
	    if(scalar(@{$feature_files[$set_num]}) == 1)
	      {
		#Each set of input files has 1 feature file
		$current_feature_file = $feature_files[$set_num]->[0];
	      }
	    #Else there must be the same number of feature files
	    elsif(scalar(@{$feature_files[$set_num]}) ==
		  scalar(@{$input_files[$set_num]}))
	      {
		#Each input file has its own feature file
		$current_feature_file = $feature_files[$set_num]->[$file_num];
	      }
	    #Else Error
	    else
	      {
		error("Cannot determine corresponding feature file for ",
		      "$input_file.");
		next;
	      }
	  }
	#There must be only 1 feature file set, so if it has more
	#than 1 feature file and has the same number of feature files as
	#the number of input file sets
	elsif(scalar(@{$feature_files[0]}) > 1 &&
	      scalar(grep {scalar(@{$feature_files[0]}) == scalar(@$_)}
		     @input_files) == scalar(@input_files))
	  {
	    #Each set of input files has the same number of input
	    #files (guaranteed in code above), so each one in series
	    #will have the corresponding feature file specified in
	    #the single feature file set

	    $current_feature_file = $feature_files[0]->[$file_num];
	  }
	#There must be only 1 feature file set, so if it's more
	#than 1 feature file and has the same number of feature files as the
	#number of input file sets
	elsif(scalar(@{$feature_files[0]}) > 1 &&
	      scalar(@{$feature_files[0]}) == scalar(@input_files))
	  {
	    #Each input file set will have the corresponding feature file
	    #in the first set of feature files in series.  Note, if the
	    #number of input files in each set and the number of sets
	    #is the same, the default mechanism is for a single set's
	    #input files to have the various feature files in the single set
	    #of feature files.  For now, this cannot be overridden.

	    $current_feature_file = $feature_files[0]->[$set_num];
	  }
	#It must be a single feature file
	else
	  {
	    #All input files have the same feature file

	    $current_feature_file = $feature_files[0]->[0];
	  }

	##
	## Create the current feature hash
	##

	my $current_features = [];
	unless(exists($feature_hash->{$current_feature_file}))
	  {
	    #Open the feature file
	    if(!open(FEAT,$current_feature_file))
	      {
		#Report an error and iterate if there was an error
		error("Unable to open feature file: [$current_feature_file].",
		      "\n$!");
		next;
	      }
	    else
	      {verbose('[',($current_feature_file eq '-' ?
			    $outfile_stub : $current_feature_file),
		       '] Opened feature file.')}

	    my $line_num       = 0;
	    my $verbose_freq   = 100;
	    my $redund_check   = {};
	    my $feat_col_check = {}; #Allows a check on the number of columns
	    $max_feat_cols->{$current_feature_file} = 0;
	    my $first_feat_recorded = 0;

	    #For each line in the current feature file
	    while(getLine(*FEAT))
	      {
		$line_num++;
		verboseOverMe('[',($current_feature_file eq '-' ?
				   $outfile_stub : $current_feature_file),
			      "] Reading line: [$line_num].")
		  unless($line_num % $verbose_freq);

		next if(/^\s*$/);

		chomp;
		my @cols = split(/ *\t */,$_,-1);

		#Skip rows that don't have enough columns
		if(scalar(grep {defined($_) && $#cols < $_}
			  (@feat_out_inds,$feat_sample_ind,@feat_chr1_inds,
			   @feat_start1_inds,@feat_end1_inds,
			   @feat_strand_inds)))
		  {
		    if(/\t/ && $_ !~ /^\s*#/)
		      {warning("Line [$line_num] of feature file ",
			       "[$current_feature_file] has too few ",
			       "columns.  Skipping.")}
		    #Else - assume it's a commented line and don't report it
		    next;
		  }

		my $feat_cols = scalar(@cols);
		if($feat_cols > $max_feat_cols->{$current_feature_file})
		  {$max_feat_cols->{$current_feature_file} = $feat_cols}

		#Skip commented lines
		if(/^\s*#/)
		  {
		    #We cannot get here unless there is enough columns, so we
		    #can assume this is a header line since it is commented and
		    #has tabs, but we only want to create column headers if
		    #they haven't already been set
		    unless(exists($feat_headers->{$current_feature_file}))
		      {
			$feat_headers->{$current_feature_file} =
			  [scalar(@feat_out_inds) ?
			   @cols[@feat_out_inds] : @cols];
		      }
		    next;
		  }

		$feat_col_check->{$feat_cols}++;

		my $feat_out = (scalar(@feat_out_inds) ?
				join("\t",@cols[@feat_out_inds]) :
				join("\t",@cols));

		my $feat_sample = (defined($feat_sample_ind) ?
				   $cols[$feat_sample_ind] : '');

		#For each pair of coordinates (and chromosome) in a row that we
		#are searching... add it to the feature hash.  Note, we will be
		#duplicating data here, but we're only reporting the closest
		#match, so we should only be outputting 1 row for a match
		#(unless both pairs of coordinates in a row overlap the data)
		for(my $f_ind = 0;$f_ind < scalar(@feat_chr1_inds);$f_ind++)
		  {
		    my($feat_chr1,$feat_start1,$feat_end1) =
		      @cols[$feat_chr1_inds[$f_ind],
			    $feat_start1_inds[$f_ind],
			    $feat_end1_inds[$f_ind]];
		    my($feat_strand);
		    if(scalar(@feat_strand_inds))
		      {$feat_strand = $cols[$feat_strand_inds[$f_ind]]}

		    #If both coordinates are in the same column, split on non-
		    #nums
		    if($feat_start1_inds[$f_ind] == $feat_end1_inds[$f_ind] &&
		       $feat_start1 =~ /\D/)
		      {
			if($feat_start1 =~ /(\d{4,}),(\d+)/)
			  {
			    $feat_start1 = $1;
			    $feat_end1   = $2;
			  }
			elsif($feat_start1 =~ /(\d+),(\d{4,})/)
			  {
			    $feat_start1 = $1;
			    $feat_end1   = $2;
			  }
			elsif($feat_start1 =~ /^[\d,]+[^\d,]{1,2}[\d,]+$/)
			  {
			    ($feat_start1,$feat_end1) =
			      grep {/\d/} split(/[^\d,]+/,$feat_start1);
			  }
			elsif($feat_start1 =~
			      /([\d,]+)(?:\.\.|[\-:;\.\/|&+_])([\d,]+)/)
			  {
			    $feat_start1 = $1;
			    $feat_end1   = $2;
			  }
			elsif($feat_start1 =~ /(\d{4,})/)
			  {
			    $feat_start1 = $feat_end1 = $1;
			    warning("Using a single coordinate: [$1] for ",
				    "start1 and end1 of feature on line ",
				    "[$line_num] of feature file ",
				    "[$current_feature_file].");
			  }
			elsif($feat_start1 =~ /^\s*([\d,]+)\s*$/)
			  {
			    $feat_start1 = $feat_end1 = $1;
			    warning("Using a single coordinate: [$1] for ",
				    "start1 and end1 of feature on line ",
				    "[$line_num] of feature file ",
				    "[$current_feature_file].");
			  }
			else
			  {
			    #If we have not yet parsed any real data, assume
			    #this is a header line and record the headers
			    if($first_feat_recorded == 0 &&
			       !exists($feat_headers->{$current_feature_file}))
			      {
				$feat_headers->{$current_feature_file} =
				  [scalar(@feat_out_inds) ?
				   @cols[@feat_out_inds] : @cols];
				last;
			      }
			    error("Unable to parse start1 and end1 of ",
				  "feature on line [$line_num] of feature ",
				  "file [$current_feature_file].  Skipping.");
			    next;
			  }
		      }

		    #Allow the coordinate to have commas
		    $feat_start1 =~ s/[,\s]//g;
		    if($feat_start1 !~ /^\d+$/)
		      {
			#If we have not yet parsed any real data, assume
			#this is a header line and record the headers
			if($first_feat_recorded == 0 &&
			   !exists($feat_headers->{$current_feature_file}))
			  {
			    $feat_headers->{$current_feature_file} =
			      [scalar(@feat_out_inds) ?
			       @cols[@feat_out_inds] : @cols];
			    last;
			  }
			error("Invalid feature start1 coordinate: ",
			      "[$feat_start1] in column ",
			      "[$feat_start1_cols[$f_ind]] on line ",
			      "[$line_num] of feature file ",
			      "[$current_feature_file].  Skipping.")
			  unless($feat_start1 eq '');
			next;
		      }

		    #Allow the coordinate to have commas
		    $feat_end1 =~ s/[,\s]//g;
		    if($feat_end1 !~ /^\d+$/)
		      {
			#If we have not yet parsed any real data, assume
			#this is a header line and record the headers
			if($first_feat_recorded == 0 &&
			   !exists($feat_headers->{$current_feature_file}))
			  {
			    $feat_headers->{$current_feature_file} =
			      [scalar(@feat_out_inds) ?
			       @cols[@feat_out_inds] : @cols];
			    last;
			  }
			error("Invalid feature end1 coordinate: [$feat_end1] ",
			      "in column [$feat_end1_cols[$f_ind]] on line ",
			      "[$line_num] of feature file ",
			      "[$current_feature_file].  Skipping.");
			next;
		      }

		    if($feat_chr1 !~ /\S/)
		      {
			error("Invalid feature chromosome: [$feat_chr1] ",
			      "in column [$feat_chr1_cols[$f_ind]] on line ",
			      "[$line_num] of feature file ",
			      "[$current_feature_file].  Skipping.");
			next;
		      }

		    debug("FEAT STRAND BEFORE: [$feat_strand].")
		      if($DEBUG > 1);
		    if(scalar(@feat_strand_inds))
		      {
			if($feat_strand !~ /(\+|-|plus|minus|\d|comp|fpr|rev)/)
			  {
			    error("Invalid feature strand: [$feat_strand] ",
				  "in column [$feat_strand_cols[$f_ind]] on ",
				  "line [$line_num] of feature file ",
				  "[$current_feature_file].  Skipping.");
			    next;
			  }
			elsif($feat_strand =~ /-|minus|\dc|comp|rev/)
			  {$feat_strand = '-'}
			elsif($feat_strand =~ /(\+|plus|\d|for)/)
			  {$feat_strand = '+'}
			else
			  {
			    error("Unable to parse feature strand: ",
				  "[$feat_strand] in column ",
				  "[$feat_strand_cols[$f_ind]] on line ",
				  "[$line_num] of feature file ",
				  "[$current_feature_file].  Skipping.");
			    next;
			  }
		      }
		    else
		      {$feat_strand = ''}
		    debug("FEAT STRAND AFTER: [$feat_strand].")
		      if($DEBUG > 1);

		    #Sometimes features like genes may have redundant entries.
		    #For example, when you take the genes in the human genome
		    #and grab the smallest and largest coordinates, many splice
		    #variants will yield the same "feature".  Here, we check
		    #for features that are indistinguishable
		    if(exists($redund_check->{$feat_sample}) &&
		       exists($redund_check->{$feat_sample}->{$feat_out}))
		      {
			warning("Skipping redundant feature found in feature ",
				"file: [$current_feature_file]: [$feat_out].");
			next;
		      }

		    my $dir = ($feat_start1 < $feat_end1 ? '+' : '-');

		    #Order the coordinates
		    ($feat_start1,$feat_end1) = sort {$a <=> $b}
		      ($feat_start1,$feat_end1);

		    debug("Adding feature: SAMPLE => $feat_sample, ",
			  "CHR1 => $feat_chr1, START1 => $feat_start1, ",
			  "STOP1 => $feat_end1") if($DEBUG > 1);

		    push(@{$feature_hash->{$current_feature_file}},
			 {SAMPLE => $feat_sample,
			  CHR1   => $feat_chr1,
			  START1 => $feat_start1,
			  STOP1  => $feat_end1,
			  STRAND => $feat_strand,
			  OUT    => $feat_out,
			  COLS   => $feat_cols});

		    $first_feat_recorded = 1;

		    if($largest_range < (abs($feat_end1-$feat_start1) + 1 +
					 (2 * $search_range)))
		      {$largest_range = abs($feat_end1-$feat_start1) + 1 +
			 (2 * $search_range)}

		    #Record the feature in the redundancy hash to help
		    #eliminate duplicates.
		    $redund_check->{$feat_sample}->{$feat_out} = 1;
		  }

		$sample_hash->{$current_feature_file}->{$feat_sample} = 1
		  if($first_feat_recorded);
	      }

	    close(FEAT);

	    #If we intend to pad rows with missing columns, check to see if
	    #it's necessary, and issue a warning if that's the case
	    if($pad_feat_outs && scalar(keys(%$feat_col_check)) > 1)
	      {
		warning("The number of columns in feature file: ",
			"[$current_feature_file] appears to be ",
			"inconsistent.  Here is a listing of the number of ",
			"columns and the number of rows with those numbers ",
			"of columns:\n\t",
			join("\n\t",map {"$_\t$feat_col_check->{$_}"}
			     sort {$a <=> $b} keys(%$feat_col_check)),
			"\nRows with fewer columns than the max will be ",
			"padded with empty columns.");

		foreach my $fh (@{$feature_hash->{$current_feature_file}})
		  {
		    if($fh->{COLS} < $max_feat_cols->{$current_feature_file})
		      {
			my $diff = $max_feat_cols->{$current_feature_file} -
			  $fh->{COLS};
			foreach(1..$diff)
			  {$fh->{OUT} .= "\t"}
			$fh->{COLS} = $max_feat_cols->{$current_feature_file};
		      }
		    elsif($fh->{COLS} >
			  $max_feat_cols->{$current_feature_file})
		      {
			error("This should not have happened.  Please report ",
			      "error 1 to rwleach\@ccr.buffalo.edu.");
		      }
		  }
	      }

	    ##
	    ##We need to ensure that we have headers, regardless of whether or
	    ##not the input file had headers
	    ##

	    #Process the feature column headers
	    if(!exists($feat_headers->{$current_feature_file}))
	      {$feat_headers->{$current_feature_file} =
		 [map {"ftcol($_)"}
		  (1..$max_feat_cols->{$current_feature_file})]}
	    #We can assume it cannot be more because the max was based on the
	    #column header row as well
	    elsif(scalar(@{$feat_headers->{$current_feature_file}}) <
		  $max_feat_cols->{$current_feature_file})
	      {
		while(scalar(@{$feat_headers->{$current_feature_file}}) <
		      $max_feat_cols->{$current_feature_file})
		  {
		    push(@{$feat_headers->{$current_feature_file}},
			 "ftcol(" .
			 (scalar(@{$feat_headers->{$current_feature_file}}) +
			  1) . ")")
		  }
	      }
	    #Now I will check for any header that is an empty string
	    foreach(0..$#{$feat_headers->{$current_feature_file}})
	      {if(!defined($feat_headers->{$current_feature_file}->[$_]) ||
		  $feat_headers->{$current_feature_file}->[$_] eq '')
		 {$feat_headers->{$current_feature_file}->[$_] =
		    "ftcol(" . ($_ + 1) . ")"}}

	    debug("Feature headers: [",
		  join(',',@{$feat_headers->{$current_feature_file}}),"].")
	      if($DEBUG > 1);

	    ##
	    ##Sort the feature hash based on start coordinate
	    ##

	    @{$feature_hash->{$current_feature_file}} =
	      sort {$a->{START1} <=> $b->{START1}}
		@{$feature_hash->{$current_feature_file}};

	    verbose('[',($current_feature_file eq '-' ?
			 $outfile_stub : $current_feature_file),
		    '] Closed feature file.  Time taken: [',scalar(markTime()),
		    ' Seconds].');
	  }

	#Determine the order of magnitude larger than the largest range (add 0
	#to turn this into an integer)
	my $magnitude = (1 . ('0' x length($largest_range))) + 0;

	if($search_range < 0)
	  {$magnitude = 0}

	#Now segment the hash based on this magnitude
	#Note: this changes the structure of the hash to have 2 more levels of
	#keys (chromosome and region start coordinate)
	$feature_hash->{$current_feature_file} =
	  segmentHash($magnitude,
		      $feature_hash->{$current_feature_file});

	#Commented out the following line to create the current features on the
	#fly with a narrower set of features based on a hash lookup (like a
	#histogram).
	#$current_features    = $feature_hash->{$current_feature_file};
	$current_sample_hash = $sample_hash->{$current_feature_file};

	##
	## Prepare the current output file
	##

	#If an output file name suffix has been defined
	if(defined($outfile_suffix))
	  {
	    ##
	    ## Open and select the next output file
	    ##

	    #Set the current output file name
	    $current_output_file = ($input_file eq '-' ?
				    $outfile_stub : $input_file)
	      . $outfile_suffix;
	  }

	#If at least 1 output directory was supplied
	if(scalar(@outdirs))
	  {
	    #Eliminate any path strings from the output file name that came
	    #from the input file supplied
	    $current_output_file =~ s/.*\///;

	    #If there is the same number of output directory sets as input
	    #file sets
	    if(scalar(@outdirs) > 1 &&
	       scalar(@outdirs) == scalar(@input_files))
	      {
		#If there's 1 directory per input file set
		if(scalar(@{$outdirs[$set_num]}) == 1)
		  {
		    #Each set of input files has 1 output directory

		    $current_output_file = $outdirs[$set_num]->[0]
		      . ($outdirs[$set_num]->[0] =~ /\/$/ ? '' : '/')
			. $current_output_file;
		  }
		#Else there must be the same number of directories
		elsif(scalar(@{$outdirs[$set_num]}) ==
		      scalar(@{$input_files[$set_num]}))
		  {
		    #Each input file has its own output directory

		    $current_output_file = $outdirs[$set_num]->[$file_num]
		      . ($outdirs[$set_num]->[$file_num] =~ /\/$/ ? '' : '/')
			. $current_output_file;
		  }
		#Else Error
		else
		  {
		    error("Cannot determine corresponding directory for ",
			  "$current_output_file.  Will output to current ",
			  "directory.");
		  }
	      }
	    #There must be only 1 output directory set, so if it's more
	    #than 1 directory and has the same number of directories as
	    #each set of input files
	    elsif(scalar(@{$outdirs[0]}) > 1 &&
		  scalar(grep {scalar(@{$outdirs[0]}) == scalar(@$_)}
			 @input_files) == scalar(@input_files))
	      {
		#Each set of input files has the same number of input
		#files (guaranteed in code above), so each one in series
		#will output to the corresponding directory specified in
		#the single output directory set

		$current_output_file = $outdirs[0]->[$file_num]
		  . ($outdirs[0]->[$file_num] =~ /\/$/ ? '' : '/')
		    . $current_output_file;
	      }
	    #There must be only 1 output directory set, so if it's more
	    #than 1 directory and has the same number of directories as the
	    #number of input file sets
	    elsif(scalar(@{$outdirs[0]}) > 1 &&
		  scalar(@{$outdirs[0]}) == scalar(@input_files))
	      {
		#Each file set will output to the corresponding directory
		#in the first set of directories in series.  Note, if the
		#number of input files in each set and the number of sets
		#is the same, the default mechanism is for a single set's
		#files to go in the various directories in the single set
		#of directories.  For now, this cannot be overridden.

		$current_output_file = $outdirs[0]->[$set_num]
		  . ($outdirs[0]->[$set_num] =~ /\/$/ ? '' : '/')
		    . $current_output_file;
	      }
	    #It must be a single output directory
	    else
	      {
		#All input files have the same output directory

		$current_output_file = $outdirs[0]->[0]
		  . ($outdirs[0]->[0] =~ /\/$/ ? '' : '/')
		    . $current_output_file;
	      }
	  }

	if(defined($outfile_suffix) || scalar(@outdirs))
	  {
	    #Open the output file
	    if(!open(OUTPUT,">$current_output_file"))
	      {
		#Report an error and iterate if there was an error
		error("Unable to open output file: [$current_output_file].\n",
		      $!);
		next;
	      }
	    else
	      {verbose("[$current_output_file] Opened output file.")}

	    #Select the output file handle
	    select(OUTPUT);

	    #Store info about the run as a comment at the top of the output
	    print(getVersion(),"\n",
		  '#',scalar(localtime($^T)),"\n",
		  '#',getCommand(1),"\n") unless($noheader);
	  }

	##
	## Prepare the current input file
	##

	#Open the input file
	if(!open(INPUT,$input_file))
	  {
	    #Report an error and iterate if there was an error
	    error("Unable to open input file: [$input_file].\n$!");
	    next;
	  }
	else
	  {verbose('[',($input_file eq '-' ? $outfile_stub : $input_file),'] ',
		   'Opened input file.')}

	my $print_header           = (defined($outfile_suffix) ||
				      scalar(@outdirs) || $first_loop);
	$first_loop                = 0;
	my $line_num               = 0;
	my $verbose_freq           = 100;
	my $max_data_cols          = 0;
	my @data_header            = ();
	my $inconsistency_reported = 0;

	#For each line in the current input file
	while(getLine(*INPUT))
	  {
	    $line_num++;
	    verboseOverMe('[',($input_file eq '-' ?
			       $outfile_stub : $input_file),
			  "] Reading line: [$line_num].")
	      unless($line_num % $verbose_freq);

	    #Skip empty lines
	    next if(/^\s*$/);

	    chomp;
	    my @cols = split(/ *\t */,$_,-1);

	    #Skip rows that don't have enough columns
	    if(scalar(grep {defined($_) && $#cols < $_}
		      (@data_out_inds,@data_chr1_inds,@data_strand_inds,
		       @data_start1_inds,@data_end1_inds)))
	      {
		#Only print the warning about too few columns if this line is
		#not commented out
		unless(/^\s*#/)
		  {
		    my $line_sample = $_;
		    $line_sample =~ s/(.{1,30}).*/$1/;
		    warning("Skipping line [$line_num] with too few columns ",
			    "[$line_sample...].");
		  }
		next;
	      }

	    my $num_data_cols = scalar(@cols);

	    #If this is the first time we're setting max_data_cols
	    if($max_data_cols == 0)
	      {$max_data_cols = $num_data_cols}
	    #Else if we've encountered an inconsistency, it's not commented,
	    #we're outputing all columns, and we haven't already reported
	    #inconsistencies
	    elsif($num_data_cols != $max_data_cols && $_ !~ /^\s*#/ &&
		  scalar(@data_out_inds) == 0 && !$inconsistency_reported)
	      {
		error("The number of columns in the data file is ",
		      "inconsistent.  All lines will be trimmed/padded ",
		      "to match the number of columns on the first line ",
		      "(which will be either the column headers or the ",
		      "first row of data if there are no headers.");
		$inconsistency_reported = 1;
		#Do not change the established max
	      }

	    #Skip commented lines (and keep an eye out for custom headers when
	    #they are on a commented line - see code below for finding
	    #uncommented headers)
	    if(/^\s*#/)
	      {
		#We cannot get here unless there are enough columns, so we
		#can assume this is a header line since it is commented and
		#has tabs, but we only want to print column headers if
		#they haven't already been printed
		if(scalar(@data_header) == 0)
		  {
		    @data_header = (scalar(@data_out_inds) ?
				    @cols[@data_out_inds] : @cols);
		  }
		next;
	      }

	    #If we are outputting all columns, we need to ensure a consistent
	    #number
	    unless(scalar(@data_out_inds))
	      {
		#Trim/pad the columns to match the first row
		#Assumes max_data_cols is set
		if(scalar(@cols) < $max_data_cols)
		  {
		    my $diff = $max_data_cols - scalar(@cols);
		    foreach(1..$diff)
		      {push(@cols,'')}
		    $num_data_cols = $max_data_cols;
		  }
		elsif(scalar(@cols) < $max_data_cols)
		  {
		    my $diff = scalar(@cols) - $max_data_cols;
		    warning("Trimming [$diff] columns from line number ",
			    "[$line_num].  This line contains more columns ",
			    "[$num_data_cols] that previous lines ",
			    "[$max_data_cols] in the file.");
		    foreach(1..$diff)
		      {pop(@cols)}
		    $num_data_cols = $max_data_cols;
		  }
	      }

	    my $data_out = (scalar(@data_out_inds) ?
			    join("\t",@cols[@data_out_inds]) :
			    join("\t",@cols));

	    my $closest_feature_hashes = {};
	    #closest_feature_hashes->{$search_stream}->{$feat_orient}->[data_coord_set_index]->{sample}

	    for(my $coord_ind = 0;
		$coord_ind < scalar(@data_start1_inds);
		$coord_ind++)
	      {
		my($data_chr1,$data_start1,$data_end1) =
		  @cols[$data_chr1_inds[$coord_ind],
			$data_start1_inds[$coord_ind],
			$data_end1_inds[$coord_ind]];
		my($data_strand);
		if(scalar(@data_strand_inds))
		  {$data_strand = $cols[$data_strand_inds[$coord_ind]]}

		#If both coordinates are in the same column, split on non-nums
		if($data_start1_inds[$coord_ind] == $data_end1_inds[$coord_ind]
		   && $data_start1 =~ /\D/)
		  {
		    #See if they are coords separated by one comma (only works
		    #for numbers larger than 999 because commas could be used
		    #in numbers to denote thousands)
		    if($data_start1 =~ /(\d{4,}),(\d+)/)
		      {
			$data_start1 = $1;
			$data_end1   = $2;
		      }
		    elsif($data_start1 =~ /(\d+),(\d{4,})/)
		      {
			$data_start1 = $1;
			$data_end1   = $2;
		      }
		    #See if the numbers have commas in them and each coord is
		    #separated by some other character or 2
		    elsif($data_start1 =~ /^[\d,]+[^\d,]{1,2}[\d,]+$/)
		      {
			($data_start1,$data_end1) =
			  grep {/\d/} split(/[^\d,]+/,$data_start1);
		      }
		    elsif($data_start1 =~
			  /([\d,]+)(?:\.\.|[\-:;\.\/|&+_])([\d,]+)/)
		      {
			$data_start1 = $1;
			$data_end1   = $2;
		      }
		    #If there's only a single number that's 4 or more digits,
		    #set both start and stop to it
		    elsif($data_start1 =~ /(\d{4,})/)
		      {
			$data_start1 = $data_end1 = $1;
			warning("Using a single coordinate: [$1] for start1 ",
				"and end1 of input data on line [$line_num] ",
				"of input data file [$input_file].");
		      }
		    #If there's only a single number and nothing else
		    #set both start and stop to it
		    elsif($data_start1 =~ /^\s*([\d,]+)\s*$/)
		      {
			$data_start1 = $data_end1 = $1;
			warning("Using a single coordinate: [$1] for start1 ",
				"and end1 of input data on line [$line_num] ",
				"of input data file [$input_file].");
		      }
		    else
		      {
			#If we have not yet printed the header or stored it,
			#assume this is a header line and record the headers
			if($print_header == 1 && scalar(@data_header) == 0)
			  {
			    @data_header = (scalar(@data_out_inds) ?
					    @cols[@data_out_inds] : @cols);
			    last;
			  }
			error("Unable to parse start1 and end1 of input data ",
			      "on line [$line_num] of input data file ",
			      "[$input_file].  Skipping.");
			#Put a place-holder in for no result for this sample
			foreach my $search_stream (@$search_streams)
			  {foreach my $feat_orient (@$feat_orients)
			     {push(@{$closest_feature_hashes->{$search_stream}
				       ->{$feat_orient}},{})}}
			next;
		      }
		  }

		#Allow the coordinate to have commas
		$data_start1 =~ s/[,\s]//g;
		if($data_start1 !~ /^\d+$/)
		  {
		    #If we have not yet printed the header or stored it,
		    #assume this is a header line and record the headers
		    if($print_header == 1 && scalar(@data_header) == 0)
		      {
			@data_header = (scalar(@data_out_inds) ?
					@cols[@data_out_inds] : @cols);
			last;
		      }
		    error("Invalid start1 coordinate: [$data_start1] ",
			  "in column [$data_start1_cols[$coord_ind]] on line ",
			  "[$line_num] of input file [$input_file].  ",
			  "Skipping.") if($data_start1 ne '');
		    #Put a place-holder in for no result for this sample
		    foreach my $search_stream (@$search_streams)
		      {foreach my $feat_orient (@$feat_orients)
			 {push(@{$closest_feature_hashes->{$search_stream}
				   ->{$feat_orient}},{})}}
		    next;
		  }

		#Allow the coordinate to have commas
		$data_end1 =~ s/[,\s]//g;
		if($data_end1 !~ /^\d+$/)
		  {
		    #If we have not yet printed the header or stored it,
		    #assume this is a header line and record the headers
		    if($print_header == 1 && scalar(@data_header) == 0)
		      {
			@data_header = (scalar(@data_out_inds) ?
					@cols[@data_out_inds] : @cols);
			last;
		      }
		    error("Invalid end1 coordinate: [$data_end1] ",
			  "in column [$data_end1_cols[$coord_ind]] on line ",
			  "[$line_num] of input file ",
			  "[$input_file].  Start1 was ",
			  "[$data_start1].  Skipping.")
		      if($data_end1 ne '');
		    #Put a place-holder in for no result for this sample
		    foreach my $search_stream (@$search_streams)
		      {foreach my $feat_orient (@$feat_orients)
			 {push(@{$closest_feature_hashes->{$search_stream}
				   ->{$feat_orient}},{})}}
		    next;
		  }

		if($data_chr1 !~ /\S/)
		  {
		    error("Invalid chromosome: [$data_chr1] ",
			  "in column [$data_chr1_cols[$coord_ind]] on line ",
			  "[$line_num] of input file ",
			  "[$input_file].  Skipping.");
		    #Put a place-holder in for no result for this sample
		    foreach my $search_stream (@$search_streams)
		      {foreach my $feat_orient (@$feat_orients)
			 {push(@{$closest_feature_hashes->{$search_stream}
				   ->{$feat_orient}},{})}}
		    next;
		  }

		if(scalar(@data_strand_inds))
		  {
		    if($data_strand !~ /(\+|-|plus|minus|\d|comp|fpr|rev)/)
		      {
			error("Invalid strand: [$data_strand] ",
			      "in column [$data_strand_cols[$coord_ind]] on ",
			      "line [$line_num] of input file ",
			      "[$input_file].  Skipping.");
			#Put a place-holder in for no result for this sample
			foreach my $search_stream (@$search_streams)
			  {foreach my $feat_orient (@$feat_orients)
			     {push(@{$closest_feature_hashes->{$search_stream}
				       ->{$feat_orient}},{})}}
			next;
		      }
		    elsif($data_strand =~ /-|minus|\dc|comp|rev/)
		      {$data_strand = '-'}
		    elsif($data_strand =~ /(\+|plus|\d|for)/)
		      {$data_strand = '+'}
		    else
		      {
			error("Unable to parse strand: ",
			      "[$data_strand] in column ",
			      "[$data_strand_cols[$coord_ind]] on line ",
			      "[$line_num] of input file ",
			      "[$input_file].  Skipping.");
			#Put a place-holder in for no result for this sample
			foreach my $search_stream (@$search_streams)
			  {foreach my $feat_orient (@$feat_orients)
			     {push(@{$closest_feature_hashes->{$search_stream}
				       ->{$feat_orient}},{})}}
			next;
		      }
		  }
		else
		  {$data_strand = ''}

		#Order the coordinates
		($data_start1,$data_end1) = sort {$a <=> $b}
		  ($data_start1,$data_end1);

		debug("Comparing features with input record: [chr1: ",
		      "$data_chr1, start1: $data_start1, end1: $data_end1] ",
		      "using search range distance: [$search_range].")
		  if($DEBUG > 1);

		#Base region membership on start coordinate
		my $mycoord = $data_start1;
		#If the coordinates are larger than the feature hash
		#segmentation, resegment the hash
		my $coord_size = abs($data_end1 - $data_start1) + 1 +
		  ($search_range >= 0 ? 2 * $search_range : 0);
		if($search_range >= 0 && $magnitude < $coord_size)
		  {
		    #Determine the new magnitude
		    my $magnitude = (1 . ('0' x length($coord_size))) + 0;
		    #Resegment the hash
		    $feature_hash->{$current_feature_file} =
		      segmentHash($magnitude,
				  [map {my $val = $_;map {@$_} values(%$val)}
				   values(%{$feature_hash
					      ->{$current_feature_file}})]);
		  }

		#Determine the current set of features to search
		$current_features = [];

		#Set the region to search
		my $region = ($magnitude ?
			      (int($mycoord / $magnitude) * $magnitude) : 0);

		#First add the features in the region to the left
		#(Note: if it's < 0, it won't exist in the hash)
		$region -= $magnitude;
		if($magnitude &&
		   exists($feature_hash->{$current_feature_file}
			  ->{$data_chr1}) &&
		   exists($feature_hash->{$current_feature_file}
			  ->{$data_chr1}->{$region}))
		  {push(@$current_features,
			@{$feature_hash->{$current_feature_file}
			    ->{$data_chr1}->{$region}})}

		#Add the features in the region containing the base coordinate
		$region += $magnitude;
		if(exists($feature_hash->{$current_feature_file}
			  ->{$data_chr1}) &&
		   exists($feature_hash->{$current_feature_file}
			  ->{$data_chr1}->{$region}))
		  {push(@$current_features,
			@{$feature_hash->{$current_feature_file}
			    ->{$data_chr1}->{$region}})}

		#Add the features from the region to the right
		$region += $magnitude;
		if($magnitude &&
		   exists($feature_hash->{$current_feature_file}
			  ->{$data_chr1}) &&
		   exists($feature_hash->{$current_feature_file}
			  ->{$data_chr1}->{$region}))
		  {push(@$current_features,
			@{$feature_hash->{$current_feature_file}
			    ->{$data_chr1}->{$region}})}

		foreach my $search_stream (@$search_streams)
		  {
		    foreach my $feat_orient (@$feat_orients)
		      {
			#Get the closest feature to start1/end1
			my $feature1 = getClosestFeature($data_chr1,
							 $data_start1,
							 $data_end1,
							 $data_strand,
							 $current_features,
							 $current_sample_hash,
							 $search_range,
							 $search_stream,
							 $feat_orient);
			#keys (of feature1):
			#$sample
			# SAMPLE
			# CHR1
			# START1
			# STOP1
			# STRAND
			# OUT
			# DISTANCE
			# OTHERS (array of hashes containing all above keys)

			push(@{$closest_feature_hashes->{$search_stream}
				 ->{$feat_orient}},$feature1);

			if(scalar(keys(%$feature1)))
			  {debug("Found a feature for chr1/start1/stop1/",
				 "$search_stream/$feat_orient")
			     if($DEBUG > 1);}
		      }
		  }
	      }

	    if($print_header)
	      {
		##
		##We need to ensure that we have headers, regardless of whether
		##or not the input file had headers
		##

		#Process the data column headers
		if(scalar(@data_header) == 0)
		  {@data_header = (map {"datcol($_)"} (1..$max_data_cols))}
		#We can assume it cannot be more because the max was based on
		#the column header row as well
		elsif(scalar(@data_header) < $max_data_cols)
		  {
		    while(scalar(@data_header) < $max_data_cols)
		      {push(@data_header,
			    "datcol(" . (scalar(@data_header) + 1) . ")")}
		  }
		#Now I will check for any header that is an empty string
		foreach(0..$#data_header)
		  {if(!defined($data_header[$_]) || $data_header[$_] eq '')
		     {$data_header[$_] = "datcol(" . ($_ + 1) . ")"}}

		##
		## Print Column headers
		##

		debug("Number of keys in current sample hash: [",
		      scalar(keys(%$current_sample_hash)),
		      "].\nFeature headers: [",
		      join(',',@{$feat_headers->{$current_feature_file}}),"].")
		  if($DEBUG > 1);

		#Columns:
		#datcol(1),datcol(2),... (there will be at least 1)
		#Foreach set of coords $c in 1 row, there will be these cols...
		#  If there are multiple samples
		#    NumSamples$c ($c will be empty if there's 1 coord set)
		#    SumDistances$c
		#  For each sample $s in the features, there will be these cols
		#    Smpl-$s-FeatDist$c
		#    For each feature out column $f in the feature data...
		#      Smpl-$s-ftcol($f)$c
		print('#',join("\t",@data_header),"\t",

		      #Join together columns associated with all the sets of
		      #coordinates in the input file
		      join("\t",
			   map
			   {
			     #If there's more than one, we're going to add a
			     #sequential number to each set of column headers
			     #associated with input coordinate sets
			     my $c = ($#data_start1_cols > 0 ?
				      '[' . ($_ + 1) . ']' : '');

			     my @feat_hdrs =
			       @{$feat_headers->{$current_feature_file}};
			     my $map_result = '';

			     #For each search_stream
			     foreach my $search_stream (@$search_streams)
			       {
				 foreach my $feat_orient (@$feat_orients)
				   {
				     ##Label column headers with search stream
				     ##and feature orientation

				     my $or = '';
				     #If there are multiple search streams or
				     #the search stream is not the default
				     #value, annotate the column header with
				     #the stream
				     if(scalar(@$search_streams) > 1 ||
				        $search_streams->[0] ne 'any')
				       {$or = "{$search_stream"}
				     #If a value was assigned above, append a
				     #feature orientation preceded by a comma
				     #and followed by a closing curly
				     if($or ne '')
				       {
					 if(scalar(@$feat_orients) > 1 ||
					    $feat_orients->[0] ne 'any')
					   {$or .= ",$feat_orient}"}
					 else
					   {$or .= "}"}
				       }
				     elsif(scalar(@$feat_orients) > 1 ||
					   $feat_orients->[0] ne 'any')
				       {$or = "{$feat_orient}"}

			     #Add 2 columns before the feature columns when
			     #there are multiple samples in the data
			     if($multiple_samples)
			       {$map_result = "NumSamples$c$or\t" .
				  "SumDistances$c$or\t"}

			     $map_result .=
			       #Note, if no samples were indicated, it is
			       #assumed that a sample name using a empty string
			       #is in the current sample hash
			       join("\t",
				    map
				    {
				      #Determine the sample prefix to the
				      #feature column headers
				      my $smpl = ($_ ? "Smpl-$_-" : "");

				      #Prepend a sample's feature distance
				      #column header before each sample's set
				      #of feature column headers
				      $smpl . "Distance$c$or\t$smpl" .
					join("$c$or\t$smpl",@feat_hdrs) .
					  "$c$or"
				    }
				    sort {$a cmp $b}
				    keys(%$current_sample_hash));

		                   }#foreach feat_orient
			       }#foreach search_stream

			     $map_result
			   } (0..$#data_start1_cols)),

		      "\n");

		$print_header = 0;
	      }

	    #Columns:
	    #datcol(1),datcol(2),... (there will be at least 1)
	    #Foreach set of coords $c in 1 row, there will be these columns...
	    #  If there are multiple samples
	    #    NumSamples$c ($c will be empty if there's only 1 coords set)
	    #    SumDistances$c
	    #  For each sample $s in the features, there will be these columns
	    #    Smpl-$s-FeatDist$c
	    #    For each feature out column $f in the feature data...
	    #      Smpl-$s-ftcol($f)$c
	    #Unfortunately, there will always be an empty column at the end
	    print("$data_out\t",

		  #Join together sets of columns associated with each set of
		  #coordinates in one row of the input file we're using as
		  #search coordinates
		  join("\t",
		       map
		       {
			 my $n          = $_; #Index into data_start1_cols
			 my @map_result = ();

			 #For each search_stream
			 foreach my $search_stream (@$search_streams)
			   {
			     foreach my $feat_orient (@$feat_orients)
			       {
			 #If there are multiple samples, push on the number of
			 #samples that have features close to the current data,
			 #along with the sum of the distances each sample's
			 #closest feature to the data coordinates.
			 #Calculate the sum distances
			 if($multiple_samples)
			   {
			     my $sum_distances1 = 0;
			     foreach my $sam
			       (keys(%{$closest_feature_hashes
					 ->{$search_stream}->{$feat_orient}
					   ->[$n]}))
				 {$sum_distances1 +=
				    $closest_feature_hashes->{$search_stream}
				      ->{$feat_orient}->[$n]->{$sam}
					->{DISTANCE}}
			     push(@map_result,
			       (scalar(keys(%{$closest_feature_hashes
						->{$search_stream}
						  ->{$feat_orient}->[$n]})),
				$sum_distances1));
			   }

			 push(@map_result,
			 (#Grab all the feature data for each sample
			  #Note, if no samples were indicated, it is
			  #assumed that a sample name using a empty
			  #string is in the current sample hash
			  map
			  {
			    my $s   = $_; #This ia a sample ID
			    my @ret = (); #This is the array we'll return

			    #If there is not a closest feature
			    if(!exists($closest_feature_hashes
				       ->{$search_stream}->{$feat_orient}->[$n]
				       ->{$s}))
			      {
				#If feature out columns were provided, tack
				#on empty values as place holders after the
				#empty column reserved for the feature distance
				if(scalar(@feat_out_cols))
				  {@ret = ('',map {''} @feat_out_cols)}
				#Else tack on empty values for all the feature
				#columns
				else
				  {
				    #empty value for the feature distance
				    @ret = ('');
				    foreach(1..$max_feat_cols
					    ->{$current_feature_file})
				      {push(@ret,'')}
				  }
			      }
			    else
			      {
				#Return a list.  Note, we do not need to
				#include the sequence ID because it has to be
				#the same as the input data's sequence ID
				@ret =
				  ($closest_feature_hashes->{$search_stream}
				   ->{$feat_orient}->[$n]->{$s}
				   ->{DISTANCE});

				#Append out cols
				push(@ret,
				     $closest_feature_hashes->{$search_stream}
				     ->{$feat_orient}->[$n]->{$s}->{COMB});
			      }

			    #The array returned
			    @ret
			  }
			  sort {$a cmp $b}
			  keys(%$current_sample_hash)));
		               }#foreach feat_orient
			   }#foreach search_stream

			 #The array returned
			 @map_result
		       } (0..$#data_start1_cols)),
		  "\n");
	  }

	close(INPUT);

	verbose('[',($input_file eq '-' ? $outfile_stub : $input_file),'] ',
		'Input file done.  Time taken: [',scalar(markTime()),
		' Seconds].');

	#If an output file name suffix is set
	if(defined($outfile_suffix))
	  {
	    #Select standard out
	    select(STDOUT);
	    #Close the output file handle
	    close(OUTPUT);

	    verbose("[$current_output_file] Output file done.");
	  }
      }
  }











verbose("[STDOUT] Output done.") if(!defined($outfile_suffix));

#Report the number of errors, warnings, and debugs on STDERR
if(!$quiet && ($verbose                     ||
	       $DEBUG                       ||
	       defined($main::error_number) ||
	       defined($main::warning_number)))
  {
    print STDERR ("\n",'Done.  EXIT STATUS: [',
		  'ERRORS: ',
		  ($main::error_number ? $main::error_number : 0),' ',
		  'WARNINGS: ',
		  ($main::warning_number ? $main::warning_number : 0),
		  ($DEBUG ?
		   ' DEBUGS: ' .
		   ($main::debug_number ? $main::debug_number : 0) : ''),' ',
		  'TIME: ',scalar(markTime(0)),"s]\n");

    if($main::error_number || $main::warning_number)
      {print STDERR ("Scroll up to inspect errors and warnings.\n")}
  }

##
## End Main
##






























##
## Subroutines
##

##
## This subroutine prints a description of the script and it's input and output
## files.
##
sub help
  {
    my $script = $0;
    my $lmd = localtime((stat($script))[9]);
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #$software_version_number  - global
    #$created_on_date          - global
    $created_on_date = 'UNKNOWN' if($created_on_date eq 'DATE HERE');

    #Print a description of this program
    print << "end_print";

$script version $software_version_number
Copyright 2008
Robert W. Leach
Created: $created_on_date
Last Modified: $lmd
Center for Computational Research
701 Ellicott Street
Buffalo, NY 14203
rwleach\@ccr.buffalo.edu

* WHAT IS THIS: This script takes an input data file with chromosomal
                coordinates and a feature file also with chromosomal
                coordinates (and optional sample IDs) and reports the closest
                feature to each pair of input coordinates.  Both the input file
                and feature file are optionally allowed to have multiple pairs
                of coordinates (e.g. structural variant coordinates that
                have been narrowed down to a region identifying a breakpoint).
                Breakpoints come in pairs, hence multiple allowed regions.  You
                can either input the structural variants as the feature file or
                input data file.  The input data file coordinates will be
                output with the closest feature to each region.  Sample
                information is only used in the feature file to report how many
                samples have structural variant breakpoints near the input
                coordinate pairs.

* INPUT FORMAT: Tab-delimited text file.

* FEATURE FILE FORMAT: Tab-delimited text file.

* OUTPUT FORMAT: Tab-delimited text file.  Columns from the input data file and
                 feature file are all reported in the same order unless
                 otherwise specified by the -m or -w options respectively.
                 Intervening columns indicating feature distances of closest
                 features among samples are reported.  If -u, -d, -v, or -t are
                 supplied, the feature column set specified by -w and
                 associated intervening columns are multiplied.  See column
                 headers to know which columns contain features associated to
                 which samples, regions, and orientations.  Column headers in
                 the input files will be re-used if they can be identified.
                 Otherwise, columns from the input data files will have headers
                 formatted as 'datcol(#)' and columns from the feature file
                 will be formatted as 'ftcol(#)' where '#' indicates column
                 number from the original input/feature file.  Here is an
                 example of a full column header and what it means:

                 Smpl-abc-ftcol(2)[1]{over,opp}

                 This column contains features that were part of sample "abc"
                 (the string "abc" was parsed from a sample column in the
                 feature file).  This is column 2 from the feature file.  It
                 contains features that were found close to the first
                 chr/start/stop in the input data file.  It also only contains
                 features that overlap the input data coordinates on the
                 opposite strand.

* ADVANCED FILE I/O FEATURES: Sets of input files, each with different output
                              directories can be supplied.  Supply each file
                              set with an additional -i (or --data-file) flag.
                              The files will have to have quotes around them so
                              that they are all associated with the preceding
                              -i option.  Likewise, output directories
                              (--outdir) can be supplied multiple times in the
                              same order so that each input file set can be
                              output into a different directory.  If the number
                              of files in each set is the same, you can supply
                              all output directories as a single set instead of
                              each having a separate --outdir flag.  Here are
                              some examples of what you can do:

                              -i 'a b c' --outdir '1' -i 'd e f' --outdir '2'

                                 1/
                                   a
                                   b
                                   c
                                 2/
                                   d
                                   e
                                   f

                              -i 'a b c' -i 'd e f' --outdir '1 2 3'

                                 1/
                                   a
                                   d
                                 2/
                                   b
                                   e
                                 3/
                                   c
                                   f

                                 This is the default behavior if the number of
                                 sets and the number of files per set are all
                                 the same.  For example, this is what will
                                 happen:

                                    -i 'a b' -i 'd e' --outdir '1 2'

                                       1/
                                         a
                                         d
                                       2/
                                         b
                                         e

                                 NOT this: 1/a,b 2/d,e  To do this, you must
                                 supply the --outdir flag for each set, like
                                 this:

                                    -i 'a b' -i 'd e' --outdir '1' --outdir '2'

                              -i 'a b c' -i 'd e f' --outdir '1 2'

                                 1/
                                   a
                                   b
                                   c
                                 2/
                                   d
                                   e
                                   f

                              -i 'a b c' --outdir '1 2 3' -i 'd e f' --outdir '4 5 6'

                                 1/
                                   a
                                 2/
                                   b
                                 3/
                                   c
                                 4/
                                   d
                                 5/
                                   e
                                 6/
                                   f

end_print

    return(0);
  }

##
## This subroutine prints a usage statement in long or short form depending on
## whether "no descriptions" is true.
##
sub usage
  {
    my $no_descriptions = $_[0];

    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Grab the first version of each option from the global GetOptHash
    my $options = '[' .
      join('] [',
	   grep {$_ ne '-i'}           #Remove REQUIRED params
	   map {my $key=$_;            #Save the key
		$key=~s/\|.*//;        #Remove other versions
		$key=~s/(\!|=.|:.)$//; #Remove trailing getopt stuff
		$key = (length($key) > 1 ? '--' : '-') . $key;} #Add dashes
	   grep {$_ ne '<>'}           #Remove the no-flag parameters
	   keys(%$GetOptHash)) .
	     ']';

    print << "end_print";
USAGE: $script -i "input file(s)" $options
       $script $options < input_file
end_print

    if($no_descriptions)
      {print("`$script` for expanded usage.\n")}
    else
      {
        print << 'end_print';

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
                                   coordinates and report features found there.
                                   Default behavior is to search upstream,
                                   downstream, and overlap and report the
                                   single closest feature (or multiple
                                   equidistant features).  Requires -p.
     -d|--search-         OPTIONAL [Off] Search downstream of the input data
        downstream                 coordinates and report features found there.
                                   Default behavior is to search upstream,
                                   downstream, and overlap and report the
                                   single closest feature (or multiple
                                   equidistant features).  Requires -p.
     -v|--search-overlap  OPTIONAL [Off] Search for overlap of the input data
                                   coordinates and report features found there.
                                   Default behavior is to search upstream,
                                   downstream, and overlap and report the
                                   single closest feature (or multiple
                                   equidistant features).
     -t|--feat-           OPTIONAL [any] {any,plus,minus,+,-,same,opposite,
        orientation                away,toward,upstream,downstream} Report
                                   features in the supplied orientation.
                                   Default behavior is to report the closest
                                   feature in any orientation and does not
                                   require -p or -n.  Plus, minus, +, and - do
                                   not require -p, but require -n.
                                   Orientations relative to the input data
                                   coordinates (same, opposite, away, toward,
                                   upstream,downstream) require -p and -n.
                                   "Away" (same as "upstream") means that the
                                   feature's upstream region is closest to the
                                   input data coordinates.  "Toward" (same as
                                   "downstream") means that the feature's
                                   downstream region is closest.  If there is
                                   any overlap, the feature is not considered
                                   either 'away' or 'toward'.  You may supply
                                   multiple orientations separated by non-
                                   alphanumeric (alphanumeric includes '_')
                                   characters.  Each orientation will cause
                                   multuple sets of feature columns (specified
                                   by -w) to be reported.  This is compounded
                                   by the multiple column sets generated by -u,
                                   -d, and -v.
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
end_print
      }

    return(0);
  }


##
## Subroutine that prints formatted verbose messages.  Specifying a 1 as the
## first argument prints the message in overwrite mode (meaning subsequence
## verbose, error, warning, or debug messages will overwrite the message
## printed here.  However, specifying a hard return as the first character will
## override the status of the last line printed and keep it.  Global variables
## keep track of print length so that previous lines can be cleanly
## overwritten.
##
sub verbose
  {
    return(0) unless($verbose);

    #Read in the first argument and determine whether it's part of the message
    #or a value for the overwrite flag
    my $overwrite_flag = $_[0];

    #If a flag was supplied as the first parameter (indicated by a 0 or 1 and
    #more than 1 parameter sent in)
    if(scalar(@_) > 1 && ($overwrite_flag eq '0' || $overwrite_flag eq '1'))
      {shift(@_)}
    else
      {$overwrite_flag = 0}

#    #Ignore the overwrite flag if STDOUT will be mixed in
#    $overwrite_flag = 0 if(isStandardOutputToTerminal());

    #Read in the message
    my $verbose_message = join('',grep {defined($_)} @_);

    $overwrite_flag = 1 if(!$overwrite_flag && $verbose_message =~ /\r/);

    #Initialize globals if not done already
    $main::last_verbose_size  = 0 if(!defined($main::last_verbose_size));
    $main::last_verbose_state = 0 if(!defined($main::last_verbose_state));
    $main::verbose_warning    = 0 if(!defined($main::verbose_warning));

    #Determine the message length
    my($verbose_length);
    if($overwrite_flag)
      {
	$verbose_message =~ s/\r$//;
	if(!$main::verbose_warning && $verbose_message =~ /\n|\t/)
	  {
	    warning('Hard returns and tabs cause overwrite mode to not work ',
		    'properly.');
	    $main::verbose_warning = 1;
	  }
      }
    else
      {chomp($verbose_message)}

    #If this message is not going to be over-written (i.e. we will be printing
    #a \n after this verbose message), we can reset verbose_length to 0 which
    #will cause $main::last_verbose_size to be 0 the next time this is called
    if(!$overwrite_flag)
      {$verbose_length = 0}
    #If there were \r's in the verbose message submitted (after the last \n)
    #Calculate the verbose length as the largest \r-split string
    elsif($verbose_message =~ /\r[^\n]*$/)
      {
	my $tmp_message = $verbose_message;
	$tmp_message =~ s/.*\n//;
	($verbose_length) = sort {length($b) <=> length($a)}
	  split(/\r/,$tmp_message);
      }
    #Otherwise, the verbose_length is the size of the string after the last \n
    elsif($verbose_message =~ /([^\n]*)$/)
      {$verbose_length = length($1)}

    #If the buffer is not being flushed, the verbose output doesn't start with
    #a \n, and output is to the terminal, make sure we don't over-write any
    #STDOUT output
    #NOTE: This will not clean up verbose output over which STDOUT was written.
    #It will only ensure verbose output does not over-write STDOUT output
    #NOTE: This will also break up STDOUT output that would otherwise be on one
    #line, but it's better than over-writing STDOUT output.  If STDOUT is going
    #to the terminal, it's best to turn verbose off.
    if(!$| && $verbose_message !~ /^\n/ && isStandardOutputToTerminal())
      {
	#The number of characters since the last flush (i.e. since the last \n)
	#is the current cursor position minus the cursor position after the
	#last flush (thwarted if user prints \r's in STDOUT)
	#NOTE:
	#  tell(STDOUT) = current cursor position
	#  sysseek(STDOUT,0,1) = cursor position after last flush (or undef)
	my $num_chars = sysseek(STDOUT,0,1);
	if(defined($num_chars))
	  {$num_chars = tell(STDOUT) - $num_chars}
	else
	  {$num_chars = 0}

	#If there have been characters printed since the last \n, prepend a \n
	#to the verbose message so that we do not over-write the user's STDOUT
	#output
	if($num_chars > 0)
	  {$verbose_message = "\n$verbose_message"}
      }

    #Overwrite the previous verbose message by appending spaces just before the
    #first hard return in the verbose message IF THE VERBOSE MESSAGE DOESN'T
    #BEGIN WITH A HARD RETURN.  However note that the length stored as the
    #last_verbose_size is the length of the last line printed in this message.
    if($verbose_message =~ /^([^\n]*)/ && $main::last_verbose_state &&
       $verbose_message !~ /^\n/)
      {
	my $append = ' ' x ($main::last_verbose_size - length($1));
	unless($verbose_message =~ s/\n/$append\n/)
	  {$verbose_message .= $append}
      }

    #If you don't want to overwrite the last verbose message in a series of
    #overwritten verbose messages, you can begin your verbose message with a
    #hard return.  This tells verbose() to not overwrite the last line that was
    #printed in overwrite mode.

    #Print the message to standard error
    print STDERR ($verbose_message,
		  ($overwrite_flag ? "\r" : "\n"));

    #Record the state
    $main::last_verbose_size  = $verbose_length;
    $main::last_verbose_state = $overwrite_flag;

    #Return success
    return(0);
  }

sub verboseOverMe
  {verbose(1,@_)}

##
## Subroutine that prints errors with a leading program identifier containing a
## trace route back to main to see where all the subroutine calls were from,
## the line number of each call, an error number, and the name of the script
## which generated the error (in case scripts are called via a system call).
##
sub error
  {
    return(0) if($quiet);

    #Gather and concatenate the error message and split on hard returns
    my @error_message = split(/\n/,join('',grep {defined($_)} @_));
    push(@error_message,'') unless(scalar(@error_message));
    pop(@error_message) if(scalar(@error_message) > 1 &&
			   $error_message[-1] !~ /\S/);

    $main::error_number++;
    my $leader_string = "ERROR$main::error_number:";

    #Assign the values from the calling subroutines/main
    my(@caller_info,$line_num,$caller_string,$stack_level,$script);
    if($DEBUG)
      {
	$script = $0;
	$script =~ s/^.*\/([^\/]+)$/$1/;
	@caller_info = caller(0);
	$line_num = $caller_info[2];
	$caller_string = '';
	$stack_level = 1;
	while(@caller_info = caller($stack_level))
	  {
	    my $calling_sub = $caller_info[3];
	    $calling_sub =~ s/^.*?::(.+)$/$1/ if(defined($calling_sub));
	    $calling_sub = (defined($calling_sub) ? $calling_sub : 'MAIN');
	    $caller_string .= "$calling_sub(LINE$line_num):"
	      if(defined($line_num));
	    $line_num = $caller_info[2];
	    $stack_level++;
	  }
	$caller_string .= "MAIN(LINE$line_num):";
	$leader_string .= "$script:$caller_string";
      }

    $leader_string .= ' ';

    #Figure out the length of the first line of the error
    my $error_length = length(($error_message[0] =~ /\S/ ?
			       $leader_string : '') .
			      $error_message[0]);

    #Put location information at the beginning of the first line of the message
    #and indent each subsequent line by the length of the leader string
    print STDERR ($leader_string,
		  shift(@error_message),
		  ($verbose &&
		   defined($main::last_verbose_state) &&
		   $main::last_verbose_state ?
		   ' ' x ($main::last_verbose_size - $error_length) : ''),
		  "\n");
    my $leader_length = length($leader_string);
    foreach my $line (@error_message)
      {print STDERR (' ' x $leader_length,
		     $line,
		     "\n")}

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size  = 0;
	$main::last_verbose_state = 0;
      }

    #Return success
    return(0);
  }


##
## Subroutine that prints warnings with a leader string containing a warning
## number
##
sub warning
  {
    return(0) if($quiet);

    $main::warning_number++;

    #Gather and concatenate the warning message and split on hard returns
    my @warning_message = split(/\n/,join('',grep {defined($_)} @_));
    push(@warning_message,'') unless(scalar(@warning_message));
    pop(@warning_message) if(scalar(@warning_message) > 1 &&
			     $warning_message[-1] !~ /\S/);

    my $leader_string = "WARNING$main::warning_number:";

    #Assign the values from the calling subroutines/main
    my(@caller_info,$line_num,$caller_string,$stack_level,$script);
    if($DEBUG)
      {
	$script = $0;
	$script =~ s/^.*\/([^\/]+)$/$1/;
	@caller_info = caller(0);
	$line_num = $caller_info[2];
	$caller_string = '';
	$stack_level = 1;
	while(@caller_info = caller($stack_level))
	  {
	    my $calling_sub = $caller_info[3];
	    $calling_sub =~ s/^.*?::(.+)$/$1/ if(defined($calling_sub));
	    $calling_sub = (defined($calling_sub) ? $calling_sub : 'MAIN');
	    $caller_string .= "$calling_sub(LINE$line_num):"
	      if(defined($line_num));
	    $line_num = $caller_info[2];
	    $stack_level++;
	  }
	$caller_string .= "MAIN(LINE$line_num):";
	$leader_string .= "$script:$caller_string";
      }

    $leader_string .= ' ';

    #Figure out the length of the first line of the error
    my $warning_length = length(($warning_message[0] =~ /\S/ ?
				 $leader_string : '') .
				$warning_message[0]);

    #Put leader string at the beginning of each line of the message
    #and indent each subsequent line by the length of the leader string
    print STDERR ($leader_string,
		  shift(@warning_message),
		  ($verbose &&
		   defined($main::last_verbose_state) &&
		   $main::last_verbose_state ?
		   ' ' x ($main::last_verbose_size - $warning_length) : ''),
		  "\n");
    my $leader_length = length($leader_string);
    foreach my $line (@warning_message)
      {print STDERR (' ' x $leader_length,
		     $line,
		     "\n")}

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size  = 0;
	$main::last_verbose_state = 0;
      }

    #Return success
    return(0);
  }


##
## Subroutine that gets a line of input and accounts for carriage returns that
## many different platforms use instead of hard returns.  Note, it uses a
## global array reference variable ($infile_line_buffer) to keep track of
## buffered lines from multiple file handles.
##
sub getLine
  {
    my $file_handle = $_[0];

    #Set a global array variable if not already set
    $main::infile_line_buffer = {} if(!defined($main::infile_line_buffer));
    if(!exists($main::infile_line_buffer->{$file_handle}))
      {$main::infile_line_buffer->{$file_handle}->{FILE} = []}

    #If this sub was called in array context
    if(wantarray)
      {
	#Check to see if this file handle has anything remaining in its buffer
	#and if so return it with the rest
	if(scalar(@{$main::infile_line_buffer->{$file_handle}->{FILE}}) > 0)
	  {
	    return(@{$main::infile_line_buffer->{$file_handle}->{FILE}},
		   map
		   {
		     #If carriage returns were substituted and we haven't
		     #already issued a carriage return warning for this file
		     #handle
		     if(s/\r\n|\n\r|\r/\n/g &&
			!exists($main::infile_line_buffer->{$file_handle}
				->{WARNED}))
		       {
			 $main::infile_line_buffer->{$file_handle}->{WARNED}
			   = 1;
			 warning('Carriage returns were found in your file ',
				 'and replaced with hard returns.');
		       }
		     split(/(?<=\n)/,$_);
		   } <$file_handle>);
	  }
	
	#Otherwise return everything else
	return(map
	       {
		 #If carriage returns were substituted and we haven't already
		 #issued a carriage return warning for this file handle
		 if(s/\r\n|\n\r|\r/\n/g &&
		    !exists($main::infile_line_buffer->{$file_handle}
			    ->{WARNED}))
		   {
		     $main::infile_line_buffer->{$file_handle}->{WARNED}
		       = 1;
		     warning('Carriage returns were found in your file ',
			     'and replaced with hard returns.');
		   }
		 split(/(?<=\n)/,$_);
	       } <$file_handle>);
      }

    #If the file handle's buffer is empty, put more on
    if(scalar(@{$main::infile_line_buffer->{$file_handle}->{FILE}}) == 0)
      {
	my $line = <$file_handle>;
	#The following is to deal with files that have the eof character at the
	#end of the last line.  I may not have it completely right yet.
	if(defined($line))
	  {
	    if($line =~ s/\r\n|\n\r|\r/\n/g &&
	       !exists($main::infile_line_buffer->{$file_handle}->{WARNED}))
	      {
		$main::infile_line_buffer->{$file_handle}->{WARNED} = 1;
		warning('Carriage returns were found in your file and ',
			'replaced with hard returns.');
	      }
	    @{$main::infile_line_buffer->{$file_handle}->{FILE}} =
	      split(/(?<=\n)/,$line);
	  }
	else
	  {@{$main::infile_line_buffer->{$file_handle}->{FILE}} = ($line)}
      }

    #Shift off and return the first thing in the buffer for this file handle
    return($_ = shift(@{$main::infile_line_buffer->{$file_handle}->{FILE}}));
  }

##
## This subroutine allows the user to print debug messages containing the line
## of code where the debug print came from and a debug number.  Debug prints
## will only be printed (to STDERR) if the debug option is supplied on the
## command line.
##
sub debug
  {
    return(0) unless($DEBUG);

    $main::debug_number++;

    #Gather and concatenate the error message and split on hard returns
    my @debug_message = split(/\n/,join('',grep {defined($_)} @_));
    push(@debug_message,'') unless(scalar(@debug_message));
    pop(@debug_message) if(scalar(@debug_message) > 1 &&
			   $debug_message[-1] !~ /\S/);

    #Assign the values from the calling subroutine
    #but if called from main, assign the values from main
    my($junk1,$junk2,$line_num,$calling_sub);
    (($junk1,$junk2,$line_num,$calling_sub) = caller(1)) ||
      (($junk1,$junk2,$line_num) = caller());

    #Edit the calling subroutine string
    $calling_sub =~ s/^.*?::(.+)$/$1:/ if(defined($calling_sub));

    my $leader_string = "DEBUG$main::debug_number:LINE$line_num:" .
      (defined($calling_sub) ? $calling_sub : '') .
	' ';

    #Figure out the length of the first line of the error
    my $debug_length = length(($debug_message[0] =~ /\S/ ?
			       $leader_string : '') .
			      $debug_message[0]);

    #Put location information at the beginning of each line of the message
    print STDERR ($leader_string,
		  shift(@debug_message),
		  ($verbose &&
		   defined($main::last_verbose_state) &&
		   $main::last_verbose_state ?
		   ' ' x ($main::last_verbose_size - $debug_length) : ''),
		  "\n");
    my $leader_length = length($leader_string);
    foreach my $line (@debug_message)
      {print STDERR (' ' x $leader_length,
		     $line,
		     "\n")}

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size = 0;
	$main::last_verbose_state = 0;
      }

    #Return success
    return(0);
  }


##
## This sub marks the time (which it pushes onto an array) and in scalar
## context returns the time since the last mark by default or supplied mark
## (optional) In array context, the time between all marks is always returned
## regardless of a supplied mark index
## A mark is not made if a mark index is supplied
## Uses a global time_marks array reference
##
sub markTime
  {
    #Record the time
    my $time = time();

    #Set a global array variable if not already set to contain (as the first
    #element) the time the program started (NOTE: "$^T" is a perl variable that
    #contains the start time of the script)
    $main::time_marks = [$^T] if(!defined($main::time_marks));

    #Read in the time mark index or set the default value
    my $mark_index = (defined($_[0]) ? $_[0] : -1);  #Optional Default: -1

    #Error check the time mark index sent in
    if($mark_index > (scalar(@$main::time_marks) - 1))
      {
	error('Supplied time mark index is larger than the size of the ',
	      "time_marks array.\nThe last mark will be set.");
	$mark_index = -1;
      }

    #Calculate the time since the time recorded at the time mark index
    my $time_since_mark = $time - $main::time_marks->[$mark_index];

    #Add the current time to the time marks array
    push(@$main::time_marks,$time)
      if(!defined($_[0]) || scalar(@$main::time_marks) == 0);

    #If called in array context, return time between all marks
    if(wantarray)
      {
	if(scalar(@$main::time_marks) > 1)
	  {return(map {$main::time_marks->[$_ - 1] - $main::time_marks->[$_]}
		  (1..(scalar(@$main::time_marks) - 1)))}
	else
	  {return(())}
      }

    #Return the time since the time recorded at the supplied time mark index
    return($time_since_mark);
  }

##
## This subroutine reconstructs the command entered on the command line
## (excluding standard input and output redirects).  The intended use for this
## subroutine is for when a user wants the output to contain the input command
## parameters in order to keep track of what parameters go with which output
## files.
##
sub getCommand
  {
    my $perl_path_flag = $_[0];
    my($command);

    #Determine the script name
    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Put quotes around any parameters containing un-escaped spaces or astericks
    my $arguments = [@$preserve_args];
    foreach my $arg (@$arguments)
      {if($arg =~ /(?<!\\)[\s\*]/ || $arg eq '')
	 {$arg = "'" . $arg . "'"}}

    #Determine the perl path used (dependent on the `which` unix built-in)
    if($perl_path_flag)
      {
	$command = `which $^X`;
	chomp($command);
	$command .= ' ';
      }

    #Build the original command
    $command .= join(' ',($0,@$arguments));

    #Note, this sub doesn't add any redirected files in or out

    return($command);
  }

##
## This subroutine checks for files with spaces in the name before doing a glob
## (which breaks up the single file name improperly even if the spaces are
## escaped).  The purpose is to allow the user to enter input files using
## double quotes and un-escaped spaces as is expected to work with many
## programs which accept individual files as opposed to sets of files.  If the
## user wants to enter multiple files, it is assumed that space delimiting will
## prompt the user to realize they need to escape the spaces in the file names.
## Note, this will not work on sets of files containing a mix of spaces and
## glob characters.
##
sub sglob
  {
    my $command_line_string = $_[0];
    unless(defined($command_line_string))
      {
	warning("Undefined command line string encountered.");
	return($command_line_string);
      }
    return(#If matches unescaped spaces
	   $command_line_string =~ /(?!\\)\s+/ &&
	   #And all separated args are files
	   scalar(@{[bsd_glob($command_line_string)]}) ==
	   scalar(@{[grep {-e $_} bsd_glob($command_line_string)]}) ?
	   #Return the glob array
	   bsd_glob($command_line_string) :
	   #If it's a series of all files with escaped spaces
	   (scalar(@{[split(/(?!\\)\s/,$command_line_string)]}) ==
	    scalar(@{[grep {-e $_} split(/(?!\\)\s+/,$command_line_string)]}) ?
	    split(/(?!\\)\s+/,$command_line_string) :
	    #Return the single arg
	    ($command_line_string =~ /\*|\?|\[/ ?
	     bsd_glob($command_line_string) : $command_line_string)));
  }


sub getVersion
  {
    my $full_version_flag = $_[0];
    my $template_version_number = '1.43';
    my $version_message = '';

    #$software_version_number  - global
    #$created_on_date          - global
    #$verbose                  - global

    my $script = $0;
    my $lmd = localtime((stat($script))[9]);
    $script =~ s/^.*\/([^\/]+)$/$1/;

    if($created_on_date eq 'DATE HERE')
      {$created_on_date = 'UNKNOWN'}

    $version_message  = '#' . join("\n#",
				   ("$script Version $software_version_number",
				    " Created: $created_on_date",
				    " Last modified: $lmd"));

    if($full_version_flag)
      {
	$version_message .= "\n#" .
	  join("\n#",
	       ('Generated using perl_script_template.pl ' .
		"Version $template_version_number",
		' Created: 5/8/2006',
		' Author:  Robert W. Leach',
		' Contact: rwleach@ccr.buffalo.edu',
		' Company: Center for Computational Research',
		' Copyright 2008'));
      }

    return($version_message);
  }

#This subroutine is a check to see if input is user-entered via a TTY (result
#is non-zero) or directed in (result is zero)
sub isStandardInputFromTerminal
  {return(-t STDIN || eof(STDIN))}

#This subroutine is a check to see if prints are going to a TTY.  Note,
#explicit prints to STDOUT when another output handle is selected are not
#considered and may defeat this subroutine.
sub isStandardOutputToTerminal
  {return(-t STDOUT && select() eq 'main::STDOUT')}

#This subroutine exits the current process.  Note, you must clean up after
#yourself before calling this.  Does not exit is $ignore_errors is true.  Takes
#the error number to supply to exit().
sub quit
  {
    my $errno = $_[0];
    if(!defined($errno))
      {$errno = -1}
    elsif($errno !~ /^[+\-]?\d+$/)
      {
	error("Invalid argument: [$errno].  Only integers are accepted.  Use ",
	      "error() or warn() to supply a message, then call quit() with ",
	      "an error number.");
	$errno = -1;
      }

    debug("Exit status: [$errno].");

    exit($errno) if(!$ignore_errors || $errno == 0);
  }

#Assumes all starts and stops (data and features) are sorted numerically.
#This means that upstream and downstream cannot be determined.
sub getClosestFeature
  {
    my $chr1                   = $_[0];
    my $start1                 = $_[1];
    my $stop1                  = $_[2];
    my $strand                 = $_[3];
    my $features               = $_[4];
    my $num_samples            = scalar(keys(%{$_[5]}));
    my $search_range           = $_[6];
    my $search_stream          = $_[7]; #any,up,down,over
    my $feat_orient            = $_[8]; #+,-,same,opp,away,toward

    my $closest_feat           = {};
    my $closest_distance       = {};
    my $closest_feat_left      = {};
    my $closest_feat_right     = {};
    my $closest_distance_left  = {};
    my $closest_distance_right = {};







    #Make sure chromosome naming conventions are the same between the files
    my $num_inspected = scalar(grep {$_->{CHR1} eq $chr1} @$features);
    unless($num_inspected)
      {warning("None of the supplied [",scalar(@$features),"] features were ",
	       "inspected for sequence: [$chr1].  Please check to make sure ",
	       "that the sequence ID naming styles are the same between your ",
	       "feature file and input file.",
	       (scalar(@$features) ? "  Here is an example of one of the " .
		"feature sequence IDs supplied: [$features->[0]->{CHR1}]." :
		''))}

    #Note: It is assumed that features are sorted on the start1 coordinate and
    #that that start1 coordinate is always less than the stop1 coordinate)
    foreach my $feat (grep {(#The feature is on the same chromosome
			     $_->{CHR1} eq $chr1 &&
			     (#There is no limit to the search range
			      $search_range == -1 ||
			      #start1 is within the search range of the feature
			      abs($start1-$_->{STOP1})  <= $search_range ||
			      abs($start1-$_->{START1}) <= $search_range ||
			      #stop1 is within the search range of the feature
			      abs($stop1-$_->{STOP1})   <= $search_range ||
			      abs($stop1-$_->{START1})  <= $search_range ||
			      #The start1 is inside the feature
			      ($start1 >= $_->{START1} &&
			       $start1 <= $_->{STOP1}) ||
			      #The stop1 is inside the feature
			      ($stop1 >= $_->{START1} &&
			       $stop1 <= $_->{STOP1}) ||
			      #The start1 and stop1 encompass the feature
			      ($start1 <= $_->{START1} &&
			       $stop1 >= $_->{STOP1})))}
		      @$features)
      {
	$num_inspected++;
	debug("Inspecting [$chr1 $start1 $stop1] with [$feat->{CHR1} ",
	      "$feat->{START1} $feat->{STOP1}].")
	  if($DEBUG > 1);

	if(($feat_orient eq 'same' && $feat->{STRAND} ne $strand) ||
	   ($feat_orient eq 'opp'  && $feat->{STRAND} eq $strand))
	  {debug();next}
	elsif(($feat_orient eq '+' && $feat->{STRAND} ne '+') ||
	      ($feat_orient eq '-' && $feat->{STRAND} ne '-'))
	  {debug();next}
	elsif($search_stream ne 'any')
	  {
	    #Overlap
	    if($search_stream eq 'over' &&
	       !(($feat->{START1} >= $start1 && $feat->{START1} <= $stop1) ||
		 ($feat->{STOP1} >= $start1 && $feat->{STOP1} <= $stop1) ||
		 ($feat->{START1} < $start1 && $feat->{STOP1} > $stop1)))
	      {debug();next}
	    #Upstream/downstream
	    elsif($search_stream eq 'up' || $search_stream eq 'down')
	      {
		if($strand eq '+')
		  {
		    if($search_stream eq 'up' && $feat->{STOP1} >= $start1)
		      {debug();next}
		    elsif($search_stream eq 'down' &&
			  $feat->{START1} <= $stop1)
		      {debug();next}
		  }
		elsif($strand eq '-')
		  {
		    if($search_stream eq 'down' && $feat->{STOP1} >= $start1)
		      {debug();next}
		    elsif($search_stream eq 'up' && $feat->{START1} <= $stop1)
		      {debug();next}
		  }
		else
		  {
		    error("Invalid strand value: [$strand].");
		    next;
		  }
	      }
	  }

	#Away/toward
	my $side = $feat->{START1} < $start1 ? 'left' : 'right';
	if($feat_orient eq 'away')
	  {
	    #If there's overlap, it's not 'away'
	    if((($feat->{START1} >= $start1 && $feat->{START1} <= $stop1) ||
		($feat->{STOP1} >= $start1 && $feat->{STOP1} <= $stop1) ||
		($feat->{START1} < $start1 && $feat->{STOP1} > $stop1)))
	      {debug();next}

	    #Away: (side = left && feat strand = -) OR
	    #      (side = right && feat strand = +)
	    if(($feat->{STRAND} eq '+' && $side eq 'left') ||
	       ($feat->{STRAND} eq '-' && $side eq 'right'))
	      {debug();next}
	  }
	elsif($feat_orient eq 'toward')
	  {
	    #If there's overlap, it's not 'toward'
	    if((($feat->{START1} >= $start1 && $feat->{START1} <= $stop1) ||
		($feat->{STOP1} >= $start1 && $feat->{STOP1} <= $stop1) ||
		($feat->{START1} < $start1 && $feat->{STOP1} > $stop1)))
	      {debug();next}

	    #Toward: (side = left && feat strand = +) OR
	    #        (side = right && feat strand = -)

	    if(($feat->{STRAND} eq '+' && $side eq 'right') ||
	       ($feat->{STRAND} eq '-' && $side eq 'left'))
	      {debug();next}
	  }

	debug("Inspecting: $search_stream,$feat_orient\nDATA: $chr1,$start1,$stop1,$strand\nFEAT: $feat->{CHR1},$feat->{START1},$feat->{STOP1},$feat->{STRAND}");

	#Strip any distances which have previously been added by previous calls
	if(exists($feat->{DISTANCE}))
	  {delete($feat->{DISTANCE})}
	if(exists($feat->{OTHERS}))
	  {delete($feat->{OTHERS})}

	#Handle overlap first
	if(#The start1 is inside the feature
	   ($start1 >= $feat->{START1} && $start1 <= $feat->{STOP1}) ||
	   #The stop1 is inside the feature
	   ($stop1 >= $feat->{START1} && $stop1 <= $feat->{STOP1}) ||
	   #The start1 and stop1 encompass the feature
	   ($start1 <= $feat->{START1} && $stop1 >= $feat->{STOP1}))
	  {
	    #See if there already exists a feature for this sample at this
	    #distance
	    if(exists($closest_feat->{$feat->{SAMPLE}}) &&
	       $closest_feat->{$feat->{SAMPLE}}->{DISTANCE} == 0)
	      {
		push(@{$closest_feat->{$feat->{SAMPLE}}->{OTHERS}},$feat);
		push(@{$closest_feat_left->{$feat->{SAMPLE}}->{OTHERS}},
		     $feat);
		push(@{$closest_feat_right->{$feat->{SAMPLE}}->{OTHERS}},
		     $feat);
	      }
	    else
	      {
		#Handle closest overall feature
		delete($closest_feat->{$feat->{SAMPLE}}->{OTHERS})
		  if(exists($closest_feat->{$feat->{SAMPLE}}) &&
		     exists($closest_feat->{$feat->{SAMPLE}}->{OTHERS}));
		$closest_feat->{$feat->{SAMPLE}} = copyFeature($feat);
		$closest_feat->{$feat->{SAMPLE}}->{DISTANCE} = 0;
		$closest_distance->{$feat->{SAMPLE}} = 0;

		#Handle closest feature to the left
		delete($closest_feat_left->{$feat->{SAMPLE}}->{OTHERS})
		  if(exists($closest_feat_left->{$feat->{SAMPLE}}) &&
		     exists($closest_feat_left->{$feat->{SAMPLE}}
			    ->{OTHERS}));
		$closest_feat_left->{$feat->{SAMPLE}} = copyFeature($feat);
		$closest_feat_left->{$feat->{SAMPLE}}->{DISTANCE} = 0;
		$closest_distance_left->{$feat->{SAMPLE}} = 0;

		#Handle closest feature to the right
		delete($closest_feat_right->{$feat->{SAMPLE}}->{OTHERS})
		  if(exists($closest_feat_right->{$feat->{SAMPLE}}) &&
		     exists($closest_feat_right->{$feat->{SAMPLE}}
			    ->{OTHERS}));
		$closest_feat_right->{$feat->{SAMPLE}} =
		  copyFeature($feat);
		$closest_feat_right->{$feat->{SAMPLE}}->{DISTANCE} = 0;
		$closest_distance_right->{$feat->{SAMPLE}} = 0;
	      }
	    debug("Feature Overlaps.") if($DEBUG > 1);;
	  }

	#Determine how far away this feature is (shortest distance)
	my $distance = (sort {$a <=> $b}
			(abs($start1 - $feat->{STOP1}),
			 abs($feat->{START1} - $stop1),
			 abs($start1 - $feat->{START1}),
			 abs($feat->{STOP1} - $stop1)))[0];

	debug("Feature is $distance away.") if($DEBUG > 1);
	#If either of the start or stop of the feature is less than the query start or stop, then it is "to the left", otherwise it's "to the
	#right".  This is beacause we handled overlap above and can ignore
	#that case.  After the loop, we will determine whether the feature
	#is "upstream" or "downstream" based on the order of the start and
	#stop coordinates.

	my $direction = $feat->{START1} < $start1 ? 'left' : 'right';

	if(!exists($closest_distance->{$feat->{SAMPLE}}) ||
	   $distance < $closest_distance->{$feat->{SAMPLE}})
	  {
	    $closest_distance->{$feat->{SAMPLE}} = $distance;
	    $closest_feat->{$feat->{SAMPLE}}     = copyFeature($feat);
	    $closest_feat->{$feat->{SAMPLE}}->{DISTANCE} = $distance;
	    delete($closest_feat->{$feat->{SAMPLE}}->{OTHERS})
	      if(exists($closest_feat->{$feat->{SAMPLE}}) &&
		 exists($closest_feat->{$feat->{SAMPLE}}->{OTHERS}));
	    debug("Feature is Closer.") if($DEBUG > 1);

	    #The closest-overall feature is handled above and below I handle the closest feature "to the left" (i.e. the coordinates of the feature are less than the coordinates of the query.  We can't handle the upstream/downstream issue because the start is always less than the stop in the 
	    if($direction eq 'left')
	      {
		$closest_distance_left->{$feat->{SAMPLE}} = $distance;
		$closest_feat_left->{$feat->{SAMPLE}}     =
		  copyFeature($feat);
		$closest_feat_left->{$feat->{SAMPLE}}->{DISTANCE} =
		  $distance;
		delete($closest_feat_left->{$feat->{SAMPLE}}->{OTHERS})
		  if(exists($closest_feat_left->{$feat->{SAMPLE}}) &&
		     exists($closest_feat_left->{$feat->{SAMPLE}}
			    ->{OTHERS}));
	      }
	    else
	      {
		$closest_distance_right->{$feat->{SAMPLE}} = $distance;
		$closest_feat_right->{$feat->{SAMPLE}}     =
		  copyFeature($feat);
		$closest_feat_right->{$feat->{SAMPLE}}->{DISTANCE} =
		  $distance;
		delete($closest_feat_right->{$feat->{SAMPLE}}->{OTHERS})
		  if(exists($closest_feat_right->{$feat->{SAMPLE}}) &&
		     exists($closest_feat_right->{$feat->{SAMPLE}}
			    ->{OTHERS}));
	      }
	  }
	elsif($distance == $closest_distance->{$feat->{SAMPLE}})
	  {
	    push(@{$closest_feat->{$feat->{SAMPLE}}->{OTHERS}},$feat);

	    if($direction eq 'left' &&
	       (!defined($closest_distance_left->{$feat->{SAMPLE}}) ||
		$distance == $closest_distance_left->{$feat->{SAMPLE}}))
	      {push(@{$closest_feat_left->{$feat->{SAMPLE}}->{OTHERS}},
		    $feat)}
	    elsif($direction eq 'right' &&
		  (!defined($closest_distance_right->{$feat->{SAMPLE}}) ||
		   $distance ==
		   $closest_distance_right->{$feat->{SAMPLE}}))
	      {push(@{$closest_feat_right->{$feat->{SAMPLE}}->{OTHERS}},
		    $feat)}
	  }
      }

    debug("Value of chr1: $chr1 start1: [$start1].");

    #Merge the outputs of equidistance features into a value in the hash keyed
    #on COMB
    foreach my $closest_hash ($closest_feat,$closest_feat_right,
			      $closest_feat_left)
      {
	foreach my $samp (keys(%{$closest_hash}))
	  {
	    my $fh  = $closest_feat->{$samp};
	    my $str = '';
	    my @vals = split(/\t/,$fh->{OUT},-1);
	    if(exists($fh->{OTHERS}) && scalar(@{$fh->{OTHERS}}))
	      {
		foreach my $fh2 (@{$fh->{OTHERS}})
		  {
		    my @newvals = split(/\t/,$fh2->{OUT},-1);
		    for(my $i = 0;$i < scalar(@vals);$i++)
		      {$vals[$i] .= ",$newvals[$i]"}
		  }
	      }
	    $fh->{COMB} = join("\t",@vals);
	  }
      }

#    warning("No valid features found for input coordinates [$chr1 $start1 ",
#	    "$stop1]!") if(scalar(keys(%$closest_feat)) == 0);

    return(wantarray ?
	   ($closest_feat_left,$closest_feat_right) :
	   $closest_feat);
  }

sub copyFeature
  {
    my $source = $_[0];
    my $copy   = {};

    foreach my $key (keys(%$source))
      {
	my $type = ref(\$source->{$key});
	if($type ne 'SCALAR')
	  {
	    error("A feature hash may only contain scalar values, but ",
		  "instead, the key [$key] contains a [$type].");
	    return({});
	  }
	$copy->{$key} = $source->{$key};
      }
    return($copy);
  }

sub segmentHash
  {
    my $magnitude = $_[0];
    my $feat_hash = $_[1]; #Actually an array of hashes

    debug("In segmentHash.");

    if($magnitude !~ /^[01]0*$/)
      {
	error("Invalid order of magnitude passed in: [$magnitude].");
	quit(1);
      }

    my $new_feat_hash = {};

    foreach my $feat (@$feat_hash)
      {
	my $region  = ($magnitude > 0 ? int($feat->{START1} / $magnitude) *
		       $magnitude : 0);
	push(@{$new_feat_hash->{$feat->{CHR1}}->{$region}},$feat);
      }

    return($new_feat_hash);
  }
