#! user/bin/perl
###############################################################################
#
#    fasta_header_rename.pl
#
#    Copyright (C) 2013 Zhuofei Xu
#
#	 Simplify the fasta header of each sequence record to create required input
#    data file by PAML.
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
my $ingenomeid;
my $outputfile;

$inputfile = &overrideDefault("inputfile.fasta",'inputfile');
$ingenomeid = &overrideDefault("genomeid",'ingenomeid');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');
 


######################################################################
# CODE
######################################################################

	
open (IN, "$inputfile") or die;
open (OUT, ">$outputfile") or die;

my $d = 0;
my $new_d = 0000;

while (<IN>){
	chomp;
	if (/^>(.*)/){
	    $d++;
		$new_d = sprintf("%04d",$d);
		print ">$ingenomeid"."_$new_d\n";
		
	}
	else {
	print OUT "$_\n";
	}
}
close (IN);

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "ingenomeid|d:s", "outputfile|o:s");
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

    fasta_header_rename.pl

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

	Simplify the fasta header of each sequence record to create required input
    data file by PAML.

=head1 SYNOPSIS

script.pl  -i -d -o [-h]

 [-help -h]                 Displays this basic usage information
 [-inputfile -i]            Input fasta file 
 [-genome_identifier -d]    A short identifier instead of GenBank accession number
 [-outputfile -o]           Outputfile
 
=cut