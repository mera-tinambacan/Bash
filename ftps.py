from ftplib import FTP_TLS
import os #to interact with the operating system, for working with file paths and directory listings


local_directory_to_upload = '/home/merac/test_directory'
remote_directory = 'destination'

def upload_directory(ftp, local_directory, remote_directory):
    for item in os.listdir(local_directory):
        item_path = os.path.join(local_directory, item)

        if os.path.isfile(item_path):
            with open(item_path, 'rb') as file:
                remote_file = os.path.join(remote_directory, item)
                ftp.storbinary('STOR ' + remote_file, file)
                print(f'File "{item}" uploaded successfully to "{remote_file}"')

                # Delete the local file after successful upload
                os.remove(item_path)
                print(f'Local file "{item}" deleted.')

def main():
    #ProFTPD server details
    ftp_server = '127.0.0.1'
    ftp_port = 21
    ftp_user = 'mers'
    ftp_password = 'mers'

    # Connect to the FTP server
    ftp = FTP_TLS()
    ftp.connect(ftp_server, port=ftp_port)
    # print(ftp.getwelcome())
    ftp.login(user=ftp_user, passwd=ftp_password)
    ftp.prot_p()
    upload_directory(ftp, local_directory_to_upload, remote_directory)

    # Close the FTP connection
    ftp.quit()

if __name__ == "__main__":
    main()
