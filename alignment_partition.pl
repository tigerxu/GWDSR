#!/usr/bin/perl
###############################################################################
#
#    alignment_partition.pl
#
#	 Use the position of significant breakpoints to partition alignment. The
#    output partitioned alignment is in phylip format.
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
my $inputlist;
my $outputdir;
$inputdir = &overrideDefault("inputfile.dir",'inputdir');
$inputlist = &overrideDefault("input.list",'inputlist');
$outputdir = &overrideDefault("outputfile.dir",'outputdir');

system("mkdir $outputdir"); 

######################################################################
# CODE
######################################################################

  open (LIST, "$inputlist") or die;
  my %hash = ();
  my $bf = '';
  my $gene = '';
  my @array = ();
  
 while(<LIST>){
   chomp;
   if(/^(\S+)\s+\d+\s+(.*)\s+\d+$/){
     $gene = $1;
	 $bf = $2;
	 #warn "$bf\n";
	 if($bf eq 'None'){
	   $hash{$gene} = 'none';
	   }else{
	     @array = split(/\s+/, $bf);
	     for my $ele (@array){
		   push @{$hash{$gene}}, $ele;
		  }
	 }
	 }
}
close LIST;

opendir(DIR, "$inputdir") or die;
my @store_array = ();
@store_array = readdir(DIR);

foreach my $file (@store_array) {
	my $name = '';
	next unless ($file =~ /^\S+\.aln$/);
	if ($file =~ /^(\S+)\.improved\.aln$/){
		$name = $1;
	}
  my $in = Bio::AlignIO->new(-format => 'fasta',
                             -file   => "$inputdir/$file");
	
  if( my $aln = $in->next_aln ){
     my $col_start = 1;
	 my $col_end = $aln->length;
	 if($hash{$name} eq 'none'){
	  my $out = Bio::AlignIO->new(-format => 'phylip',
	                             -idlength=> 20,
								 -interleaved => 0,
                                 -file   => ">$outputdir/$name.phylip");
	  my $piece = $aln->slice($col_start, $col_end);
      $out->write_aln($piece);
	 }else{
	   my $count = 0;
	   for (my $i = 0; $i < scalar @{$hash{$name}}; $i++){
	     $col_end = (int(($hash{$name}[$i])/3))*3;
		 $count = $i+1;
	     my $out = Bio::AlignIO->new(-format => 'phylip',
	                             -idlength=> 20,
								 -interleaved => 0,
                                 -file   => ">$outputdir/$name-$count.phylip");
		 if(($col_start % 3) == 1){
	       my $piece = $aln->slice($col_start, $col_end);
           $out->write_aln($piece);
		   $col_start = $hash{$name}[$i] + 1;
		}elsif(($col_start % 3) == 2){
		   my $piece = $aln->slice(($col_start+2), $col_end);
           $out->write_aln($piece);
		   $col_start = $hash{$name}[$i] + 1;
		}elsif(($col_start % 3) == 0){
		   my $piece = $aln->slice(($col_start+1), $col_end);
           $out->write_aln($piece);
		   $col_start = $hash{$name}[$i] + 1;
		}
	}
	  $count++;
	  $col_end = $aln->length;
	  my $out = Bio::AlignIO->new(-format => 'phylip',
	                             -idlength=> 20,
								 -interleaved => 0,
                                 -file   => ">$outputdir/$name-$count.phylip");
		 if(($col_start % 3) == 1){
	       my $piece = $aln->slice($col_start, $col_end);
           $out->write_aln($piece);
		}elsif(($col_start % 3) == 2){
		   my $piece = $aln->slice(($col_start+2), $col_end);
           $out->write_aln($piece);
		}elsif(($col_start % 3) == 0){
		   my $piece = $aln->slice(($col_start+1), $col_end);
           $out->write_aln($piece);
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
    my @standard_options = ( "help|h+", "inputdir|i:s", "inputlist|t:s", "outputdir|o:s");
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

    alignment_partition.pl

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

	Use the position of significant breakpoints to partition alignment. The
    output partitioned alignment is in phylip format.

=head1 SYNOPSIS

script.pl -i -t -o [-h]

 [-help -h]                Displays this basic usage information
 [-inputdir -i]            Input directory containing alignment files for the GARD test
 [-inputlist -t]           Input list containing breakpoint positions in the alignment
 [-outputdir -o]           Output dir
 
=cut