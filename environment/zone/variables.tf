# variables.tf contains definitions of variables used by the module.

# The project where the parent managed zone lives. The provider must have the
# ability to manage resources in this zone. We default to the project which
# contains our delegated zone.
variable "parent_project" {
  default = "uis-automation-infrastructure"
}

# The Cloud DNS zone in parent_managed_zone which will have the created zone
# added. The "google.admin" provider must have the ability to manage resources
# in this zone.
variable "parent_zone" {
  default = "gcloud-automation-uis"
}

# A prefix for the generated DNS zone name. The full DNS name will be a random
# id generated with this prefix with the parent zone's DNS name appended.
variable "generated_dns_name_prefix" {
  default = "exp-"
}
