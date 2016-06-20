## OpenLDAP Server
OpenLDAP server with out of the box configuration, build in TLS and memberof support.
For further information how to customize it, please see the image readme: https://github.com/osixia/docker-openldap

Please give all the kudos to [osixia](https://github.com/osixia/docker-openldap) - such a greate image!


### Features
+ supports TLS out of the box
+ build in support for memberof (module and overly configured)
+ creates basic BASE from the start, so you are ready to go after the start
+ You can even setup replication.

### After the installation
After the installation, you can login using your password and the user

+ cn=admin,dc=yourgiverndomain,dc=tld
+ your provided LDAP password

where dc=yourgiverndomain,dc=tld is derived form your LDAP domain you have provided during the configuration