variable "user_names" {
  description = "Test usernames"
  type = "list"
  default = ["neo", "trinity", "morpheus"]
}

variable "give_neo_cloudwatch_full_access" {
  description = "If true, neo gets full access to CloudWatch"
}