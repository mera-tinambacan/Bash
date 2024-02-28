import os
import boto3
from ftplib import FTP_TLS

# Configure FTP connection settings
ftp_host = "18.141.188.78"
ftp_user = "tejun"
ftp_password = "tejun"
target_directory = "/home/ubuntu/destination"

s3 = boto3.client('s3')
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
    transferred_files = []  # List to store transferred file names
    try:
        # Connect to the FTP server
        ftp = FTP_TLS(ftp_host)
        ftp.login(ftp_user, ftp_password)
        ftp.prot_p()
        
        # List objects in the S3 bucket
        s3_bucket = 's3-to-ftp'
        response = s3.list_objects_v2(Bucket=s3_bucket)
        if 'Contents' in response:
            for obj in response['Contents']:
                s3_key = obj['Key']
                
                # Download the file from S3 to local storage
                local_file_path = '/tmp/' + os.path.basename(s3_key)
                s3.download_file(s3_bucket, s3_key, local_file_path)
                
                # Backup the object to backup-s3-ftp bucket
                destination_bucket = 'backup-s3-to-ftp'
                s3.copy_object(
                    Bucket=destination_bucket,
                    CopySource={'Bucket': s3_bucket, 'Key': s3_key},
                    Key=s3_key
                )

                # Upload the file to the FTP server
                ftp.cwd(target_directory)
                with open(local_file_path, 'rb') as file:
                    ftp.storbinary('STOR ' + os.path.basename(local_file_path), file)

                # Add transferred file name to the list
                transferred_files.append(os.path.basename(s3_key))

                # Delete the object from S3
                s3.delete_object(Bucket=s3_bucket, Key=s3_key)

                print(f"File {s3_key} transferred to FTP server successfully.")

            # Send email notification with a list of transferred files
            if transferred_files:
                email_subject = "File Transfer Successful"
                email_body = f"The following files were transferred to FTP server:\n\n"
                email_body += '\n'.join(transferred_files)
                send_email_notification(email_subject, email_body)
                print("Email notification sent with the list of transferred files.")

        else:
            print("No objects found in the S3 bucket.")

    except Exception as e:
        print(f"Error: {e}")