#!/usr/bin/perl
###############################################################################
#
#    seq_filtering.pl
#
#	 Extract the fasta sequence more than 150 nt and remove the stop codon per
#    ORF.
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
use Bio::SeqIO;

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
my $threshold;
my $outputfile;

$inputfile = &overrideDefault("inputfile.fasta",'inputfile');
$threshold = &overrideDefault("threshold.value",'threshold');
$outputfile = &overrideDefault("outputfile.fasta",'outputfile');

######################################################################
# CODE
######################################################################

my $in = new Bio::SeqIO(-format => 'fasta', -file => "$inputfile");
open (OUT, ">$outputfile") or die;

while( my $seq = $in->next_seq ) {

	if (($seq->length) >= $threshold){
		print OUT ">",$seq->display_id, "\n";
		my $len = ($seq->length) -3;
		print OUT $seq->subseq(1,$len),"\n";
	}
}

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "threshold|t:s", "outputfile|o:s");
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

    seq_filtering.pl

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

	Extract the fasta sequence more than 150 nt and remove the stop codon per
    ORF.

=head1 SYNOPSIS

script.pl  -i -t -o [-h]

 [-help -h]                 Displays this basic usage information
 [-inputfile -i]            Input fasta file 
 [-length_threshold -t]     A threshold value for sequence length
 [-outputfile -o]           Outputfile
 
=cut