#!/usr/bin/perl
###############################################################################
#
#    nexus_convert_phylip.pl
#
#	 Convert all the nexus-format alignments into phylip-format within the same
#    directory.
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
use Bio::AlignIO;

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

$inputdir = &overrideDefault("inputfile.dir",'inputdir');

######################################################################
# CODE
######################################################################

my $dir = "./"."$inputdir";
opendir(DIR, $dir) || die "Can't open directory $dir\n";
my @store_array = ();
@store_array = readdir(DIR);

my $name = '';

foreach my $file (@store_array) {
	next unless ($file =~ /^\S+_finalout$/);
	if ($file =~ /^(.*?)\./){
		$name = $1;
	}
	my $seqno = 0;
    my $seqlen = 0;
    my @taxid = ();
    my @align = ();
	my $sequence = '';
	my $seqname = '';
    my %hash = ();
	
  open (IN, "$dir/$file") || die "can't open file:$!\n";
  while(<IN>){
     chomp;
	 if(/\s+DIMENSIONS NTAX = (\d+)/){
	    $seqno = $1;
	}elsif(/\s+DIMENSIONS NCHAR = (\d+)/){
	    $seqlen = $1;
	}
	if($_ =~ /'/){
	   $_ =~ s/'//g;
       $_ =~ s/^\s+//g;
	   $_ =~ s/\s*;$//g;
	   #warn "$_\n";
	   @taxid = split(/\s+/,$_);
	   }
	if(/^ (\S+)$/){
	  $sequence = $1;
	  $sequence =~ s/;$//;
	  push @align, $sequence;
	  }
	 #	CHARSET span_1 = 1-1101;
	 if(/^\s+CHARSET span_(\d+) = (\d+)-(\d+)/){
	   push @{$hash{$1}}, $2, $3;
	   }
  }
	 for my $ele (keys %hash){
	   open (OUT, ">$dir/$name\_$ele.phylip") || die "can't open file:outfile\n";
	   my $partition = $hash{$ele}[1]-$hash{$ele}[0]+1;
	   my $partition2 = (int($partition/3))*3;
	   print OUT " $seqno $partition2\n";
	   for (my $i = 0; $i < @taxid; $i++){
	     $seqname = sprintf("%-20s", $taxid[$i]);
		 if(($hash{$ele}[0] % 3) == 1){
		 print OUT "$seqname", substr($align[$i], ($hash{$ele}[0]-1), $partition2), "\n";
		 }elsif(($hash{$ele}[0] % 3) == 2){
		 print OUT "$seqname", substr($align[$i], ($hash{$ele}[0]-1+2), $partition2), "\n";
		 }elsif(($hash{$ele}[0] % 3) == 0){
		 print OUT "$seqname", substr($align[$i], ($hash{$ele}[0]-1+1), $partition2), "\n";
		 }
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
    my @standard_options = ( "help|h+", "inputdir|i:s");
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

    nexus_convert_phylip.pl

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

	Convert all the nexus-format alignments into phylip-format within the same
    directory.

=head1 SYNOPSIS

script.pl  -i [-h]

 [-help -h]                Displays this basic usage information
 [-inputdir -i]            Input directory containing raw alignment file to be tested 
 
=cut
