# Configuration.
# Place often configured values here for easy modification.
locals {
  region = "europe-west2"

  project_name                = "Experimental GitLab deployment"
  billing_account             = "012C79-5323D4-2B6B52"
  folder_id                   = "497670463628"                   # == "UIS Automation/Experiments"
  generated_project_id_prefix = "gitlab-exp"
}
