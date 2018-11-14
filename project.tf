# project.tf contains configuration for the GCP project itself and any eternal
# resources.

# The GCP project and Cloud DNS managed zone. Since this creates resources
# outside of the project proper, we need to use a provider with elevated access.
#
# This module will create the GCP project, create a new delegated DNS zone for
# it and create a managed DNS zone resource within the project.
module "project" {
  source = "./project"

  providers = {
    google      = "google.admin"
    google-beta = "google-beta.admin"
  }
}
