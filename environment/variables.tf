# variables.tf contains definitions of external variables used to configure the
# environment

# Service account credentials for the terraform admin service account. Required
# to create the project in the first place and to configure the delegated DNS
# zone.
variable "admin_service_account_credentials" {}

# Human readable name for project associated with this environment.
variable "project_name" {}

# Prefix used to generate project name if an exact project name is not given.
variable "generated_project_id_prefix" {
  default = "gitlab"
}

# Override the DNS domain for gitlab. Does not include a trailing ".". You must
# ensure by some other means that this domain name points to the correct IP.
variable "gitlab_domain" {
  default = ""
}

# Folder id which project should be placed in
variable "project_folder_id" {}

# Prefix for generating domain names for this project
variable "generated_dns_name_prefix" {}

# Tier for the cloud SQL instance.
variable "db_tier" {}

# Machine type for k8s cluster nodes.
variable "k8s_node_machine_type" {}

# A directory which it is safe to put secrets in.
variable "secrets_dir" {}

# Prefix used for generated domain names for each release.
variable "release_generated_domain_prefix" {
  default = "rel-"
}

# Size of gitaly persistent storage. E.g. "50Gi".
variable "gitaly_persistence_size" {}
