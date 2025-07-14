#!/bin/bash

# Function to make POST request with JSON body
make_post_request() {
  local url="$1"
  local json_body="$2"
  local temp_file=$(mktemp)

  wget --method=POST \
    --header="Content-Type: application/json" \
    --header="Accept: application/json" \
    --body-data="$json_body" \
    --quiet \
    --output-document="$temp_file" \
    --server-response \
    "$url" 2>&1

  local exit_code=$?
  local response_body=$(cat "$temp_file")
  rm -f "$temp_file"

  echo "$response_body"
  return $exit_code
}

API_URL="https://console-to-kafka-test.console.gcp.mia-platform.eu/proxy/job/job-id/buildWithParameters"

# Generate a random trigger ID (portable, works in most CI environments)
if command -v openssl >/dev/null 2>&1; then
  TRIGGER_ID=$(openssl rand -hex 16)
else
  TRIGGER_ID=$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c32)
fi
echo "TRIGGER_ID: $TRIGGER_ID"

# Define all required variables with default values or environment variables
JOB_TOKEN=${JENKINS_JOB_TOKEN:-""}
echo "JOB_TOKEN: $JOB_TOKEN"

JOB_ID=${JOB_ID:-""}
echo "JOB_ID: $JOB_ID"

TROUX_ID=${TROUX_ID:-""}
echo "TROUX_ID: $TROUX_ID"

PROJECT_NAME=${PROJECT_NAME:-""}
echo "PROJECT_NAME: $PROJECT_NAME"

SUFFIX=${SUFFIX:-""}
echo "SUFFIX: $SUFFIX"

ROLE_NAME=${ROLE_NAME:-""}
echo "ROLE_NAME: $ROLE_NAME"

JSON_DATA=${JSON:-"{}"}
echo "JSON_DATA: $JSON_DATA"

JSON_PAYLOAD=$(jq -n \
  --arg jobId "$JOB_ID" \
  --arg TrouxID "$TROUX_ID" \
  --arg ProjectName "$PROJECT_NAME" \
  --arg Suffix "$SUFFIX" \
  --arg RoleName "$ROLE_NAME" \
  --arg Json "$JSON_DATA" \
  --arg token "$JOB_TOKEN" \
  --arg triggerId "$TRIGGER_ID" \
  '{jobId: $jobId, token: $token, TrouxID: $TrouxID, ProjectName: $ProjectName, Suffix: $Suffix, RoleName: $RoleName, Json: $Json, key: $triggerId}')
echo "JSON_PAYLOAD: $JSON_PAYLOAD"

# Execute the POST request
echo "Making POST request to: $API_URL"
response=$(make_post_request "$API_URL" "$JSON_PAYLOAD" 2>&1)
exit_code=$?

# Check if request was successful
if [ $exit_code -eq 0 ]; then
  echo "Request successful"
else
  echo "Request failed with exit code: $exit_code"
  echo "Response: $response"
  exit 1
fi