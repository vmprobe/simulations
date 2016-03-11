#!/usr/bin/env perl

use strict;

use Digest::SHA;
use List::Util;
use Session::Token;

my $dir = shift || die "need base dir";
my $num = shift || die "need number of files in data-set";
my $size = shift || die "need file size";

$num =~ s/_//g;
$size =~ s/_//g;

my $gen = Session::Token->new(alphabet => [ map { chr } (0 .. 255) ], length => $size, seed => "\x00" x 1024);
srand(0);

my $curr = 1;

for my $i (List::Util::shuffle(1 .. $num)) {
    my $hash = Digest::SHA::sha1_hex($i);

    $hash =~ /\A(..)(..)(.*)\z/;

    mkdir("$dir/$1");
    mkdir("$dir/$1/$2");

    my $filename = "$dir/$1/$2/$3";

    print "$curr: $i -> $filename\n";
    $curr++;

    open(my $fh, '>:raw', $filename) || die "couldn't open $filename for writing: $!";
    print $fh $gen->get;
}
