variable "humanitec_org" {
  description = "The ID of the organization"
  default     = "humanitec"
  type        = string
}

variable "agent_id" {
  description = "The ID of the agent"
  default     = "qhd"
  type        = string
}

variable "kubeconfig" {
  description = "The kubeconfig"
  type        = string
  default     = "../kube/config.yaml"
}

variable "agent_kubeconfig" {
  description = "Kubeconfig used by the agent"
  type        = string
  default     = "../kube/config-internal.yaml"
}

resource "tls_private_key" "agent_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "humanitec_agent" "agent" {
  id          = var.agent_id
  description = "QHD"
  public_keys = [{
    key = tls_private_key.agent_private_key.public_key_pem
  }]
}

resource "helm_release" "humanitec_agent" {
  name             = "humanitec-agent"
  namespace        = "humanitec-agent"
  create_namespace = true

  repository = "oci://ghcr.io/humanitec/charts"
  chart      = "humanitec-agent"

  set {
    name  = "humanitec.org"
    value = var.humanitec_org
  }

  set {
    name  = "humanitec.privateKey"
    value = tls_private_key.agent_private_key.private_key_pem
  }

  depends_on = [
    humanitec_agent.agent
  ]
}

resource "humanitec_resource_definition" "agent" {
  id   = var.agent_id
  name = var.agent_id
  type = "agent"

  driver_type = "humanitec/agent"
  driver_inputs = {
    values_string = jsonencode({
      id = var.agent_id
    })
  }

  depends_on = [
    helm_release.humanitec_agent
  ]
}

resource "humanitec_resource_definition_criteria" "agent" {
  resource_definition_id = humanitec_resource_definition.agent.id
  res_id                 = "agent"
}

locals {
  kubeconfig = yamldecode(file(var.agent_kubeconfig))
}

resource "humanitec_resource_definition" "qhd_cluster" {
  id          = "${var.agent_id}-cluster"
  name        = "${var.agent_id}-cluster"
  type        = "k8s-cluster"
  driver_type = "humanitec/k8s-cluster"

  driver_inputs = {
    values_string = jsonencode({
      loadbalancer = "0.0.0.0" # ensure dns records are created pointing to localhost
      cluster_data = local.kubeconfig["clusters"][0]["cluster"]
    })
    secrets_string = jsonencode({
      agent_url   = "$${resources['agent#agent'].outputs.url}"
      credentials = local.kubeconfig["users"][0]["user"]
    })
  }

  depends_on = [
    humanitec_resource_definition_criteria.agent
  ]
}


resource "humanitec_resource_definition_criteria" "qhd_cluster" {
  resource_definition_id = humanitec_resource_definition.qhd_cluster.id
}


resource "humanitec_resource_definition" "k8s_namespace" {
  driver_type = "humanitec/echo"
  id          = "default-namespace"
  name        = "default-namespace"
  type        = "k8s-namespace"

  driver_inputs = {
    values_string = jsonencode({
      "namespace" = "$${context.app.id}-$${context.env.id}"
    })
  }
}

resource "humanitec_resource_definition_criteria" "k8s_namespace" {
  resource_definition_id = humanitec_resource_definition.k8s_namespace.id
}

resource "humanitec_resource_definition" "localhost_dns" {
  id          = "localhost-dns"
  name        = "localhost-dns"
  type        = "dns"
  driver_type = "humanitec/dns-wildcard"

  driver_inputs = {
    values_string = jsonencode({
      "domain"   = "localhost"
      "template" = "$${context.app.id}-{{ randAlphaNum 4 | lower}}"
    })
  }

  provision = {
    ingress = {
      match_dependents = false
      is_dependent     = false
    }
  }
}

resource "humanitec_resource_definition_criteria" "localhost_dns" {
  resource_definition_id = humanitec_resource_definition.localhost_dns.id
}
