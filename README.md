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

The initial helm release will fail dues to some remaining issues. Fix it:

```bash
$ ./fixit.sh
```

After fixing things, re-run `terraform apply`.

## Get URL

```bash
$ cd infrastructure
$ terraform output gitlab_url
```

## Get initial root password

```bash
$ gcloud --project=$(cd project; terraform output project_id) \
    container clusters get-credentials \
    --region=$(cd project; terraform output region) \
    "$(cd infrastructure; terraform output cluster_name)"
$ kubectl -n gitlab-production get secret gitlab-gitlab-initial-root-password -o jsonpath={.data.password} | \
    base64 -d; echo
```

## Setting up service account

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
