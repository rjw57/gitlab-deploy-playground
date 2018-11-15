# Gitlab helm chart release

This module deploys the Gitlab helm chart into the k8s cluster and creates the
appropriate GCP resources for deployment. Since so many resources are created,
they've been split into separate terraform configurations.

## TODO

* Backup buckets
* Sending email
* Receiving email
* Testing Redis in a HA configuration

## Backups

Currently the Gitlab helm chart requires the use of
[s3cmd](https://s3tools.org/s3cmd) when making a backup/restoring a backup.
This, in turn, requires the S3-style HMAC authentication which Google does not
support with Service Accounts.

See the [generation of the s3cfg secret](k8s_secrets.tf) for more information.
