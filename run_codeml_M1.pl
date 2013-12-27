#! /usr/bin/perl
###############################################################################
#
#    run_codeml_M1.pl
#
#    Copyright (C) 2013 Zhuofei Xu
#
#	 Run a null hypothesis model M1a using the codeml program on many coding
#    genes.
#    
#    Copyright (C) 2013 Zhuofei Xu
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>. 
#
###############################################################################

use strict;
use warnings;

#core Perl modules
use Getopt::Long;

#locally-written modules
BEGIN {
    select(STDERR);
    $| = 1;
    select(STDOUT);
    $| = 1;
}

# get input params
my $global_options = checkParams();

my $seqdir;
my $treedir;
my $outputdir;

$seqdir = &overrideDefault("alignment.dir",'seqdir');
$treedir = &overrideDefault("tree.dir",'treedir');
$outputdir = &overrideDefault("M1a.dir",'outputdir');

######################################################################
# CODE
######################################################################

 system("mkdir $outputdir"); 
 
#==============================================================

my %count = ();
opendir(DIR, $seqdir) or die;
my @store_array = ();
@store_array = readdir(DIR);
my $name = '';

foreach my $file (@store_array) {
	next unless ($file =~ /^\S+\.phylip$/);
	if ($file =~ /^(\S+)\.phylip$/){
		$name = $1;
	}
	
  open (OUT, ">$name.M1.ctl")|| die "can't open contral file:$!\n";

  print OUT "seqfile           = $seqdir/$name.phylip\n",
            "treefile          = $treedir/$name.phylip.tree\n",
            "outfile           = $outputdir/$name.M1\n",
            "noisy             = 0\n",
            "verbose           = 1\n",
            "runmode           = 0\n",
            "seqtype           = 1\n",
            "CodonFreq         = 2\n",
            "aaDist            = 0\n",
            "model             = 0\n",
            "NSsites           = 1\n",                         #modify this parameter
            "icode             = 0\n",
            "fix_kappa         = 0\n",
            "kappa             = 0\n",
            "fix_omega         = 0\n",
            "omega             = 1\n",
            "fix_alpha         = 1\n",
            "alpha             = 0\n",
            "Malpha            = 0\n",
            "ncatG             = 10\n",
            "clock             = 0\n",
            "getSE             = 0\n",
            "RateAncestor      = 0\n",
            "Small_Diff        = .5e-6\n",
            "cleandata         = 1\n";

  system("codeml $name.M1.ctl");
}
#==============================================================

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "seqdir|s:s", "treedir|t:s", "outputdir|o:s");
    my %options;

    # Add any other command line options, and the code to handle them
    # 
    GetOptions( \%options, @standard_options );
    
	#if no arguments supplied print the usage and exit
    #
    exec("pod2usage $0") if (0 == (keys (%options) ));

    # If the -help option is set, print the usage and exit
    #
    exec("pod2usage $0") if $options{'help'};

    # Compulsosy items
    #if(!exists $options{'infile'} ) { print "**ERROR: $0 : \n"; exec("pod2usage $0"); }

    return \%options;
}

sub overrideDefault
{
    #-----
    # Set and override default values for parameters
    #
    my ($default_value, $option_name) = @_;
    if(exists $global_options->{$option_name}) 
    {
        return $global_options->{$option_name};
    }
    return $default_value;
}

__DATA__

=head1 NAME

   run_codeml_M1.pl

=head1 COPYRIGHT

   Copyright (C) 2013 Zhuofei Xu

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 DESCRIPTION

	Run a null hypothesis model M1a using the codeml program on many coding
    genes.

=head1 SYNOPSIS

script.pl  -i -t -p [-h]

 [-help -h]              Displays this basic usage information
 [-seqdir -s]            Input directory containing non-recombinant alignments 
 [-treedir -t]           Input directory containing ML tree
 [-outputdir -o]         Output directory
=cut
