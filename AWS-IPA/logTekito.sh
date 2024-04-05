#!/bin/bash

# Function to replace timestamps with current timestamp in log lines
replace_timestamp() {
    while read -r line; do
        current_timestamp=$(date +"%Y-%m-%d %H:%M:%S.%3N")
        echo "${line/20[0-9][0-9]-[0-1][0-9]-[0-3][0-9] [0-2][0-9]:[0-5][0-9]:[0-5][0-9].[0-9][0-9][0-9]/$current_timestamp}"
    done
}

# Function to modify filename with current timestamp
modify_filename() {
    current_timestamp=$(date +"%Y%m%d%H%M%S")
    echo "$1" | sed "s/\(.*_\)[0-9]\{14\}\(_.*\)/\1$current_timestamp\2/"
}

# Replace timestamps in lines containing "AssignAdminPassword" and append modified content to new file
grep -e "AssignAdminPassword" tm1server.log | replace_timestamp >> file5.log

# Modify filename for TM1ProcessError file
modified_filename=$(modify_filename "TM1ProcessError_20231130140134_41513540_tekito.log")

# Upload modified log file
curl --ftp-ssl -u fs_kobelco-dev:6mCQhWJ90jnUdL -T file5.log ftp://kobelco-dev.planning-analytics.cloud.ibm.com/prod/connect_test/

# Upload modified TM1ProcessError file
curl --ftp-ssl -u fs_kobelco-dev:6mCQhWJ90jnUdL -T "TM1ProcessError_20231130140134_41513540_sample.log" ftp://kobelco-dev.planning-analytics.cloud.ibm.com/$

