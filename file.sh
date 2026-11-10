#!/bin/bash

# Update installed packages
yum update -y

# Install Apache
yum install -y httpd

# Start and enable Apache
systemctl enable httpd
systemctl start httpd

# Create a test webpage
echo "Hello World from $(hostname -f)" > /var/www/html/index.html

# Set permissions
chmod 644 /var/www/html/index.html

# Verify Apache is running
systemctl status httpd
