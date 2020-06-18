#!/usr/bin/env perl
# tm.pl -- minimal templating script
#                  ^ ^^^ 
use strict;
use warnings;

use File::Basename qw(dirname);
use FindBin;

my $TOP = dirname($FindBin::Bin);

while (my $l = <>) {
    process_line($l);
}

sub process_line {
    my $l = shift;
    if ($l =~ /{% include=(.*) %}/) {
        process_file($1);
    } else {
        print $l;
    }
}

sub process_file {
    my $f = shift;

    my $tmpl = "$TOP/templates/$f.tmpl";
    die "bad template: $tmpl" unless -e $tmpl;
    open(my $tfh, '<', $tmpl) or die "open: $!";
    while (my $l = <$tfh>) {
        process_line($l);
    }
    close($tfh) or die "close: $!";
}
