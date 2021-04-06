## PureFTP Server

A FTP server based on the pureFTP Server.

Credits for the docker image to https://github.com/stilliard/docker-pure-ftpd

## Persistence
Data in `/home/ftpusers` and in `/etc/pure-ftpd/passwd` is persisted ( so all uploads and all created users)

### Documentation
https://github.com/stilliard/docker-pure-ftpd

### Setup

#### Ports
User a LoadBalancer to forward TCP 21 and 30000-30009 to the container

#### Configuration
Just connect to the container using the rancher shell and run

`pure-pw useradd bob -f /etc/pure-ftpd/passwd/pureftpd.passwd -m -u ftpuser -d /home/ftpusers/bob`

Thats it

