 #!/usr/bin/perl
###############################################################################
#
#    parse_codeml_M2a.pl
#
#	 Parse information from the output based on the model M2a.
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

my $inputdir;
my $outputfile;

$inputdir = &overrideDefault("inputfile.dir",'inputdir');
$outputfile = &overrideDefault("outputfile.txt",'outputfile');

######################################################################
# CODE
######################################################################

  use Bio::Tools::Phylo::PAML;
  use Bio::Tools::Phylo::PAML::Result;
  use Bio::Tools::Phylo::PAML::ModelResult;
  use Bio::Seq;
  use Bio::SeqIO;
  use Bio::PrimarySeq;

  open (OUT, ">$outputfile") or die;
  print OUT "OG_ID\tLikelihood (M2a)\tp2\tw2\tPositively selected sites";       #extract model1a results

  opendir(DIR, $inputdir) or die;
  
my @store_array = ();
@store_array = readdir(DIR);
my $name = '';
my @array = ();

foreach my $file (@store_array) {
	@array = ();
 	next unless ($file =~ /^(\S+)\.M2/);
 	if ($file =~ /^(\S+)\.M2/){
		$name = $1;
	} 
  print OUT "\n$name\t";
  my $outcodeml = "$inputdir/$file";
  my $parser = Bio::Tools::Phylo::PAML->new(-file => $outcodeml);
  my $result = $parser->next_result();

  for my $modelresult ( $result->get_NSSite_results ) {
  # get any general model parameters: kappa (the
  # transition/transversion ratio), NSsites model parameters ("p0",
  # "p1", "w0", "w1", etc.), etc.

  print OUT $modelresult->likelihood, "\t";
  print OUT $modelresult->dnds_site_classes->{p}[2], "\t";
  print OUT $modelresult->dnds_site_classes->{w}[2], "\t";
  foreach my $model ( $result->get_NSSite_results ) {
    	for my $sites ( $model->get_BEB_pos_selected_sites ) {
    		    if (@$sites[3] cmp ''){
              push (@array, @$sites[0]);
           }
    		  }print OUT join(', ', @array), "\t";
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

    parse_codeml_M2a.pl

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

	Parse information from the output based on the model M2a.

=head1 SYNOPSIS

script.pl -i -o [-h]

 [-help -h]                Displays this basic usage information
 [-inputdir -i]            Input directory containing the output of M2a
 [-outputfile -o]          Output file
 
=cut