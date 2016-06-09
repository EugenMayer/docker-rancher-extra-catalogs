## OpenLDAP Server
OpenLDAP server with out of the box configuration based on https://github.com/osixia/docker-openldap
For further information how to customize it, please see the image readme: https://github.com/osixia/docker-openldap

You can even setup replication.

After the installation, you can login using your password and the user

+ cn=admin,dc=yourgiverndomain,dc=tld
+ your provided LDAP password

where dc=yourgiverndomain,dc=tld is derived form your LDAP domain you have provided during the configuration