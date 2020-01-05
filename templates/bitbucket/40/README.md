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

## Migration from < 6.9.0.2 ( <52 )
 
You will need to migrate your database postgresql from 9.4 to 11 - in this case you will need to do something like this

_before_ you upgrade the catalog to >= 6.9.0.2

!!!!!!! DO A BACKUP OF THE DATABASE BEFORE YOU START !!!!!!!!!

```
ssh rancherserver
sudo -s
docker stop bitbucket-db-container
docker volume create newdb
docker run -v bitbucket-volume:/var/lib/postgresql/9.4/data -v newdb:/var/lib/postgresql/10/data tianon/postgres-upgrade:9.4-to-10
docker inspect bitbucket-volume
cd <bitbucket-volume-location>/_data
# create an inline backup
mkdir old-backup
mv * old
# now move the migrated data onto our old volume
docker inspect newdb
mv <newdb-location>/_data/* <bitbucket-volume-location>/_data
docker volume rm newdb
```

Now upgrade the catalog and you should be up and running again

if it is all up and running, remove your inline backup

```
cd <bitbucket-volume-location>/_data/old-backup
```
