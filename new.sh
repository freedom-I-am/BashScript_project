#!/bin/bash

# Welcome message

echo "!!!BACKING UP YOUR FILES!!!"
echo
echo "Files in your home directory less than 1MB are to be backed up to the /backup dir."
echo

echo "Backup starting..."
echo
# Define variables
backup_dir="./backup" # Directory for backup
home_dir="$HOME"
threshold_size="1048576c"

echo "Checking for destination dir..."
echo
sleep 3
# Create backup directory if it doesn't exist
if [ ! -d "$backup_dir" ]; then
    echo "$backup_dir does not exist."
    echo "Creating backup directory..."
    sleep 3
    mkdir -p "$backup_dir"
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
echo "Changing backup directory permissions..."
sleep 3
echo
# Set permissions for backup directory
chmod 700 "$backup_dir"
if [ $? -eq 0 ]; then
    echo "Permissions changed successfully"
    echo "Only $(basename "$home_dir") can read, write, and execute the backup directory"
else
    echo "Failed to change permissions for directory $backup_dir"
    exit 1
fi
echo
echo "Initializing backup..."
sleep 5
echo
# Find files in home directory less than 1MB and compress them

find "$home_dir" -maxdepth 1 -type f -size -$threshold_size -exec sh -c "filename=\$(basename '{}'); echo \"Zipping \$filename to $backup_dir\"; sleep 2; zip -j \"$backup_dir/\${filename%.*}.zip\" '{}'" \;

sleep 5
echo

if [ $? -eq 0 ]; then
    echo "Backup successful!"
else
    echo "Backup failed"
fi
echo
