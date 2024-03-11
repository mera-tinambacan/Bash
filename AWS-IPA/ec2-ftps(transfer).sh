# Set the AWS S3 details
s3_bucket="mysource-directory"
s3_key="source.csv"

# Temporary directory to store the downloaded file
temp_dir="/tmp"

# Set the FTPS server details
ftps_server="ftp://localhost" #home/mera
username="mera"
password="mers1234"

transfer() {
  echo "Downloading $s3_key from S3..."
  aws s3 cp "s3://$s3_bucket/$s3_key" "$temp_dir"
  if [ $? -eq 0 ]; then
    echo "Download complete."
    local_file="$temp_dir/$s3_key"
    echo "Transferring $local_file..."
    curl --upload-file "$local_file" -k --ftp-ssl --user "$username:$password" "$ftps_server"
    echo "Transfer complete."
    echo "Deleting $s3_key from $s3_bucket bucket..."
    aws s3 rm "s3://$s3_bucket/$s3_key"
    echo "Deletion complete."
  else
    echo "Failed to download $s3_key from S3."
  fi
}
transfer
