k8s_config "app" {
  depends_on = ["module.consul"]

  cluster = "k8s_cluster.kubernetes"
  paths = [
    "./files/k8s_config",
  ]

  wait_until_ready = true
}

template "waypoint_app" {
  source = <<EOF
#!/bin/sh -e
cd /app
waypoint login --from-kubernetes ${shipyard_ip()}:9701
waypoint init
sleep 5
waypoint build
waypoint deploy -release=false
EOF

  destination = "${data("waypoint")}/install_app.sh"
}

exec_remote "waypoint_app" {
  depends_on = ["module.consul", "helm.waypoint"]

  image {
    name = "shipyardrun/hashicorp-tools:v0.7.0"
  }

  network {
    name = "network.cloud"
  }

  cmd = "bash"
  args = [
    "/files/install_app.sh",
  ]

  volume {
    source = "${k8s_config_docker("kubernetes")}"

    #source      = "${shipyard()}/config/kubernetes"
    destination = "/config/kubeconfig-docker.yaml"
  }

  volume {
    source      = "./files/app"
    destination = "/app"
  }

  volume {
    source      = "${data("waypoint")}/"
    destination = "/files"
  }

  env {
    key   = "KUBECONFIG"
    value = "/config/kubeconfig-docker.yaml"
  }
}

container "waypoint_app" {
  depends_on = ["module.consul", "helm.waypoint"]

  image {
    name = "shipyardrun/hashicorp-tools:v0.7.0"
  }

  network {
    name = "network.cloud"
  }

  command = ["tail",
    "-f", "/dev/null",
  ]

  volume {
    source = "${k8s_config_docker("kubernetes")}"

    #source      = "${shipyard()}/config/kubernetes"
    destination = "/config/kubeconfig-docker.yaml"
  }

  volume {
    source      = "./files/app"
    destination = "/app"
  }

  volume {
    source      = "${data("waypoint")}/"
    destination = "/files"
  }

  env {
    key   = "KUBECONFIG"
    value = "/config/kubeconfig-docker.yaml"
  }
}