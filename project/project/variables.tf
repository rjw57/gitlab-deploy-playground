# Human-readable project name.
variable "project_name" {}

# Project name to use. If unset, a random value is used. The actual project id
# used is available as the project_id output from the module.
variable "project_id" {
  default = ""
}

# Billing account to associate with generated project.
variable "billing_account" {}

# ID of folder to insert generated project into.
variable "folder_id" {}

# Region to create resources in.
variable "region" {
  default = "europe-west2"
}

# Prefix used to generate project name if an exact project name is not given.
variable "generated_project_id_prefix" {
  default = "uis-devops"
}

# List of services which should be enabled in the project in addition to any
# manually enabled ones or ones enabled by Google's infrastructure.
variable "additional_services" {
  default = []
}

# List of project editors. This list is non-authoritative in that if someone
# already has the role/editor role and does not appear in the list, they will
# not be removed from the role. This is intentional since, otherwise, it would
# be all to easy to remove all accounts you have access to and be unable to
# manage the project.
variable "editors" {
  default = []
}
