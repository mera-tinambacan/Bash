#!/bin/bash

# Set the local directory containing files to transfer
local_dir="/mnt/c/Users/meracle.tinambacan/Desktop/directory/files"

# Set the FTPS server details
ftps_server="ftp://localhost/destination/"
username="mers"
password="mers"

# Transfer files using curl
for file in "$local_dir"/*; do
    if [ -f "$file" ]; then
        echo "Transferring $file..."
        curl --upload-file "$file" -k --ftp-ssl --user "$username:$password" "$ftps_server"
        echo "Transfer complete."
    fi
done
