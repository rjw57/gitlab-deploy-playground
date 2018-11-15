# variables.tf contains definitions of variables used by the module.

# The region to create the DB in. Annoyingly, this is a required property for
# the resource.
variable "region" {}

# The tier of the DB instance
variable "tier" {}
