#!/bin/bash

# Set the FTPS server details
ftps_server="ftp://localhost/"
username="mers"
password="mers"

# Specify the directory where success.txt will be created
directory="ftp://localhost/shared_folder/"

# Change to the specified directory
cd "$directory" || exit

# Create the success.txt file
touch success.txt

echo "success.txt created in $directory"




#!/bin/bash

# Set the FTPS server details
ftps_server="ftp://localhost/destination/"
username="mers"
password="mers"

# Specify the directory where success.txt will be created
directory="ftp://localhost/shared_folder/"

# Change to the specified directory
cd "$directory" || exit

# Create the success.txt file
touch error.txt

echo "error.txt created in $directory"

#####################

#!/bin/bash

# Set the FTPS server details
ftps_server="ftp://localhost/shared_folder"
username="mers"
password="mers"

# Create success.txt using curl
curl -k --ftp-ssl --user "$username:$password" -T /dev/null "$ftps_server/error.txt"

echo "error.txt created in $directory on the FTPS server"
