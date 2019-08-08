## Concourse CI Cluster

This Concourse Server can be used to build a cluster of workers which are offside this docker engine 
to specificly spread the rather high load of an concourse-ci worker

To do that, you need to pre-create the actual private keys

```
ssh-keygen -m PEM -t rsa -f tsa_host_key
rancher secrets create concourse-tsa-private-key tsa_host_key
rancher secrets create concourse-tsa-public-key tsa_host_key.pub

ssh-keygen -m PEM  t rsa -f session_signing_key
rancher secrets create concourse-tsa-session-signing-key session_signing_key


ssh-keygen -m PEM -t rsa -f worker_key
rancher secrets create concourse-worker-private-key worker_key

# here you could actually add more keys to that file to have other worker keys
rancher secrets create concourse-tsa-authorized-workers worker_key.pub
```

Do not forget to launch the secret catalog container: http://rancher.com/docs/rancher/latest/en/cattle/secrets/#enabling-secrets-in-containers


- You can also create those secrets using the UI, see http://rancher.com/docs/rancher/latest/en/cattle/secrets/#adding-secrets-in-the-ui
- Reading up the general topic about secrets would be http://rancher.com/docs/rancher/latest/en/cattle/secrets/

## Auth backends

You can select either `local` or `ldap`.
 
`Local` means, your users are created locally on the concourse server, see the official concourse documentation https://concourse-ci.org/install.html#auth-config

`Ldap` means, you can login using an user directory you already have

You cannot have both or mix them. If you switch backends during an upgrade, i have no clue about the outcome.

## Ports

- 8080/TCP for http
- 2222/TCP for TSA

## Minio

To ease up the dependencies concourse implies on you, especially regarding the resource usage with s3, a Minio S3 server is 
included, so you do not need to signup for AWS or even host your artifacts on AWS at all.

If you want to access Minio API/GUI from the outside, be sure to expose the port 9000 e.g. using a Traefik segment

## Traefik 

Integrates with with ranchers traefik catalog https://github.com/rancher/community-catalog/tree/master/templates/traefik
using rancher metadata