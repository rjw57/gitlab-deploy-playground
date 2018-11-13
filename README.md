# Bootstrap

1. Download [terraform](https://www.terraform.io/) and [helm](https://helm.sh/).
   Helm must be installed so that the ``helm`` command is available on the path.
2. Generate a key for the Terraform Service account in the uis-automation-dm
   project:

    ```bash
    $ gcloud iam --project uis-automation-dm service-accounts \
        keys create secrets/terraform-admin-service-account-credentials.json \
        --iam-account terraform-admin@uis-automation-dm.iam.gserviceaccount.com
    ```

# Install

```bash
$ terraform init  # required only once
$ terraform apply
```

# Get URL and initial root password

```bash
$ terraform output gitlab_url
$ terraform output initial_root_password
```

# Setting up admin service account

The terraform admin service account is created in the following way:

```bash
$ gcloud iam --project uis-automation-dm service-accounts \
    create terraform-admin --display-name "Terraform admin account"
$ gcloud projects add-iam-policy-binding uis-automation-dm \
    --member serviceAccount:terraform-admin@uis-automation-dm.iam.gserviceaccount.com \
    --role roles/viewer
$ gcloud projects add-iam-policy-binding uis-automation-dm \
    --member serviceAccount:terraform-admin@uis-automation-dm.iam.gserviceaccount.com \
    --role roles/storage.admin
$ gcloud alpha resource-manager folders add-iam-policy-binding 497670463628 \
    --member serviceAccount:terraform-admin@uis-automation-dm.iam.gserviceaccount.com \
    --role roles/resourcemanager.projectCreator
$ gcloud projects add-iam-policy-binding uis-automation-infrastructure \
    --member serviceAccount:terraform-admin@uis-automation-dm.iam.gserviceaccount.com \
    --role roles/dns.admin
```

Additionally terraform-admin@uis-automation-dm.iam.gserviceaccount.com is added
as a "Billing User" to the billing account.
