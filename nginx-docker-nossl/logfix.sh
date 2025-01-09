#!/bin/bash

# Script to clean up disk space and configure log rotation
# Must be run as root or with sudo

# Log current disk usage
echo "Current disk usage:"
df -h /

echo

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root or with sudo"
    exit 1
fi

echo "Starting cleanup process..."

# Function to print section headers
print_header() {
    echo
    echo "=== $1 ==="
    echo
}

# Backup nginx logrotate config
print_header "Backing up nginx logrotate configuration"
if [ -f /etc/logrotate.d/nginx ]; then
    cp /etc/logrotate.d/nginx /etc/logrotate.d/nginx.backup.$(date +%Y%m%d)
    echo "Backup created at /etc/logrotate.d/nginx.backup.$(date +%Y%m%d)"
fi

# Update nginx logrotate configuration
print_header "Updating nginx logrotate configuration"
cat > /etc/logrotate.d/nginx << 'EOF'
/var/log/nginx/*.log {
    daily
    missingok
    rotate 7
    size 100M
    maxsize 100M
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    sharedscripts
    prerotate
        if [ -d /etc/logrotate.d/httpd-prerotate ]; then \
            run-parts /etc/logrotate.d/httpd-prerotate; \
        fi \
    endscript
    postrotate
        invoke-rc.d nginx rotate >/dev/null 2>&1
    endscript
}
EOF

# Clear current nginx logs
print_header "Clearing current nginx logs"
if [ -d /var/log/nginx ]; then
    find /var/log/nginx -type f -name "*.log" -exec truncate -s 0 {} \;
    find /var/log/nginx -type f -name "*.log.[8-14].gz" -delete
    echo "Nginx logs cleaned"
fi

# Docker cleanup
print_header "Cleaning up Docker resources"
if command -v docker &> /dev/null; then
    echo "Removing unused Docker resources..."
    docker system prune -a -f --volumes
else
    echo "Docker not installed, skipping Docker cleanup"
fi

# Clean temporary files
print_header "Cleaning temporary files"
rm -rf /tmp/*
echo "Temporary files cleaned"

# Clean old journal logs
print_header "Cleaning system journal"
if command -v journalctl &> /dev/null; then
    journalctl --vacuum-time=7d
    echo "Journal logs cleaned"
fi

# Force log rotation
print_header "Forcing log rotation"
if command -v logrotate &> /dev/null; then
    logrotate -f /etc/logrotate.d/nginx
    echo "Log rotation completed"
fi

# Print disk usage before and after
print_header "Disk usage results"
echo "Disk usage:"
df -h /

echo
echo "Cleanup process completed!"
echo "Please check the output above for any errors"
echo "You may need to restart services or containers if you cleaned their logs"

exit 0