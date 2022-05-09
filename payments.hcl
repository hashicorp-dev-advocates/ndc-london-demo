k8s_config "payments" {
  depends_on = ["module.consul"]

  cluster = "k8s_cluster.kubernetes"
  paths = [
    "./files/k8s_config",
  ]

  wait_until_ready = true
}

template "waypoint_payments" {
  source = <<EOF
#!/bin/sh -e
waypoint login --from-kubernetes ${shipyard_ip()}:9701
waypoint init
EOF

  destination = "${data("waypoint")}/install_payments.sh"
}

exec_remote "waypoint_payments" {
  depends_on = ["module.consul", "helm.waypoint", "template.waypoint_payments", "k8s_config.payments"]

  image {
    name = "shipyardrun/hashicorp-tools:v0.7.0"
  }

  network {
    name = "network.cloud"
  }

  working_directory = "/payments"

  cmd = "bash"
  args = [
    "/files/install_payments.sh",
  ]

  volume {
    source = "${k8s_config_docker("kubernetes")}"

    #source      = "${shipyard()}/config/kubernetes"
    destination = "/config/kubeconfig-docker.yaml"
  }

  volume {
    source      = "./files/payments"
    destination = "/payments"
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

container "waypoint_payments" {
  depends_on = ["module.consul", "helm.waypoint", "template.waypoint_payments"]

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
    source      = "./files/payments"
    destination = "/payments"
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

ingress "payments_db" {
  source {
    driver = "local"
    
    config {
      port = 5432
    }
  }
  
  destination {
    driver = "k8s"
    
    config {
      cluster = "k8s_cluster.kubernetes"
      address = "payments-db.default.svc"
      port = 5432
    }
  }
}
