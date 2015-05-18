#!/usr/bin/perl -w
###############################################################################
#
#    ortholog_list.pl
#
#	 Extract a list of single copy orthologous gene per genome based on the 
#    .clstr file.
#    
#    Copyright (C) 2015 Zhuofei Xu
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

my $inputfile;
my $genomenumber;
my $outputfile;

$inputfile = &overrideDefault("inputfile.clstr",'inputfile');
$genomenumber = &overrideDefault("genome.number",'genomenumber');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
 


######################################################################
# CODE
######################################################################

open (IN, "$inputfile") or die;
open (OUT, ">$outputfile") or die;

my $count = 0;
my @array = ();
my %hash = ();
my $locustag = '';
my $strainame = '';
my $geneno = 0;

while (<IN>){
	chomp;
	if (/^>Cluster/){
	  foreach my $flag (keys %hash){
       $count++;
	   }
	   $geneno = scalar @array;
	    if(($count == $genomenumber) && ($geneno == $genomenumber)){
		  print OUT join("\t",@array), "\n";
		  }
		$count = 0;
		$geneno = 0;
		@array = ();
		%hash = ();
	}
		if(/\s+>(\S+.*?)\.\.\./){
		  $locustag = $1;
		  push @array, $locustag;
		  if($locustag =~ /(\S+)_\d+/){
		   $strainame = $1;
		   $hash{$strainame}++;
		  #$count++;
		  }
		}
}
close (IN);

	foreach my $flag (keys %hash){
       $count++;
	   }
	   	$geneno = scalar @array;
	    if(($count == $genomenumber) && ($geneno = $genomenumber)){
		  print OUT join("\t",@array), "\n";
		  }

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "genomenumber|t:s", "outputfile|o:s");
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

    ortholog_list.pl

=head1 COPYRIGHT

   Copyright (C) 2015 Zhuofei Xu

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

	Extract a list of single copy orthologous gene per genome based on the 
    .clstr file.

=head1 SYNOPSIS

script.pl  -i -t -o [-h]

 [-help -h]                 Displays this basic usage information
 [-inputfile -i]            Input .clstr file output by CD-HIT 
 [-genome_number -t]        The number of genomes used
 [-outputfile -o]           A list of single copy orthologous gene per genome
 
=cut
