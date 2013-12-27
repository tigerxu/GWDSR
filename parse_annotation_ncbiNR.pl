#!/usr/bin/perl
###############################################################################
#
#    parse_annotation_ncbiNR.pl
#
#	 Assign functional description of best NCBI NR hit to the query reference
#    sequence of orthologous group.
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
use Bio::SearchIO;

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
my $outputfile;

$inputfile = &overrideDefault("inputfile.blast",'inputfile');
$outputfile = &overrideDefault("outputfile.tab",'outputfile');

######################################################################
# CODE
######################################################################

my $in = Bio::SearchIO->new(-format => 'blast',
                            -file    => $inputfile);
open (OUT, ">$outputfile") or die;
print OUT "OG_id\tFunction\n";

my $count = 0;
my $number = 0;

while( my $r = $in->next_result ) {          #read a result
  $count = 0;
  $number++;
  	if ($r->num_hits < 1){
  	 print OUT $r->query_name,"\t","No hit\n";
  	 next;
  }
  while( my $h = $r->next_hit ) {            #read a hit
    my $hitlen = $h->length;
    while( my $hsp = $h->next_hsp ) {
     my $desc = $h->description;
     if ($desc =~ /^(.*?)\s+\[(.*?)\]/){
     	my $function = $1;
     if ($count < 1){
      print OUT $r->query_name,"\t", $function,"\n";
     $count++;
     }
    }elsif ($desc =~ /^(.*)/){
     	my $function = $1;
     if ($count < 1){
      print OUT $r->query_name,"\t", $function,"\n";
     $count++;
     }
    }    
    last;
     }
    last;	 
  }
}

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "outputfile|o:s");
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

   parse_annotation_ncbiNR.pl

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

	Assign functional description of best NCBI NR hit to the query reference
    sequence of orthologous group.

=head1 SYNOPSIS

script.pl  -i -o [-h]

 [-help -h]                Displays this basic usage information
 [-inputfile -i]           BLAST output report as input file
 [-outputfile -o]          Output file in the tabular form
 
=cut