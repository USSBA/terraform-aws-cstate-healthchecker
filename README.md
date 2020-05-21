# CSTATE Health Checker Module

## Descripton

Provides a mechanizm for monitoring the health of a system and automatically create and resolve CSTATE issues.

## Usage

### Templates

The `alarm_name` property of a healthcheck must match the part of the issue template. An issue template must be located on the `/content/issues` directory and named accordingly:

* {alarm_name}-latest.md.template

The template contents must be of the follwoing format:

```
---
section: issue
title: An issue title of your choice
date: {{start_date}}
resolved: {{resolved}}
informational: false
resolvedWhen: {{end_date}}
affected: ['<your-cstate-component-name>']
severity: disrupted
---
A markdown formatted message of your choice
```



### Example Configuration
```
module "healthchecks" {
  source      = "github.com/USSBA/terraform-aws-cstate-healthchecker.git"
  name_prefix = "healthchecks"
  github_conf = {
    branch_name                  = "<your-branch>"
    organization_name            = "<your-github-organization>"
    repository_name              = "<your-github-repository>"
    oauth_token_ssm_paramter_arn = data.aws_ssm_parameter.github_token.arn
  }
  healthchecks = [
    {
      fqdn               = "first.com"
      port               = 443
      type               = "HTTPS"
      resource_path      = "/"
      evaluation_periods = 1
      alarm_name         = "first"
    },
    {
      fqdn               = "second.com"
      port               = 443
      type               = "HTTPS"
      resource_path      = "/"
      evaluation_periods = 1
      alarm_name         = "second"
    }
  ]
  healthcheck_regions = [
    "us-east-1",
    "us-west-1",
    "us-west-2",
  ]
}
```
