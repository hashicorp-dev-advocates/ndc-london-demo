variable "waypoint_odr_tag" {
  default = "0.0.3"
}

# Build a custom ODR with our certs
container "waypoint-odr" {
  network {
    name = "network.cloud"
  }

  build {
    file    = "./Dockerfile.odr"
    context = "./files/keys"
    tag     = var.waypoint_odr_tag
  }

  command = ["/kaniko/waypoint"]
}

exec_remote "waypoint_secrets" {
  depends_on = ["k8s_cluster.kubernetes"]

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
    "--from-file=/certs/waypoint.cert",
    "--from-file=/certs/waypoint.key"
  ]

  volume {
    source      = "${shipyard()}/config/kubernetes"
    destination = "/config"
  }

  env {
    key   = "KUBECONFIG"
    value = "/config/kubeconfig-docker.yaml"
  }

  volume {
    source      = "./files/keys"
    destination = "/certs"
  }
}

helm "waypoint" {
  depends_on = ["exec_remote.waypoint_secrets"]

  cluster = "k8s_cluster.kubernetes"
  chart   = "github.com/hashicorp/waypoint-helm"

  values_string = {
    "server.certs.secretName"     = "waypoint-certs"
    "server.certs.certName"       = "waypoint.cert"
    "server.certs.keyName"        = "waypoint.key"
    "runner.odr.image.repository" = "shipyard.run/localcache/waypoint-odr"
    "runner.odr.image.tag"        = var.waypoint_odr_tag
  }
}

k8s_ingress "waypoint" {
  cluster = "k8s_cluster.kubernetes"
  service = "waypoint-ui"

  network {
    name = "network.cloud"
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
