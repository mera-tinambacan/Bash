#!/bin/bash

# FTPS server details
ftps_server="ftp://localhost" #home/mera
ftps_file="destination3.csv"

# AWS S3 details
s3_bucket="mydestination-directory"

# Temporary directory to store the downloaded file
temp_dir="/tmp"

transfer() {
  local username="$1"
  local password="$2"

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

# Check if the correct number of arguments is passed
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <username> <password>"
  exit 1
fi

transfer "$1" "$2"
