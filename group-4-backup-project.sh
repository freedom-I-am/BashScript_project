#!/bin/bash
# ==============================================================================================================================================
# Date: April 4 2024
# Author: Group4 Linux/DevOps Students of Ingryd Academy (January 2024 Cohort) [10 contributors]
# Names of all contributors
        # Adeyemi Vicor [Group Leader: Code testing and implementation : Pull requests execution]
        # John Pamisi [Member: Code testing and implementation : Pull requests exxecution]
        # Ibrahim Toheeb [Member: Workflow maintenance : Code research]
        # Moshood Owolabi [Member: Workflow maintenance : Code research : Documentation]
        # Kafayat Adeyemi [Member: Documentation]
        # Freedom Unugbai [Member: Documentation : Functions creation]
        # Ibrahim Olayinka: [Member: Suggestions : Error Handling]
        # Abdulmuminu Agenyi [Member: Planning]
        # Miracle Ogochwuku [Member: Planning]
        # Abdulsamad Ahmed [Member: Planning]
# ==============================================================================================================================================
# Credits:
#       > Tutor: Mr. Martin M.
#       > Group 1 Leader: Toluwani Emmanuel
#       > ChatGPT 3.5: AI language model by OpenAI
# This project was collaboratively developed using GitHub, a platform for version control and collaboration.
# Linux/DevOps Class
# Ingryd Academy
# (c) April, 2024
# ==============================================================================================================================================
# This script is designed to automate various system maintenance tasks, including files backup and cleanup, system monitoring, and alerting. 
# The script aims to simplify the process of:
#	- backing up files less than 1M in user's home directory , 
# 	- monitoring key system metrics,
#	- reporting and alerting system administrators and manager about events such as high CPU usage, low disk space, etc via email. 
# To schedule the backups and monitoring activities through cron jobs 2AM everyday, run:
# 	$ crontab -e
# then include the following line in the crontab file
# 0 2 * * * path/to/script
# Usage: $ ./group-4-backup-project.sh
# ==============================================================================================================================================
# set default behaviour to exit on error

# Definition of variables
backup_dir="/backup" #This is the directory for backup
home_dir="$HOME" #This is the user's home directory
threshold_size="1048576c" #This is the threshold for the files to be compressed and backed up
log_file="script_log.log" # Log file to record activities and errors
# ==============================================================================================================================================
# Initialize log file
echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting script execution" | tee -a "$log_file"

# Redirect stout and stderr to both terminal and log file
exec > >(tee -a "$log_file") 2>&1
# ==============================================================================================================================================
# Definition of function for the intial prompt
initial_prompt() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - Prompting user for backup initiation"
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
# ==============================================================================================================================================
# Definition of function to check if the backup directory already exists and if it does not, it is created
create_dir() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - Checking and creating backup directory if it doesn't exist"
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
# ===============================================================================================================================================
# Definition of function to change direrevtory permission & ownership
change_perm() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - Changing directory permission and ownership"
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
}
# ===============================================================================================================================================
# Definition of function for the files backup
backup() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting backup process"
 	file_count=0
	
	for file in $(find "$home_dir" -maxdepth 1 -type f -size -$threshold_size -not -path '*/.*'); do
		filename=$(basename "$file")
		echo "checking if $filename is already backed-up"
		sleep 3
    
		if [ -f "$backup_dir/${filename%.*}.zip" ]; then
			echo $filename already backed up
			echo skipping to next file...
			sleep 2
		else
			echo "Zipping $filename to $backup_dir"
			sleep 2
			sudo zip -j "$backup_dir/${filename%.*}.zip" "$file"
			
			if [ $? -eq 0 ]; then
				((file_count++))
			else
				echo "Failed to zip $filename"
			fi
		fi
	done
	
	echo
	sleep 3
	echo "Backup complete!"
	echo "$file_count total file(s) zipped to $backup_dir"
	echo
}
# ===============================================================================================================================================
# Implementation of automated cleanup mechanism
# Definition of function for intial prompt
initial_prompt2() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - Prompting user for cleanup initiation"
	echo "CLEANING UP OLD FILES"
        echo
        echo "Files backed-up in $backup_dir dir modified more than 30days ago will be deleted."
        echo

        read -p "Do you want to proceed (y/n)? " response
	sleep 2 
        if [[ ${response,,} != 'y' && ${response,,} != 'yes' ]]; then
                echo "cleanup aborted"
                exit 1
	else
        	echo "initiating cleanup..."
        	echo
        	sleep 3
	fi   
}
# ==============================================================================================================================================
# Definition of function for auto cleanup
auto_cleanup() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - Starting cleanup process"
 	file_count=0
	cleanup_dir="$backup_dir"
	age_threshold="30" 	#in days
