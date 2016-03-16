use common::sense;
use Data::Dumper;
use File::Temp qw/tempdir/;
use Date::Parse;
use Time::Piece;

my $query_num = shift || die "need query num";

my $data_dir = "data$query_num";
my $temp_dir = tempdir(CLEANUP => $ENV{CLEANUP} // 1);
say "tempdir: $temp_dir";


my $log = {};

{
  open(my $fh, '<', "$data_dir/log") || die $!;

  while(<$fh>) {
    /^(.*?): ([\d.]+)$/;
    $log->{$1} = $2;
  }
}


my $ymd = Time::Piece::gmtime($log->{'cold start'})->ymd;


say "$data_dir," . ($log->{'cold end'} - $log->{'cold start'}) . "," . ($log->{'preload end'} - $log->{'preload start'}) . "," . ($log->{'hot end'} - $log->{'preload end'});


my $xrange = $log->{'cold end'} - $log->{'cold start'};
my $switchover = $log->{'preload end'} - $log->{'preload start'};


{
open(my $rtps_a, '>', "$temp_dir/rtps_a") || die;
open(my $rtps_b, '>', "$temp_dir/rtps_b") || die;

open(my $breads_a, '>', "$temp_dir/breads_a") || die;
open(my $breads_b, '>', "$temp_dir/breads_b") || die;

{
  # 01:42:16 AM       tps      rtps      wtps   bread/s   bwrtn/s

  open(my $fh, '<', "$data_dir/sar_blockio") || die;

  while(<$fh>) {
    m{^(\d\d:\d\d:\d\d .M)\s+\S+\s+(\S+)\s+\S+\s+(\S+)} || next;
    my ($time, $rtps, $breads) = ($1, $2, $3);
    next unless $breads =~ /\d/;

    $time = str2time("$ymd $time", 'UTC');

    if ($time > $log->{'cold start'} && $time < $log->{'cold end'}) {
      my $time_rel = $time - $log->{'cold start'};
      print $rtps_a "$time_rel,$rtps\n";
      print $breads_a "$time_rel,$breads\n";
    } elsif ($time > $log->{'preload start'} && $time < $log->{'hot end'}) {
      my $time_rel = $time - $log->{'preload start'};
      print $rtps_b "$time_rel,$rtps\n";
      print $breads_b "$time_rel,$breads\n";
    }
  }
}
}




=pod
{
open(my $user_a, '>', "$temp_dir/user_a") || die;
open(my $user_b, '>', "$temp_dir/user_b") || die;

open(my $iowait_a, '>', "$temp_dir/iowait_a") || die;
open(my $iowait_b, '>', "$temp_dir/iowait_b") || die;

{
  # 01:42:17 AM     all      0.25      0.00      0.00      0.00      0.00     99.75

  open(my $fh, '<', "$data_dir/sar_cpu") || die;

  while(<$fh>) {
    m{^(\d\d:\d\d:\d\d .M)\s+\S+\s+(\S+)\s+\S+\s+\S+\s+(\S+)} || next;
    my ($time, $user, $iowait) = ($1, $2, $3);
    next unless $iowait =~ /\d/;

    $time = str2time("$ymd $time", 'UTC');

    if ($time > $log->{'cold start'} && $time < $log->{'cold end'}) {
      my $time_rel = $time - $log->{'cold start'};
      print $user_a "$time_rel,$user\n";   
      print $iowait_a "$time_rel,$iowait\n";
    } elsif ($time > $log->{'preload start'} && $time < $log->{'hot end'}) {
      my $time_rel = $time - $log->{'preload start'};
      print $user_b "$time_rel,$user\n";   
      print $iowait_b "$time_rel,$iowait\n";
    }
  }
}
}
=cut




foreach my $graph (qw( breads rtps )) {

my $title = $graph eq 'breads' ? 'Block read rate (blocks / s)'
                               : 'Read IOP rate (IOP / s)';

my $yrange = $graph eq 'breads' ? 350_000
                                : 5_000;

my $colour = $graph eq 'breads' ? '#0060ad'
                                : '#1d6000';

my $script = <<END;
###############

set terminal svg size 1024,1000 enhanced font 'Arial,20'
set output 'query${query_num}_$graph.svg'

set title "Postgres (query $query_num; cold cache)"
set format y "%.0s%c"

set xlabel "Time (s)"
set ylabel "$title"

set key off

set datafile separator ','

set style line 1 lc rgb '$colour' lt 1 lw 2 pt 7 ps 0.3

set xrange [0:$xrange]
set yrange [0:$yrange]

set multiplot
set size 1, 0.5

set origin 0.0,0.5
plot '$temp_dir/${graph}_a' with points ls 1


set title "Vmprobe+Postgres (query $query_num; cold cache)"

set origin 0.0,0.0
set arrow from $switchover,$yrange to $switchover,0.00 lc rgb 'red' nohead
plot '$temp_dir/${graph}_b' with points ls 1

###############
END



{
  open(my $fh, '>', "$temp_dir/script") || die;
  print $fh $script;
}

system("gnuplot $temp_dir/script");

}
