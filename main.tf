# main.tf contains configuration for the top-level resources

# For various annoying reasons, bits of this configuration have to "escape" from
# terraform every so often and write some state to the local disk. This
# directory is a "safe" place to write stuff to which is ignored by git.
locals {
  secrets_dir           = "${path.module}/secrets/"
  experiments_folder_id = "497670463628"            # == "UIS Automation/Experiments"
}

# production environment
module "production" {
  source = "./environment"

  project_name                = "Gitlab Production"
  project_folder_id           = "${local.experiments_folder_id}"
  generated_project_id_prefix = "gitlab-prod"
  generated_dns_name_prefix   = "gitprod-"

  # If we want a more friendly URL for the deployment then we can use the
  # gitlab_domain variable. For example, if we wanted this deployment to appear
  # at https://gitlab.developers.cam.ac.uk/ with the Docker image registry at
  # https://registry.developers.cam.ac.uk/, we would use the following setting:
  #
  # gitlab_domain = "developers.cam.ac.uk"


  # The gitlab docs[1] recommend that we use n1-standard-4 machines over 2
  # nodes. Since we use regional clusters we have a minimum of 3 nodes and so we
  # reduce the machine type down to n1-standard-2.
  #
  # [1] https://gitlab.com/charts/gitlab/blob/master/doc/cloud/gke.md

  db_tier                           = "db-custom-1-3840"
  k8s_node_machine_type             = "n1-standard-2"                              # x 3 nodes per cluster
  gitaly_persistence_size           = "200Gi"
  admin_service_account_credentials = "${local.admin_service_account_credentials}"
  secrets_dir                       = "${local.secrets_dir}"
}

# test environment
module "test" {
  source = "./environment"

  project_name                = "Gitlab Test"
  project_folder_id           = "${local.experiments_folder_id}"
  generated_project_id_prefix = "gitlab-test"
  generated_dns_name_prefix   = "gittest-"

  # These resources are intentionally smaller than the production environment so
  # that a) we notice resource problems sooner and b) we don't have to pay as
  # much for it.
  #
  # Note that we need to use n1-standard-2 nodes even in test because otherwise
  # the gitlab workloads become unschedulable due to CPU and memory constraints.

  db_tier                           = "db-f1-micro"
  k8s_node_machine_type             = "n1-standard-2"                              # x 3 nodes per cluster
  gitaly_persistence_size           = "10Gi"
  admin_service_account_credentials = "${local.admin_service_account_credentials}"
  secrets_dir                       = "${local.secrets_dir}"
}
