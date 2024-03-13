#!/bin/bash

# FTPS server details
ftps_server="ftp://localhost" #home/mera

# Set the AWS S3 details
s3_bucket="mysource-directory"
s3_key="source1.csv"

# Temporary directory to store the downloaded file
temp_dir="/tmp"

transfer() {
  local username="$1"
  local password="$2"

  echo "Downloading $s3_key from S3..."
  aws s3 cp "s3://$s3_bucket/$s3_key" "$temp_dir/$s3_key"
  if [ $? -eq 0 ]; then
    echo "Download complete."
    local_file="$temp_dir/$s3_key"
    echo "Transferring $local_file to FTPS..."
    curl -T "$local_file" --ftp-ssl --user "$username:$password" "$ftps_server/$ftps_file"
    if [ $? -eq 0 ]; then
      echo "Transfer complete."
      echo "Deleting $s3_key from S3 bucket..."
      aws s3 rm "s3://$s3_bucket/$s3_key"
      echo "Deletion complete."
    else
      echo "Failed to transfer $local_file to FTPS."
    fi
  else
    echo "Failed to download $s3_key from S3."
  fi
}

# Check if the correct number of arguments is passed
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <username> <password>"
  exit 1
fi

# Invoke the transfer function with the provided credentials
transfer "$1" "$2"
