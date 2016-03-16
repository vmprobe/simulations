use strict;

use Time::HiRes;


my $query_filename = shift || die "need query filename";
my $output_dir = shift || die "need output dir";

die "no such query file: $!" if !-e $query_filename;
die "output directory already exists" if -e $output_dir;

mkdir($output_dir) || die "mkdir:($output_dir) $!";

open(my $fh, '>', "$output_dir/log") || die $!;

system("sudo vmprobe cache -p /mnt/postgres evict") && die;

system("sar -b 1 > $output_dir/sar_blockio &");
system("sar -r 1 > $output_dir/sar_mem &");
system("sar -u 1 > $output_dir/sar_cpu &");
sleep 2;

print $fh "cold start: " . Time::HiRes::time() . "\n";

system("sudo -u postgres psql94 < $query_filename") && die;

print $fh "cold end: " . Time::HiRes::time() . "\n";

system("sudo vmprobe cache -p /mnt/postgres snapshot > $output_dir/snapshot") && die;


system("sudo vmprobe cache -p /mnt/postgres evict") && die;

print $fh "preload start: " . Time::HiRes::time() . "\n";

system("sudo vmprobe cache -p /mnt/postgres restore < $output_dir/snapshot") && die;

print $fh "preload end: " . Time::HiRes::time() . "\n";

system("sudo -u postgres psql94 < $query_filename") && die;

print $fh "hot end: " . Time::HiRes::time() . "\n";

system("pkill sar");
