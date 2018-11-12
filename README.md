# Bootstrap

1. Download [terraform](https://www.terraform.io/).
2. Generate a key for the Terraform Service account in the uis-automation-dm
   project:

    ```bash
    $ gcloud iam --project uis-automation-dm service-accounts \
        keys create secrets/terraform-admin-service-account-credentials.json \
        --iam-account terraform-admin@uis-automation-dm.iam.gserviceaccount.com
    ```

# Project

Bootstrap and create project

```bash
$ cd project
$ terraform init
$ terraform apply
```

# Release

```bash
$ cd infrastructure
$ terraform init
$ terraform apply
```
