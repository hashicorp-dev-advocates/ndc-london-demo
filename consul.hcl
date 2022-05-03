variable "consul_k8s_cluster" {
  default = "kubernetes"
}

variable "consul_k8s_network" {
  default = "cloud"
}

variable "consul_monitoring_enabled" {
  description = "Should the monitoring stack, Prometheus, Grafana, Loki be installed"
  default     = true
}

variable "consul_smi_controller_enabled" {
  description = "Should the SMI controller be installed"
  default     = false
}

variable "consul_release_controller_enabled" {
  description = "Enable the consul release controller?"
  default     = true
}

variable "consul_acls_enabled" {
  description = "Enable ACLs for securing the Consul server"
  default     = true
}

variable "consul_tls_enabled" {
  description = "Enable TLS to secure the Consul server"
  default     = true
}

module "consul" {
  source = "github.com/shipyard-run/blueprints?ref=756f7d18b27e4040d1699638da0b36fea8c13a94/modules//kubernetes-consul"
}