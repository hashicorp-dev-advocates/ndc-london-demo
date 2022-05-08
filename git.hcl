template "gogs_payments" {
  source = <<EOF
# Copy payments source to a temp folder to create a new git repo
mkdir -p /data/tmp_payments
cp -r /payments/* /data/tmp_payments

git config --global init.defaultBranch main
git config --global user.email "admin@hashicraft.com"
git config --global user.name "Barry"

# create the base gogs payments repo
mkdir -p /data/git/gogs-repositories/hashicraft/payments.git
cd /data/git/gogs-repositories/hashicraft/payments.git
git init --bare

chown git -R /data/git/gogs-repositories
chgrp git -R /data/git/gogs-repositories

# add the payments source to the gogs repo
cd /data/tmp_payments

# create the repo and initial commit
git init
git add .
git commit -m "Initial commit"

# add the remote
git remote add origin https://hashicraft:secret@localhost:3000/hashicraft/payments.git

# push the repo to gogs
GIT_SSL_NO_VERIFY=true git push --set-upstream origin main
EOF

  destination = "${data("gogs")}/init_payments.sh"
}

container "gogs" {
  network {
    name       = "network.cloud"
    ip_address = "10.10.0.20"
  }

  entrypoint = ["/data/gogs/bin/setup.sh"]

  image {
    name = "gogs/gogs:0.12.6"
  }

  volume {
    source      = "${data("gogs")}/init_payments.sh"
    destination = "/data/gogs/bin/init_payments.sh"
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
    source      = "./files/gogs/gogs.db.bak"
    destination = "/data/gogs/data/gogs.db.bak"
  }

  volume {
    source      = "./files/keys/authorized_keys"
    destination = "/data/git/.ssh/authorized_keys"
  }

  volume {
    source      = "./files/payments"
    destination = "/payments"
  }

  port {
    local  = 22
    remote = 22
    host   = 1022
  }

  port {
    local  = 3000
    remote = 3000
    host   = 3000
  }

  health_check {
    timeout = "60s"
    http    = "https://localhost:3000"
  }
}

exec_remote "gogs_payments" {
  depends_on = ["template.gogs_payments", "container.gogs"]
  target     = "container.gogs"

  cmd = "bash"
  args = [
    "/data/gogs/bin/init_payments.sh",
  ]
}
