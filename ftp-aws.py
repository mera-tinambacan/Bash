from ftplib import FTP

def lambda_handler(event, context):
    ftp_host = "13.211.18.29"
    ftp_user = "aws"
    ftp_password = "aws"

    try:
        with FTP(ftp_host, ftp_user, ftp_password) as ftp:
            print("Successfully connected to FTP server.")

            # List the contents of the current directory
            ftp.retrlines('LIST')
            
    except Exception as e:
        print(f"Error: {e}")