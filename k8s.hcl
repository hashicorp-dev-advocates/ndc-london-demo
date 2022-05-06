# Build a custom ODR with our certs
container "waypoint-odr" {
  network {
    name = "network.cloud"
  }

  build {
    file    = "./Dockerfile.odr"
    context = "./files/keys"
  }

  command = ["/kaniko/waypoint"]
}

k8s_cluster "kubernetes" {
  depends_on = ["container.waypoint-odr"]
  driver     = "k3s"

  network {
    name = "network.cloud"
  }

  image {
    name = "shipyard.run/localcache/waypoint-odr:latest"
  }

  volume {
    source      = "./files/keys/registries.yaml"
    destination = "/etc/rancher/k3s/registries.yaml"
  }
}

output "KUBECONFIG" {
  value = k8s_config("kubernetes")
}