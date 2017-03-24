#!/usr/bin/perl -w

#Robert W. Leach
#Princeton University
#Carl Icahn Laboratory
#Lewis Sigler Institute for Integrative Genomics
#Bioinformatics Group
#Room 137A
#Princeton, NJ 08544
#rleach@princeton.edu
#Copyright 2017

use strict;
use CommandLineInterface;

#These variables are set in the BEGIN block for the help & usage info
my($description,$input_desc,$feature_input_desc,$output_desc,$iflag_desc,
   $fflag_desc,$rflag_desc,$cflag_desc,$bflag_desc,$eflag_desc,$pflag_desc,
   $mflag_desc,$sflag_desc,$aflag_desc,$jflag_desc,$kflag_desc,$nflag_desc,
   $wflag_desc,$uflag_desc,$dflag_desc,$lflag_desc,$gflag_desc,$vflag_desc,
   $xflag_desc,$zflag_desc,$tflag_desc,$oflag_desc);

##
## Define the command line interface
##

setScriptInfo(VERSION => '3.9',
              CREATED => '11/2/2011',
              AUTHOR  => 'Robert William Leach',
              CONTACT => 'rleach@princeton.edu',
              COMPANY => 'Princeton University',
              LICENSE => 'Copyright 2017',
              HELP    => $description);

my $iid =
  addInfileOption(GETOPTKEY   => 'i|data-file|input-file=s',
		  REQUIRED    => 1,
		  PRIMARY     => 1,
		  SMRY_DESC   => 'File to which features will be added.',
		  DETAIL_DESC => $iflag_desc,
		  FORMAT_DESC => $input_desc);

my($outfile_suffix);
addOutfileSuffixOption(GETOPTKEY   => 'o|outfile-suffix=s',
		       FILETYPEID  => $iid,
		       GETOPTVAL   => \$outfile_suffix,
		       PRIMARY     => 1,
		       SMRY_DESC   => 'Outfile extension added to -i files.',
		       DETAIL_DESC => $oflag_desc,
		       FORMAT_DESC => $output_desc);

#my @feature_files = ();
my $fid =
  addInfileOption(GETOPTKEY   => 'f|feature-file=s',
		  REQUIRED    => 1,
		  PRIMARY     => 0,
		  SMRY_DESC   => 'File of features to add to -i files.',
		  DETAIL_DESC => $fflag_desc,
		  FORMAT_DESC => $feature_input_desc);

my $search_range = -1;
addOption(GETOPTKEY   => 'r|search-range=s',
	  GETOPTVAL   => \$search_range,
	  DEFAULT     => $search_range,
	  SMRY_DESC   => 'Closest feature distance limit.',
	  DETAIL_DESC => $rflag_desc);

my @data_chr1_cols = ();
addArrayOption(GETOPTKEY   => 'c|data-seq-id-col=s',
	       GETOPTVAL   => \@data_chr1_cols,
	       REQUIRED    => 1,
	       DEFAULT     => '0',
	       SMRY_DESC   => 'Sequence ID col num of data file (-i).',
	       DETAIL_DESC => $cflag_desc,
	       INTERPOLATE => 1);

my @feat_chr1_cols = ();
addArrayOption(GETOPTKEY   => 'a|feat-seq-id-col=s',
	       GETOPTVAL   => \@feat_chr1_cols,
	       REQUIRED    => 1,
	       DEFAULT     => '0',
	       SMRY_DESC   => 'Sequence ID col num of feat file (-f).',
	       DETAIL_DESC => $aflag_desc,
	       INTERPOLATE => 1);

my @data_start1_cols = ();
addArrayOption(GETOPTKEY   => 'b|data-start-col=s',
	       GETOPTVAL   => \@data_start1_cols,
	       REQUIRED    => 1,
	       DEFAULT     => '0',
	       SMRY_DESC   => 'Start coord col num of data file (-i).',
	       DETAIL_DESC => $bflag_desc,
	       INTERPOLATE => 1);

my @feat_start1_cols = ();
addArrayOption(GETOPTKEY   => 'j|feat-start-col=s',
	       GETOPTVAL   => \@feat_start1_cols,
	       REQUIRED    => 1,
	       DEFAULT     => '0',
	       SMRY_DESC   => 'Start coord col num of feat file (-f).',
	       DETAIL_DESC => $jflag_desc,
	       INTERPOLATE => 1);

my @data_end1_cols = ();
addArrayOption(GETOPTKEY   => 'e|data-stop-col=s',
	       GETOPTVAL   => \@data_end1_cols,
	       REQUIRED    => 1,
	       DEFAULT     => '0',
	       SMRY_DESC   => 'Stop coord col num of data file (-i).',
	       DETAIL_DESC => $eflag_desc,
	       INTERPOLATE => 1);

my @feat_end1_cols = ();
addArrayOption(GETOPTKEY   => 'k|feat-stop-col=s',
	       GETOPTVAL   => \@feat_end1_cols,
	       REQUIRED    => 1,
	       DEFAULT     => '0',
	       SMRY_DESC   => 'Stop coord col num of feat file (-f).',
	       DETAIL_DESC => $kflag_desc,
	       INTERPOLATE => 1);

my $feat_sample_col = 0;
addOption(GETOPTKEY   => 's|feat-sample-col=s',
	  GETOPTVAL   => \$feat_sample_col,
	  DEFAULT     => $feat_sample_col,
	  SMRY_DESC   => 'Sample name col num of feat file (-f).',
	  DETAIL_DESC => $sflag_desc);

my @data_out_cols = ();
addArrayOption(GETOPTKEY   => 'm|data-out-cols=s',
	       GETOPTVAL   => \@data_out_cols,
	       DEFAULT     => '0',
	       SMRY_DESC   => 'Col nums of data file (-i) to output.',
	       DETAIL_DESC => $mflag_desc,
	       INTERPOLATE => 1);

