---
title: Canary Deploys with Waypoint and Consul
author: Nic Jackson, Erik Veld
slug: consul_waypoint
---

# Readme

* [Gogs UI](https://localhost:3000)
* [Waypoint UI](https://localhost:9702)
* [Grafana](https://localhost:8080)
* [Consul](https://localhost:18500)

## Logging into Waypoint

Set the environment variables to use the Kubernetes config set by Shipyard

```shell
eval $(shipyard env)
```

Login to the Waypoint server

```shell
waypoint login --from-kubernetes localhost:9701
```

You can now open the Waypoint UI

```shell
waypoint ui -authenticate
```

## Deploying the Payments application to Waypoint

The example application is located in `./files/app`, change into this folder and execute the
following commands:

Initialize the application in Waypoint

```shell
waypoint init
```

Build the application

```shell
waypoint build
```

Deploy the application

```shell
waypoint deploy -release=false
```

Once complete the application will be deployed to Kubernetes, you can test it using
the following command:

```shell
curl -vv http://localhost:18080/v1/weather
```

The application has simulated traffic sent through to it, full visualization can
be seen in the Grafana dashboard:

http://localhost:8080/d/sdfsdfsdf/application-dashboard?orgId=1&refresh=10s

## Deploying the canary release

To deploy a canary release, first install the configuration for Consul release controller

```shell
kubectl apply -f ./files/k8s_config/canary/payments_release.yaml
```

It will take about 60s or so for Consul release controller to clone your deployment
renaming it `payments-primary`, and to set up the necessary Consul configuration.

Once this is complete you will see the Payments Primary Pods Running change from `0`
to `1` in the dashboard.

You can also use `cURL` to see the status of the release controller

curl https://localhost:19443/v1/releases -k

```json
[{"name":"payments","status":"state_idle","version":"2"}]
```

If the status is not `state_idle` the release controller will reject any kubernetes 
deployments.

To trigger a canary release you can now trigger another Waypoint build

```shell
waypoint build
waypoint deploy -release=false
```