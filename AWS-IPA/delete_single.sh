#!/bin/bash
# local or source directory
local_dir="/mnt/c/Users/meracle.tinambacan/Desktop/directory/files"

# local or source file
file_name="/mnt/c/Users/meracle.tinambacan/Desktop/directory/files/source.csv"

# backup directory
backup_dir="/mnt/c/Users/meracle.tinambacan/Desktop/directory/backup"

# Set the FTPS server details
ftps_server="ftp://localhost/destination/"
username="mers"
password="mers"
backup() {
  if [ -f "$1" ]; then
      echo "Backing up $1..."
      cp "$1" "$backup_dir"
      echo "Backup complete."
      echo "Transferring $1..."
      curl --upload-file "$1" -k --ftp-ssl --user "$username:$password" "$ftps_server"
      echo "Transfer complete."
      # Delete the file from the source folder
      echo "Deleting $1 from source folder..."
      rm "$1"
      echo "Deletion complete."
  fi
}
backup $file_name
## Transfer multiple files using curl
#for file in "$local_dir"/*; do
#  backup $file
#done