#!/usr/bin/perl -w

# Script:  subsample.pl
# Purpose: Subsample FASTA or FASTQ files
# Author:  Richard Leggett

use warnings;
use strict;

use Getopt::Long;

my $input_r1_file;
my $output_r1_file;
my $remainder_r1_file;

my $wc_file;
my $n_reads = 0;
my $number_required;
my %keep;
my $fasta;
my $fastq;
my $lines_per_entry = 4;
my $help_requested;
my $id_marker = "@";
my $min_length = 1;
my %n_to_id;
my %n_to_length;

&GetOptions(
    'a:s' => \$input_r1_file,
    'c:s' => \$output_r1_file,
    'e:s' => \$remainder_r1_file,
    'h|help' => \$help_requested,
    'n:i' => \$number_required,
    'p|fasta' => \$fasta,
    'q|fastq' => \$fastq,
    'l|minlength:i' => \$min_length,
    'reads|r:i' => \$n_reads
);

if (defined $help_requested) {
    print "\nSubsample from FASTA or FASTQ files.\n\n";
    print "Usage: subsample.pl <-a input R1> <-b input R2> <-c output R1> <-d output R2> [options]\n\n";
    print "Options:\n";
    print "    -a               input R1 file\n";
    print "    -c               output R1 file\n";
    print "    -e               remainder R1 file\n";
    print "    -n               number of reads required\n";
    print "    -r | -reads      number of reads in file\n";
    print "                     (if not specified, will be found with wc\n";
    print "    -p | -fasta      FASTA format\n";
    print "    -q | -fastq      FASTQ format (defualt)\n";
    print "    -l | -minlength  Minimum read length (default 1)\n";
    print "\n";
    exit;
}

die "You must specify how many reads you require" if not defined $number_required;
die "You must specify an input R1 file" if not defined $input_r1_file;
die "You must specify an output R1 file" if not defined $output_r1_file;

if (defined $fasta) {
    $lines_per_entry = 2;
    $id_marker = ">";
} else {
    $lines_per_entry = 4;
    $id_marker = "@";
}

# Read read lengths
print "Lines per entry ".$lines_per_entry."\n";
print "Reading lengths...";
my $output_filename = $input_r1_file.".lengths";
open(INFILE, $input_r1_file) or die;
open(OUTFILE, ">".$output_filename) or die; 
while(my $line = <INFILE>) {
    my @lines_a;
    my $id_a;
    my $read_length = 0;

    $lines_a[0] = $line;
    for (my $i=1; $i<$lines_per_entry; $i++) {
        $lines_a[$i] = <INFILE>;
    }

    if ($lines_a[0] =~ /$id_marker(\S+)/) {
        $id_a = $1;
    } else {
        die "Can't get ID line from ".$lines_a[0];
    }

    chomp(my $r = $lines_a[1]);
    $read_length = length($r);

    print OUTFILE $id_a."\t".$read_length."\n";
    $n_to_id{$n_reads} = $id_a;
    $n_to_length{$n_reads} = $read_length;
    $n_reads++;
}
close(INFILE);
close(OUTFILE);

die "No entries in file!\n" if ($n_reads == 0);
die "Less entries in file than you asked for!" if ($n_reads <= $number_required);

print "Choosing ".$number_required." entries from ".$n_reads." with min length ".$min_length."...\n";

for (my $i=0; $i<$number_required; $i++) {
    my $r;
    my $tries = 0;
    my $got_one;

    do {
        $r = int(rand($n_reads));
        if ((!defined $keep{$r}) && ($n_to_length{$r} >= $min_length)) {
            $got_one = $r;
        }
        $tries++;
    } while ((!defined $got_one) && ($tries < 10000));

    if (!defined $got_one) {
       die "Gave up trying after 10,000 tries";
    } else {
        $keep{$got_one} = 1;
    }
}

print "Writing output file...\n";

open(my $input_a, $input_r1_file) or die;
open(my $output_a, ">".$output_r1_file) or die;
my $remainder_a;

if (defined $remainder_r1_file) {
    open($remainder_a, ">".$remainder_r1_file) or die;
}

my $n = 0;
while(my $line = <$input_a>) {
    my @lines_a;
    my $id_a;

    $lines_a[0] = $line;
    for (my $i=1; $i<$lines_per_entry; $i++) {
        $lines_a[$i] = <$input_a>;
    }
    
    if ($lines_a[0] =~ /$id_marker(\S+)/) {
        $id_a = $1;
    } else {
        die "Can't get ID line from ".$lines_a[0];
    }
    
    if ($id_a ne $n_to_id{$n}) {
        die "Id ".$id_a." unexpected - ".$n_to_id{$n}."\n";
    }


    for (my $i=0; $i<$lines_per_entry; $i++) {
        if (defined $keep{$n}) {
            print $output_a $lines_a[$i];
        } else {
            if (defined $remainder_r1_file) {
                print $remainder_a $lines_a[$i] if defined $remainder_a;
            }
        }
    }

    $n++;
}

close($input_a);
close($output_a);

if (defined $remainder_r1_file) {
    close($remainder_a) if defined $remainder_a;
}

print "DONE\n";
