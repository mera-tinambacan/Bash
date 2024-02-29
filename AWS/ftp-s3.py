import os
import boto3
from ftplib import FTP_TLS
import json

# Configure FTP connection settings
ftp_host = "3.0.184.148"
ftp_user = "tejun"
ftp_password = "tejun"
target_directory = "/home/ubuntu/directory"

# Initialize S3
s3 = boto3.client('s3')

def lambda_handler(event, context):
    try:
        #Connect to the FTP server
        ftp = FTP_TLS(ftp_host)
        ftp.login(ftp_user, ftp_password)
        
        # Explicitly call prot_p() to enable TLS encryption
        ftp.prot_p()
        
        # Change working directory to the source directory on FTP server
        ftp.cwd(target_directory)

        # List files in the source directory on FTP server
        files = ftp.nlst()

        # Check if files exist
        if files:
            # Loop through files
            for file_name in files:
                # Download the file from FTP server to local storage
                local_file_path = '/tmp/' + os.path.basename(file_name)
                with open(local_file_path, 'wb') as local_file:
                    ftp.retrbinary('RETR ' + file_name, local_file.write)

                # Upload the file to the S3 bucket
                with open(local_file_path, 'rb') as file:
                    s3.upload_fileobj(file, 'ftp-tos3', file_name)
                    
                # Delete the file from the FTP server
                ftp.delete(file_name)

                # Delete the local file after upload
                os.remove(local_file_path)

                print(f"File {file_name} transferred to S3 bucket successfully.")

        else:
            print("No files found in the source directory on FTP server.")

        # Close FTP connection
        ftp.quit()

    except Exception as e:
        print(f"Error: {e}")
