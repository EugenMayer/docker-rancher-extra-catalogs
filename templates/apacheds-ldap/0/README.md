Offering the [apacheDS](https://directory.apache.org/apacheds/) ldap server with kerberos and other services
as described on the homepage. You can use it with SSL termination using the load balancer, see below

Using [this docker image](https://hub.docker.com/r/h3nrik/apacheds/~/dockerfile/) as the base for now.

## Installation

+ Enter the Storage path where your LDAP-Database will get written

## After the installation

When installed, you should use your load-balancer to map the following ports:

+ Port 363 TCP no ssl on th the container port 10363
+ Port 686 TCP ssl on th the container port 10363

Yes you map the SSL port on the non SSL port, since you do SSL termination on the load-balancer

## First login

You can login with 

+ user : uid=admin,ou=system
+ password: secret

I suggest to use [ApacheStudio](http://directory.apache.org/studio/downloads.html) to adminster the LDAP Server: 

Change your password and add the configuration your need.