my @feat_out_cols = ();
addArrayOption(GETOPTKEY   => 'w|feat-out-cols=s',
	       GETOPTVAL   => \@feat_out_cols,
	       DEFAULT     => '0',
	       SMRY_DESC   => 'Col nums of feat file (-f) to output.',
	       DETAIL_DESC => $wflag_desc,
	       INTERPOLATE => 1);

my @data_strand_cols = ();
addArrayOption(GETOPTKEY   => 'p|data-strand-col=s',
	       GETOPTVAL   => \@data_strand_cols,
	       DEFAULT     => '0',
	       SMRY_DESC   => 'Strand col nums of data file (-i).',
	       DETAIL_DESC => $pflag_desc,
	       INTERPOLATE => 1);

my @feat_strand_cols = ();
addArrayOption(GETOPTKEY   => 'n|feat-strand-col=s',
	       GETOPTVAL   => \@feat_strand_cols,
	       DEFAULT     => '0',
	       SMRY_DESC   => 'Strand col nums of feat file (-f).',
	       DETAIL_DESC => $nflag_desc,
	       INTERPOLATE => 1);

my $search_upstream = 0;
addOption(GETOPTKEY   => 'u|search-upstream',
	  GETOPTVAL   => \$search_upstream,
	  SMRY_DESC   => 'Look for features upstream of data start.',
	  DETAIL_DESC => $uflag_desc);

my $search_downstream = 0;
addOption(GETOPTKEY   => 'd|search-downstream',
	  GETOPTVAL   => \$search_downstream,
	  SMRY_DESC   => 'Look for features downstream of data stop.',
	  DETAIL_DESC => $uflag_desc);

my $search_left = 0;
addOption(GETOPTKEY   => 'l|search-left',
	  GETOPTVAL   => \$search_left,
	  SMRY_DESC   => 'Look for features left of lesser data coord.',
	  DETAIL_DESC => $lflag_desc);

my $search_right = 0;
addOption(GETOPTKEY   => 'g|search-right',
	  GETOPTVAL   => \$search_right,
	  SMRY_DESC   => 'Look for features right of data greater coord.',
	  DETAIL_DESC => $gflag_desc);

my $search_overlap = 0;
addOption(GETOPTKEY   => 'v|search-overlap',
	  GETOPTVAL   => \$search_overlap,
	  SMRY_DESC   => 'Look for features that overlap data coords.',
	  DETAIL_DESC => $vflag_desc);

my $search_nonoverlap = 0;
addOption(GETOPTKEY   => 'x|search-nonoverlap',
	  GETOPTVAL   => \$search_nonoverlap,
	  SMRY_DESC   => "Look for features that don't overlap data coords.",
	  DETAIL_DESC => $xflag_desc);

my $search_any = 0;
addOption(GETOPTKEY   => 'z|search-any',
	  GETOPTVAL   => \$search_any,
	  SMRY_DESC   => 'Look for any feature closest.',
	  DETAIL_DESC => $zflag_desc);

my @feat_orientations = ();
addArrayOption(GETOPTKEY   => 't|feat-orientation=s',
	       GETOPTVAL   => \@feat_orientations,
	       DEFAULT     => 'any',
	       SMRY_DESC   => ('Feature orientation requirement relative to ' .
			       'the coords in the data file (-i) or the ' .
			       'strand.'),
	       DETAIL_DESC => $tflag_desc,
	       INTERPOLATE => 1,
	       ACCEPTS     => [qw(any away toward same opposite
                                  + - plus minus)]);

processCommandLine();

##
## Process/filter the column numbers for the various column options
##

@data_chr1_cols    =           map {split(/\s+/,$_)}    @data_chr1_cols;
@feat_chr1_cols    =           map {split(/\s+/,$_)}    @feat_chr1_cols;
@data_start1_cols  =           map {split(/\D+/,$_)}    @data_start1_cols;
@feat_start1_cols  =           map {split(/\D+/,$_)}    @feat_start1_cols;
@data_end1_cols    =           map {split(/\D+/,$_)}    @data_end1_cols;
@feat_end1_cols    =           map {split(/\D+/,$_)}    @feat_end1_cols;
@data_out_cols     = grep {$_} map {split(/\D+/,$_)}    @data_out_cols;
@feat_out_cols     = grep {$_} map {split(/\D+/,$_)}    @feat_out_cols;
@data_strand_cols  =           map {split(/\D+/,$_)}    @data_strand_cols;
@feat_strand_cols  =           map {split(/\D+/,$_)}    @feat_strand_cols;
@feat_orientations = map {split(/[^a-zA-Z_\-0-9]+/,$_)} @feat_orientations;

##
## Validate the options
##

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

if((scalar(@data_chr1_cols)   != scalar(@data_start1_cols)) ||
   (scalar(@data_start1_cols) != scalar(@data_end1_cols))   ||
   (scalar(@feat_chr1_cols)   != scalar(@feat_start1_cols)) ||
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
    error("--search-upstream or --search-downstream requires -p.");
    quit(21);
  }

my $search_streams = [];
push(@$search_streams,'any')     unless($search_upstream   ||
				        $search_downstream ||
				        $search_overlap    ||
				        $search_nonoverlap ||
					$search_any);
push(@$search_streams,'any')     if($search_any);
push(@$search_streams,'up')      if($search_upstream);
push(@$search_streams,'down')    if($search_downstream);
push(@$search_streams,'left')    if($search_left);
push(@$search_streams,'right')   if($search_right);
push(@$search_streams,'over')    if($search_overlap);
push(@$search_streams,'nonover') if($search_nonoverlap);

my $feat_orients = [];
push(@$feat_orients,'any')         if(scalar(@feat_orientations) == 0 ||
				      scalar(grep {/^an/i}
					     @feat_orientations));
push(@$feat_orients,'+')           if(scalar(grep {/^(p|\+)/i}
					     @feat_orientations));
