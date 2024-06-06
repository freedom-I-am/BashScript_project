#!/bin/bash

set -o errexit
# Key system metrics (CPU Usage, Memory Usage, Disk Space, and Network Statistics) should be reported to standard output AND
to a file called "sysinfo.txt" 
# The metrics are reported in tabulated form.

#Function to display a message and wait for a few seconds
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
#    echo -e "CPU Usage\t$cpu_usage"
}

#Function to check memory usage
check_mem_usage() {
    echo "checking memory usage..."
    sleep 2
    mem_usage="$(free -m | grep ^Mem | awk '{print $3 "MB"}')"
    echo "checking memory usage done"
    echo
#    echo -e "Memory Usage\t$mem_usage"
}

#Function to check disk space
check_disk_space() {
    echo "checking disk space..."
    sleep 2
    disk_space="$(df -h | grep /$ | awk '{print $4}')"
    echo "checking disk space done"
    echo
#    echo -e "Unused Disk Space\t$disk_space"
}

#Function to check network stats
check_network_stats() {
    echo "checking network stats..."
    sleep 3
    packets_received="$(netstat -s | grep "total packets" | awk '{print $1}')"
    requests_sent="$(netstat -s | grep "requests sent" | awk '{print $1}')"
    echo "checking network stats done"
    echo
#    echo -e "Packets received / Requests sent\t$packets_received/$requests_sent"
}

#Function to save system metrics to a file
save_sysinfo_to_file() {
    sysFile="sysinfo.txt"
#    echo "copy of the system details will be saved in $sysFile."
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


#Main script execution
display_message_and_wait "You are about to view key system info"


#Calling the functions
check_cpu_usage
check_mem_usage
check_disk_space
check_network_stats
save_sysinfo_to_file


sleep 3

# Email configuration to send file to system administrator

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
echo "...sending mail...35% completed..."
echo
sleep 3
echo "...sending mail...55% completed..."
echo
sleep 3
echo "...sending mail...75% completed..."

# Compose email
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



