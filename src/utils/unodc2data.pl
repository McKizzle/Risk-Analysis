#!/usr/bin/env perl

# Extract important data from UNODC cvs data.
use strict;
use warnings;
use Data::Dumper;
use Getopt::Long;
use Text::CSV;
use Scalar::Util qw(looks_like_number);

my $file_path;
my $first_col = "Region"; # Also used to determine the start of the tabular data.
my $fill_in_blank = 0; 

GetOptions(
    "file=s" => \$file_path,
    "fill-in-blank=i" => \$fill_in_blank
);

#print "$file_path\n";
#print "$fill_in_blank\n";

open my $FILE, "<$file_path" or die "Failed to open $file_path.\n $!\n";

my $csv = Text::CSV->new({sep_char => ','});

my $indata = 0;
my $i = 0;
my @strcols = ();
my @prvvals = ();
my $max_colindex = 0;
my @extracted_data = ();
while(<$FILE>) {
    $csv->parse($_);
    my @row = $csv->fields();
    
    if($row[0] =~ m/^$first_col/) { # Header Row
        @strcols = ((0) x @row);
        @prvvals = @strcols;
        $max_colindex = @row - 1;
        $i++;
        $indata = 1;
    } elsif($indata && ($i == 1)) {  # First Row
        foreach(0...$max_colindex) {
            my $cell = $row[$_];
            
            # Look for unblank text cells.
            if(!looks_like_number($cell) && !(!defined($cell) || ($cell eq ""))) {
                #print $cell . "\n";
                $strcols[$_] = 1;
                $prvvals[$_] = $cell; # Store the filled cell value. 
            }
        }
        
        $i++;        
    } elsif($indata) { # Data rows
        # go through each row if a cell
        my @new_row = @row[0...$max_colindex];
        for(0...$max_colindex) { 
            my $cell = $row[$_];
 
            # Modify the value of $cell if it is blank but not a value cell
            # If it isn't blank and a str then update prvvals appropriately. 
            if($strcols[$_] && (!defined($cell) || ($cell eq ""))) {
                $cell = $prvvals[$_];
            } elsif($strcols[$_] && (defined($cell) || ($cell ne ""))) {
                $prvvals[$_] = $cell; 
            }

            $new_row[$_] = $cell;
        } 
        $i++;
 
        my $isblank = 1;
        foreach(@row) {
            if($_ ne '') {
                $isblank = 0;
                last;
            }
        }
        if($isblank) {
            #print Dumper \@row;
            last;
        }


        @row = @new_row;
    } 

    push @extracted_data, \@row;
}

# Print the extracted data.
$, = ", ";
foreach(@extracted_data) {
    my $row = '';
    print @$_;
    print "\n";
}

