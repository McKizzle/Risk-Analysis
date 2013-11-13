#!/usr/bin/env perl

# Extract important data from UCR csvs

use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;

my $file_path;
# my $crime_type;

GetOptions(
    "file=s" => \$file_path
);

open my $FILE, "<$file_path" or die "Failed to open $file_path.\n $!\n";

my $indata = 0;
while(<$FILE>) {
    if($_ =~ m/(^[Yy]ear\s*,)|(^\d{4}\s*,)/) { 
        $indata = 1;
        print $_;
    } else {
        $indata = 0;
    }

    #if($indata) {
    #    print $_;
    #}
}



