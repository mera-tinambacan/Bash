#!/bin/bash

# Source the parameter functions
source parameter_function.sh

# Configuration
FTPS_SERVER="ftp://localhost"
FTPS_DESTINATION_DIRECTORY="destination"
S3_BUCKET="mysource-directory"
S3_KEY="source.csv"
BACKUP_S3_BUCKET="mybackup-directory"
BACKUP_S3_KEY="backup_source.csv"
LOG_GROUP_NAME="ipaFtp-Log2"
LOG_STREAM_NAME="ipaFtp-Stream2"

# Fetch FTP username and password from source
USERNAME=$(get_parameter "/ftp/username")
PASSWORD=$(get_parameter "/ftp/password")

# Temporary directory to store the downloaded file
TEMP_DIR="/tmp"

# Function to put logs to CloudWatch
put_logs() {
  local log_level="$1"
  local message="$2"
  local timestamp=$(date +%s%3N) # Get current timestamp in milliseconds
  local log_event="{\"timestamp\": $timestamp, \"message\": \"$log_level - $message\"}"

  # Use the AWS CLI to put the log event
  aws logs put-log-events \
    --log-group-name "$LOG_GROUP_NAME" \
    --log-stream-name "$LOG_STREAM_NAME" \
    --log-events "$log_event"
}

# Backup function
backup_to_s3() {
  # Check if the file exists on S3
  if aws s3 ls "s3://$S3_BUCKET/$S3_KEY" &>/dev/null; then
    put_logs "[INFO] Backing up $S3_KEY..."
    if aws s3 cp "s3://$S3_BUCKET/$S3_KEY" "s3://$BACKUP_S3_BUCKET/$BACKUP_S3_KEY"; then
      put_logs "[INFO] Backup complete."
    else
      put_logs "[ERROR] Failed to backup $S3_KEY to backup bucket."
      exit 1
    fi
  else
    put_logs "[ERROR] File $S3_KEY does not exist on source bucket. Exiting backup process."
    exit 1
  fi
}


# delete function
delete_files() {
  put_logs "[INFO] Deleting $S3_KEY from S3 bucket..."
  if aws s3 rm "s3://$S3_BUCKET/$S3_KEY"; then
    put_logs "[INFO] Deletion from S3 complete."
  else
    put_logs "[ERROR] Failed to delete $S3_KEY from S3 bucket."
  fi

  put_logs "[INFO] Deleting $S3_KEY from local directory..."
  if rm -f "$TEMP_DIR/$S3_KEY"; then
    put_logs "[INFO] Deletion from local directory complete."
  else
    put_logs "[ERROR] Failed to delete $S3_KEY from local directory."
  fi
}

# transfer function
transfer_files() {
  # Check if the file exists on S3
  if aws s3 ls "s3://$S3_BUCKET/$S3_KEY" &>/dev/null; then
    put_logs "[INFO] Downloading $S3_KEY from S3..."
    if aws s3 cp "s3://$S3_BUCKET/$S3_KEY" "$TEMP_DIR/$S3_KEY"; then
      put_logs "[INFO] Download complete."
      local_file="$TEMP_DIR/$S3_KEY"

      put_logs "[INFO] Transferring $local_file to FTPS server..."
      if curl -k --ftp-ssl --user "$USERNAME:$PASSWORD" -T "$local_file" "$FTPS_SERVER/$FTPS_DESTINATION_DIRECTORY/"; then
        put_logs "[INFO] Transfer complete."
        delete_files
      else
        put_logs "[ERROR] Failed to transfer $local_file to FTPS server."
        exit 1
      fi
    else
      put_logs "[ERROR] Failed to download $S3_KEY from S3."
      exit 1
    fi
  else
    put_logs "[ERROR] File $S3_KEY does not exist on source bucket. Exiting transfer process."
    exit 1
  fi
}

backup_to_s3
transfer_files
