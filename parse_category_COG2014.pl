#!/user/bin/perl
###############################################################################
#
#    parse_category_COG2014.pl
#
#	 Assign COG functional category of best hit to the query reference
#    sequence of orthologous group.
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
my $category;
my $outputfile;
my $cogcsv;

$inputfile = &overrideDefault("inputfile.blast",'inputfile');
$cogcsv = &overrideDefault("cog2003-2014.csv",'cogcsv');
$category = &overrideDefault("input.category",'category');
$outputfile = &overrideDefault("outputfile.tab",'outputfile');

######################################################################
# CODE
######################################################################

open(COGDATA,"$cogcsv") or die;
open(COGC,"$category") or die;
open(LIST, ">$outputfile") or die;
print LIST "OG_id\tCOG_family\tCOG_Major_category\n";

my %hash = ();

while(<COGDATA>){
	chomp;
	#158333741,Acaryochloris_marina_MBIC11017_uid58167,158333741,432,1,432,COG0001,0,
  if(/^(\d+),.*?,(COG\d+),/){
  	$hash{$1} = $2;
  }
}
close COGDATA;

# COG0002	E	N-acetyl-gamma-glutamylphosphate reductase

my %vash = ();
my $name = '';
my $cogcode = '';
my $cogdesc = '';

while(<COGC>){
	chomp;
	if(/^(\S+)\s+(\S+)\s+(.*)$/){
		$name = $1;
		$cogcode = $2;
		$cogdesc = $3;
		$vash{$name} = "$3\t$2";
	}
}
close COGC;


my $file = $inputfile;
my $in = Bio::SearchIO->new(-format => 'blast',
                            -file    => $file);

my $count = 0;
my $number = 0;

while( my $r = $in->next_result ) {         
  $count = 0;
  $number++;
  	if ($r->num_hits < 1){
  	 print $r->query_name,"\t","Not in COG\t-\t-\t-\n";
  	 next;
  }
  while( my $h = $r->next_hit ) {           
    my $hitlen = $h->length;
    while( my $hsp = $h->next_hsp ) { 
     my $subject = $h->name;
     if ($subject =~ /^gi\|(\d+)/){
     	my $gi = $1;
     if ($count < 1){
     	my $cogid = $hash{$gi};
      print LIST $r->query_name,"\t", $cogid, ": ", $vash{$cogid}, "\n";
     $count++;
     }
    }
    last;
     }    
  }
}

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "cogcsv|c:s", "category|l:s", "outputfile|o:s");
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

   parse_category_COG2014.pl

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

	Assign COG functional category of best hit to the query reference
    sequence of orthologous group.

=head1 SYNOPSIS

script.pl  -i -c -l -o [-h]

 [-help -h]                Displays this basic usage information
 [-inputfile -i]           BLAST output report as input file
 [-cogcsv -c]              List of orthology domains
 [-category -l]            Full hierarchy of COG function category
 [-outputfile -o]          Output file in the tabular form
 
=cut
