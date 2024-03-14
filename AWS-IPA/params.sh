#!/bin/bash

# FTPS server details
ftps_server="ftp://localhost"
ftps_file="destination4.csv"

# AWS S3 details
s3_bucket="mydestination-directory"

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

  echo "Downloading $ftps_file from FTPS..."
  curl -k --ftp-ssl --user "$username:$password" "$ftps_server/$ftps_file" -o "$temp_dir/$ftps_file"
  if [ $? -eq 0 ]; then
    echo "Download complete."
    local_file="$temp_dir/$ftps_file"
    echo "Transferring $local_file to S3..."
    aws s3 cp "$local_file" "s3://$s3_bucket"
    echo "Transfer complete."
    echo "Deleting $ftps_file from FTPS server..."
    curl -k --ftp-ssl --user "$username:$password" -Q "DELE $ftps_file" "$ftps_server"
    echo "Deletion complete."
  else
    echo "Failed to download $ftps_file from FTPS."
  fi
}

transfer
