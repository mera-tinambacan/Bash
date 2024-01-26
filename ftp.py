from ftplib import FTP

def upload_file(ftp, local_file, remote_file):
    with open(local_file, 'rb') as file:
        ftp.storbinary('STOR ' + remote_file, file)

def main():
    # ProFTPD server details
    ftp_server = '127.0.0.1'  # actual server address
    ftp_port = 21  # port number
    ftp_user = 'mers'
    ftp_password = 'mers'

    # Connect to the FTP server
    ftp = FTP()
    ftp.connect(ftp_server, port=ftp_port)
    ftp.login(user=ftp_user, passwd=ftp_password)

    local_file_to_upload = 'calculator.sh'
    remote_file_name = 'remote_calculator.sh'
    upload_file(ftp, local_file_to_upload, remote_file_name)
    print(f'File "{local_file_to_upload}" uploaded successfully to "{remote_file_name}"')


    # Close the FTP connection
    ftp.quit()
if __name__ == "__main__":
    main()