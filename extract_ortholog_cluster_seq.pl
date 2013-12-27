#!/usr/bin/perl
###############################################################################
#
#    extract_ortholog_cluster_seq.pl
#
#	 Extract the gene sequences of each orthologous group into individual
#    file in FASTA format.
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

my $inputfile;
my $orthologlist;
my $outputdir;

$inputfile = &overrideDefault("inputfile.clstr",'inputfile');
$orthologlist = &overrideDefault("ortholog.list",'orthologlist');
$outputdir = &overrideDefault("outputfile.dir",'outputdir');
 


######################################################################
# CODE
######################################################################

open (SEQ, "$inputfile") or die;

local $/ = '>';
my %hash = ();

while(<SEQ>){
	chomp;
	my ($name, $sequence) = split (/\n/, $_, 2);
	next unless ($name && $sequence);
	my ($n) = $name =~ /^(\S+)/;
	$sequence =~ s/\s+|\n|\-//g;
	$hash{$n} = $sequence;
}
close(SEQ);

open (LIST, "$orthologlist") or die;

my $dir = "./"."$outputdir";

system("mkdir $outputdir");

my $d = 0;
my $new_d = 0;

while(<LIST>){
	chomp;

	my @array = split (/\n/, $_);
	for my $ele (@array){
       $d++;
	   $new_d = sprintf("%04d",$d);	
	   my @cluster = split (/\s+/, $ele);
	   my $fna_file = "OG$new_d".".fa";

		open (OUT, ">$dir/$fna_file") || die "cannot open $fna_file\n";
		for my $ele (@cluster){
		 if(exists $hash{$ele}){
          print OUT ">$ele\n$hash{$ele}\n";
		  }else{
		  warn "error! The gene id is missing in the sequence file.\n";
		  }
    }		  
}
}
close(LIST);

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "orthologlist|l:s", "outputdir|o:s");
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

    extract_ortholog_cluster_seq.pl

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

	Extract the gene sequences of each orthologous group into individual
    file in FASTA format.

=head1 SYNOPSIS

script.pl  -i -l -o [-h]

 [-help -h]                 Displays this basic usage information
 [-inputfile -i]            Input fasta sequence file containing genes from all genomes 
 [-orthologlist -l]         The list of gene identifiers of all othologous cluster
 [-outputdir -o]            A directory of output fasta sequence files
 
=cut


