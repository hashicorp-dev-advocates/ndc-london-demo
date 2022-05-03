k8s_cluster "kubernetes" {
  driver = "k3s"

  network {
    name = "network.cloud"
  }

  // image {
  //   name = "hashicraft/gogs:v0.0.1"
  // }

  // image {
  //   name = "registry:2"
  // }
}

output "KUBECONFIG" {
  value = k8s_config("kubernetes")
}