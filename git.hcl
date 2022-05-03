// template "gogs_config" {
//   source      = "${file("${file_dir()}/files/gogs/app.ini")}"
//   destination = "${data("gogs_config")}/app.ini"
// }

// exec_local "gogs_certs" {
//   cmd = "shipyard"
//   args = [
//     "connector",
//     "generate-certs",
//     "${data("gogs_certs")}",
//     "--leaf",
//     "--root-ca",
//     "${shipyard()}/certs/root.cert",
//     "--root-key",
//     "${shipyard()}/certs/root.key",
//     "--ip-address",
//     "10.10.0.20"
//   ]
// }

exec_remote "setup_repo" {
  target = "container.gogs"

  cmd  = "sh"
  args = ["-c", "/data/gogs/bin/setup.sh"]
}

container "gogs" {
  // depends_on = ["exec_local.gogs_certs"]

  network {
    name       = "network.cloud"
    ip_address = "10.10.0.20"
  }

  image {
    name = "gogs/gogs:0.12.6"
  }

  volume {
    source      = "./files/gogs/setup.sh"
    destination = "/data/gogs/bin/setup.sh"
  }

  volume {
    source      = "./files/gogs/app.ini"
    destination = "/data/gogs/conf/app.ini"
  }

  volume {
    source      = "./files/keys"
    destination = "/data/certs"
  }

  volume {
    source      = "./files/gogs/gogs.db"
    destination = "/data/gogs/data/gogs.db"
  }

  volume {
    source      = "./files/keys/authorized_keys"
    destination = "/data/git/.ssh/authorized_keys"
  }

  // volume {
  //   source      = "./files/keys/id_rsa"
  //   destination = "/data/git/.ssh/id_rsa"
  // }

  // volume {
  //   source      = "./files/keys/id_rsa.pub"
  //   destination = "/data/git/.ssh/id_rsa.pub"
  // }

  volume {
    source      = "./files/app"
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