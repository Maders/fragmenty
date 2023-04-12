data "external" "git_hash_spider" {
  program = ["bash", "${path.module}/get_sha_module.sh"]

  query = {
    module = "spider"
  }
}

data "external" "git_hash_api" {
  program = ["bash", "${path.module}/get_sha_module.sh"]

  query = {
    module = "api"
  }
}
