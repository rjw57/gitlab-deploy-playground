# outputs.tf contain the defined outputs for the module

# The name of the storage class. Using this output adds an implicit dependency
# on the storage class being created.
output "name" {
  value      = "retain-ssd"
  depends_on = ["null_resource.retained"]
}
