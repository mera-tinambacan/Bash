import os
import boto3
from ftplib import FTP
import json

# Configure FTP connection settings
ftp_host = "3.104.115.29"
ftp_user = "aws"
ftp_password = "aws"
target_directory = "/home/ubuntu/test_directory"

# Initialize S3 and FTP clients
s3 = boto3.client('s3')
ftp = FTP(ftp_host)
ftp.login(ftp_user, ftp_password)

def lambda_handler(event, context):

    try:
        # Check if the event contains records
        if 'Records' in event:
            # Loop through records (usually there's only one)
            for record in event['Records']:
                # Extract S3 bucket and object key from the record
                s3_bucket = record['s3']['bucket']['name']
                s3_key = record['s3']['object']['key']

                # Download the file from S3 to local storage
                local_file_path = '/tmp/' + os.path.basename(s3_key)
                s3.download_file(s3_bucket, s3_key, local_file_path)

                # Change working directory to the target directory on FTP server
                ftp.cwd(target_directory)

                # Upload the file to the FTP server
                with open(local_file_path, 'rb') as file:
                    ftp.storbinary('STOR ' + os.path.basename(local_file_path), file)

                # Close FTP connection
                ftp.quit()

                # Delete the local file
                os.remove(local_file_path)

                print(f"File {s3_key} transferred to FTP server successfully.")

        else:
            print("Error: 'Records' key not found in the event. Malformed event structure.")

    except Exception as e:
        print(f"Error: {e}")
