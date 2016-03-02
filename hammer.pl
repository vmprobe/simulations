#!/usr/bin/env perl

use strict;

use Math::Random::Zipf;
use EV;
use AnyEvent;
use AnyEvent::Util;
use Digest::SHA;
use Time::HiRes;


my $num = shift || die "need number of files in data-set";
my $exponent = shift || die "need zipf exponent";
my $url_base = shift || die "need url base";
my $freq = shift || die "need request frequency";

$num =~ s/_//g;


open(my $log_fh, '>>', 'output.log') || die "couldn't append to output.log: $!";

my $zipf = Math::Random::Zipf->new($num, $exponent);


my $timer = AE::timer 0, 1/$freq, \&issue_request;

AE::cv->recv;


sub issue_request {
    my $i = $zipf->rand();

    my $hash = Digest::SHA::sha1_hex($i);

    $hash =~ /\A(..)(..)(.*)\z/;
    my $url = "$url_base/$1/$2/$3";

    my $start_time = Time::HiRes::time();

    my $cv = run_cmd [qw(
                 curl -s
                 -w %{time_namelookup},%{time_connect},%{time_appconnect},%{time_pretransfer},%{time_redirect},%{time_starttransfer},%{time_total}
                 -o /dev/null
                 ), $url],
        '>' => \my $data;

    $cv->cb(sub {
        my $err = shift->recv;
        warn "curl failed ($err)\n" if $err;

        my $end_time = Time::HiRes::time();

        print $log_fh "$i $start_time $end_time $data\n";
    });
}
