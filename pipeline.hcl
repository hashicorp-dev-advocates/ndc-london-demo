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

// template "waypoint_login" {
//   source      = <<EOF
// waypoint login --from-kubernetes localhost:9701
//   EOF
//   destination = "${data("waypoint")}/login.sh"
// }

exec_local "waypoint_login" {
  depends_on = [
    "helm.waypoint",
    "k8s_ingress.waypoint",
  ]

  cmd = "waypoint"
  args = [
    "login",
    "--from-kubernetes",
    "localhost:9701"
  ]

  // cmd = "bash"
  // args = [
  //   "-c",
  //   "${data("waypoint")}/login.sh"
  // ]
}