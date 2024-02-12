import os
import boto3
from ftplib import FTP_TLS
import json

# Configure FTP connection settings
ftp_host = "54.253.26.52"
ftp_user = "tejun"
ftp_password = "tejun"
target_directory = "/home/ubuntu/test_directory"

# Initialize S3
s3 = boto3.client('s3')

def lambda_handler(event, context):
    try:
        #Connect to the FTP server
        ftp = FTP_TLS(ftp_host)
        ftp.login(ftp_user, ftp_password)
        
        # Explicitly call prot_p() to enable TLS encryption
        ftp.prot_p()
        
        # Check if the event contains records
        if 'Records' in event:
            # Loop through records
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
                    ftp.storlines('STOR ' + os.path.basename(local_file_path), file)

                # Close FTP connection
                ftp.quit()

                
                # Delete the S3 object
                s3.delete_object(Bucket=s3_bucket, Key=s3_key)

                print(f"File {s3_key} transferred to FTPTLS server successfully.")

        else:
            print("Error: 'Records' key not found in the event. Malformed event structure.")

    except Exception as e:
        print(f"Error: {e}")