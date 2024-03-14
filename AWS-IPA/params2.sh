#!/bin/bash

# FTPS server details
ftps_server="ftp://localhost"

# AWS S3 details
s3_bucket="mysource-directory"
s3_key="source.csv"

# Temporary directory to store the downloaded file
temp_dir="/tmp"

# Fetch parameter value from AWS Systems Manager Parameter Store
get_parameter() {
  local name="$1"
  aws ssm get-parameter --name "$name" --query "Parameter.Value" --output text
}

transfer() {
  local username
  local password

  # Fetch FTP username and password from AWS Systems Manager Parameter Store
  username=$(get_parameter "/ftp/username")
  password=$(get_parameter "/ftp/password")

  echo "Downloading $s3_key from S3..."
  aws s3 cp "s3://$s3_bucket/$s3_key" "$temp_dir/$s3_key"
  if [ $? -eq 0 ]; then
    echo "Download complete."
    local_file="$temp_dir/$s3_key"
    echo "Transferring $local_file to FTPS server..."
    curl -k --ftp-ssl --user "$username:$password" -T "$local_file" "$ftps_server"
    if [ $? -eq 0 ]; then
      echo "Transfer complete."
      echo "Deleting $s3_key from S3 bucket..."
      aws s3 rm "s3://$s3_bucket/$s3_key"
      echo "Deletion complete."
    else
      echo "Failed to transfer $local_file to FTPS server."
    fi
  else
    echo "Failed to download $s3_key from S3."
  fi
}

transfer
