Offering the [apacheDS](https://directory.apache.org/apacheds/) ldap server with the basic configuration
using rancher answers and also support for TLS, especially hand with [letsencrypt](https://github.com/EugenMayer/kontextwork-catalog/tree/master/templates/letsencrypt)

Using [this docker image](https://hub.docker.com/r/eugenmayer/apacheds/).

## Installation / Full docs

Please see the [documentation](https://github.com/EugenMayer/apacheds-build) for the installation steps and further details 

## Volumes

You end up having 3 named volumes or folders on your host : boostrap ,conf and data. See the [documentation](https://github.com/EugenMayer/apacheds-build) for further details

## After the installation

When installed, you should use your load-balancer to map the following ports:

+ Port 389 TCP no ssl on th the container port 10389
+ login to your ldap server, see first login
+ create a partition for your domain
+ restart the server once to see the partition

## SSL / Encryption

Port 389 (not 636), if you provided a SSL certificate, it will be used fo startTLS, so the current way to encrypt LDAP connections. See the [documentation](https://github.com/EugenMayer/apacheds-build) 
Combining with [letsencrypt](https://github.com/rancher/community-catalog/tree/master/templates/letsencrypt) is a pretty elegant solution to handle the SSL certificates.

## First login

You can login with 

+ user : uid=admin,ou=system
+ password: secret
+ **Change the password!**

I suggest to use [ApacheStudio](http://directory.apache.org/studio/downloads.html) to administer the LDAP Server 

## Logs

You find the logs under ```/var/lib/apacheds-2.0.0_M21/default/log/apacheds.log```