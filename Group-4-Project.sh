#!/bin/bash

#Project Title: Shell Script for file Backup and system monitoring

# This  script is designed to automate various system maintenance tasks, including file backup, system monitoring, and alerting and clean up. 
# The script aims to simplify the process of backing up  files of less than 1M in user home directory , 
# monitoring key system metrics,reporting and alerting system administrators and manager about  events such as high CPU usage, low disk space, etc via email. 
# schedule the  backups and monitoring activities through cron jobs. running crontab 2 am everyday.
# running 0 2 * * * /script-path
# Others is to automated cleanup of old backup files and logging of all script activities for better troubleshooting and tracking.

#Date: April 4 2024

# Authors and Contributors
	# Adeyemi Vicor
	# John Pamisi
	# Ibrahim Toheeb
	# Moshood Owolabi
	# Adeyemi Kafayat
	# Freedom Unugbai
	# IBrahim Olayinka
		
# Backing up files 

backup_dir="/backup" #This is the directory for backup
home_dir="$HOME" #This is the user's home directory
threshold_size="1048576c" #This is the threshold for the files to be compressed and backed up


# Define function for intial prompt

initial_prompt() {

        echo "BACKING UP YOUR FILES"
        echo
        echo "Files in your home directory less than 1MB are to be backed up to the /backup dir."
        echo
        echo "This requires having sudo privileges"

        read -p "Do you want to proceed (y/n)? " response
        if [[ ${response,,} != 'y' && ${response,,} != 'yes' ]]; then
                echo "Backup aborted"
                exit 1
        fi
        echo "Backup starting..."
        echo
        echo "Checking for destination dir..."
        sleep 3
        echo
}

# Define function to check if the backup directory exists and if it does not, it is created

create_dir() {
        if [ ! -d "$backup_dir" ]; then
                echo "$backup_dir does not exist."
                echo "Creating backup directory..."
                sleep 3
                sudo mkdir -p "$backup_dir"
                if [ $? -eq 0 ]; then
                        echo "Directory created successfully"
                else
                        echo "Failed to create directory $backup_dir"
                        exit 1
                fi
                echo
        else
                echo "Backup directory exists"
        fi

        echo
}

# Define function to change dir permission & ownership

change_perm() {
        echo "Changing backup directory permissions..."
        sleep 3
        echo
        sudo chmod 700 "$backup_dir"
        if [ $? -eq 0 ]; then
                echo "Permissions changed successfully"
                echo "changing dir ownership"
                sudo chown $(basename "$home_dir"): $backup_dir
                if [ $? -eq 0 ]; then
                        echo "Note: ONLY USER $(basename "${home_dir^^}") HAS READ, WRITE AND EXECUTE PERMISSIONS FOR BACKUP DIR!!!"
                else
                        echo "Backup Dir Ownership belongs to root"
                fi
        else
                echo "Failed to change permissions for directory $backup_dir"
                exit 1
        fi
        sleep 1
        echo
        echo "Initializing backup..."
   sleep 5
        echo
}


# Define function for files backup
backup_1() {
        find "$home_dir" -maxdepth 1 -type f -size -$threshold_size -exec sh -c "filename=\$(basename '{}'); echo \"Zipping \$filename to $backup_dir\"; sleep 2; sudo zip -j \"$backup_dir/\${filename%.*}.zip\" '{}'" \;

        sleep 5
        echo

        if [ $? -eq 0 ]; then
                echo "Backup successful!"
        else
                echo "Backup failed"
        fi
}

backup() {
        file_count=0
        for file in $(find "$home_dir" -maxdepth 1 -type f -size -$threshold_size -not -path '*/.*'); do
                filename=$(basename "$file")
                echo "Zipping $filename to $backup_dir"
                sleep 2
                sudo zip -j "$backup_dir/${filename%.*}.zip" "$file"
                if [ $? -eq 0 ]; then
                        ((file_count++))
                else
                        echo "Failed to zip $filename"
                fi
        done
        echo
        sleep 3

        echo "Backup complete!"
        echo "$file_count total file(s) zipped to $backup_dir"
}

# Calling the function

initial_prompt
create_dir
change_perm
#backup_1
backup
exit 0


echo

#implementation of automated cleanup mechanism

#Definition of the directory to be automatically cleaned
Automated_cleanup(){
cleanup_dir="$backup_dir"

#Defination of the age threshold (in days)
age_threshold=30

#Find and delete files older than the age threshold
find "$cleanup_dir" -type f -mtime +"$age_threshold" -exec rm {} \;
}

Automated_cleanup

echo "Cleanup completed. Files older than $age_threshold days have been deleted from $cleanup_dir."
                                                                                                                                            149,1         Bot


