exec_local "waypoint_certs" {
  cmd = "shipyard"
  args = [
    "connector",
    "generate-certs",
    "${data("waypoint_certs")}",
    "--leaf",
    "--root-ca",
    "${shipyard()}/certs/root.cert",
    "--root-key",
    "${shipyard()}/certs/root.key",
    "--dns-name",
    "waypoint"
  ]
}

exec_local "waypoint_secrets" {
  depends_on = ["exec_local.waypoint_certs"]

  cmd = "kubectl"
  args = [
    "create",
    "secret",
    "generic",
    "waypoint-certs",
    "--from-file=${data("waypoint_certs")}/leaf.cert",
    "--from-file=${data("waypoint_certs")}/leaf.key"
  ]

  env_var = {
    KUBECONFIG = "${k8s_config("kubernetes")}"
  }
}

helm "waypoint" {
  depends_on = ["exec_local.waypoint_certs"]

  cluster = "k8s_cluster.kubernetes"
  chart   = "github.com/hashicorp/waypoint-helm"

  values_string = {
    "server.certs.secretName" = "waypoint-certs"
    "server.certs.certName"   = "leaf.cert"
    "server.certs.keyName"    = "leaf.key"
  }
}

k8s_ingress "waypoint" {
  cluster = "k8s_cluster.kubernetes"
  service = "waypoint-ui"

  network {
    name = "network.cloud"
  }

  port {
    local  = 80
    remote = 80
    host   = 8080
  }

  port {
    local  = 443
    remote = 443
    host   = 8443
  }

  port {
    local  = 9701
    remote = 9701
    host   = 9701
  }

  port {
    local  = 9702
    remote = 9702
    host   = 9702
  }
}