# Find and delete files older than the age threshold
	echo "Searching for files older than $age_threshold days in $cleanup_dir..."
	echo
	
  for file in $(find "$cleanup_dir" -type f -mtime +"$age_threshold" -not -path '*/.*'); do
		rm "$file"
		if [ $? -eq 0 ]; then
			((file_count++))
			sleep 1
		else
			echo "Failed to delete $file"
		fi
	done
		
    echo "Cleanup completed."
		echo "$file_count files older than $age_threshold days have been deleted from $cleanup_dir."
echo
sleep 2
}
# ==============================================================================================================================================
# Key system metrics monitoring and reporting
# Definition of function for monitoring and reporting system metrics
monitor_and_report() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - Monitoring and reporting system metrics"
	echo
	# Function to display a message and wait for a few seconds
	display_message_and_wait() {
    	echo "$1"
    	sleep 2
	}

	#Function to check CPU usage
	check_cpu_usage() {
    		echo "checking cpu usage..."
    		sleep 2
    		cpu_usage="$[100-$(vmstat 1 2 | tail -1 | awk '{print $15}')]%"
    		echo "checking cpu usage done"
    		echo
	}

	#Function to check memory usage
	check_mem_usage() {
    		echo "checking memory usage..."
    		sleep 2
    		mem_usage="$(free -m | grep ^Mem | awk '{print $3 "MB"}')"
    		echo "checking memory usage done"
    		echo
	}

	#Function to check disk space
	check_disk_space() {
    		echo "checking disk space..."
    		sleep 2
    		disk_space="$(df -h | grep /$ | awk '{print $4}')"
    		echo "checking disk space done"
    		echo
	}

	#Function to check network stats
	check_network_stats() {
    		echo "checking network stats..."
    		sleep 3
    		packets_received="$(netstat -s | grep "total packets" | awk '{print $1}')"
    		requests_sent="$(netstat -s | grep "requests sent" | awk '{print $1}')"
    		echo "checking network stats done"
    		echo
	}

	# Function to save system metrics to a file
	save_sysinfo_to_file() {
    		sysFile="sysinfo.txt"
		echo -e "CPU Usage\tMemory Usage\tUnused Disk Space\tPackets received / Requests sent" > "$sysFile"
    		if [ $? -eq 0 ]; then
        		echo -e "$cpu_usage\t\t$mem_usage\t\t$disk_space\t\t\t$packets_received/$requests_sent" >> "$sysFile"
        		cat "$sysFile"
        		sleep 3
        		echo
        		echo
        		echo "System metrics saved to $sysFile"
    		else
        		echo "Error: Failed to extract necessary system metric to $sysFile"
        		exit 1
    		fi
	}	

	# Calling functions to monitor and report
	display_message_and_wait "You are about to view key system info"
	check_cpu_usage
	check_mem_usage
	check_disk_space
	check_network_stats
	save_sysinfo_to_file
}
# ==============================================================================================================================================
# Email configuration to send file to system administrator
# Function to send copy of sysinfo.txt as mail attachment to System admin
send_mail() {
	echo "$(date '+%Y-%m-%d %H:%M:%S') - Sending email to system administrator"
 	echo "Copy of $sysFile will now be sent to the system administrator"
	echo "Initialiazing mail sending..."
	sleep 3
	echo
	echo "Collecting necessary details..."

	# Entering mail details
	current_date=$(date +"%Y-%m-%d %H:%M:%S")
	read -p "Please enter email address of system administrator: " recipient
	subject="System Report @ $current_date"
	attachment_path="./$sysFile"

	echo "mail will now be sent to $recipient"
	read -p "Do you want to proceed (y/n)? " ans
	sleep 2

	if [[ ${ans,,} != 'y' && ${ans,,} != 'yes' ]]; then
	    echo mail aborted!
	    exit 1
	fi
	
	echo
	echo "...sending mail...35% completed..."
	echo
	sleep 3
	echo "...sending mail...55% completed..."
	echo
	sleep 3
	echo "...sending mail...75% completed..."

# Sending email
mutt -s "$subject" -a "$attachment_path" -- "$recipient" << EOF
System alert!

Find attached copy of the most recent Key system metrics.
You are receiving this mail as the system administrator.
	        
Best regards,
Linux engineer, $(basename "${HOME^^}").
EOF

if [ $? -eq 0 ]; then
	echo "...sending mail...99% completed"
	sleep 3
	echo "mail sent successfully"
else
	echo "error in sending mail"
	echo "mail sending failed"
	exit 1
fi
}
# ==============================================================================================================================================
# Main script logic

# Calling functions
initial_prompt
create_dir
change_perm
backup
initial_prompt2
auto_cleanup
monitor_and_report
send_mail

echo "$(date '+%Y-%m-%d %H:%M:%S') - Script execution completed successfully"
echo "#=========================================================================================================================================#"
echo
# ==============================================================================================================================================
# END
