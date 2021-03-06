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


my $timer;

sub start_timer {
    $timer = AE::timer rand(2/$freq), 0, sub {
        issue_request();
        start_timer();
    };
}

start_timer();

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

        my $duration = Time::HiRes::time() - $start_time;

        print $log_fh "$start_time,$duration,$i,$data\n";
    });
}
