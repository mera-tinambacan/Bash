#!/bin/bash

# Set the FTPS server details
ftps_server="ftp://localhost/shared_folder"
username="mers"
password="mers"

# Create success.txt using curl
curl -k --ftp-ssl --user "$username:$password" -T /dev/null "$ftps_server/success.txt"

echo "success.txt created in $directory on the FTPS server"
