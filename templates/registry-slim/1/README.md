### Installs Portus and the docker Regstry v2 - but with a rather slim infrastructural footprint

It is based on [registry](https://github.com/rancher/community-catalog/tree/master/templates/registry)
and serves exactly the same need while having a newer portus build, some infrastructural differences and also additional features ( domains and ssl ):

While original registry catalog might offer a better "out of the box" experience, this catalog aims for production an

## 1. More recent builds of portus
As a companion to this catalog, i started to build/package portus [myself](https://github.com/EugenMayer/portus-build) and released on [hub.github.io](https://hub.docker.com/r/eugenmayer/portus/)

This builds of portus include the newest feature like deleting images and tags and also some important bugfixes for portus all build on the vanilla [SUSE/portus repo](https://github.com/SUSE/Portus) 

## 2. Not including LB/Nginx
We do not expose or add a loadbalancer/ssl proxy but rather require you to use your rancher-lb for routing

Reason: 

The current catalogs seem to boldly bind on the hosts 443 port - well that will work for one catalog app, all the others will fail.
Instead you are now required to use a central load-balancer that binds to 443 and then routes to all your catalog apps, also doing ssl termination.
Sound complicated, but in case, its very easy, see [ranchers virtual host routing howto](http://rancher.com/virtual-host-routing-using-rancher-load-balancer/)

+ Your portus lb entry usually routes from 443 to port 3000 of the portus service
+ Your registry lb entry usually routes from 443 to port 5000 of the registry service   

Also, there is no need for an nginx ssl proxy at all, i yet do not know why its there in the original approach at all.

## 3. We do not setup a mysql server
.. , but rather require you to setup one.
Reason:
Since portus yet does not enable you to connect to several registries, you end up having several portus+registry "packs" - each for the registry you need.
In this case running a dedicated mysql server for each is a heavy overkill. Beside that, its usually and overkill to run every low-frequency infrastructure app with a 
dedicated mysql server. 

Deploy yourself a mysql-server as a service, use the image you like most.

+ [Percona](https://hub.docker.com/_/percona/)
+ [MariaDB](https://hub.docker.com/_/mariadb/)
+ [https://hub.docker.com/_/mysql/](https://hub.docker.com/_/mariadb/)

Set MYSQL_ROOT_PASSWORD as you like and set the same password when setting up this catalog in "Password for the mysql root connection"

## 4. You can use different domains for the registry and portus
While the original image forces you to run both on the same domain, here its supported to run them on different ones like portus.domain.tld and registry.domain.tld

## 5. Official SSL the easy way: 
Using the letsencrypt catalog [letsencrypt](https://github.com/EugenMayer/kontextwork-catalog/tree/master/templates/letsencrypt) which is based on [the original](https://github.com/rancher/community-catalog/tree/master/templates/letsencrypt)
you can easily manage your certificates by exporting the certificates from the letsencrypt container to the host and then mount those in the registry / portus to be used 
for signing the tokens. The SSL tertrination using the load balancer can also easily access the certificates uing the rancher certificate API.

[letsencrypt](https://github.com/EugenMayer/kontextwork-catalog/tree/master/templates/letsencrypt) has been forked temporary until [this issue](https://github.com/janeczku/rancher-letsencrypt/issues/6) has been merged

+ Set the STORAGEPATH in the letencrypt catalog, lets say /data/ssl/<certificatename>
+ set the CERTSTORAGEPATH in this catalog to /data/ssl/<certificatename>/production/certificates/<certificatename>
 
You are done!

You do not need to adjust SSL_SIGN_KEY / SSL_SIGN_CERT since they match the default, otherwise you have to give the full path from /certs on the container to your cert/key