#! user/bin/perl
###############################################################################
#
#    corr_fasta_header.pl
#
#	 Simplify the fasta header in fasta files.
#    
#    Copyright (C) 2013 Zhuofei Xu
#
#
###############################################################################

use strict;
use warnings;
die "Usage: perl $0 fasta.ffn genome_id > corrected_header.fa \n" if(@ARGV != 2);

open (IN, "$ARGV[0]")||die "Can't open IN: $!\n";

my $input = $ARGV[1];

my $d = 0;
my $new_d = 0000;

while (<IN>){
	chomp;
	if (/^>(.*)/){
	    $d++;
		$new_d = sprintf("%04d",$d);
		print ">$ARGV[1]"."_$new_d\n";
		
	}
	else {
	print "$_\n";
	}
}
close (IN);