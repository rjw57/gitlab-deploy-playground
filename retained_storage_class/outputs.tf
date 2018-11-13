output "name" {
  value = "${data.null_data_source.storage_class.outputs["name"]}"
}
