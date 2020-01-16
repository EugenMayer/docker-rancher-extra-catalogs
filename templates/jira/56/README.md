## Atlassian JIRA server

Helps you setting up a jira server, running on a local or external database.

Based on https://github.com/eugenmayer/jira and https://hub.docker.com/r/eugenmayer/jira

## Ports

- 8080/TCP for http

## Traefik 

Integrates with with ranchers traefik catalog https://github.com/rancher/community-catalog/tree/master/templates/traefik
using rancher metadata

## Migration from < 8.6.0.1 ( <51 )

If you migrate to this version from earlier releases ( <39 aka 8.6.0.1 ) you will need to move your postgresql volume contant
from `./data` to `./` in the volume, since the official postgresql image expects the mount in `/var/lib/postgresql/data` but the old
`pg` image we use had `/var/lib/postgresql`

!!!!!!! DO A BACKUP OF THE DATABASE BEFORE YOU START !!!!!!!!!

So just stop you stack
 - `docker inspect <db container>` .. and find your volume name
 - `docker inspec <volume name>` .. and find the location
 - `cd <location>` 
 - `mv ./data/* ./`
 - `rm -fr ./data`
 
## Migration from < 8.6.0.5 ( <52 )
 
!! Be sure to have done the 8.6.0.1 before you continue with this! 

You will need to migrate your database postgresql from 9.4 to 10 - in this case you will need to do something like this

**Before** you upgrade the catalog to >= 8.6.0.2

!!!!!!! DO A BACKUP OF THE DATABASE BEFORE YOU START !!!!!!!!!

1. stop the stack

2. do this

```
ssh rancherserver
sudo -s
docker volume create newdb
docker inspect jira-db-container
# not down the volume name, we call it jira-volume here
docker run --rm -v jira-volume:/var/lib/postgresql/9.4/data -v newdb:/var/lib/postgresql/10/data tianon/postgres-upgrade:9.4-to-10
docker inspect jira-volume
cd <jira-volume-location>/_data
# create an inline backup
mkdir old-backup
mv * old
# now move the migrated data onto our old volume
docker inspect newdb
echo "host all all all md5" >> <newdb-location>/_data/pg_hba.conf
mv <newdb-location>/_data/* <jira-volume-location>/_data
docker volume rm newdb
```

Now upgrade the catalog and you should be up and running again

if it is all up and running, remove your inline backup

```
rm -fr <jira-volume-location>/_data/old-backup
```

