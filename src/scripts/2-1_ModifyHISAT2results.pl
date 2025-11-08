#!/usr/bin/perl -w
use strict;

#20191216_okada
#project: CRESTwheat
#usage: perl 02_ModifyAlignmentResults_tagseq.pl input output

my $input = $ARGV[0];
my $dest = $ARGV[1];

push (my @sample_name, "Sample name\t");
push (my @read_number, "read number\t");
push (my @paired, "paired reads\t");
push (my @paired2, "paired multi\t");
push (my @disc, "discordantly\t");
push (my @align0, "aligned 0 time\t");
push (my @align1, "exactly 1 times\t");
push (my @align2, "> 1 time\t");
push (my @rate, "over all alignment rate\t");

open (IN, $input) or die "cannot open input file";
open (DEST, ">$dest") or die "cannot create dest";
while (<IN>) {
    chomp;
    @_ = $_;
    $_ =~ s/^\s+//;
    if (/# start/){
        my $sample = $_;
        $sample =~ s/# start //;
        push (@sample_name, "$sample\t");
    }elsif (/(^.*)(\sreads;\sof\sthese:)/) {
        push (@read_number, "$1\t");
    }elsif(/(^.*)\s\(.*\%\)\saligned\sconcordantly\sexactly\s1\stime/){
        push (@paired, "$1\t");
    }elsif(/(^.*)\s\(.*\%\)\saligned\sconcordantly\s>1\stimes/){
        push (@paired2, "$1\t");
    }elsif(/(^.*)\s\(.*\%\)\saligned\sdiscordantly/){
        push (@disc, "$1\t");
    }elsif(/(^.*)\s\(.*\%\)\saligned\s0\stimes/){
        push (@align0, "$1\t");
    }elsif(/(^.*)\s\(.*\%\)\saligned\sexactly\s1\stime/){
        push (@align1, "$1\t");
    }elsif(/(^.*)\s\(.*\%\)\saligned\s>1\stimes/){
        push (@align2, "$1\t");
    }elsif(/(^.*)\soverall\salignment\srate/){
        push (@rate, "$1\t");
    }else{
        next;
    }
}

print DEST "@sample_name\n@read_number\n@paired\n@paired2\n@disc\n@align0\n@align1\n@align2\n@rate\n";

close IN;
close DEST;
