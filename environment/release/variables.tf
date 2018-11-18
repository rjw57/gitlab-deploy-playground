# variables.tf contains definitions of variables used by the module.

# Contact email for certmanager
variable "certmanager_email" {
  default = "devops+gitlab@uis.cam.ac.uk"
}

# Override the DNS domain for gitlab. Does not include a trailing ".". You must
# ensure by some other means that this domain name points to the correct IP.
variable "gitlab_domain" {
  default = ""
}

# Helm chart name.
variable "chart" {
  default = "gitlab/gitlab"
}

# Unique name for this release. Used to form GCP resource names such as database
# names and database users.
variable "name" {}

# DNS domain for gitlab release. NOTE: this needs the trailing ".".
variable "dns_name" {}

# Cloud DNS zone.
variable "zone" {}

# Kubernetes storage class for persistent volumes.
variable "storage_class" {}

# Cloud SQL instance to create database in, the connection name an Cloud SQL
# proxy credentials.
variable "sql_instance" {}

variable "sql_instance_connection_name" {}
variable "sql_instance_credentials" {}

# Specific cloud SQL proxy image to use.
variable "cloud_sql_proxy_image" {
  default = "gcr.io/cloudsql-docker/gce-proxy:1.11"
}

# Size of gitaly persistent storage. E.g. "50Gi".
variable "gitaly_persistence_size" {}

variable "tiller_service_account" {}

variable "secrets_dir" {}

variable "kubeconfig_content" {}
