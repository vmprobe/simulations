# Fail-over experiment

## Servers

* 2 file servers (r3.xlarge, $0.333/h):
  * each has mirrored copy of 500gb of files (a million 500k files)
  * each server has 30.5gb of memory, so can cache about 60_000 files
  * filenames are `sha1($i)` where `$i` is index into zipf distribution
    (example `35/6a/192b7913b04c54574d18c28d46e6395428ab`)
  * serving dir via nginx

* load balancer (m4.xlarge, $0.239/h):
  * simple nginx proxy
  * configured to send all traffic to file server 1 unless it dies, then fails over to file server 2

* 4 clients (m4.large, $0.12/h):
  * hammering load balancer
  * zipf exponent 1.3 (~97% of requests are for most-popular 10gb of files)
    $ perl -MMath::Random::Zipf -E 'my $zipf = Math::Random::Zipf->new(1_000_000, 1.3); say $zipf->cdf(20_000)'
    0.969580426626379

## Notes

https://www.nngroup.com/articles/zipf-curves-and-website-popularity/
