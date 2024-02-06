import os
import boto3
from ftplib import FTP
import json

def lambda_handler(event, context):
    print("Received event:", json.dumps(event, indent=2))
    try:
        # Extract S3 bucket and object key from the event
        s3_bucket = event['Records'][0]['s3']['bucket']['name']
        s3_key = event['Records'][0]['s3']['object']['key']

        # Configure FTP connection settings
        ftp_host = "13.211.18.29"
        ftp_user = "aws"
        ftp_password = "aws"
        target_directory = "/home/ubuntu/test_directory"
        
        # Initialize S3 and FTP clients
        s3 = boto3.client('s3')
        ftp = FTP(ftp_host, ftp_user, ftp_password)
        
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
        
    except KeyError as e:
        print(f"Error: {e}. Malformed event structure, unable to extract necessary data.")
    except Exception as e:
        print(f"Error: {e}")
