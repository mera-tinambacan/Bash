import os
import boto3
from io import BytesIO

# S3 bucket names
source_bucket_name = os.environ['mera-source']
destination_bucket_name = os.environ['remote-destination']

def copy_files_s3(source_bucket, destination_bucket):
    s3 = boto3.client('s3')

    # List all objects in the source bucket
    objects = s3.list_objects_v2(Bucket=source_bucket).get('Contents', [])

    for obj in objects:
        # Copy each object from the source to the destination bucket
        copy_source = {'Bucket': source_bucket, 'Key': obj['Key']}
        destination_key = f"destination/{obj['Key']}"  # Modify the destination key as needed

        s3.copy_object(CopySource=copy_source, Bucket=destination_bucket, Key=destination_key)
        print(f'File "{obj["Key"]}" copied to "{destination_bucket}/{destination_key}"')

def lambda_handler(event, context):
    # Copy files from source S3 bucket to destination S3 bucket
    copy_files_s3(source_bucket_name, destination_bucket_name)

    return {
        'statusCode': 200,
        'body': 'Files copied successfully!'
    }
