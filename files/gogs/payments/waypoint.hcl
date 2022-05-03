project = "hashicraft"

runner {
  enabled = true

  data_source "git" {
    url = "https://10.10.0.20:3000/hashicraft/payments.git"
  }
}

app "payments" {
  build {
    use "docker" {}

    registry {
      use "docker" {
        image = "10.10.0.10/hashicraft/payments"
        tag   = "latest"
      }
    }
  }

  deploy {
    use "docker" {}
  }
}