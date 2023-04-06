provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_public_key
  private_key = var.mongodb_atlas_private_key
}

resource "mongodbatlas_project" "fragmenty" {
  name   = "fragmenty"
  org_id = var.mongodb_atlas_organs_id
}


# https://www.mongodb.com/docs/atlas/reference/amazon-aws/#amazon-web-services--aws-
# https://www.mongodb.com/docs/atlas/reference/free-shared-limitations/#service-m0--free-cluster---m2--and-m5-limitations
resource "mongodbatlas_cluster" "my_cluster" {
  project_id = mongodbatlas_project.fragmenty.id
  name       = "my-atlas-cluster"

  // Provider Settings
  # https://github.com/mongodb/terraform-provider-mongodbatlas/issues/64
  provider_name               = "TENANT" // FOR AWS Free Tier Cluster
  backing_provider_name       = "AWS"
  provider_region_name        = "EU_CENTRAL_1"
  provider_instance_size_name = "M0" // Free Tier
}

resource "mongodbatlas_database_user" "my_database_user" {
  username           = var.database_username
  password           = var.database_password
  project_id         = mongodbatlas_project.fragmenty.id
  auth_database_name = "admin"
  # delete_after_date  = "2023-04-30T12:00:00Z" // Set the date when the user should be deleted.
  roles {
    role_name     = "readWrite"
    database_name = var.database_name
  }
}

# https://www.mongodb.com/docs/atlas/security-vpc-peering
resource "mongodbatlas_project_ip_access_list" "everywhere" {
  project_id = mongodbatlas_project.fragmenty.id
  cidr_block = "0.0.0.0/0"
  comment    = "accessing from everywhere"
}
