#!/usr/bin/env perl

use strict;

use Digest::SHA;

my $dir = shift || die "need base dir";
my $num = shift || die "need number of files in data-set";
my $size = shift || die "need file size";

$num =~ s/_//g;
$size =~ s/_//g;

for my $i (1 .. $num) {
    my $hash = Digest::SHA::sha1_hex($i);

    $hash =~ /\A(..)(..)(.*)\z/;

    mkdir("$dir/$1");
    mkdir("$dir/$1/$2");

    my $filename = "$dir/$1/$2/$3";

    system("dd if=/dev/urandom of=$filename bs=$size count=1");
}
