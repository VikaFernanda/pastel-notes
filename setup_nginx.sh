#!/bin/bash

# Define the application directory for clarity
APP_DIR="/var/www/pastel-notes"

# Ensure the target directory exists, creating it if necessary.
# This is good practice, even if the directory is already expected to be there.
mkdir -p $APP_DIR

# Set the ownership of the application files to the 'nginx' user and group.
# This is crucial for allowing the Nginx process to read and serve the files.
# For Amazon Linux 2, the user is 'nginx'. For Ubuntu/Debian, it would be 'www-data'.
chown -R nginx:nginx $APP_DIR

# Set the appropriate file and directory permissions.
# '755' allows the owner (nginx) to read/write/execute, and others to read/execute.
chmod -R 755 $APP_DIR

# Gracefully reload the Nginx service to apply the changes without downtime.
# This tells Nginx to pick up the new files without dropping existing connections.
systemctl reload nginx