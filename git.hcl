template "gogs_config" {
  source      = "${file("${file_dir()}/files/gogs/app.ini")}"
  destination = "${data("gogs_config")}/app.ini"
}

exec_local "gogs_certs" {
  cmd = "shipyard"
  args = [
    "connector",
    "generate-certs",
    "${data("gogs_certs")}",
    "--leaf",
    "--root-ca",
    "${shipyard()}/certs/root.cert",
    "--root-key",
    "${shipyard()}/certs/root.key",
    "--ip-address",
    "10.10.0.20"
  ]
}

container "gogs" {
  depends_on = ["exec_local.gogs_certs"]

  network {
    name       = "network.cloud"
    ip_address = "10.10.0.20"
  }

  image {
    name = "gogs/gogs:0.12.6"
  }

  volume {
    source      = "${data("gogs_config")}/app.ini"
    destination = "/data/gogs/conf/app.ini"
  }

  volume {
    source      = "${data("gogs_certs")}"
    destination = "/data/certs"
  }

  volume {
    source      = "./files/gogs/gogs.db"
    destination = "/data/gogs/data/gogs.db"
  }

  volume {
    source      = "./files/gogs/payments"
    destination = "/data/git/gogs-repositories/hashicraft/payments.git"
  }

  port {
    local  = 22
    remote = 22
    host   = 22
  }

  port {
    local  = 3000
    remote = 3000
    host   = 3000
  }
}

// k8s_config "git" {
//   cluster = "k8s_cluster.kubernetes"
//   paths = [
//     "./files/k8s_config/git.yaml",
//   ]

//   wait_until_ready = true
// }

// k8s_ingress "git" {
//   cluster = "k8s_cluster.kubernetes"
//   service = "git"

//   network {
//     name = "network.cloud"
//   }

//   port {
//     local  = 3000
//     remote = 3000
//     host   = 3000
//   }
// }