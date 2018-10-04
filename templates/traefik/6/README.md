# Traefik active load balancer 

 This template deploys traefik active load balancers on top of Rancher. The configuration is generated and updated with confd from Rancher metadata.
 It would be deployed in hosts with label traefik_lb=true.

### Requirements

Be sure to add the `traefik_lb=true` label to the host you deploy this catalog on.

### Service configuration labels:

See https://docs.traefik.io/configuration/backends/docker/#on-containers for possible labels.
Those labels are exposed using the rancher metadata api and then picked up by the traefik server

You can use segments in the labels to expose several services per container