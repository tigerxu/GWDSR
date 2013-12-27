#! /usr/bin/perl
###############################################################################
#
#    run_GARDProcessor.pl
#
#	 Run a GARDProcessor analysis to confirm that the topologies differ between
#    segments and the significant recombination breakpoints.
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

my $inputdir;
my $templatefile;
my $path;

$inputdir = &overrideDefault("inputfile.dir",'inputdir');
$templatefile = &overrideDefault("template.bf",'templatefile');
$path = &overrideDefault("wd.path",'path');

######################################################################
# CODE
######################################################################

my %count = ();
opendir(DIR, $inputdir) || die "Can't open directory $inputdir\n";
my @store_array = ();
@store_array = readdir(DIR);
my $name = '';

foreach my $file (@store_array) {
	next unless ($file =~ /^\S+\.aln$/);
	if ($file =~ /^(\S+\.aln)$/){
		$name = $1;
	}
  open (IN, "$templatefile") or die;
  open (OUT, ">$inputdir/runGARDPro.$name.bf") or die;
  my $fullpath = $path.'/'.$inputdir.'/'.$file;
  while(<IN>){
   chomp;
   $_ =~ s/full path to the original alignment file/$fullpath/;
   $_ =~ s/full path to the output file with extension _splits/$fullpath.html_splits/;
   print OUT "$_\n";
  }
  system("HYPHYMPI $inputdir/runGARDPro.$name.bf > $inputdir/$name.SH.txt");
}

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputdir|i:s", "templatefile|t:s", "path|p:s");
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

    run_GARDProcessor.pl

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

	Run a GARDProcessor analysis to confirm that the topologies differ between
    segments and the significant recombination breakpoints.

=head1 SYNOPSIS

script.pl  -i -t -p [-h]

 [-help -h]                Displays this basic usage information
 [-inputdir -i]            Input directory containing raw alignment file to be tested 
 [-templatefile -t]        Batch file as template to create input by running GARDProcessor
 [-path -p]                The current working directory prompted by pwd
=cut


