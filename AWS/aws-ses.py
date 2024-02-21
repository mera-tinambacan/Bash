import os
import boto3
from ftplib import FTP_TLS

# Configure FTP connection settings
ftp_host = "13.213.2.164"
ftp_user = "tejun"
ftp_password = "tejun"
target_directory = "/home/ubuntu/destination"

# Initialize S3
s3 = boto3.client('s3')

# Initialize SES
ses = boto3.client('ses')

# Retrieve recipient email address from environment variable
recipient_email = os.environ.get('RECIPIENT_EMAIL')

def send_email_notification(subject, body):
    
    # Create a MIME message
    message = {
        'Subject': {'Data': subject},
        'Body': {'Text': {'Data': body}}
    }
    # Send the email
    response = ses.send_email(
        Source=recipient_email,
        Destination={'ToAddresses': [recipient_email]},
        Message=message
    )
    return response

def lambda_handler(event, context):
    try:
        # Connect to the FTP server
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
                    ftp.storbinary('STOR ' + os.path.basename(local_file_path), file)

                # Close FTP connection
                ftp.quit()

                # Delete the S3 object
                s3.delete_object(Bucket=s3_bucket, Key=s3_key)

                # Send email notification
                email_subject = "File Transfer Successful"
                email_body = f"File {s3_key} transferred to FTPTLS server successfully."
                send_email_notification(email_subject, email_body)

                print(f"File {s3_key} transferred to FTPTLS server successfully.")

        else:
            print("Error: 'Records' key not found in the event. Malformed event structure.")

    except Exception as e:
        print(f"Error: {e}")
