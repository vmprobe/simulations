# Fail-over experiment

## Servers

* NAS (i2.xlarge, $0.853/h):
  500gb of files on NAS: 50_000 10mb files
  * filenames are `sha1($i)` where `$i` is index into zipf distribution
    (example `35/6a/192b7913b04c54574d18c28d46e6395428ab`)

* 2 file servers (r3.xlarge, $0.333/h):
  * each with 30.5gb of memory, so can cache about 3_000 files
  * mounting NAS over NFS
  * serving mounted dir via nginx

* load balancer (m4.xlarge, $0.239/h):
  * simple nginx proxy
  * configured to send all traffic to file server 1 unless it dies, then fails over to file server 2

* 4? clients (m4.large, $0.12/h):
  * hammering load balancer
  * zipf exponent: 1.1?

## Notes

https://www.nngroup.com/articles/zipf-curves-and-website-popularity/
