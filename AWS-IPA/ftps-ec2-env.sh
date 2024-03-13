#!/bin/bash

# Source environment variables
source env.sh

# Set the FTPS server details
ftps_server="ftp://localhost" #home/mera
ftps_file="destination1.csv"

# Set the AWS S3 details
s3_bucket="mydestination-directory"

# Temporary directory to store the downloaded file
temp_dir="/tmp"

transfer() {
  echo "Downloading $ftps_file from FTPS..."
  curl -k --ftp-ssl --user "$FTPS_USERNAME:$FTPS_PASSWORD" "$ftps_server/$ftps_file" -o "$temp_dir/$ftps_file"
  if [ $? -eq 0 ]; then
    echo "Download complete."
    local_file="$temp_dir/$ftps_file"
    echo "Transferring $local_file to S3..."
    aws s3 cp "$local_file" "s3://$s3_bucket"
    echo "Transfer complete."
    echo "Deleting $ftps_file from FTPS server..."
    curl -k --ftp-ssl --user "$FTPS_USERNAME:$FTPS_PASSWORD" -Q "DELE $ftps_file" "$ftps_server"
    echo "Deletion complete."
  else
    echo "Failed to download $ftps_file from FTPS."
  fi
}
transfer

