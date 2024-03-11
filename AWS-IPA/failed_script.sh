ftps_server="ftp://localhost/shared_folder"
username="mers"
password="mers"

# Create success.txt using curl
curl -k --ftp-ssl --user "$username:$password" -T /dev/null "$ftps_server/error.txt"

echo "error.txt created in $directory on the FTPS server"
