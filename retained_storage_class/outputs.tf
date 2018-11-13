output "name" {
  value = "${local.name}"

  depends_on = ["null_resource.storage_class"]
}
