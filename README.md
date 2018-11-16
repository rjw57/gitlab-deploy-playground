# UIS Gitlab deployment

This repository contains a declarative deployment of Gitlab using the official
helm charts on GKE.

**IMPORTANT:** when first experimenting with this repository, it is *highly*
recommended that you make use of terraform
[workspaces](https://www.terraform.io/docs/state/workspaces.html) to create a
parallel deployment first. See the section below on "getting familiar with this
deployment".

## Known issues

This deployment is not yet complete. Known issues include:

* There is no configuration of email sending or receiving.
* There are no backup object storage buckets created.
* The mechanism for having the Gitlab instance on a custom URL is untested.

## Bootstrap

> **ALWAYS** make sure you have the latest versions of terraform and helm
> installed. Especially with helm, earlier versions have bugs which are not
> worked around by this configuration.

1. Download [terraform](https://www.terraform.io/) and [helm](https://helm.sh/).
   Helm must be installed so that the ``helm`` command is available on the path.
2. Make sure that the ``kubectl`` command is installed and is on the path.
3. Generate a key for the Terraform Service account in the uis-automation-dm
   project:

    ```bash
    $ gcloud iam --project uis-automation-dm service-accounts \
        keys create secrets/terraform-admin-service-account-credentials.json \
        --iam-account terraform-admin@uis-automation-dm.iam.gserviceaccount.com
    ```
4. Make sure your local helm install is up-to-date and has the Gitlab repository
   configured:

    ```bash
    $ helm init --client-only
    $ helm repo add gitlab https://charts.gitlab.io/
    ```

## Deploy Gitlab

```bash
# Required only once
$ terraform init

# Update production deployment
$ terraform apply -target=module.production

# Update test deployment
$ terraform apply -target=module.test

# Update all the things
$ terraform apply
```

### First ever deployment

> This section only applies if you are deploying completely from scratch. You
> may be doing this if you are making use of terraform's
> [workspace](https://www.terraform.io/docs/state/workspaces.html) feature.

This section is of use if you are getting errors of the following form:

```
module.{...}.provider.google: google: could not find default credentials.
```

Terraform may have difficulty reconciling state the very first time a new
deployment is made. This is because the Google provider's credentials are
themselves generated by terraform and it may have difficulty bootstrapping
itself. You can help it out by manually creating the project first:

```bash
$ terraform apply -target=module.production.module.project
$ terraform apply -target=module.test.module.project
```

## Overview

The general idea with this deployment is that individual instances of Gitlab can
be deployed *n* times. The default configuration includes a production and test
instance but we should be able to "let a thousand Gitlabs bloom".

To that end most resources which share a global namespace have random names. For
example, all of the DNS entries for the releases have random names. Similarly,
the Google project ids have random elements. From looking at other people's
terraform examples this appears to be Very Much The Way To Do It.

The top-level [main.tf](main.tf) in this repository contains configuration for
two environments: ``test`` and ``production``.

## Hacking on this deployment

*PLEASE, PLEASE, PLEASE* make sure you use ``terraform fmt`` before committing.

## Recipes

This section contains some recipes which are useful when dealing with the
deployment.

### Get Gitlab URL and initial root password

The following will (on Linux) open your web browser at the production deployment
and copy the root password to the clipboard. Replace ``production`` with
``test`` for the test deployment.

```bash
$ xdg-open $(terraform output production_gitlab_url)
$ terraform output production_initial_root_password | xclip -i -sel clip
```

### Using kubectl/helm directly

A kubeconfig file suitable for connecting to the clusters created by this
deployment is available as an output. For example, to connect to the production
cluster:

```bash
$ export KUBECONFIG=$(mktemp ./secrets/kubeconfig.XXXXXX)
$ terraform output production_kubeconfig_content > "$KUBECONFIG"
$ kubectl -n gitlab get pod
$ helm ls
```

### Overriding the domain name for a particular environment

> This feature is unused at the moment and may change as we make use of it.

The [environment module](environment/) takes a variable named ``gitlab_domain``.
This can be used to override the domain name which is passed into the gitlab
config.

This variable just updates the gitlab configuration, it doesn't do any DNS
registration and so it is up to you to make sure that the domain name ends up at
the right IP. This could be by making it a CNAME to a host within the generated
DNS zone.

### Doing some large scale refactoring

If you want to do some large-scale experimentation with this deployment, you can
switch to a new terraform
[workspace](https://www.terraform.io/docs/state/workspaces.html) which will spin
up a brand new set of infrastructure.

### Fixing random helm errors

You may encounter errors which look like the following:

```
helm_release.gitlab: rpc error: code = Unavailable desc = transport is closing
```

This is a sign that the ``helm init`` command succeeded but the tiller pod is
not yet fully up. By the time you've read the message and found this entry in
the README, the pod is probably up so just go back to your terminal and press
"up" and "enter".

## Getting familiar with this deployment

This deployment is large and complex and is possibly best understood by
experimenting with it. One has two choices in this regard:

1. Experiment but only ever deploy the testing release.

2. Set up two entirely new Google projects.

If you want to go down the latter route, you can set up a new "workspace". A
"workspace" is an entirely parallel terraform state which is different from the
"default" workspace. In this parallel workspace you can try deploying your own
version of Gitlab.

You really should read and digest the entire section of the terraform manual on
workspaces first but the quick, quick version is:

```bash
$ terraform workspace new my-workspace  # choose a better name than this!
$ terraform init
$ terraform apply -target=module.production.module.project -target=module.test.module.project
$ terraform apply
```

## Setting up terraform admin service account

> This should only ever need to be done once. It is documented here for
> reference. See the [backend configuration](backend.tf) for how the account is
> used.

We make use of terraform's remote state backend. We configure the backend to
store the terraform state in a GCS bucket. We need to configure a terraform
admin serice account which is used to manage the contents of that bucket and to
create the actual GCP projects in the deployment. The terraform admin service
account is created in the following way:

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

The terraform state bucket is created in the following way:

```bash
$ gsutil mb -p uis-automation-dm -l europe-west2 gs://uis-devops-terraform-state-you6phet
$ gsutil versioning set on gs://uis-devops-terraform-state-you6phet
```

Additionally terraform-admin@uis-automation-dm.iam.gserviceaccount.com is added
as a "Billing User" to the billing account.