push(@$feat_orients,'-')           if(scalar(grep {/^(m|-)/i}
					     @feat_orientations));
push(@$feat_orients,'away')        if(scalar(grep {/^(aw|u)/i}
					     @feat_orientations));
push(@$feat_orients,'toward')      if(scalar(grep {/^(t|d)/i}
					     @feat_orientations));
push(@$feat_orients,'same')        if(scalar(grep {/^s/i} @feat_orientations));
push(@$feat_orients,'opp')         if(scalar(grep {/^o/i} @feat_orientations));

if(scalar(@feat_orientations) > scalar(@$feat_orients))
  {
    error("One or more of these feature orientations (-t) were invalid: [",
	  join(',',@feat_orientations),"].");
    usage(1);
    quit(26);
  }

if(scalar(grep {$_ eq 'over'} @$search_streams) &&
   scalar(@$search_streams) == 1 &&
   scalar(grep {$_ eq 'away' || $_ eq 'toward'} @$feat_orients))
  {
    error("The -v flag (search for overlap of the input data) and -t with a ",
	  "facing orientation (e.g. away, toward, upstream, or downstream) ",
	  "are incompatible.  The determination of away/toward feature ",
	  "orientations in cases of overlap is not supported at this time.  ",
	  "Please use -u, -d, -l, -g, or -x when using -t with a facing ",
	  "orientation.  You may supply -v to search overlap as well, but ",
	  "only in addition to -u, -d, -x, -l, -g, or -z.  See the usage for ",
	  "more details.");
    quit(25);
  }

if(scalar(grep {$_ eq 'over' || $_ eq 'any'} @$search_streams) &&
   scalar(grep {$_ eq 'away' || $_ eq 'toward'} @$feat_orients))
  {
    warning("Supplying -t with a facing orientation (e.g. away, toward, ",
	    "upstream, or downstream) and with -v or -z (or without -u, -d, ",
	    "-v, -x, -l, -g, and -z) may produce unexpected results.  The ",
	    "determination of away/toward feature orientations in cases of ",
	    "overlap is not supported at this time.  See the usage for more ",
	    "details.");
  }

if(scalar(grep {$_ ne 'any' && $_ ne 'nonover'} @$search_streams) ||
   scalar(grep {$_ ne 'any' && $_ ne 'away'} @$feat_orients))
  {
    my @untested_streams = grep {$_ ne 'any' && $_ ne 'up'} @$search_streams;
    error("The validity of the output using the -u -v, or -d options (e.g. ",
	  join(',',@untested_streams),") has not been tested.  Use at your ",
	  "own risk.  It is highly recommended that you check the output for ",
	  "correctness.") if(scalar(@untested_streams));

    #Filter out the properly tested and validated values
    my @untested_orients = grep {$_ ne 'any' && $_ ne 'away' && $_ ne 'toward'}
      @$feat_orients;
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
    error("-n and -p are both required when -t is 'same' or 'opposite' [",
	  join(",",@$feat_orients),"].");
    quit(24);
  }

##
## Initialize variables
##

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

#Keep track of the chromosome names to make sure they're in the same format in
#both the input files and the feature files
my $feat_chr_hash = {};

#Keep track of the largest feature (to be added to the search range in order to
#create a hash of feature regions to speed up the search).  The script will
#jump to the regions nearest the input coordinates.
my $largest_range = 0;
my $region_size   = 1;

my $first_loop = 1;

