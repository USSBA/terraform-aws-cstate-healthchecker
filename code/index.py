from github import Github
import chevron

import os
import base64
import re
import json
from datetime import datetime, timezone

import boto3
ssm = boto3.client('ssm')

# Current Time
def current_time():
  return datetime.utcnow().replace(tzinfo=timezone.utc).isoformat(timespec='seconds')
def current_time_filename():
  return datetime.utcnow().strftime('%Y%m%d-%H%M%S')
# Fetch Template
def fetch_template(template_file_path, repo, branch = "master"):
  template_contents = None
  try:
    print(f"INFO: Looking for template: {template_file_path}")
    template_file = repo.get_contents(template_file_path, ref=branch)
    print("INFO: Template found")
    template_contents=base64.b64decode(template_file.content).decode("utf-8")
  except:
    print("WARN: Template not found")
  return template_contents


def lambda_handler(event, context):
  sns_message = json.loads(event['Records'][0]['Sns']['Message'])
  current_state = sns_message['NewStateValue']
  print(f"INFO: NewStateValue: {current_state}")
  #TODO: Get this from the event
  application_name="sbagov"

  parameter_name = os.environ.get("GITHUB_OAUTH_TOKEN_SSM_PARAM_NAME")
  #gh_token = ssm.get_parameter(Name='/sba-status/github_token', WithDecryption=True)['Parameter']['Value']
  gh_token = ssm.get_parameter(Name=parameter_name, WithDecryption=True)['Parameter']['Value']
  gh = Github(gh_token)

  #repo_org="USSBA"
  #repo_name="sba-status"
  #branch="master"
  repo_org  = os.environ.get('GITHUB_ORG')
  repo_name = os.environ.get('GITHUB_REPO')
  branch    = os.environ.get('GITHUB_REPO_BRANCH')

  latest_file=f"content/issues/{application_name}-latest.md"
  template_file_path=f"{latest_file}.template"

  repo = gh.get_repo(f"{repo_org}/{repo_name}")

  try:
    # Try to get contents of `latest` file, continue if exists, throw exception if it doesnt
    old_file = repo.get_contents(latest_file, ref=branch)
    # Found Existing `latest` File, implying active incident; updating if necessary
    old_file_contents = base64.b64decode(old_file.content).decode("utf-8")
    if current_state == "OK":
      # Status is okay, updating file to archive existing issue
      resolved_file_contents=re.sub(r'^(resolved:) .*', r'\1 true', old_file_contents, flags=re.MULTILINE)
      # Set resolvedWhen to current time
      resolved_file_contents=re.sub(r'^(resolvedWhen:) .*', rf'\1 {current_time()}', resolved_file_contents, flags=re.MULTILINE)
      resolved_file_path=re.sub("latest", current_time_filename(), latest_file)
      try:
        repo.create_file(resolved_file_path, message=f"Automatic update for {application_name}: resolved incident", content=resolved_file_contents, branch=branch)
        print(f"INFO: Latest file moved to {resolved_file_path}")
        try:
          repo.delete_file(latest_file, message=f"Automatic update for {application_name}: delete latest_file", branch=branch, sha=old_file.sha)
        except Exception as err:
          print(f"ERROR: Could not delete old latest file: path={latest_file}")
          print(err)
      except Exception as err:
        print(f"ERROR: Could not create new resolved_file: path={resolved_file_path}")
        print(err)
    else:
      print(f"INFO: Latest file exists, current_state={current_state}; no updates necessary")
  except:
    # File not found, create instead of update
    if current_state == "ALARM":
      # Fetch Template
      template_contents = fetch_template( template_file_path=template_file_path, repo=repo, branch=branch )
      if template_contents:
        target_contents=chevron.render(template_contents, {
          'start_date': current_time(),
          'resolved': 'false',
          'end_date': '\'\'',
        })
      else:
        target_contents="No template file found"
      try:
        repo.create_file(latest_file, message=f"Automatic update for {application_name}: new incident", content=target_contents, branch=branch)
        print("INFO: New file created")
      except:
        print("ERROR: Could not create new file")
        raise
    else:
      print(f"INFO: Latest file does not exist, current_state={current_state}; no updates necessary")


if __name__ == '__main__':
  print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
  print("UNIT TESTING MODE")
  print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
  lambda_handler(None, None)
