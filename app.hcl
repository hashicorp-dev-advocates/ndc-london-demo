k8s_config "app" {
  depends_on = ["module.consul"]

  cluster = "k8s_cluster.kubernetes"
  paths = [
    "./files/k8s_config",
  ]

  wait_until_ready = true
}