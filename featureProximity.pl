#!/usr/bin/perl -w

#Generated using perl_script_template.pl 1.43
#Robert W. Leach
#rwleach@ccr.buffalo.edu
#Center for Computational Research
#Copyright 2008

#These variables (in main) are used by getVersion() and usage()
my $software_version_number = '2.4';
my $created_on_date         = '11/2/2011';

##
## Start Main
##

use strict;
use Getopt::Long;
use File::Glob ':glob';

#Declare & initialize variables.  Provide default values here.
my($outfile_suffix); #Not defined so input can be overwritten
my @input_files            = ();
my @feature_files          = ();
my @outdirs                = ();
my $current_output_file    = '';
my $help                   = 0;
my $version                = 0;
my $overwrite              = 0;
my $noheader               = 0;
my $feat_sample_col        = 0; #1
my @feat_chr1_cols         = (); #2
my @feat_start1_cols       = (); #19
my @feat_end1_cols         = (); #19
#my $feat_chr2_col       = 0; #4
#my $feat_start2_col     = 0; #20
#my $feat_end2_col       = 0; #20
my @feat_id_cols           = (); #2,3,4,5,6
my @feat_comment_cols      = ();
my @data_chr1_cols         = (); #1
my @data_start1_cols       = (); #2
my @data_end1_cols         = (); #3
#my @data_chr2_col       = 0;
#my @data_start2_col     = 0;
#my @data_end2_col       = 0;
my @data_id_cols           = (); #4
my @data_comment_cols      = ();
my $id_delimiter           = '.';
my $data_comment_delimiter = "\t";
my $feat_comment_delimiter = "\t";
my $search_range           = -1;

#These variables (in main) are used by the following subroutines:
#verbose, error, warning, debug, getCommand, quit, and usage
my $preserve_args = [@ARGV];  #Preserve the agruments for getCommand
my $verbose       = 0;
my $quiet         = 0;
my $DEBUG         = 0;
my $ignore_errors = 0;

