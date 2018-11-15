# DNS managed zone

This module creates a Google Cloud DNS managed zone in the default project and
sets it up to be a delegated zone from a shared parent zone.

The default parent zone is the ``gcloud.automation.uis.cam.ac.uk`` in our shared
infrastructure project.

It will use the ``google`` and ``google-beta`` providers to create resources
within the default project. It will use the ``google.admin`` and
``google-beta.admin`` providers to create and query resources outside of the
default project.
