## Concourse CI Cluster

Compared to the other  Concourse CI this catalog is less working out of the box, but capabale 
of deploying workers across hosts - the cluster version.

To do that, you need to pre-create the actual private keys

```
ssh-keygen -t rsa -f tsa_host_key
rancher secrets create concourse-tsa-private-key tsa_host_key
rancher secrets create concourse-tsa-public-key tsa_host_key.pub

ssh-keygen -t rsa -f session_signing_key
rancher secrets create concourse-session-signing-key session_signing_key


ssh-keygen -t rsa -f worker_key
rancher secrets create concourse-worker-private-key worker_key

# here you could actually add more keys to that file to have other worker keys
rancher secrets create concourse-tsa-authorized-workers worker_key.pub
```

Reading up the general topic about secrets would be http://rancher.com/docs/rancher/latest/en/cattle/secrets/