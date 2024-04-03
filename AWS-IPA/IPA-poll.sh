#!/bin/bash

# Source the parameter functions
source /home/ec2-user/s3toftps/parameter_function.sh

# Configuration
FTPS_SERVER="kobelco-dev.planning-analytics.cloud.ibm.com"
FTPS_DESTINATION_DIRECTORY="prod/connect_test"
USERNAME=$(get_parameter "/ipa-test/username")
PASSWORD=$(get_parameter "/ipa-test/password")
LOG_GROUP_NAME="HostToIPA"
LOG_STREAM_NAME="HostToIPA-Stream"

echo "$USERNAME"
# Function to put logs into CloudWatch
put_logs() {
  local log_level="$1"
  local message="$2"
  local timestamp=$(date +%s%3N)
  local log_event="{\"timestamp\": $timestamp, \"message\": \"$log_level - $message\"}"
  aws logs put-log-events \
    --log-group-name "$LOG_GROUP_NAME" \
    --log-stream-name "$LOG_STREAM_NAME" \
    --log-events "$log_event" \
    --region ap-northeast-1 >/dev/null 2>&1
}

# Function to poll the file on FTPS server
poll_file() {
  local file="$1"

  # Polling loop
  while true; do
    # Check if file exists on the server
    if curl -s --ftp-ssl -u "$USERNAME:$PASSWORD" "ftp://$FTPS_SERVER/$FTPS_DESTINATION_DIRECTORY/$file" >/dev/null; th$      put_logs "INFO" "File $file found on FTPS server."
      break
    else
      put_logs "INFO" "File $file not found on FTPS server. Polling again in 60 seconds..."
      sleep 60
    fi
  done
}

# Main
if [ $# -eq 0 ]; then
  echo "Error: No file path provided. Please provide the file path as an argument."
  exit 1
fi

file="$1"
poll_file "$file"
