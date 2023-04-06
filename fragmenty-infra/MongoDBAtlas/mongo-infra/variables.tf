variable "mongodb_atlas_public_key" {
  description = "The MongoDB Atlas public API key"
}

variable "mongodb_atlas_private_key" {
  description = "The MongoDB Atlas private API key"
  sensitive   = true
}

variable "mongodb_atlas_organs_id" {
  description = "The MongoDB Atlas Organization Id"
}

variable "database_username" {
  description = "The created database username"
  sensitive   = true
}

variable "database_password" {
  description = "The created database password"
  sensitive   = true
}

variable "database_name" {
  description = "The cteated database name"
  default     = "fragmenty"
}
