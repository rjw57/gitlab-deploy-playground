# Google Cloud Platform Project

This module creates a project on Google cloud platform, enables services in it
and, optionally, configures additional project editors.

A service account is created with owner rights on the project. The email and
credentials for the service account are available from the project
[outputs](outputs.tf).

It will use the ``google`` and ``google-beta`` providers to create resources.
These are usually configured to only have access within the project created by
this module and so one usually uses provider
[aliases](https://www.terraform.io/docs/configuration/providers.html#multiple-provider-instances)
to provided a specialised "admin" provider to the module.
