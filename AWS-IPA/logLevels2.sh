#!/bin/bash

# Source the parameter function
source parameter_function.sh

# FTPS server details
ftps_server="ftp://localhost"

# AWS S3 details
s3_bucket="mysource-directory"
s3_key="source.csv"

# CloudWatch Logs details
log_group_name="ipaFtp-Log"
log_stream_name="ipaFtp-stream"

# Temporary directory to store the downloaded file
temp_dir="/tmp"

# Function to put logs to CloudWatch
put_logs() {
  local log_level="$1"
  local message="$2"
  local timestamp=$(date +%s%3N) # Get current timestamp in milliseconds
  
  # Construct the JSON object for the log event
  local log_event="{\"timestamp\": $timestamp, \"message\": \"$log_level - $message\"}"

  # Use the AWS CLI to put the log event
  aws logs put-log-events \
    --log-group-name "$log_group_name" \
    --log-stream-name "$log_stream_name" \
    --log-events "$log_event"
}

transfer() {
  local username
  local password

  # Fetch FTP username and password from AWS Systems Manager Parameter Store
  username=$(get_parameter "/ftp/username")
  password=$(get_parameter "/ftp/password")

  put_logs "[INFO] Downloading $s3_key from S3 $s3_bucket bucket"
  aws s3 cp "s3://$s3_bucket/$s3_key" "$temp_dir/$s3_key"
  if [ $? -eq 0 ]; then
    put_logs "[INFO] Download complete."
    local_file="$temp_dir/$s3_key"
    put_logs "[INFO] Transferring $local_file to FTPS server..."
    curl -k --ftp-ssl --user "$username:$password" -T "$local_file" "$ftps_server"
    if [ $? -eq 0 ]; then
      put_logs "[INFO] Transfer complete."
      put_logs "[INFO] Deleting $s3_key from S3 $s3_bucket bucket."
      aws s3 rm "s3://$s3_bucket/$s3_key"
      put_logs "[INFO] Deletion complete."
    else
      put_logs "[ERROR] Failed to transfer $local_file to FTPS server."
    fi
  else
    put_logs "[ERROR] Failed to download $s3_key from S3 $s3_bucket bucket."
  fi
}

transfer
