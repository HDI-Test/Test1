# test1 Kustomize Configuration

This repo contains a basic template for projects with Kustomize configuration.

For further details concerning Kustomize or the chosen directory structure, please refer to this [wiki](https://makeitapp.atlassian.net/wiki/spaces/cecom/pages/3433922624/Configuration+management+with+Kustomize).

# Actions to perform after the project creation
You need to communicate to HDI that 3 new "A" records on AWS DNS (Route53) should be created.
This can be done only after the ingresses are deployed.
