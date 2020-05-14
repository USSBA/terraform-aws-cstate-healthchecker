variable "github_conf" {
  type = object({
    repository = string,
    organization = string,
    oauth_token_ssm_paramter_name = string
  })
}
variable "healthcheck_conf" {
  type = list(object({
    endpoint_url = string,
    template_file_name = string
  }))
}

