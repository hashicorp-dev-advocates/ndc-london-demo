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

variable "consul_ingress_gateway_enabled" {
  description = "Enable ingress gateways"
  default     = true
}

variable "consul_release_controller_helm_version" {
  description = "Helm chart version for Consul release controller"
  default     = "0.2.1"
}

module "consul" {
  source = "github.com/shipyard-run/blueprints?ref=9f96877b0fe29da2534d90e0de4fee10cb333cd1/modules//kubernetes-consul"
}