my $GetOptHash =
  {'i|data-file|input-file=s' => sub {push(@input_files,         #REQ'D unless
					   [sglob($_[1])])},     #<> supplied
   '<>'                       => sub {push(@input_files,         #REQ'D unless
					   [sglob($_[0])])},     #-i supplied
   'f|feature-file=s'         => sub {push(@feature_files,       #REQ'D unless
				     [sglob($_[1])])},           #<> supplied
   'r|search-range=s'         => \$search_range,                 #OPTIONAL [-1]

   'c|data-seq-id-col=s'      => sub {push(@data_chr1_cols,      #REQUIRED [0]
					   map {split(/\s+/,$_)}
					   sglob($_[1]))},
   'a|feat-seq-id-col=s'      => sub {push(@feat_chr1_cols,      #REQUIRED [0]
					   map {split(/\s+/,$_)}
					   sglob($_[1]))},
   'b|data-start-col=s'       => sub {push(@data_start1_cols,    #REQUIRED [0]
					   map {split(/\D+/,$_)}
					   sglob($_[1]))},
   'j|feat-start-col=s'       => sub {push(@feat_start1_cols,    #REQUIRED [0]
					   map {split(/\D+/,$_)}
					   sglob($_[1]))},
   'e|data-stop-col=s'        => sub {push(@data_end1_cols,      #REQUIRED [0]
					   map {split(/\D+/,$_)}
					   sglob($_[1]))},
   'k|feat-stop-col=s'        => sub {push(@feat_end1_cols,      #REQUIRED [0]
					   map {split(/\D+/,$_)}
					   sglob($_[1]))},

#   'h|data-seq-id2-col=s'=> \$data_chr2_col,           #OPTIONAL [0]
#   'l|feat-seq-id2-col=s'=> \$feat_chr2_col,           #OPTIONAL [0]
#   'g|data-start2-col=s' => \$data_start2_col,         #OPTIONAL [0]
#   'p|feat-start2-col=s' => \$feat_start2_col,         #OPTIONAL [0]
#   'n|data-stop2-col=s'  => \$data_end2_col,           #OPTIONAL [0]
#   't|feat-stop2-col=s'  => \$feat_end2_col,           #OPTIONAL [0]

   'd|data-row-id-col=s' => sub {push(@data_id_cols,   #OPTIONAL [0]
				     map {split(/\D+/,$_)} sglob($_[1]))},
   'u|feat-row-id-col=s' => sub {push(@feat_id_cols,   #OPTIONAL [0]
				     map {split(/\D+/,$_)} sglob($_[1]))},
   's|feat-sample-col=s' => \$feat_sample_col,         #OPTIONAL [0]
   'm|data-comment-col=s'=> sub {push(@data_comment_cols, #OPTIONAL [0]
				      grep {$_}
				      map {split(/\D+/,$_)} sglob($_[1]))},
   'w|feat-comment-col=s'=> sub {push(@feat_comment_cols, #OPTIONAL [0]
				      grep {$_}
				      map {split(/\D+/,$_)} sglob($_[1]))},
   'id-delimiter=s'      => \$id_delimiter,             #OPTIONAL [.]
   'data-comment-delim=s'=> \$data_comment_delimiter,   #OPTIONAL [tab]
   'feat-comment-delim=s'=> \$feat_comment_delimiter,   #OPTIONAL [tab]
   'o|outfile-suffix=s'  => \$outfile_suffix,           #OPTIONAL [undef]
   'outdir=s'            => sub {push(@outdirs,         #OPTIONAL
				      [sglob($_[1])])},
   'force|overwrite'     => \$overwrite,                #OPTIONAL [Off]
   'ignore'              => \$ignore_errors,            #OPTIONAL [Off]
   'verbose:+'           => \$verbose,                  #OPTIONAL [Off]
   'quiet'               => \$quiet,                    #OPTIONAL [Off]
   'debug:+'             => \$DEBUG,                    #OPTIONAL [Off]
   'help'                => \$help,                     #OPTIONAL [Off]
   'version'             => \$version,                  #OPTIONAL [Off]
   'noheader|no-header'  => \$noheader,                 #OPTIONAL [Off]
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




#if(scalar(@data_id_cols) == 0)
#  {push(@data_id_cols,4)}
#els
if(scalar(grep {$_ !~ /^\d+$/} @data_id_cols))
  {
    error("Invalid ID column number(s) (-d): [",
	  join(',',grep {$_ !~ /^\d+$/} @data_id_cols),
	  "] for input data file (-i).");
    quit(14);
  }

#if(scalar(@feat_id_cols) == 0)
#  {push(@feat_id_cols,(2,3,4,5,6))}
#els
if(scalar(@feat_id_cols) && scalar(grep {$_ !~ /^\d+$/} @feat_id_cols))
  {
    error("Invalid ID column number(s) (-D): [",
	  join(',',grep {$_ !~ /^\d+$/} @feat_id_cols),
	  "] for feature file (-f).");
    quit(15);
  }

if(scalar(grep {$_ !~ /^\d+$/} @data_comment_cols))
  {
    error("Invalid comment column number(s) (-m): [",
	  join(',',grep {$_ !~ /^\d+$/} @data_comment_cols),
	  "] for input data file (-i).");
    quit(16);
  }

if(scalar(grep {$_ !~ /^\d+$/} @feat_comment_cols))
  {
    error("Invalid comment column number(s) (-M): [",
	  join(',',grep {$_ !~ /^\d+$/} @feat_comment_cols),
	  "] for input data file (-i).");
    quit(17);
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
my $sample_hash          = {};
my $current_sample_hash  = {};

#Create array indexes from the column numbers for the feature file columns
my @feat_id_inds      = map {$_ - 1} @feat_id_cols;
my @feat_comment_inds = map {$_ - 1} @feat_comment_cols;
my @feat_chr1_inds    = map {$_ - 1} @feat_chr1_cols;
my @feat_start1_inds  = map {$_ - 1} @feat_start1_cols;
my @feat_end1_inds    = map {$_ - 1} @feat_end1_cols;
my($feat_sample_ind);
$feat_sample_ind = $feat_sample_col - 1 if($feat_sample_col ne '' &&
					   $feat_sample_col != 0);

#Create array indexes from the column numbers for the input data file columns
my @data_id_inds      = map {$_ - 1} @data_id_cols;
my @data_chr1_inds    = map {$_ - 1} @data_chr1_cols;
my @data_start1_inds  = map {$_ - 1} @data_start1_cols;
my @data_end1_inds    = map {$_ - 1} @data_end1_cols;
my @data_comment_inds = map {$_ - 1} @data_comment_cols;

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

	    my $line_num     = 0;
	    my $verbose_freq = 100;
	    my $redund_check = {};

	    #For each line in the current feature file
	    while(getLine(*FEAT))
	      {
		$line_num++;
		verboseOverMe('[',($current_feature_file eq '-' ?
				   $outfile_stub : $current_feature_file),
			      "] Reading line: [$line_num].")
		  unless($line_num % $verbose_freq);

		next if(/^\s*#/ || /^\s*$/);

		chomp;
		my @cols = split(/ *\t */,$_,-1);

		#Skip rows that don't have enough columns
		if(scalar(grep {defined($_) && $#cols < $_}
			  (@feat_id_inds,@feat_comment_inds,
			   $feat_sample_ind,@feat_chr1_inds,
			   @feat_start1_inds,@feat_end1_inds)))
		  {
		    if(/\t/)
		      {warning("Line [$line_num] of feature file ",
			       "[$current_feature_file] has too few ",
			       "columns.  Skipping.")}
		    #Else - assume it's a header line and don't report it
		    next;
		  }

		my $feat_id = (scalar(@feat_id_cols) ?
			       join($id_delimiter,@cols[@feat_id_inds]) : '');

		my $feat_comment = (scalar(@feat_comment_inds) ?
				    join($feat_comment_delimiter,
					 @cols[@feat_comment_inds]) : '');

		my $feat_sample = (defined($feat_sample_ind) ?
				   $cols[$feat_sample_ind] : '');

		for(my $f_ind = 0;$f_ind < scalar(@feat_chr1_inds);$f_ind++)
		  {
		    my($feat_chr1,$feat_start1,$feat_end1) =
		      @cols[$feat_chr1_inds[$f_ind],
			    $feat_start1_inds[$f_ind],
			    $feat_end1_inds[$f_ind]];

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

		    #Sometimes features like genes may have redundant entries.
		    #For example, when you take the genes in the human genome
		    #and grab the smallest and largest coordinates, many splice
		    #variants will yield the same "feature".  Here, we check
		    #for features that are indistinguishable
		    if(exists($redund_check->{$feat_id}) &&
		       exists($redund_check->{$feat_id}->{$feat_sample}) &&
		       exists($redund_check->{$feat_id}->{$feat_sample}
			      ->{$feat_chr1}) &&
		       exists($redund_check->{$feat_id}->{$feat_sample}
			      ->{$feat_chr1}->{$feat_start1}) &&
		       exists($redund_check->{$feat_id}->{$feat_sample}
			      ->{$feat_chr1}->{$feat_start1}->{$feat_end1}) &&
		       exists($redund_check->{$feat_id}->{$feat_sample}
			      ->{$feat_chr1}->{$feat_start1}->{$feat_end1}
			      ->{$feat_comment}))
		      {
			warning("Skipping redundant feature found in feature ",
				"file: [$current_feature_file]: [$feat_id,",
				"$feat_sample,$feat_chr1,$feat_start1,",
				"$feat_end1,$feat_comment].");
			next;
		      }

#		    $feat_chr1 = uc($feat_chr1);
#		    $feat_chr1 =~ s/chr(omosome)?/chr/i;
#		    if($feat_chr1 !~ /^chr/)
#		      {$feat_chr1 = "chr$feat_chr1"}

#		    if($feat_id !~ /\S/)
#		      {
#			error("Invalid feature ID: [$feat_id] in column(s) [",
#			      join(',',@feat_id_cols),"] on line [$line_num] ",
#			      "of feature file [$current_feature_file].  ",
#			      "Skipping.");
#			next;
#		      }

		    my $dir = ($feat_start1 < $feat_end1 ? '+' : '-');

		    #Order the coordinates
		    ($feat_start1,$feat_end1) = sort {$a <=> $b}
		      ($feat_start1,$feat_end1);

		    debug("Adding feature: ID => $feat_id, SAMPLE => ",
			  "$feat_sample, CHR1 => $feat_chr1, START1 => ",
			  "$feat_start1, STOP1 => $feat_end1") if($DEBUG > 1);

		    push(@{$feature_hash->{$current_feature_file}},
			 {ID      => $feat_id,
			  SAMPLE  => $feat_sample,
			  CHR1    => $feat_chr1,
			  START1  => $feat_start1,
			  STOP1   => $feat_end1,
			  COMMENT => $feat_comment});

		    #Record the feature in the redundancy hash to help
		    #eliminate duplicates.
		    $redund_check->{$feat_id}->{$feat_sample}->{$feat_chr1}
		      ->{$feat_start1}->{$feat_end1}->{$feat_comment} = 1;
		  }

		$sample_hash->{$current_feature_file}->{$feat_sample} = 1;
	      }

	    close(FEAT);

	    @{$feature_hash->{$current_feature_file}} =
	      sort {$a->{START1} <=> $b->{START1}}
		@{$feature_hash->{$current_feature_file}};

	    verbose('[',($current_feature_file eq '-' ?
			 $outfile_stub : $current_feature_file),
		    '] Closed feature file.  Time taken: [',scalar(markTime()),
		    ' Seconds].');
	  }

	$current_features    = $feature_hash->{$current_feature_file};
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

	##
	## Print Column headers
	##

	my $data_cmnt_hdr_str = join($data_comment_delimiter,
				     map {"DataComment($_)"}
				     (1..scalar(@feat_comment_cols)));

	#Column headers:
	#DataRowID       (if a data id was supplied on the command line)
	#DataComment(1),DataComment(2),... (there may be 0 of these)
	#Foreach set of coordinates $c in 1 row, there will be these columns...
	#  SeqID$c       ($c will be empty if there's only 1 set of coords)
	#  Start$c
	#  Stop$c
	#  NumSamples$c
	#  SumDistances$c
	#  For each sample $s in the feature data, there will be these columns
	#    Smpl-$s-FeatID$c
	#    Smpl-$s-FeatDist$c
	#    Smpl-$s-FeatStart$c
	#    Smpl-$s-FeatStop$c
	#    For each feature comment column $f in the feature data...
	#      Smpl-$s-FeatComment($f)$c
	#Unfortunately, there will always be an empty column at the end
	print("#",(scalar(@data_id_cols) ? "DataRowID\t" : ''),

	      #There may not be comment columns, so the trailing tab is
	      #conditionally printed
	      (scalar(@feat_comment_cols) ? "$data_cmnt_hdr_str\t" : ''),

	      #Join together columns associated with all the sets of
	      #coordinates in the input file
	      join("\t",
		   map
		   {
		     #If there's more than one, we're going to add a sequential
		     #number to each set of column headers associated with
		     #input coordinate sets
		     my $c = ($#data_start1_cols > 0 ? $_ + 1 : "");

		     #These are the standard feature headers for each feature
		     #assigned as being closest to the data coordinates
		     my @feat_hdrs = map {$_ . $c} ('FeatID','FeatDist',
						    'FeatStart','FeatStop');

		     #Add optional headers for the feature comment columns
		     if(scalar(@feat_comment_cols))
		       {
			 if($feat_comment_delimiter eq "\t")
			   {push(@feat_hdrs,
				 map {"FeatComment($_)"}
				 (1..scalar(@feat_comment_cols)))}
			 else
			   {push(@feat_hdrs,'FeatComment')}
		       }

		     "SeqID$c\tStart$c\tStop$c\t" .
		       "NumSamples$c\tSumDistances$c\t" .
			 #Grab all the feature data for each sample
			 #Note, if no samples were indicated, it is assumed
			 #that a sample name using a empty string is in the
			 #current sample hash
			 join("\t",
			      map
			      {
				#Add the sample ID to the Feature headers
				my $smpl=($_ ? "Smpl-$_-" : "");
				$smpl . join("\t$smpl",@feat_hdrs)
			      }
			      sort {$a cmp $b} keys(%$current_sample_hash)) .
				"\t"
		   } (0..$#data_start1_cols)),

	      "\n")
	  if(defined($outfile_suffix) || scalar(@outdirs) || $first_loop);

	$first_loop = 0;

	my $line_num     = 0;
	my $verbose_freq = 100;

	#For each line in the current input file
	while(getLine(*INPUT))
	  {
	    $line_num++;
	    verboseOverMe('[',($input_file eq '-' ?
			       $outfile_stub : $input_file),
			  "] Reading line: [$line_num].")
	      unless($line_num % $verbose_freq);

	    next if(/^\s*#/ || /^\s*$/);

	    chomp;
	    my @cols = split(/ *\t */,$_,-1);

	    #Skip rows that don't have enough columns
	    if(scalar(grep {defined($_) && $#cols < $_}
		      (@data_id_inds,@data_comment_inds,@data_chr1_inds,
		       @data_start1_inds,@data_end1_inds)))
	      {
		my $line_sample = $_;
		$line_sample =~ s/(.{1,30}).*/$1/;
		warning("Skipping line [$line_num] with too few columns ",
			"[$line_sample...].");
		next;
	      }

	    my $data_id = '';
	    $data_id = join($id_delimiter,@cols[@data_id_inds])
	      if(scalar(@data_id_inds));

	    debug("The data ID: [$data_id] looks weird on line $line_num: ",
		  "[$_]") if($data_id =~ /^,/);

	    my $data_comment = (scalar(@data_comment_inds) ?
				join($data_comment_delimiter,
				     @cols[@data_comment_inds]) : '');

	    my @closest_feature_hashes = ();
	    my($closest_distance);

	    for(my $coord_ind = 0;
		$coord_ind < scalar(@data_start1_inds);
		$coord_ind++)
	      {
		my($data_chr1,$data_start1,$data_end1) =
		  @cols[$data_chr1_inds[$coord_ind],
			$data_start1_inds[$coord_ind],
			$data_end1_inds[$coord_ind]];

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
			error("Unable to parse start1 and end1 of input data ",
			      "on line [$line_num] of input data file ",
			      "[$input_file].  Skipping.");
			push(@closest_feature_hashes,{});
			next;
		      }
		  }

		#Allow the coordinate to have commas
		$data_start1 =~ s/[,\s]//g;
		if($data_start1 !~ /^\d+$/)
		  {
		    error("Invalid start1 coordinate: [$data_start1] ",
			  "in column [$data_start1_cols[$coord_ind]] on line ",
			  "[$line_num] of input file [$input_file].  ",
			  "Skipping.") if($data_start1 ne '');
		    push(@closest_feature_hashes,{});
		    next;
		  }

		#Allow the coordinate to have commas
		$data_end1 =~ s/[,\s]//g;
		if($data_end1 !~ /^\d+$/)
		  {
		    error("Invalid end1 coordinate: [$data_end1] ",
			  "in column [$data_end1_cols[$coord_ind]] on line ",
			  "[$line_num] of input file ",
			  "[$current_feature_file].  Start1 was ",
			  "[$data_start1].  Skipping.")
		      if($data_end1 ne '');
		    push(@closest_feature_hashes,{});
		    next;
		  }

		if($data_chr1 !~ /\S/)
		  {
		    error("Invalid chromosome: [$data_chr1] ",
			  "in column [$data_chr1_cols[$coord_ind]] on line ",
			  "[$line_num] of input file ",
			  "[$current_feature_file].  Skipping.");
		    push(@closest_feature_hashes,{});
		    next;
		  }

		#$data_chr1 = uc($data_chr1);
		#$data_chr1 =~ s/chr(omosome)?/chr/i;
		#if($data_chr1 !~ /^chr/)
		#  {$data_chr1 = "chr$data_chr1"}

		#if($data_id !~ /\S/)
		#  {
		#    error("Invalid ID: [$data_id] in column [",
		#	  join(',',@data_id_cols),"] on line [$line_num] ",
		#	  "of input file [$current_feature_file].  ",
		#	  "Skipping: [$data_id].");
		#    next;
		#  }

		#Order the coordinates
		($data_start1,$data_end1) = sort {$a <=> $b}
		  ($data_start1,$data_end1);

		debug("Comparing features with input record: [chr1: ",
		      "$data_chr1, start1: $data_start1, end1: $data_end1] ",
		      "using search range distance: [$search_range].")
		  if($DEBUG > 1);

		#Get the closest feature to start1/end1
		my $feature1 = getClosestFeature($data_chr1,
						 $data_start1,
						 $data_end1,
						 $current_features,
						 $current_sample_hash,
						 $search_range);
		#keys (of feature1):
		#$sample
		# ID
		# SAMPLE
		# CHR1
		# START1
		# STOP1
		# COMMENT
		# DISTANCE
		# OTHERS (array of hashes containing all above keys)

		#For each sample, determine the feature closest to all of the
		#data coordinate pairs
		foreach my $sample_id (keys(%$feature1))
		  {
		    if(!defined($closest_distance) ||
		       !exists($closest_distance->{$sample_id}) ||
		       $closest_distance->{$sample_id} >
		       $feature1->{$sample_id}->{DISTANCE})
		      {$closest_distance->{$sample_id} =
			 $feature1->{$sample_id}->{DISTANCE}}
		  }

		push(@closest_feature_hashes,$feature1);

		if(scalar(keys(%$feature1)))
		  {debug("Found a feature for chr1/start1/stop1")
		     if($DEBUG > 1);}
	      }

	    #Columns:
	    #DataRowID
	    #DataComment(1),DataComment(2),... (there may be 0 of these)
	    #Foreach set of coords $c in 1 row, there will be these columns...
	    #  SeqID$c       ($c will be empty if there's only 1 set of coords)
	    #  Start$c
	    #  Stop$c
	    #  NumSamples$c
	    #  SumDistances$c
	    #  For each sample $s in the features, there will be these columns
	    #    Smpl-$s-FeatID$c
	    #    Smpl-$s-FeatDist$c
	    #    Smpl-$s-FeatStart$c
	    #    Smpl-$s-FeatStop$c
	    #    For each feature comment column $f in the feature data...
	    #      Smpl-$s-FeatComment($f)$c
	    #Unfortunately, there will always be an empty column at the end
	    print((scalar(@data_id_cols) ? "$data_id\t" : ''),
		  (scalar(@data_comment_inds) ? "$data_comment\t" : ''),

		  #Join together columns associated with all the sets of
		  #coordinates in the input file
		  join("\t",
		       map
		       {
			 my $n = $_;
			 #Calculate the sum distances
			 my $sum_distances1 = 0;
			 foreach my $sam (keys(%{$closest_feature_hashes[$n]}))
			   {$sum_distances1 +=
			      $closest_feature_hashes[$n]->{$sam}->{DISTANCE}}

			 (#Order of columns for each coord pair:
			  #SeqID, Start, Stop, NumSamples, SumDistances, then..
			  #FeatID, FeatDist, FeatStart, FeatStop, FeatComments.
			  $cols[$data_chr1_inds[$n]],
			  $cols[$data_start1_inds[$n]],
			  $cols[$data_end1_inds[$n]],
			  scalar(keys(%{$closest_feature_hashes[$n]})),
			  $sum_distances1,

			  #Grab all the feature data for each sample
			  #Note, if no samples were indicated, it is
			  #assumed that a sample name using a empty
			  #string is in the current sample hash
			  map
			  {
			    my $s   = $_; #This ia a sample ID
			    my @ret = (); #This is the array we'll return

			    #If there is not a closest feature
			    if(!exists($closest_feature_hashes[$n]->{$s}))
			      {
				#If feature comment columns were provided
				if(scalar(@feat_comment_cols))
				  {@ret = ('','','','',
					   map {''} @feat_comment_cols)}
				else
				  {@ret = ('','','','')}
			      }
			    else
			      {
				#Create a string for the feature ID that
				#includes any other features that are
				#equidistant
				my $fid =
				  $closest_feature_hashes[$n]->{$s}->{ID} .

				    #If there are other features at the same
				    #distance away, append their IDs w/ commas
				    (exists($closest_feature_hashes[$n]->{$s}
					    ->{OTHERS}) &&
				     scalar(@{$closest_feature_hashes[$n]
						->{$s}->{OTHERS}}) ?
				     #Append a comma to the end of the orig. ID
				     ',' .
				     #Now append a comma-delim list of
				     #additional IDs
				     join(',',
					  map {$_->{ID}}
					  @{$closest_feature_hashes[$n]
					      ->{$s}->{OTHERS}}) :
				     '');

				my $strt =
				  $closest_feature_hashes[$n]->{$s}->{START1} .

				    #If there are other features at the same
				    #distance away, append their IDs w/ commas
				    (exists($closest_feature_hashes[$n]->{$s}
					    ->{OTHERS}) &&
				     scalar(@{$closest_feature_hashes[$n]
						->{$s}->{OTHERS}}) ?
				     #Append a comma to the end of the orig. ID
				     ',' .
				     #Now append a comma-delim list of
				     #additional IDs
				     join(',',
					  map {$_->{START1}}
					  @{$closest_feature_hashes[$n]
					      ->{$s}->{OTHERS}}) :
				     '');

				my $stp =
				  $closest_feature_hashes[$n]->{$s}->{STOP1} .

				    #If there are other features at the same
				    #distance away, append their IDs w/ commas
				    (exists($closest_feature_hashes[$n]->{$s}
					    ->{OTHERS}) &&
				     scalar(@{$closest_feature_hashes[$n]
						->{$s}->{OTHERS}}) ?
				     #Append a comma to the end of the orig. ID
				     ',' .
				     #Now append a comma-delim list of
				     #additional IDs
				     join(',',
					  map {$_->{STOP1}}
					  @{$closest_feature_hashes[$n]
					      ->{$s}->{OTHERS}}) :
				     '');

				#Return a list.  Note, we do not need to
				#include the sequence ID because it has to be
				#the same as the input data's sequence ID
				@ret =
				  ($fid,
				   $closest_feature_hashes[$n]->{$s}
				   ->{DISTANCE},
				   $strt,
				   $stp);

				#If no feature row IDs were provided
				if(scalar(@feat_id_cols) == 0)
				  {shift(@ret)}

				#Append comment cols if they were supplied
				if(scalar(@feat_comment_cols))
				  {push(@ret,
					$closest_feature_hashes[$n]->{$s}
					->{COMMENT})}
			      }

			    #The array returned
			    @ret
			  }
			  sort {$a cmp $b}
			  keys(%$current_sample_hash))
		       } (0..$#data_start1_cols)),
		  "\n");

#		  "$data_chr1\t$data_start1\t$data_end1\t",
#		  scalar(keys(%$feature1)) . "\t$sum_distances1\t",
#		  join("\t",
#		       map{exists($feature1->{$_}) ?
#
#			     #SampleID(FeatureID
#			     "$_($feature1->{$_}->{ID}" .
#
#			       #This appends on other features that are the
#			       #same distance away, delimited by commas
#			       (exists($feature1->{$_}->{OTHERS}) &&
#				scalar(keys(%{$feature1->{$_}->{OTHERS}})) ?
#				',' .
#				join(',',keys(%{$feature1->{$_}->{OTHERS}})) :
#				'') .
#
#				  #:Distance)
#				  ":$feature1->{$_}->{DISTANCE})" : ''}
#
#		       sort {$a cmp $b} keys(%$current_sample_hash)),"\t",
#
#		  "$data_comment\n");
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
                and feature file are optionally allowed to have 2 pairs of
                coordinates (intended to be structural variant coordinates that
                have been narrowed down to a region identifying a breakpoint).
                Breakpoints come in pairs, hence the two allowed regions.  You
                can either input the structural variants as the feature file or
                input data file.  The input data file coordinates will be
                output with the closest feature to each region.  Sample
                information is only used in the feature file to report how many
                samples have structural variant breakpointss near the input
                coordinate pairs.

                Note that if you download segmental duplications from tcag:

            http://projects.tcag.ca/humandup/segmental_b35/duplication.hg17.gff

                and you are comparing them to structural variants generated
                from an hg19 reference alignment, you will need to convert the
                coordinates to hg19.

* INPUT FORMAT: Tab-delimited text file.

* FEATURE FILE FORMAT: Tab-delimited text file.

* OUTPUT FORMAT: Tab-delimited text file.

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
     -d|--data-row-id-col OPTIONAL [0] The column number or numbers (separated
                                   by non-numbers (e.g. commas)) where a unique
                                   ID can be found in the data file (see -i)
                                   for each row. (e.g. This could be a
                                   structural variant ID.)  You may re-use
                                   column numbers supplied elsewhere.  If there
                                   is no unique ID, you can supply multiple
                                   column numbers here that together make a
                                   unique ID (e.g. Sequence ID, Start, and Stop
                                   is likely unique).  See --id-delimiter to
                                   change how these columns are linked together
                                   in the output as an ID.
     -c|--data-seq-id-col REQUIRED [0] The column number where the sequence ID
                                   for the first pair of coordinates can be
                                   found in the data file (see -i).  This can
                                   be a chromosome number, a GI number, or any
                                   identifier of a single contiguous sequence.
                                   This identifier must match a sequence
                                   identifier in the feature file.  More than 1
                                   may be provided (e.g. to denote structural
                                   variants).
     -b|--data-start-col  REQUIRED [0] The column number where the first start
                                   coordinate can be found in the data file
                                   (see -i).  The value in the column may be
                                   two numbers separated by non-numbers as long
                                   as the start is first and the stop is last
                                   (e.g. 1..526 where start=1 and stop=526).
                                   More than 1 may be provided (e.g. to denote
                                   structural variants).
     -e|--data-stop-col   REQUIRED [0] The column number where the first stop
                                   coordinate can be found in the data file
                                   (see -i).  The value in the column may be
                                   two numbers separated by non-numbers as long
                                   as the start is first and the stop is last
                                   (e.g. 1..526 where start=1 and stop=526).
                                   More than 1 may be provided (e.g. to denote
                                   structural variants).
     -m|--data-comment-   OPTIONAL [0] The column number(s) (separated by non-
        col                        numbers (e.g. commas)) in the data file (see
                                   -i) that are to be appended to the output
                                   table.  You may re-use column numbers.  See
                                   --comment-delimiter to change how these
                                   columns are linked together in the output.
     -u|--feat-row-id-col OPTIONAL [none] The column number or numbers
                                   (separated by non-numbers (e.g. commas))
                                   where a unique ID can be found in the
                                   feature file (see -f) for each row (e.g.
                                   This could be a gene ID).  You may re-use
                                   column numbers supplied elsewhere, so if
                                   there is no unique ID, you can supply
                                   multiple column numbers here that together
                                   make a unique ID.  See --id-delimiter to
                                   change how these columns are linked together
                                   in the output as an ID.
     -s|--feat-sample-col OPTIONAL [0] The column number where a sample ID can
                                   be found in the feature file (see -f).  For
                                   every row of output, the samples that have
                                   features close to the coordinates in the
                                   input file will be added as a separate
                                   sample column.  '0' means there is no sample
                                   data.  Note, sample data in the data file is
                                   not supported.
     -a|--feat-seq-id-col REQUIRED [0] The column number where the sequence ID
                                   for the first pair of coordinates can be
                                   found in the feature file (see -f).  This
                                   can be a chromosome number, a GI number, or
                                   any identifier of a single contiguous
                                   sequence.  This identifier must match a
                                   sequence identifier in the data file.  More
                                   than 1 may be provided (e.g. to denote
                                   structural variants).
     -j|--feat-start-col  REQUIRED [0] The column number where the first start
                                   coordinate can be found in the feature file
                                   (see -f).  The value in the column may be
                                   two numbers separated by non-numbers as long
                                   as the start is first and the stop is last
                                   (e.g. 1..526 where start=1 and stop=526).
                                   More than 1 may be provided (e.g. to denote
                                   structural variants).
     -k|--feat-stop-col   REQUIRED [0] The column number where the first stop
                                   coordinate can be found in the feature file
                                   (see -f).  The value in the column may be
                                   two numbers separated by non-numbers as long
                                   as the start is first and the stop is last
                                   (e.g. 1..526 where start=1 and stop=526).
                                   More than 1 may be provided (e.g. to denote
                                   structural variants).
     -w|--feat-comment-   OPTIONAL [0] The column number or numbers (separated
        col                        by non-numbers (e.g. commas)) in the
                                   feature file (supplied with -f) that are to
                                   be appended to the output rows.  You may
                                   re-use column numbers.  See --comment-
                                   delimiter to change how these columns are
                                   linked together in the output.
     --id-delimiter       OPTIONAL [.] The delimiter inserted between values in
                                   the columns indicated in options -d and -u.
     --data-comment-delim OPTIONAL [tab] The delimiter inserted between values
                                   in the columns indicated in option -m.
     --feat-comment-delim OPTIONAL [tab] The delimiter inserted between values
                                   in the columns indicated in option -w.
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

EXAMPLES & TIPS
---------------
To use a gff file downloaded from tcag.ca (see --help) with the default column
number selections, use this series of piped commends:

cut -f 1,4,5,9 duplication.hg19.most.gff.unix | cut -d '"' -f 1,4 | perl -ne 's/"//g;print' | ./featureProximity.pl -i - -f myfeatures.txt

Swap the files so that the structural variants are the input data file and the
segmental duplications are the feature file:

./featureProximity.pl -i mydata.txt -f myfeatures.txt -s 0 -a 1 -j 2 -k 3 -l 0 -p 0 -t 0 -u 4 -w 0 -c 2 -b 19 -e 19 -h 4 -g 20 -n 20 -d 2,3,4,5,6 -m 0

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

sub getClosestFeatureOLD
  {
    my $chr1             = $_[0];
    my $start1           = $_[1];
    my $stop1            = $_[2];
    my $chr2             = $_[3];
    my $start2           = $_[4];
    my $stop2            = $_[5];
    my $features         = $_[6];
    my $num_samples      = scalar(keys(%{$_[7]}));
    my $search_range     = $_[8];
    my $closest_feat     = {};
    my $closest_distance = {};

    #Make shure chromosome naming conventions are the same between the files
    my $num_inspected = scalar(grep {$_->{CHR1} eq $chr1 ||
				       (exists($_->{CHR2}) &&
					defined($_->{CHR2}) &&
					$_->{CHR2} eq $chr1)} @$features);
    unless($num_inspected)
      {warning("No features were inspected for chromosome: [$chr1].  Please ",
	       "check to make sure that the chromosome naming styles are the ",
	       "same between your feature file and input file.")}

    #Note: features are sorted on the start1 coordinate (which is always less
    #than the stop1 coordinate) however since we can't sort both on start1 and
    #start2, we must traverse the whole loop.  I'll optimize this if necessary
    #later
    foreach my $feat (grep {(#The feature is on the same chromosome
			     $_->{CHR1} eq $chr1 &&
			     (#There is no limit to the search range
			      $search_range == 0 ||
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
			       $stop1 >= $_->{STOP1}))) ||
				(#There exists a second set of coordinates for
				 #the feature and the chromosome is the same
				 exists($_->{CHR2}) && defined($_->{CHR2}) &&
				 $_->{CHR2} eq $chr1 &&
				 (#There is no limit to the search range
				  $search_range == 0 ||
				  #start1 is w/in the search range of the feat.
				  abs($start1-$_->{STOP2})  <= $search_range ||
				  abs($start1-$_->{START2}) <= $search_range ||
				  #stop1 is w/in the search range of the feat.
				  abs($stop1-$_->{STOP2})   <= $search_range ||
				  abs($stop1-$_->{START2})  <= $search_range ||
				  #The start1 is inside the feature
				  ($start1 >= $_->{START2} &&
				   $start1 <= $_->{STOP2}) ||
				  #The stop1 is inside the feature
				  ($stop1 >= $_->{START2} &&
				   $stop1 <= $_->{STOP2}) ||
				  #The start1 and stop1 encompass the feature
				  ($start1 <= $_->{START2} &&
				   $stop1 >= $_->{STOP2})))}
		      @$features)
      {
	$num_inspected++;
	debug("Inspecting [$chr1 $start1 $stop1] with [$feat->{CHR1} ",
	      "$feat->{START1} $feat->{STOP1} ",
	      (exists($feat->{CHR2}) && defined($feat->{CHR2}) ?
	       "$feat->{CHR2} $feat->{START2} $feat->{STOP2}" : '  '),"].")
	  if($DEBUG > 1);;

	#Strip any distances which have previously been added by previous calls
	if(exists($feat->{DISTANCE}))
	  {delete($feat->{DISTANCE})}
	if(exists($feat->{OTHERS}))
	  {delete($feat->{OTHERS})}

	if($feat->{CHR1} eq $chr1)
	  {
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
		  {$closest_feat->{$feat->{SAMPLE}}->{OTHERS}->{$feat->{ID}}=1}
		else
		  {
		    delete($closest_feat->{$feat->{SAMPLE}}->{OTHERS})
		      if(exists($closest_feat->{$feat->{SAMPLE}}) &&
			 exists($closest_feat->{$feat->{SAMPLE}}->{OTHERS}));
		    $closest_feat->{$feat->{SAMPLE}} = copyFeature($feat);
		    $closest_feat->{$feat->{SAMPLE}}->{DISTANCE} = 0;
		    $closest_distance->{$feat->{SAMPLE}} = 0;
		  }
		debug("Feature Overlaps.") if($DEBUG > 1);;
	      }

	    my $distance = (sort {$a <=> $b}
			    (abs($start1 - $feat->{STOP1}),
			     abs($feat->{START1} - $stop1),
			     abs($start1 - $feat->{START1}),
			     abs($feat->{STOP1} - $stop1)))[0];

	    debug("Feature is $distance away.") if($DEBUG > 1);;

	    if(!exists($closest_distance->{$feat->{SAMPLE}}) ||
	       $distance < $closest_distance->{$feat->{SAMPLE}})
	      {
		$closest_distance->{$feat->{SAMPLE}} = $distance;
		$closest_feat->{$feat->{SAMPLE}}     = copyFeature($feat);
		$closest_feat->{$feat->{SAMPLE}}->{DISTANCE} = $distance;
		delete($closest_feat->{$feat->{SAMPLE}}->{OTHERS})
		  if(exists($closest_feat->{$feat->{SAMPLE}}) &&
		     exists($closest_feat->{$feat->{SAMPLE}}->{OTHERS}));
		debug("Feature is Closer.") if($DEBUG > 1);;
	      }
	    elsif($distance == $closest_distance->{$feat->{SAMPLE}})
	      {$closest_feat->{$feat->{SAMPLE}}->{OTHERS}->{$feat->{ID}}=1}
	  }

	if(exists($feat->{CHR2}) && defined($feat->{CHR2}) &&
	   $feat->{CHR2} eq $chr1)
	  {
	    if(#The start1 is inside the feature
	       ($start1 >= $feat->{START2} && $start1 <= $feat->{STOP2}) ||
	       #The stop1 is inside the feature
	       ($stop1 >= $feat->{START2} && $stop1 <= $feat->{STOP2}) ||
	       #The start1 and stop1 encompass the feature
	       ($start1 <= $feat->{START2} && $stop1 >= $feat->{STOP2}))
	      {
		#See if there already exists a feature for this sample at this
		#distance
		if(exists($closest_feat->{$feat->{SAMPLE}}) &&
		   $closest_feat->{$feat->{SAMPLE}}->{DISTANCE} == 0)
		  {$closest_feat->{$feat->{SAMPLE}}->{OTHERS}->{$feat->{ID}}=1}
		else
		  {
		    delete($closest_feat->{$feat->{SAMPLE}}->{OTHERS})
		      if(exists($closest_feat->{$feat->{SAMPLE}}) &&
			 exists($closest_feat->{$feat->{SAMPLE}}->{OTHERS}));
		    $closest_feat->{$feat->{SAMPLE}} = copyFeature($feat);
		    $closest_distance->{$feat->{SAMPLE}} = 0;
		    $closest_feat->{$feat->{SAMPLE}}->{DISTANCE} = 0;
		  }
	      }

	    my $distance = (sort {$a <=> $b}
			    (abs($start1 - $feat->{STOP2}),
			     abs($feat->{START2} - $stop1),
			     abs($start1 - $feat->{START2}),
			     abs($feat->{STOP2} - $stop1)))[0];

	    if(!exists($closest_distance->{$feat->{SAMPLE}}) ||
	       $distance < $closest_distance->{$feat->{SAMPLE}})
	      {
		$closest_distance->{$feat->{SAMPLE}} = $distance;
		$closest_feat->{$feat->{SAMPLE}}     = copyFeature($feat);
		$closest_feat->{$feat->{SAMPLE}}->{DISTANCE} = $distance;
		delete($closest_feat->{$feat->{SAMPLE}}->{OTHERS})
		  if(exists($closest_feat->{$feat->{SAMPLE}}) &&
		     exists($closest_feat->{$feat->{SAMPLE}}->{OTHERS}));
	      }
	    elsif($distance == $closest_distance->{$feat->{SAMPLE}})
	      {$closest_feat->{$feat->{SAMPLE}}->{OTHERS}->{$feat->{ID}}=1}
	  }
      }

    my $closest_feat2 = {};
    $closest_distance = {};

    debug("Value of chr1: $chr1 start1: [$start1] chr2: $chr2 start2: ",
	  "[$start2].") if(defined($chr1) && defined($start1) &&
			   defined($chr2) && defined($start2));

    if(defined($start2) && $start2)
      {
	foreach my $feat (grep {($_->{CHR1} eq $chr2 &&
			     ($search_range == 0 ||
			      abs($start2-$_->{STOP1})  <= $search_range ||
			      abs($start2-$_->{START1}) <= $search_range ||
			      abs($stop2-$_->{STOP1})   <= $search_range ||
			      abs($stop2-$_->{START1})  <= $search_range ||
			      #The start2 is inside the feature
			      ($start2 >= $_->{START1} &&
			       $start2 <= $_->{STOP1}) ||
			      #The stop2 is inside the feature
			      ($stop2 >= $_->{START1} &&
			       $stop2 <= $_->{STOP1}) ||
			      #The start2 and stop2 encompass the feature
			      ($start2 <= $_->{START1} &&
			       $stop2 >= $_->{STOP1}))) ||
				(exists($_->{CHR2}) && defined($_->{CHR2}) &&
				 $_->{CHR2} eq $chr2 &&
				 ($search_range == 0 ||
				  abs($start2-$_->{STOP2})  <= $search_range ||
				  abs($start2-$_->{START2}) <= $search_range ||
				  abs($stop2-$_->{STOP2})   <= $search_range ||
				  abs($stop2-$_->{START2})  <= $search_range ||
				  #The start2 is inside the feature
				  ($start2 >= $_->{START2} &&
				   $start2 <= $_->{STOP2}) ||
				  #The stop2 is inside the feature
				  ($stop2 >= $_->{START2} &&
				   $stop2 <= $_->{STOP2}) ||
				  #The start2 and stop2 encompass the feature
				  ($start2 <= $_->{START2} &&
				   $stop2 >= $_->{STOP2})))}
			  @$features)
	  {
	    debug("Second coordinate inspection.");

	    #Strip any distances which have previously been added by the above
	    #loop or previous calls
	    if(exists($feat->{DISTANCE}))
	      {delete($feat->{DISTANCE})}
	    if(exists($feat->{OTHERS}))
	      {delete($feat->{OTHERS})}

	    if($feat->{CHR1} eq $chr2)
	      {
		if(#The start2 is inside the feature
		   ($start2 >= $feat->{START1} && $start2 <= $feat->{STOP1}) ||
		   #The stop2 is inside the feature
		   ($stop2 >= $feat->{START1} && $stop2 <= $feat->{STOP1}) ||
		   #The start2 and stop2 encompass the feature
		   ($start2 <= $feat->{START1} && $stop2 >= $feat->{STOP1}))
		  {
		    #See if there already exists a feature for this sample at
		    #this distance
		    if(exists($closest_feat2->{$feat->{SAMPLE}}) &&
		       $closest_feat2->{$feat->{SAMPLE}}->{DISTANCE} == 0)
		      {$closest_feat2->{$feat->{SAMPLE}}->{OTHERS}
			 ->{$feat->{ID}}=1}
		    else
		      {
			delete($closest_feat2->{$feat->{SAMPLE}}->{OTHERS})
			  if(exists($closest_feat2->{$feat->{SAMPLE}}) &&
			     exists($closest_feat2->{$feat->{SAMPLE}}
				    ->{OTHERS}));
			$closest_feat2->{$feat->{SAMPLE}} = copyFeature($feat);
			$closest_feat2->{$feat->{SAMPLE}}->{DISTANCE} = 0;
			$closest_distance->{$feat->{SAMPLE}} = 0;
		      }
		  }

		my $distance = (sort {$a <=> $b}
				(abs($start2 - $feat->{STOP1}),
				 abs($feat->{START1} - $stop2),
				 abs($start2 - $feat->{START1}),
				 abs($feat->{STOP1} - $stop2)))[0];

		if(!exists($closest_distance->{$feat->{SAMPLE}}) ||
		   $distance < $closest_distance->{$feat->{SAMPLE}})
		  {
		    $closest_distance->{$feat->{SAMPLE}}          = $distance;
		    $closest_feat2->{$feat->{SAMPLE}}             =
		      copyFeature($feat);
		    $closest_feat2->{$feat->{SAMPLE}}->{DISTANCE} = $distance;
		    delete($closest_feat2->{$feat->{SAMPLE}}->{OTHERS})
		      if(exists($closest_feat2->{$feat->{SAMPLE}}) &&
			 exists($closest_feat2->{$feat->{SAMPLE}}->{OTHERS}));
		  }
		elsif($distance == $closest_distance->{$feat->{SAMPLE}})
		  {$closest_feat2->{$feat->{SAMPLE}}->{OTHERS}->{$feat->{ID}}
		     = 1}
	      }

	    if(exists($feat->{CHR2}) && defined($feat->{CHR2}) &&
	       $feat->{CHR2} eq $chr2)
	      {
		if(#The start2 is inside the feature
		   ($start2 >= $feat->{START2} && $start2 <= $feat->{STOP2}) ||
		   #The stop2 is inside the feature
		   ($stop2 >= $feat->{START2} && $stop2 <= $feat->{STOP2}) ||
		   #The start2 and stop2 encompass the feature
		   ($start2 <= $feat->{START2} && $stop2 >= $feat->{STOP2}))
		  {
		    #See if there already exists a feature for this sample at
		    #this distance
		    if(exists($closest_feat2->{$feat->{SAMPLE}}) &&
		       $closest_feat2->{$feat->{SAMPLE}}->{DISTANCE} == 0)
		      {$closest_feat2->{$feat->{SAMPLE}}->{OTHERS}
			 ->{$feat->{ID}} = 1}
		    else
		      {
			delete($closest_feat2->{$feat->{SAMPLE}}->{OTHERS})
			  if(exists($closest_feat2->{$feat->{SAMPLE}}) &&
			     exists($closest_feat2->{$feat->{SAMPLE}}
				    ->{OTHERS}));
			$closest_feat2->{$feat->{SAMPLE}} = copyFeature($feat);
			$closest_feat2->{$feat->{SAMPLE}}->{DISTANCE} = 0;
			$closest_distance->{$feat->{SAMPLE}} = 0;
		      }
		  }

		my $distance = (sort {$a <=> $b}
				(abs($start2 - $feat->{STOP2}),
				 abs($feat->{START2} - $stop2),
				 abs($start2 - $feat->{START2}),
				 abs($feat->{STOP2} - $stop2)))[0];


		if(!exists($closest_distance->{$feat->{SAMPLE}}) ||
		   $distance < $closest_distance->{$feat->{SAMPLE}})
		  {
		    $closest_distance->{$feat->{SAMPLE}} = $distance;
		    $closest_feat2->{$feat->{SAMPLE}}    = copyFeature($feat);
		    $closest_feat2->{$feat->{SAMPLE}}->{DISTANCE} = $distance;
		    delete($closest_feat2->{$feat->{SAMPLE}}->{OTHERS})
		      if(exists($closest_feat2->{$feat->{SAMPLE}}) &&
			 exists($closest_feat2->{$feat->{SAMPLE}}->{OTHERS}));
		  }
		elsif($distance == $closest_distance->{$feat->{SAMPLE}})
		  {$closest_feat2->{$feat->{SAMPLE}}->{OTHERS}->{$feat->{ID}}
		     = 1}
	      }
	  }
      }
  }

#Assumes all starts and stops (data and features) are sorted numerically.
#This means that upstream and downstream cannot be determined.
sub getClosestFeature
  {
    my $chr1                   = $_[0];
    my $start1                 = $_[1];
    my $stop1                  = $_[2];
    my $features               = $_[3];
    my $num_samples            = scalar(keys(%{$_[4]}));
    my $search_range           = $_[5];

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
	  if($DEBUG > 1);;

	#Strip any distances which have previously been added by previous calls
	if(exists($feat->{DISTANCE}))
	  {delete($feat->{DISTANCE})}
	if(exists($feat->{OTHERS}))
	  {delete($feat->{OTHERS})}

	#If the chromosome of the feature is the same as the chromosome sent in
	if($feat->{CHR1} eq $chr1)
	  {
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



###Also need to change the way the feature file is read in so that if there are multiple pairs of starts and stops, they are put into the same data structure



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
      }

    debug("Value of chr1: $chr1 start1: [$start1].");

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
