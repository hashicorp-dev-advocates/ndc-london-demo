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

exec_remote "waypoint_secrets" {
  depends_on = ["k8s_cluster.kubernetes", "exec_local.waypoint_certs"]

  image {
    name = "shipyardrun/tools:v0.6.0"
  }

  network {
    name = "network.cloud"
  }

  cmd = "kubectl"
  args = [
    "create",
    "secret",
    "generic",
    "waypoint-certs",
    "--from-file=/certs/leaf.cert",
    "--from-file=/certs/leaf.key"
  ]

  volume {
    source      = "${shipyard()}/config/kubernetes"
    destination = "/config"
  }

  volume {
    source      = "${data("waypoint_certs")}"
    destination = "/certs"
  }

  env {
    key   = "KUBECONFIG"
    value = "/config/kubeconfig-docker.yaml"
  }
}

helm "waypoint" {
  depends_on = ["exec_remote.waypoint_secrets"]

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
