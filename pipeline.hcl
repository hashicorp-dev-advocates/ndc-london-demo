helm "waypoint" {
  cluster = "k8s_cluster.kubernetes"
  chart   = "github.com/hashicorp/waypoint-helm"
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
