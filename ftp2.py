from ftplib import FTP
import os #to interact with the operating system, for working with file paths and directory listings



def upload_directory(ftp, local_directory, remote_directory):
    for item in os.listdir(local_directory):
        item_path = os.path.join(local_directory, item)

        if os.path.isfile(item_path):
            with open(item_path, 'rb') as file:
                remote_file = os.path.join(remote_directory, item)
                ftp.storbinary('STOR ' + remote_file, file)
                print(f'File "{item}" uploaded successfully to "{remote_file}"')

def main():
    #ProFTPD server details
    ftp_server = '127.0.0.1'
    ftp_port = 21 
    ftp_user = 'mers'
    ftp_password = 'mers'

    remote_directory = 'destination'
    
    # Connect to the FTP server
    ftp = FTP()
    ftp.connect(ftp_server, port=ftp_port) 
    ftp.login(user=ftp_user, passwd=ftp_password)

    #Upload all files from local directory to the server
    local_directory_to_upload = '/home/merac_tinambacan/test_directory'
    upload_directory(ftp, local_directory_to_upload, remote_directory)

    ftp.quit() # Close the FTP connection

if __name__ == "__main__":
    main()

#############

# Grant write permissions to the owner, group, and others for the directory
#chmod a+w /home/mers/destination
#sudo chmod 755 /home/mers/destination
