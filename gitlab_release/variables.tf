# GCP project id
variable "project" {}

# Region to create resources in
variable "region" {}

# Location of gitlab chart
variable "chart" {}

# Unique name for this release. Used to form GCP resource names
variable "name" {}

# DNS domain for gitlab release
variable "domain" {}

# Cloud DNS zone
variable "zone" {}

# Kubernetes storage class for persistent volumes
variable "storage_class" {}

# Cloud SQL instance to create database in
variable "sql_instance" {}

variable "sql_instance_connection_name" {}
variable "sql_instance_credentials" {}

variable "cloud_sql_proxy_image" {
  default = "gcr.io/cloudsql-docker/gce-proxy:1.11"
}