#For each input file set
while(nextFileSet())
  {
    my $data_file = getInfile($iid);
    my $feat_file  = getInfile($fid);

    #Keep track of the chromosome names to make sure they're in the same
    #format in both the input files and the feature files
    my $data_chr_hash = {};

    ##
    ## Create the current feature hash
    ##

    my $current_features = [];
    unless(exists($feature_hash->{$feat_file}) &&
	   scalar(keys(%$feature_hash)))
      {
	#Open the feature file
	openIn(*FEAT,$feat_file) || next;

	my $line_num       = 0;
	my $verbose_freq   = 100;
	my $redund_check   = {};
	my $feat_col_check = {}; #Allows a check on the number of columns
	$max_feat_cols->{$feat_file} = 0;
	my $first_feat_recorded = 0;

	#For each line in the current feature file
	while(getLine(*FEAT))
	  {
	    $line_num++;
	    verboseOverMe({FREQUENCY => $verbose_freq},
			  "[$feat_file] Reading line: [$line_num].");

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
			   "[$feat_file] has too few ",
			   "columns.  Skipping.")}
		#Else - assume it's a commented line and don't report it
		next;
	      }

	    my $feat_cols = scalar(@cols);
	    if($feat_cols > $max_feat_cols->{$feat_file})
	      {$max_feat_cols->{$feat_file} = $feat_cols}

	    #Skip commented lines
	    if(/^\s*#/)
	      {
		#We cannot get here unless there are enough columns, so we
		#can assume this is a header line since it is commented and
		#has tabs, but we only want to create column headers if
		#they haven't already been set
		unless(exists($feat_headers->{$feat_file}))
		  {
		    $feat_headers->{$feat_file} =
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

		#Keep track of the chromosome names
		$feat_chr_hash->{$feat_file}->{$feat_chr1} = 1;

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
				"[$feat_file].");
		      }
		    elsif($feat_start1 =~ /^\s*([\d,]+)\s*$/)
		      {
			$feat_start1 = $feat_end1 = $1;
			warning("Using a single coordinate: [$1] for ",
				"start1 and end1 of feature on line ",
				"[$line_num] of feature file ",
				"[$feat_file].");
		      }
		    else
		      {
			#If we have not yet parsed any real data, assume
			#this is a header line and record the headers
			if($first_feat_recorded == 0 &&
			   !exists($feat_headers->{$feat_file}))
			  {
			    $feat_headers->{$feat_file} =
			      [scalar(@feat_out_inds) ?
			       @cols[@feat_out_inds] : @cols];
			    last;
			  }
			error("Unable to parse start1 and end1 of ",
			      "feature on line [$line_num] of feature ",
			      "file [$feat_file].  Skipping.");
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
		       !exists($feat_headers->{$feat_file}))
		      {
			$feat_headers->{$feat_file} =
			  [scalar(@feat_out_inds) ?
			   @cols[@feat_out_inds] : @cols];
			last;
		      }
		    error("Invalid feature start1 coordinate: ",
			  "[$feat_start1] in column ",
			  "[$feat_start1_cols[$f_ind]] on line ",
			  "[$line_num] of feature file ",
			  "[$feat_file].  Skipping.")
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
		       !exists($feat_headers->{$feat_file}))
		      {
			$feat_headers->{$feat_file} =
			  [scalar(@feat_out_inds) ?
			   @cols[@feat_out_inds] : @cols];
			last;
		      }
		    error("Invalid feature end1 coordinate: [$feat_end1] ",
			  "in column [$feat_end1_cols[$f_ind]] on line ",
			  "[$line_num] of feature file ",
			  "[$feat_file].  Skipping.");
		    next;
		  }

		if($feat_chr1 !~ /\S/)
		  {
		    error("Invalid feature chromosome: [$feat_chr1] ",
			  "in column [$feat_chr1_cols[$f_ind]] on line ",
			  "[$line_num] of feature file ",
			  "[$feat_file].  Skipping.");
		    next;
		  }

		debug({LEVEL => 2},"FEAT STRAND BEFORE: [",
		      (defined($feat_strand) ? $feat_strand : 'undef'),"].");
		if(scalar(@feat_strand_inds))
		  {
		    if($feat_strand !~ /(\+|-|plus|minus|\d|comp|fpr|rev)/)
		      {
			error("Invalid feature strand: [$feat_strand] ",
			      "in column [$feat_strand_cols[$f_ind]] on ",
			      "line [$line_num] of feature file ",
			      "[$feat_file].  Skipping.");
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
			      "[$feat_file].  Skipping.");
			next;
		      }
		  }
		else
		  {$feat_strand = ''}
		debug({LEVEL => 2},"FEAT STRAND AFTER: [$feat_strand].");

		#Sometimes features like genes may have redundant entries.
		#For example, when you take the genes in the human genome
		#and grab the smallest and largest coordinates, many splice
		#variants will yield the same "feature".  Here, we check
		#for features that are indistinguishable
		if(exists($redund_check->{$feat_sample}) &&
		   exists($redund_check->{$feat_sample}
			  ->{"$feat_chr1:$feat_start1-$feat_end1"}))
		  {
		    warning("Skipping redundant feature found in feature ",
			    "file: [$feat_file]: [$feat_chr1:",
			    "$feat_start1-$feat_end1].");
		    next;
		  }

		my $dir = ($feat_start1 < $feat_end1 ? '+' : '-');

		#Order the coordinates
		($feat_start1,$feat_end1) = sort {$a <=> $b}
		  ($feat_start1,$feat_end1);

		debug({LEVEL => 2},"Adding feature: SAMPLE => $feat_sample, ",
		      "CHR1 => $feat_chr1, START1 => $feat_start1, ",
		      "STOP1 => $feat_end1");

		push(@{$feature_hash->{$feat_file}},
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
		$redund_check->{$feat_sample}
		  ->{"$feat_chr1:$feat_start1-$feat_end1"} = 1;
	      }

	    $sample_hash->{$feat_file}->{$feat_sample} = 1
	      if($first_feat_recorded);
	  }

	closeIn(*FEAT);

	if(!$first_feat_recorded)
	  {
	    error("No features were found in feature file: ",
		  "[$feat_file].  Skipping.");
	    next;
	  }

	#If we intend to pad rows with missing columns, check to see if
	#it's necessary, and issue a warning if that's the case
	if($pad_feat_outs && scalar(keys(%$feat_col_check)) > 1)
	  {
	    warning("The number of columns in feature file: ",
		    "[$feat_file] appears to be ",
		    "inconsistent.  Here is a listing of the number of ",
		    "columns and the number of rows with those numbers ",
		    "of columns:\n\t",
		    join("\n\t",map {"$_\t$feat_col_check->{$_}"}
			 sort {$a <=> $b} keys(%$feat_col_check)),
		    "\nRows with fewer columns than the max will be ",
		    "padded with empty columns.");

	    foreach my $fh (@{$feature_hash->{$feat_file}})
	      {
		if($fh->{COLS} < $max_feat_cols->{$feat_file})
		  {
		    my $diff = $max_feat_cols->{$feat_file} -
		      $fh->{COLS};
		    foreach(1..$diff)
		      {$fh->{OUT} .= "\t"}
		    $fh->{COLS} = $max_feat_cols->{$feat_file};
		  }
		elsif($fh->{COLS} >
		      $max_feat_cols->{$feat_file})
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
	if(!exists($feat_headers->{$feat_file}))
	  {$feat_headers->{$feat_file} =
	     [map {"ftcol($_)"}
	      grep {my $c = $_;scalar(@feat_out_cols) == 0 ||
		      scalar(grep {$_ == $c} @feat_out_cols)}
	      (1..$max_feat_cols->{$feat_file})]}
	#We can assume it cannot be more because the max was based on the
	#column header row as well
	elsif(scalar(@{$feat_headers->{$feat_file}}) <
	      $max_feat_cols->{$feat_file})
	  {
	    while(scalar(@{$feat_headers->{$feat_file}}) <
		  $max_feat_cols->{$feat_file})
	      {
		push(@{$feat_headers->{$feat_file}},
		     "ftcol(" .
		     (scalar(@{$feat_headers->{$feat_file}}) +
		      1) . ")")
	      }
	  }
	#Now I will check for any header that is an empty string
	foreach(0..$#{$feat_headers->{$feat_file}})
	  {if(!defined($feat_headers->{$feat_file}->[$_]) ||
	      $feat_headers->{$feat_file}->[$_] eq '')
	     {$feat_headers->{$feat_file}->[$_] =
		"ftcol(" . ($_ + 1) . ")"}}

	debug({LEVEL => 2},"Feature headers: [",
	      join(',',@{$feat_headers->{$feat_file}}),"].");

	##
	##Sort the feature hash based on start coordinate
	##

	@{$feature_hash->{$feat_file}} =
	  sort {$a->{START1} <=> $b->{START1}}
	    @{$feature_hash->{$feat_file}};
      }
    #Since a key already exists, it's no longer a hash of arrays, but a
    #hash of hashes (keyed on chromosome) of hashes (keyed on region) of
    #arrays of feature hashes
    elsif(scalar(keys(%{$feature_hash->{$feat_file}})) == 0)
      {
	warning("No features were parsed from feature file: ",
		"[$feat_file].  Skipping.");
	next;
      }

    #Determine the order of magnitude larger than the largest range (add 0
    #to turn this into an integer)
    my $magnitude = (1 . ('0' x length($largest_range))) + 0;

    if($search_range < 0)
      {$magnitude = 0}

    #Now (if it hasn't already been segmented - inferred by the structure)
    #segment the hash based on this magnitude
    #Note: this changes the structure of the hash to have 2 more levels of
    #keys (chromosome and region start coordinate)
    if(ref($feature_hash->{$feat_file}) eq 'ARRAY')
      {$feature_hash->{$feat_file} =
	 segmentHash($magnitude,
		     $feature_hash->{$feat_file})}

    if(scalar(keys(%{$feature_hash->{$feat_file}})) == 0)
      {
	error("No features found for feature file ",
	      "[$feat_file].");
	next;
      }

    #Commented out the following line to create the current features on the
    #fly with a narrower set of features based on a hash lookup (like a
    #histogram).
    #$current_features    = $feature_hash->{$feat_file};
    $current_sample_hash = $sample_hash->{$feat_file};

    ##
    ## Prepare the current output file
    ##

    my $outfile = getOutfile();
    openOut(*OUTPUT,$outfile) || next;

    ##
    ## Prepare the current input file
    ##

    openIn(*INPUT,$data_file) || next;

    my $print_header           = (defined($outfile) || $first_loop);
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
	verboseOverMe({FREQUENCY => $verbose_freq},'[',$data_file,
		      "] Reading line: [$line_num].");

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

	    $data_chr_hash->{$data_chr1} = 1;

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
			    "of input data file [$data_file].");
		  }
		#If there's only a single number and nothing else
		#set both start and stop to it
		elsif($data_start1 =~ /^\s*([\d,]+)\s*$/)
		  {
		    $data_start1 = $data_end1 = $1;
		    warning("Using a single coordinate: [$1] for start1 ",
			    "and end1 of input data on line [$line_num] ",
			    "of input data file [$data_file].");
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
			  "[$data_file].  Skipping.");
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
		      "[$line_num] of input file [$data_file].  ",
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
		      "[$data_file].  Start1 was ",
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
		      "[$data_file].  Skipping.");
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
			  "[$data_file].  Skipping.");
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
			  "[$data_file].  Skipping.");
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

	    debug({LEVEL => 2},"Comparing features with input record: [chr1: ",
		  "$data_chr1, start1: $data_start1, end1: $data_end1] ",
		  "using search range distance: [$search_range].");

	    #Base region membership on start coordinate
	    my $mycoord = $data_start1;
	    #If the coordinates are larger than the feature hash
	    #segmentation, resegment the hash
	    my $coord_size = abs($data_end1 - $data_start1) + 1 +
	      ($search_range >= 0 ? 2 * $search_range : 0);
	    if($search_range >= 0 && $magnitude < $coord_size)
	      {
		#Determine the new magnitude
		$magnitude = (1 . ('0' x length($coord_size))) + 0;
		#Resegment the hash
		$feature_hash->{$feat_file} =
		  segmentHash($magnitude,
			      [map {my $val = $_;map {@$_} values(%$val)}
			       values(%{$feature_hash
					  ->{$feat_file}})]);
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
	       exists($feature_hash->{$feat_file}
		      ->{$data_chr1}) &&
	       exists($feature_hash->{$feat_file}
		      ->{$data_chr1}->{$region}))
	      {push(@$current_features,
		    @{$feature_hash->{$feat_file}
			->{$data_chr1}->{$region}})}

	    #Add the features in the region containing the base coordinate
	    $region += $magnitude;
	    if(exists($feature_hash->{$feat_file}
		      ->{$data_chr1}) &&
	       exists($feature_hash->{$feat_file}
		      ->{$data_chr1}->{$region}))
	      {push(@$current_features,
		    @{$feature_hash->{$feat_file}
			->{$data_chr1}->{$region}})}

	    #Add the features from the region to the right
	    $region += $magnitude;
	    if($magnitude &&
	       exists($feature_hash->{$feat_file}
		      ->{$data_chr1}) &&
	       exists($feature_hash->{$feat_file}
		      ->{$data_chr1}->{$region}))
	      {push(@$current_features,
		    @{$feature_hash->{$feat_file}
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
		      {debug({LEVEL => 2},"Found a feature for chr1/start1/",
			     "stop1/$search_stream/$feat_orient")}
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

	    debug({LEVEL => 2},"Number of keys in current sample hash: [",
		  scalar(keys(%$current_sample_hash)),
		  "].\nFeature headers: [",
		  join(',',@{$feat_headers->{$feat_file}}),"].");

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
			   @{$feat_headers->{$feat_file}};
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
				   #assumed that a sample name using a empty
				   #string is in the current sample hash
				   join("\t",
					map
					{
					  #Determine the sample prefix to the
					  #feature column headers
					  my $smpl = ($_ ? "Smpl-$_-" : "");

					  #Prepend a sample's feature distance
					  #column header before each sample's
					  #set of feature column headers
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
					    ->{$feat_file})
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

    closeIn(*INPUT);

    #Now make sure that the format of the chromosome names is the same
    #between the current feature file and the current input file
    my @not_in_data = grep {!exists($data_chr_hash->{$_})}
      keys(%{$feat_chr_hash->{$feat_file}});
    if(scalar(@not_in_data))
      {warning("These sequence IDs in the feature file ",
	       "[$feat_file] were not found in the data file ",
	       "[$data_file]: [",join(',',@not_in_data),"].")}
    my @not_in_feat = grep {!exists($feat_chr_hash
				    ->{$feat_file}->{$_})}
      keys(%$data_chr_hash);
    if(scalar(@not_in_feat))
      {warning("These sequence IDs in the input file [$data_file] were ",
	       "not found in the feature file [$feat_file]: [",
	       join(',',@not_in_feat),"].")}

    closeOut(*OUTPUT);
  }






























##
## Subroutines
##

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
    my $search_stream          = $_[7]; #any,up,down,over,nonover,left,right
    my $feat_orient            = $_[8]; #+,-,same,opp,away,toward

    my $closest_feat           = {};
    my $closest_distance       = {};
    my $closest_feat_left      = {};
    my $closest_feat_right     = {};
    my $closest_distance_left  = {};
    my $closest_distance_right = {};

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
	debug({LEVEL => 2},"Inspecting [$chr1 $start1 $stop1] with ",
	      "[$feat->{CHR1} $feat->{START1} $feat->{STOP1}].");

	if(($feat_orient eq 'same' && $feat->{STRAND} ne $strand) ||
	   ($feat_orient eq 'opp'  && $feat->{STRAND} eq $strand))
	  {debug();next}
	elsif(($feat_orient eq '+' && $feat->{STRAND} ne '+') ||
	      ($feat_orient eq '-' && $feat->{STRAND} ne '-'))
	  {debug();next}
	elsif($search_stream ne 'any')
	  {
	    #Overlap - skip if search_stream is over & feature doesn't overlap
	    if($search_stream eq 'over' &&
	       !(($feat->{START1} >= $start1 && $feat->{START1} <= $stop1) ||
		 ($feat->{STOP1} >= $start1 && $feat->{STOP1} <= $stop1) ||
		 ($feat->{START1} < $start1 && $feat->{STOP1} > $stop1)))
	      {debug();next}

	    #Non-Overlap - skip if search_stream is nonover & feature overlaps
	    if(($search_stream eq 'nonover' || $search_stream eq 'up' ||
		$search_stream eq 'down' || $search_stream eq 'left' ||
		$search_stream eq 'right') &&
	       (($feat->{START1} >= $start1 && $feat->{START1} <= $stop1) ||
		($feat->{STOP1} >= $start1 && $feat->{STOP1} <= $stop1) ||
		($feat->{START1} < $start1 && $feat->{STOP1} > $stop1)))
	      {debug();next}

	    #Upstream/downstream - skip if feature is not in the search area
	    if($search_stream eq 'up' || $search_stream eq 'down')
	      {
		if($strand eq '+')
		  {
		    if($search_stream eq 'up' && $feat->{STOP1} >= $start1 &&
		       $feat->{START1} >= $start1)
		      {debug();next}
		    elsif($search_stream eq 'down' &&
			  $feat->{START1} <= $stop1 &&
			  $feat->{STOP1} <= $stop1)
		      {debug();next}
		  }
		elsif($strand eq '-')
		  {
		    if($search_stream eq 'down' && $feat->{STOP1} >= $start1 &&
		       $feat->{START1} >= $start1)
		      {debug();next}
		    elsif($search_stream eq 'up' &&
			  $feat->{START1} <= $stop1 &&
			  $feat->{STOP1} <= $stop1)
		      {debug();next}
		  }
		else
		  {
		    error("Invalid strand value: [$strand].");
		    next;
		  }
	      }

	    #Left/right - skip if feature is not in the search area
	    if($search_stream eq 'left' || $search_stream eq 'right')
	      {
		if($search_stream eq 'left' && $feat->{STOP1} >= $start1 &&
		   $feat->{STOP1} >= $stop1 && $feat->{START1} >= $start1 &&
		   $feat->{START1} >= $stop1)
		  {debug();next}
		elsif($search_stream eq 'right' && $feat->{START1} <= $stop1 &&
		      $feat->{START1} <= $start1 && $feat->{STOP1} <= $stop1 &&
		      $feat->{STOP1} <= $start1)
		  {debug();next}
	      }
	  }

	#Determine which side the feature is on, relative to the plus strand
	my $side = '';

	#If it's not on either side, but rather is overlapping
	if((($feat->{START1} >= $start1 && $feat->{START1} <= $stop1) ||
	    ($feat->{STOP1} >= $start1 && $feat->{STOP1} <= $stop1) ||
	    ($feat->{START1} < $start1 && $feat->{STOP1} > $stop1)))
	  {$side = 'over'}
	else
	  {$side = $feat->{START1} < $start1 ? 'left' : 'right'}

	#Away/toward
	if($feat_orient eq 'away')
	  {
	    #Version 3.6 includes overlap in away/toward searches
#	    #An overlapping feature cannot be facing away
#	    if($side eq 'over')
#	      {debug();next}

	    #Away: (side = left && feat strand = -) OR
	    #      (side = right && feat strand = +)
	    if(($feat->{STRAND} eq '+' && $side eq 'left') ||
	       ($feat->{STRAND} eq '-' && $side eq 'right'))
	      {debug();next}
	  }
	elsif($feat_orient eq 'toward')
	  {
	    #Version 3.6 includes overlap in away/toward searches
#	    #An overlapping feature cannot be facing toward
#	    if($side eq 'over')
#	      {debug();next}

	    #Toward: (side = left && feat strand = +) OR
	    #        (side = right && feat strand = -)
	    if(($feat->{STRAND} eq '+' && $side eq 'right') ||
	       ($feat->{STRAND} eq '-' && $side eq 'left'))
	      {debug();next}
	  }

	debug("Inspecting: $search_stream,$feat_orient\nDATA: $chr1,$start1,",
	      "$stop1,$strand\nFEAT: $feat->{CHR1},$feat->{START1},",
	      "$feat->{STOP1},$feat->{STRAND}");

	#Strip any distances which have been added by previous calls
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
	    debug({LEVEL => 2},"Feature Overlaps.");
	  }

	#Determine how far away this feature is (shortest distance)
	my $distance = (sort {$a <=> $b}
			(abs($start1 - $feat->{STOP1}),
			 abs($feat->{START1} - $stop1),
			 abs($start1 - $feat->{START1}),
			 abs($feat->{STOP1} - $stop1)))[0];

	debug({LEVEL => 2},"Feature is $distance away.");
	#If either of the start or stop of the feature is less than the query
	#start or stop, then it is "to the left", otherwise it's "to the
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
	    debug({LEVEL => 2},"Feature is Closer.");

	    #The closest-overall feature is handled above and below I handle the closest feature "to the left" (i.e. the coordinates of the feature are less than the coordinates of the query.  We can't handle the upstream/downstream issue because the start is always less than the stop)
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
    my $tmp_feat_hash = $feat_hash;

    if(!defined($feat_hash) || ref($feat_hash) ne 'ARRAY')
      {
	error('Expected a reference to an array, but got [',
	      (defined($feat_hash) ? ref($feat_hash) : 'undef'),'] instead.');
	return($new_feat_hash);
      }

    foreach my $feat (@$tmp_feat_hash)
      {
	my $region  = ($magnitude > 0 ? int($feat->{START1} / $magnitude) *
		       $magnitude : 0);
	push(@{$new_feat_hash->{$feat->{CHR1}}->{$region}},$feat);
      }

    return($new_feat_hash);
  }

BEGIN
  {
    $description =<< 'DESC_END';
This script takes an input data file with chromosomal coordinates and a feature file also with chromosomal coordinates (and optional sample IDs) and reports the closest feature to each pair of input coordinates.  Both the input file and feature file are optionally allowed to have multiple pairs of coordinates (e.g. structural variant coordinates that have been narrowed down to a region identifying a breakpoint).  Breakpoints come in pairs, hence multiple allowed regions.  You can either input the structural variants as the feature file or input data file.  The input data file coordinates will be output with the closest feature to each region.  Sample information is only used in the feature file to report how many samples have structural variant breakpoints near the input coordinate pairs.
DESC_END

    $input_desc = 'Tab-delimited text file.';

    $feature_input_desc = 'Tab-delimited text file.';

    $output_desc =<< 'DESC_END';
Tab-delimited text file.  Columns from the input data file and feature file are all reported in the same order unless otherwise specified by the -m or -w options respectively.  Intervening columns indicating feature distances of closest features among samples are reported.  If -u, -d, -v, -x, or -t are supplied, the feature column set specified by -w and associated intervening columns are multiplied.  See column headers to know which columns contain features associated to which samples, regions, and orientations.  Column headers in the input files will be re-used if they can be identified. Otherwise, columns from the input data files will have headers formatted as 'datcol(#)' and columns from the feature file will be formatted as 'ftcol(#)' where '#' indicates column number from the original input/feature file.  Here is an example of a full column header and what it means:

Smpl-abc-ftcol(2)[1]{over,opp}

This column contains features that were part of sample "abc" (the string "abc" was parsed from a sample column in the feature file).  This is column 2 from the feature file.  It contains features that were found close to the first chr/start/stop in the input data file.  It also only contains features that overlap the input data coordinates on the opposite strand.
DESC_END

    $iflag_desc =<< 'END_DESC';
Space-separated tab-delimited data file(s) which contain a unique data ID for each row, a sequence ID, and a start and stop coordinate.  When used with input on standard-in, the value of this paramter is used as a file name stub for naming the output files).  Note, -o can be  used to append to what is supplied here to form new output file names.  The script will expand BSD glob characters such as '*', '?', and '[...]' (e.g. -i "*.txt *.text").  See --help for a description of the input file format.
END_DESC

    $fflag_desc =<< 'END_DESC';
Space-separated tab-delimited feature file(s) which contain a unique feature ID for each row, a sequence ID, and a start and stop coordinate.  The script will expand BSD glob characters such as '*', '?', and '[...]' (e.g. -i "*.txt *.text").  See --help for a description of the feature file format.  See --help for advanced usage.
END_DESC

    $rflag_desc =<< 'END_DESC';
The maximum distance of reported features.  Features further away will not be output.  A negative value means no limit.  A 0 value means only report overlapping features.
END_DESC

    $cflag_desc =<< 'END_DESC';
The column number where the sequence ID for the start and stop can be found in the data file (see -i).  This can be a chromosome number, a GI number, or any identifier of a single contiguous sequence. This identifier must match a sequence identifier in the feature file.  More than 1 may be provided (e.g. to denote structural variants).
END_DESC

    $bflag_desc =<< 'END_DESC';
The column number where the start coordinate can be found in the data file (see -i).  The value in the column may be two numbers separated by non-numbers as long as the start is first and the stop is last (e.g. 1..526 where start=1 and stop=526). More than 1 may be provided (e.g. to denote structural variants).
END_DESC

    $eflag_desc =<< 'END_DESC';
The column number where the stop coordinate can be found in the data file (see -i).  The value in the column may be two numbers separated by non-numbers as long as the start is first and the stop is last (e.g. 1..526 where start=1 and stop=526). More than 1 may be provided (e.g. to denote structural variants).
END_DESC

    $pflag_desc =<< 'END_DESC';
The column number where the strand can be found in the data file (see -i). Note, this script is smart enough to interpret strandedness when combined with coordinate columns.  You may re-use a coordinate column to supply here as the strand column.  Here are example patterns are matched: {+,-,plus,minus,1234c, comp(1234..5678),for,rev}.  As long as a portion of the string is matched, strand will be saved.  Required if -u, -d, or -t is supplied.
END_DESC

    $mflag_desc =<< 'END_DESC';
The column number(s) (separated by non-numbers (e.g. commas)) in the data file (see -i) that are to be used in the output table (in the supplied order).  You may re- use column numbers.
END_DESC

    $sflag_desc =<< 'END_DESC';
The column number where a sample ID can be found in the feature file (see -f).  For every row of output, the samples that have features close to the coordinates in the input file will be added as a separate sample column.  '0' means there is no sample data.  Note, sample data in the data file is not supported.
END_DESC

    $aflag_desc =<< 'END_DESC';
The column number where the sequence ID for the start and stop coordinates can be found in the feature file (see -f).  This can be a chromosome number, a GI number, or any identifier of a single contiguous sequence.  This identifier must match a sequence identifier in the data file.  More than 1 may be provided (e.g. to denote structural variants).
END_DESC

    $jflag_desc =<< 'END_DESC';
The column number where the start coordinate can be found in the feature file (see -f).  The value in the column may be two numbers separated by non-numbers as long as the start is first and the stop is last (e.g. 1..526 where start=1 and stop=526). More than 1 may be provided (e.g. to denote structural variants).
END_DESC

    $kflag_desc =<< 'END_DESC';
The column number where the stop coordinate can be found in the feature file (see -f).  The value in the column may be two numbers separated by non-numbers as long as the start is first and the stop is last (e.g. 1..526 where start=1 and stop=526). More than 1 may be provided (e.g. to denote structural variants).
END_DESC

    $nflag_desc =<< 'END_DESC';
The column number where the strand can be found in the data file (see -i). Note, this script is smart enough to interpret strandedness when combined with coordinate columns.  You may re-use a coordinate column to supply here as the strand column.  Here are example patterns are matched: {+,-,plus,minus,1234c, comp(1234..5678),for,rev}.  As long as a portion of the string is matched, strand will be saved.  Required if -t is supplied.
END_DESC

    $wflag_desc =<< 'END_DESC';
The column number or numbers (separated by non-numbers (e.g. commas)) in the feature file (supplied with -f) that are to be included in the output table (in the order supplied).  You may re-use column numbers.
END_DESC

    $uflag_desc =<< 'END_DESC';
Search upstream of the input data coordinates and report closest single feature (or multiple equidistant features) found there.  Default behavior is to search upstream, downstream, and overlap and report the single closest feature (or multiple equidistant features).  Requires -p.
END_DESC

    $dflag_desc =<< 'END_DESC';
Search downstream of the input data coordinates and report the closest single feature (or multiple equidistant features) found there.  Default behavior is to search upstream, downstream, and overlap and report the single closest feature (or multiple equidistant features).  Requires -p.
END_DESC

    $lflag_desc =<< 'END_DESC';
Search left of the input data coordinates (i.e. feature coordinates are lesser than data input coordinates) and report closest single feature (or multiple equidistant features) found there.  Default behavior is to search upstream, downstream, and overlap and report the single closest feature (or multiple equidistant features).
END_DESC

    $gflag_desc =<< 'END_DESC';
Search right of the input data coordinates (i.e. feature coordinates are greater than data input coordinates) and report closest single feature (or multiple equidistant features) found there.  Default behavior is to search upstream, downstream, and overlap and report the single closest feature (or multiple equidistant features).
END_DESC

    $vflag_desc =<< 'END_DESC';
Search for overlap of the input data coordinates and report features found there. All overlapping features will be reported, even if they overlap by a single base. Default behavior is to search upstream, downstream, and overlap and report the single closest feature (or multiple equidistant features).
END_DESC

    $xflag_desc =<< 'END_DESC';
Search upstream and downstream of the input data coordinates and report the closest single feature (or multiple equidistant features) found in one of the two regions.  All overlapping features will be ignored, even if they overlap by a single base.  Default behavior is to search upstream, downstream, and overlap and report the single closest feature (or multiple equidistant features).
END_DESC

    $zflag_desc =<< 'END_DESC';
Search upstream, downstream, and the overlapping region of the input data coordinates and report the closest single feature (or multiple equidistant features) found in any of the regions.  All overlapping features will be considered equivalently closest, even if they overlap by a single base.  This is the default behavior if -u, -d, -v, -x, and -z are not supplied.
END_DESC

    $tflag_desc =<< 'END_DESC';
Report features in the supplied orientation. Default behavior is to report the closest feature in any orientation and does not require -p or -n.  Plus & minus (or + & -) require -n.  Orientations of the feature coordinates relative to the input data coordinates (same, opposite, away, toward) require -p and -n.  Away means that the feature's upstream region is closer to the input data coordinates.  Toward means that the feature's downstream region is closer.  If there is any overlap, the feature is considered neither 'away' nor 'toward', but rather 'overlapping'.  So if overlaps are included in the search (i.e. -d, -u, -v, and -x are not provided), overlapping features, regardless of orientation, will be reported instead of non-overlapping features in the away/toward orientation because the overlaps are 'closer'.  To use away/toward and ignore overlapping features, use -x.  To always report both non-overlapping away/toward features and overlapping features separately, supply both -v and -x.  You may supply multiple orientations separated by non-alphanumeric (including '_') characters. Each orientation supplied here will cause multiple sets of feature columns (specified by -w) to be reported.  This is compounded by the multiple column sets generated by -u, -d, -v, and -x.
END_DESC

    $oflag_desc =<< 'END_DESC';
This suffix is added to the input file names to use as output files. Redirecting a file into this script will result in the output file name to be "STDIN" with your suffix appended.  See --help for a description of the output file format.
END_DESC
  }

