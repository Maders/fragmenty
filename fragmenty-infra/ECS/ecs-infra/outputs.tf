output "play_app_secret" {
  value = random_string.play-app_secret.result
}

output "spider_sha" {
  value = data.external.git_hash_spider.result["sha_commit"]
}

output "api_sha" {
  value = data.external.git_hash_api.result["sha_commit"]
}
