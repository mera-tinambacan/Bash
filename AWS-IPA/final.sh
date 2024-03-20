#!/bin/bash

# Source the parameter functions
source parameter_function.sh

# FTPS server details
ftps_server="ftp://localhost"
ftps_source_directory="source"
ftps_backup_directory="backup"
ftps_file="source.csv"

# AWS S3 details
s3_bucket="mydestination-directory"

# CloudWatch Logs details
log_group_name="ipaFtp-Log"
log_stream_name="ipaFtp-Stream"

# Temporary directory to store the downloaded file
temp_dir="/tmp"

# Function to put logs to Cloudwatch
put_logs() {
  local log_level="$1"
  local message="$2"
  local timestamp=$(date +%s%3N)

  # Construct the JSON object for the log event
  local log_event="{\"timestamp\": $timestamp, \"message\": \"$log_level - $message\"}"

  # Use the AWS CLI to put the log event
  aws logs put-log-events \
    --log-group-name "$log_group_name" \
    --log-stream-name "$log_stream_name" \
    --log-events "$log_event"
}

backup_file() {
  local username
  local password

  # Fetch FTP username and password from source
  username=$(get_parameter "/ftp/username")
  password=$(get_parameter "/ftp/password")

  put_logs "Copying $ftps_file from source to backup directory..."
  curl -k --ftp-ssl --user "$username:$password" "$ftps_server/$ftps_source_directory/$ftps_file" -o "$temp_dir/$ftps_file" # Download the file
  curl -k --ftp-ssl --user "$username:$password" -T "$temp_dir/$ftps_file" "$ftps_server/$ftps_backup_directory/$ftps_file" # Upload the file to backup directory
  put_logs "[INFO] Backup complete."
}

delete_files() {
  local username
  local password

  # Fetch FTP username and password from source
  username=$(get_parameter "/ftp/username")
  password=$(get_parameter "/ftp/password")

  put_logs "Deleting $ftps_file from source directory..."
  curl -k --ftp-ssl --user "$username:$password" -Q "DELE $ftps_source_directory/$ftps_file" "$ftps_server"
  put_logs "[INFO] Deletion from source complete."

  put_logs "Deleting $ftps_file from temporary directory..."
  rm "$temp_dir/$ftps_file"
  put_logs "[INFO] Deletion from temporary directory complete."
}

transfer() {
  backup_file

  put_logs "Downloading $ftps_file from FTPS..."
  if [ $? -eq 0 ]; then
    put_logs "[INFO] Download complete."
    local_file="$temp_dir/$ftps_file"
    put_logs "[INFO] Transferring $local_file to S3..."
    aws s3 cp "$local_file" "s3://$s3_bucket"
    put_logs "[INFO] Transfer complete."
    delete_files
  else
    put_logs "[ERROR] Failed to download $ftps_file from FTPS."
  fi
}

transfer
