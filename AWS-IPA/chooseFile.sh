#!/bin/bash

# Source the .env file to load credentials
source "/mnt/c/Users/meracle.tinambacan/Desktop/directory/Secret Manager/.env"

# Backup directory
backup_dir="/mnt/c/Users/meracle.tinambacan/Desktop/directory/backup"

# Set the FTPS server details
FTPS_SERVER="ftp://localhost/destination/"

# Prompt user to choose the file
read -p "Enter the path to the file you want to backup: " file_name

backup() {
  if [ -f "$1" ]; then
      echo "Backing up $1..."
      cp "$1" "$backup_dir"
      echo "Backup complete."
      echo "Transferring $1..."
      curl --upload-file "$1" -k --ftp-ssl --user "$FTPS_USERNAME:$FTPS_PASSWORD" "$FTPS_SERVER"
      echo "Transfer complete."
      # Delete the file from the source folder
      echo "Deleting $1 from source folder..."
      rm "$1"
      echo "Deletion complete."
  else
      echo "File not found: $1"
  fi
}

backup "$file_name"

#/mnt/c/Users/meracle.tinambacan/Desktop/directory/files/trial1.csv