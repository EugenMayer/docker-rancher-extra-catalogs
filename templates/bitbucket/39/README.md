## Atlassian Bitbucket server

Helps you setting up a bitbucket server, running on a local or external database.

Based on https://github.com/eugenmayer/docker-image-atlassian-bitbucket and https://hub.docker.com/r/eugenmayer/bitbucket

## Ports

- 8080/TCP for http and 2201/TCP for SSH

## Traefik 

Integrates with with ranchers traefik catalog https://github.com/rancher/community-catalog/tree/master/templates/traefik
using rancher metadata

## Migration from <  6.9.0.1 ( <39)

If you migrate to this version from earlier releases ( <39 aka 6.9.0.1 ) you will need to move your postgresql volume contant
from `./data` to `./` in the volume, since the official postgresql image expects the mount in `/var/lib/postgresql/data` but the old
`pg` image we use had `/var/lib/postgresql`

!!!!!!! DO A BACKUP OF THE DATABASE BEFORE YOU START !!!!!!!!!

So just stop you stack
 - `docker inspect <db container>` .. and find your volume name
 - `docker inspec <volume name>` .. and find the location
 - `cd <location>` 
 - `mv ./data/* ./`
 - `rm -fr ./data`
