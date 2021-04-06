## Geminabox Rubygems-Server

Hint: I moved on to [sonatype nexus](https://github.com/EugenMayer/docker-rancher-extra-catalogs/tree/master/templates/sona-nexus) as my gem-server - so you might checkout that ( also supports NPM, docker, maven and more ).

A rubygems server build on [geminabox](https://github.com/geminabox/geminabox) to host your own private gems

Expose the port 9292 using your HAproxy to let the gem-server be accessible to the outer world

The image is based on Geminabox: https://github.com/EugenMayer/geminabox-docker
For more docs see

# Features
Based on alpine / [geminabox](https://github.com/geminabox/geminabox), providing a configurable Docker supporting
 - no auth
 - basic auth (for admin and optional for the reader)
 - LDAP auth (admin/reader is the same)
