from ftplib import FTP

def lambda_handler(event, context):
    ftp_host = "13.211.18.29"
    ftp_user = "aws"
    ftp_password = "aws"
    target_directory = "/home/ubuntu"

    try:
        with FTP(ftp_host, ftp_user, ftp_password) as ftp:
            print("Successfully connected to FTP server.")
            
            # Change working directory to the target directory
            ftp.cwd(target_directory)
            
            # Get a list of directories
            directories = ftp.nlst()
            print("Directories in", target_directory, ":")
            for directory in directories:
                print(directory)
            
    except Exception as e:
        print(f"Error: {e}")

#ssh -i .\ftpKey.pem ec2-user@3.104.78.147
#increase timeout; include port 21 in outbound and inbound in security group-EC2; and maybe add permission about vpc?
#change event jason format
