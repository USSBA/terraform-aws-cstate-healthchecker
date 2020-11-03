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
variable "healthchecks" {
  type = list(object({
    fqdn               = string,
    port               = number,
    type               = string,
    resource_path      = string,
    evaluation_periods = number,
    alarm_name         = string
  }))
}

variable "healthcheck_regions" {
  type    = list(string)
  default = []
}

variable "retention_period_in_minutes" {
  type = number
  default = -1
  description = "Retain events that persist longer than this threshold. Default is -1 resulting in all events being retained."
}
