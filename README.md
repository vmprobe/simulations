# Fail-over experiment

## Servers

* NAS (i2.xlarge, $0.853/h):
  500gb of files on NAS: 50_000 10mb files
  * filenames are `sha1($i)` where `$i` is index into zipf distribution
    (example `35/6a/192b7913b04c54574d18c28d46e6395428ab`)

* 2 file servers (r3.xlarge, $0.333/h):
  * each with 30.5gb of memory

* load balancer (c4.large, $0.105/h):
  * simple nginx proxy

* 4? clients (m4.large, $0.12/h):
  * hammering load balancer
  * zipf exponent: 1.1?



## Misc

http://www.migrate2cloud.com/blog/how-to-setup-nfs-server-on-aws-ec2/
