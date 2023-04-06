output "mongo_connection_string" {
  value = mongodbatlas_cluster.my_cluster.connection_strings[0].standard_srv
  # .my_cluster.connection_strings.standard_srv
  sensitive = true
}
