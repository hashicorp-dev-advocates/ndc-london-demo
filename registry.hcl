exec_local "registry_certs" {
  cmd = "shipyard"
  args = [
    "connector",
    "generate-certs",
    "${data("registry_certs")}",
    "--leaf",
    "--root-ca",
    "${shipyard()}/certs/root.cert",
    "--root-key",
    "${shipyard()}/certs/root.key",
    "--ip-address",
    "10.10.0.10"
  ]
}

container "registry" {
  depends_on = ["exec_local.registry_certs"]

  network {
    name       = "network.cloud"
    ip_address = "10.10.0.10"
  }

  image {
    name = "registry:2"
  }

  volume {
    source      = "${data("registry_certs")}"
    destination = "/certs"
  }

  env_var = {
    REGISTRY_HTTP_ADDR            = "0.0.0.0:443"
    REGISTRY_HTTP_TLS_CERTIFICATE = "/certs/leaf.cert"
    REGISTRY_HTTP_TLS_KEY         = "/certs/leaf.key"
  }

  port {
    local  = 443
    remote = 443
    host   = 443
  }
}