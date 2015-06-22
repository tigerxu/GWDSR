 #!/usr/bin/perl
###############################################################################
#
#    parse_codeml_M1a.pl
#
#	 Parse information from the output based on the model M1a.
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

my $inputdir;
my $outputfile;

$inputdir = &overrideDefault("inputfile.dir",'inputdir');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');

######################################################################
# CODE
######################################################################

  open (OUT, ">$outputfile") or die;
	
  print OUT "OG_ID\tLikelihood (M1a)";       #extract model1a results
# lnL(ntime: 21  np: 24):  -1587.359539      +0.000000
# lnL(ntime: 43  np: 46):  -6326.833436      +0.000000
  opendir(DIR, $inputdir) or die;

  
my @store_array = ();
@store_array = readdir(DIR);
my $name = '';
my @array = ();

foreach my $file (@store_array) {
	@array = ();
 	next unless ($file =~ /^(\S+)\.M1/);
 	if ($file =~ /^(\S+)\.M1/){
		$name = $1;
	} 
  print OUT "\n$name\t";
  my $outcodeml = "$inputdir/$file";
  
  open (DATA, $outcodeml) or die;
  while(<DATA>){
    chomp;
	if(/^lnL\(ntime:.*\):\s+(\S+)\s+/){
	  print OUT "$1\t";
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
    my @standard_options = ( "help|h+", "inputdir|i:s", "outputfile|o:s");
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

    parse_codeml_M1a.pl

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

	Parse information from the output based on the model M1a.

=head1 SYNOPSIS

script.pl -i -o [-h]

 [-help -h]                Displays this basic usage information
 [-inputdir -i]            Input directory containing the output of M1a
 [-outputfile -o]          Output file
 
=cut
