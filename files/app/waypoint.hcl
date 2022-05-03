project = "hashicraft"

runner {
  enabled = true

  data_source "git" {
    url = "git@10.10.0.20:22/hashicraft/payments.git"
  }
}

app "payments" {
  build {
    use "docker" {}

    registry {
      use "docker" {
        image    = "10.10.0.10/hashicraft/payments"
        tag      = "latest"
        insecure = true
      }
    }
  }

  deploy {
    use "kubernetes" {}
  }
}