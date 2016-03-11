#!/usr/bin/env perl

use strict;

use Digest::SHA;

my $dir = shift || die "need directory";
my $num = shift || die "need number of files to preload";

$num =~ s/_//g;

for my $i (1 .. $num) {
    my $hash = Digest::SHA::sha1_hex($i);

    $hash =~ /\A(..)(..)(.*)\z/;

    my $filename = "$dir/$1/$2/$3";

    open(my $fh, '<:raw', $filename) || die "couldn't open $filename for reading: $!";

    my $junk;

    {
        undef $/;
        $junk = <$fh>;
    }
}
