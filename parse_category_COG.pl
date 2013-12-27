#!/user/bin/perl
###############################################################################
#
#    parse_category_COG.pl
#
#	 Assign COG functional category of best hit to the query reference
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
my $category;
my $outputfile;

$inputfile = &overrideDefault("inputfile.blast",'inputfile');
$category = &overrideDefault("input.category",'category');
$outputfile = &overrideDefault("outputfile.tab",'outputfile');

######################################################################
# CODE
######################################################################

open(WHOG,"$category") or die;
open(BLAST,"$inputfile") or die;
open(LIST, ">$outputfile") or die;
print LIST "OG_id\tCOG_id\tCOG_category\n";

my %cog = ();
my $id = '';
my $cogclass = '';
my $secendclass = '';
while(<WHOG>){
        chomp;
        if(/^\_/){next;}
        if(/^$/){next;}
        if(/\[(\S+)\]\s+(COG\d{4}\s+\S+.*)/)
        {
                $id = $1;
                $cogclass = $2;
        }elsif(/^\s+(\S+)\:\s+(.*)/){
        		$secendclass = $1;
                my $string = $2;
                my @arr = split(/\s+/,$string);
                for(my $i = 0; $i < @arr; $i ++){
                	my $ele = $arr[$i];
                	next if ($ele eq '');
                	unless (exists $cog{$ele}){       
                		$cog{$ele} = $ele."\=".$secendclass."\=".$cogclass."\=".$id;
                	}else{
                		warn "$ele:    1:$cog{$ele}\t    2:$id\n";
                	}
                }
        }else{
                my $string = $_;
                my @arr = split(/\s+/,$string);
                for(my $i = 0; $i < @arr; $i ++){
                	my $ele = $arr[$i];
                	next if ($ele eq '');
                	unless (exists $cog{$ele}){
                		$cog{$ele} = $ele."\=".$secendclass."\=".$cogclass."\=".$id;
                	}else{
                		warn "$ele:    1:$cog{$ele}\t    2:$id\n";
                	}
                }
        }
}
close(WHOG);

my %abb = ('J' => 'Translation', 
            'A' => 'RNA', 
            'K' => 'Transcription', 
            'L' => 'DNA', 
            'B' => 'Chromatin', 
            'D' => 'Cell cycle', 
            'Y' => 'Nuclear structure', 
            'V' => 'Defense', 
            'T' => 'Signal transduction', 
            'M' => 'Cell membrane', 
            'N' => 'Cell motility', 
            'Z' => 'Cytoskeleton', 
            'W' => 'Extracellular', 
            'U' => 'Secretion', 
            'O' => 'Protein turnover', 
            'C' => 'Energy', 
            'G' => 'Carbohydrate', 
            'E' => 'Amino acid', 
            'F' => 'Nucleotide', 
            'H' => 'Coenzyme', 
            'I' => 'Lipid', 
            'P' => 'Inorganic ion', 
            'Q' => 'Secondary metabolites', 
            'R' => 'General function', 
            'S' => 'Function unknown', 
            'Not in COGs' => 'Not in COGs');

my $count = 0;
my $gene = '';
my $annotation = '';
my $letters = 0;
my $flag = 0;
my $strand = '+';
my $start = 0;
my $ends = 0;
my %hash =();
my $len = 0;
my $Identities = 0;
			
while(<BLAST>){
   chomp;
   if(/^\s*$/){next;}

   if(/Query=\s+(\S+)\s*(.*)/){
   	if($count > 0){
   		my $cogid = $hash{$gene};
   		if($len == 1){
   			$cogid = '-';
   		}
   		unless(exists $cog{$cogid}){
   			$cog{$cogid} = '===Not in COGs';
   		}
   		my ($element,$secend,$class,$code) = split(/\=/,$cog{$cogid});
		if(exists $abb{$code}){
   		 print LIST "$gene\t$code\t$abb{$code}\n";
        }else{
		 print LIST "$gene\t$code\tMultiple COG categories\n";
		}   
  }
    $count++;
   	$gene = $1;
   	$flag = 0;
   	$len = 0;
   	next;
   }
  if(/No hits found/){
  	$len = 1;
  }
  if($flag < 1){
   if(/>(\S+)/){
   		$hash{$gene} = $1;
  		$flag++;
  	}
  }  
}

	my $cogid = $hash{$gene};
  if($len == 1){
  	$cogid = '-';
  }
	unless(exists $cog{$cogid}){
   	$cog{$cogid} = '===Not in COGs';
  }
  my ($element,$secend,$class,$code) = split(/\=/,$cog{$cogid});
  if(exists $abb{$code}){
   		 print LIST "$gene\t$code\t$abb{$code}\n";
        }else{
		 print LIST "$gene\t$code\tMultiple COG categories\n";
		}   

close(BLAST);

######################################################################
# TEMPLATE SUBS
######################################################################
sub checkParams {
    #-----
    # Do any and all options checking here...
    #
    my @standard_options = ( "help|h+", "inputfile|i:s", "category|l:s", "outputfile|o:s");
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

   parse_category_COG.pl

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

	Assign COG functional category of best hit to the query reference
    sequence of orthologous group.

=head1 SYNOPSIS

script.pl  -i -l -o [-h]

 [-help -h]                Displays this basic usage information
 [-inputfile -i]           BLAST output report as input file
 [-category -l]            Full hierarchy of COG function category
 [-outputfile -o]          Output file in the tabular form
 
=cut