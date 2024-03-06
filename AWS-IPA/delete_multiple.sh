#!/bin/bash

# local or source directory
local_dir="/mnt/c/Users/meracle.tinambacan/Desktop/directory/files"

# backup directory
backup_dir="/mnt/c/Users/meracle.tinambacan/Desktop/directory/backup"

# Set the FTPS server details
ftps_server="ftp://localhost/destination/"
username="mers"
password="mers"

# Transfer files using curl
for file in "$local_dir"/*; do
    if [ -f "$file" ]; then
        echo "Backing up $file..."
        cp "$file" "$backup_dir"
        echo "Backup complete."
        
        echo "Transferring $file..."
        curl --upload-file "$file" -k --ftp-ssl --user "$username:$password" "$ftps_server"
        echo "Transfer complete."

        # Delete the file from the source folder
        echo "Deleting $file from source folder..."
        rm "$file"
        echo "Deletion complete."
    fi
done
