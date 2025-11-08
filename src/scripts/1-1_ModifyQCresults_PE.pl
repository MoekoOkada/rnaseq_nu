#!/usr/bin/perl -w
use strict;

#20211008_okada
#usage: perl 2-1_ModifyQCresults.pl input output


my $input = $ARGV[0];
my $output = $ARGV[1];

push (my @name, "sample\t");
push (my @both, "Both surviving\t");
push (my @F, "Forward only surviving\t");
push (my @R, "Reverse only surviving\t");
push (my @Drop, "Dropped\t");


open (IN, $input) or die "cannot open results";
open(DEST, ">$output") or die "cannot create outputPE";

while (<IN>){
    chomp;
    @_ = $_;
    if (/# start /){
        my $sample = $_;
        $sample =~ s/# start //;
        print $sample;
        push (@name, "$sample\t");
    }elsif (/^Input/){
        push (@both, "$2\t") if (/(Both\sSurviving\:\s)(.*)(\s\(.*\%\)\s)Forward/);
        push (@F, "$2\t") if (/(Forward\sOnly\sSurviving\:\s)(.*)(\s\(.*\%\)\s)Reverse/);
        push (@R, "$2\t") if (/(Reverse\sOnly\sSurviving\:\s)(.*)(\s\(.*\%\)\s)Drop/);
        push (@Drop, "$2\t") if (/(Dropped\:\s)(.*)(\s\(.*\))/);
    }else{
        next;
    }
}

print DEST "@name\n@both\n@F\n@R\n@Drop\n";

close IN;
close DEST;


