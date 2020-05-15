variable "name_prefix" {
  type = string
}
variable "github_conf" {
  type = object({
    branch_name                  = string,
    organization_name            = string,
    repository_name              = string,
    oauth_token_ssm_paramter_arn = string
  })
  #validation {
  #  condition     = join(":", regex("arn:aws:(ssm):.*:(parameter)/.*", var.github_conf.oauth_token_ssm_paramter_arn)) == "ssm:parameter"
  #  error_message = "Validation Error: github_conf.oauth_token_ssm_parameter_arn is not valid."
  #}
}
variable "healthcheck_conf" {
  type = list(object({
    endpoint_url     = string,
    application_name = string
  }))
}

