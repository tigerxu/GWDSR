#!/usr/bin/perl
###############################################################################
#
#    summary_breakpoint.pl
#
#	 Summary significant breakpoints by the SH test.
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

my $inputdir;
my $outputfile;

$inputdir = &overrideDefault("inputfile.dir",'inputdir');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');

######################################################################
# CODE
######################################################################

my $dir = "./"."$inputdir";
my $name = '';
opendir(DIR, $dir) || die "Can't open directory $dir\n";
my @array = ();
@array = readdir(DIR);

open (OUT, ">$outputfile") or die;
print OUT "OG_ID\tLength (bp)\tBreakpoint sites\tNumber of Breakpoint\n";

foreach my $file (@array){
	next unless ($file =~ /^\S+.SH.txt$/);
	if ($file =~ /^(\S.*?)\./){
		$name = $1;
		print OUT "$name\t";
	}
	my $alnlen = 0;
	my $bp = '';
	my $lhs = 0;
	my $rhs = 0;
	my $count = 0;
	
	open (IN, "$dir/$file") or die;
	while(<IN>){
	  chomp;
	  if(/^Sites\s{5}:(\d+)/){
	    $alnlen = $1;
		print OUT "$alnlen\t";
		}
	  if(/^\s{7}(\d+)\s+\|\s+\S+\s+\|\s+(\S+)\s+\|\s+\S+\s+\|\s+(\S+)\s*$/){
	     $bp = $1;
		 $lhs = $2;
		 $rhs = $3;
		 if(($lhs < 0.05) && ($rhs < 0.05)){
		  print OUT "$bp  ";
		  $count++;
		  }
		  }
	  if(/^Mean splits identify:/){
	    if($count == 0){
		 print OUT "None\t$count\n";
		 }else{
		 print OUT "\t$count\n";
		}
		}
		}
}
closedir (DIR);

######################################################################
# The corrected p-values of SH-test
#Breakpoint | LHS Raw p | LHS adjusted p | RHS Raw p | RHS adjusted p 
#       291 |   0.00140 |        0.00840 |   0.00010 |        0.00060
#       411 |   0.01210 |        0.07260 |   0.00010 |        0.00060
#       517 |   0.00010 |        0.00060 |   0.01740 |        0.10440
#####################################################################

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputdir|i:s", "outputfile|o:s");
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

    summary_breakpoint.pl

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

	Summary significant breakpoints by the SH test.

=head1 SYNOPSIS

script.pl -i -o [-h]

 [-help -h]                Displays this basic usage information
 [-inputdir -i]            Input directory containing the text report of SH test
 [-outputfile -o]          Output file
 
=cut

