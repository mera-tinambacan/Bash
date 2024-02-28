import os
import boto3
from ftplib import FTP_TLS

# Configure FTP connection settings
ftp_host = "18.141.188.78"
ftp_user = "tejun"
ftp_password = "tejun"
target_directory = "/home/ubuntu/destination"

# Initialize FTP
ftp = FTP_TLS(ftp_host)
ftp.login(ftp_user, ftp_password)
ftp.prot_p()

# Initialize S3 and SES clients using boto3
s3 = boto3.client('s3')
ses = boto3.client('ses')

# Retrieve recipient email address from environment variable
recipient_email = os.environ.get('RECIPIENT_EMAIL')

def copy_to_backup_bucket(s3_key, s3_bucket, destination_bucket):
    try:
        s3.copy_object(
            Bucket=destination_bucket,
            CopySource={'Bucket': s3_bucket, 'Key': s3_key},
            Key=s3_key
        )
        print(f"File {s3_key} copied to backup bucket successfully.")
    except Exception as e:
        print(f"Error copying file {s3_key} to backup bucket: {e}")

def upload_to_ftp(local_file_path, ftp):
    try:
        ftp.cwd(target_directory)
        with open(local_file_path, 'rb') as file:
            ftp.storlines('STOR ' + os.path.basename(local_file_path), file)
        print(f"File {local_file_path} uploaded to FTP server successfully.")
    except Exception as e:
        print(f"Error uploading file {local_file_path} to FTP server: {e}")

def send_email_notification(subject, body):
    try:
        message = {
            'Subject': {'Data': subject},
            'Body': {'Text': {'Data': body}}
        }
        response = ses.send_email(
            Source=recipient_email,
            Destination={'ToAddresses': [recipient_email]},
            Message=message
        )
        print("Email notification sent successfully.")
    except Exception as e:
        print(f"Error sending email notification: {e}")
        
def delete_from_s3(s3_key, s3_bucket):
    try:
        s3.delete_object(Bucket=s3_bucket, Key=s3_key)
        print(f"File {s3_key} deleted from S3 bucket successfully.")
    except Exception as e:
        print(f"Error deleting file {s3_key} from S3 bucket: {e}")

def lambda_handler(event, context):
    transferred_files = []
    try:
        s3_bucket = 's3-to-ftp'
        destination_bucket = 'backup-s3-to-ftp'
        
        response = s3.list_objects_v2(Bucket=s3_bucket)
        if 'Contents' in response:
            for obj in response['Contents']:
                s3_key = obj['Key']
                local_file_path = '/tmp/' + os.path.basename(s3_key)
                
                # Copy to backup bucket
                copy_to_backup_bucket(s3_key, s3_bucket, destination_bucket)
                
                # Download from S3
                s3.download_file(s3_bucket, s3_key, local_file_path)
                
                # Upload to FTP
                upload_to_ftp(local_file_path, ftp)
                
                # Add to transferred_files list
                transferred_files.append(os.path.basename(s3_key))

            # Send email notification
            if transferred_files:
                email_subject = "File Transfer Successful"
                email_body = f"The following files were transferred to FTP server:\n\n"
                email_body += '\n'.join(transferred_files)
                send_email_notification(email_subject, email_body)

        else:
            print("No objects found in the S3 bucket.")
            
        # Delete from S3
        delete_from_s3(s3_key, s3_bucket)

    except Exception as e:
        print(f"Error: {e}")
