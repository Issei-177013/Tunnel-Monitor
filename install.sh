#!/bin/bash

# Define variables
SCRIPT_DIR="/opt/Tunnel-Monitors"
SCRIPT_NAME="tunnel_monitor.sh"
CRON_JOB_FILE="/etc/cron.d/tunnel_monitor"
CRON_JOB="0 */6 * * * root /opt/tunnel_monitor.sh"
LOG_FILE="/var/log/tunnel_monitor.log"

# Function to log messages
log_message() {
    local message=$1
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" >> $LOG_FILE
}

# Function to handle errors
handle_error() {
    local exit_code=$1
    local message=$2
    if [ $exit_code -ne 0 ]; then
        log_message "ERROR: $message"
        echo "ERROR: $message. Check the log file $LOG_FILE for details."
        exit $exit_code
    fi
}

# Function to validate cron schedule
validate_cron_schedule() {
    local schedule=$1
    if [[ ! "$schedule" =~ ^[0-9]{1,2} [0-9]{1,2} [0-9]{1,2} [0-9]{1,2} [0-9]{1,2} ]]; then
        echo "Invalid cron schedule format. It should be in the format 'min hour day month day-of-week'."
        return 1
    fi
    return 0
}

# Function to install the script and create cron job
install_script() {
    log_message "Starting script installation."

    # Create the script content
    read -r -d '' SCRIPT_CONTENT << 'EOF'
#!/bin/bash

# Function to get the connected IPv6 address
get_connected_ipv6() {
    local ipv6_addr=$1
    # Extract the base address and last segment
    local base_addr=$(echo $ipv6_addr | sed 's/:[0-9a-f]*$//')
    local last_segment=$(echo $ipv6_addr | awk -F: '{print $NF}')
    
    # Toggle last segment between :1 and :2
    if [[ "$last_segment" == "1" ]]; then
        echo "${base_addr}:2"
    elif [[ "$last_segment" == "2" ]]; then
        echo "${base_addr}:1"
    else
        echo "Unknown segment: $last_segment"
    fi
}

# Find interfaces with 'tun' or 'tunnel' in their name and get their IPv6 addresses
interfaces=$(ip -6 addr show | grep -E 'tun|tunnel' | grep -oP '(?<=inet6 )[^/]+(?= scope global)')

# Ping the connected server's IPv6 address
for ipv6_addr in $interfaces; do
    connected_ipv6=$(get_connected_ipv6 $ipv6_addr)
    if [ ! -z "$connected_ipv6" ]; then
        echo "Pinging connected server's IPv6 address $connected_ipv6 from local IPv6 address $ipv6_addr"
        ping6 -c 5 $connected_ipv6
    fi
done
EOF

    # Create the script file
    echo "$SCRIPT_CONTENT" > $SCRIPT_DIR/$SCRIPT_NAME
    handle_error $? "Failed to create script file $SCRIPT_DIR/$SCRIPT_NAME."

    # Make the script executable
    chmod +x $SCRIPT_DIR/$SCRIPT_NAME
    handle_error $? "Failed to make the script executable."

    # Create a cron job
    echo "$CRON_JOB" > $CRON_JOB_FILE
    handle_error $? "Failed to create cron job file $CRON_JOB_FILE."

    log_message "Script installed and cron job created successfully."
    echo "Installation complete. The script has been installed to $SCRIPT_DIR and a cron job has been created to run it every 6 hours."
}

# Function to update the cron job
update_cron_job() {
    local new_schedule
    read -p "Enter new cron schedule (e.g., '0 */6 * * *'): " new_schedule
    if validate_cron_schedule "$new_schedule"; then
        echo "$new_schedule root $SCRIPT_DIR/$SCRIPT_NAME" > $CRON_JOB_FILE
        handle_error $? "Failed to update cron job file $CRON_JOB_FILE."
        log_message "Cron job updated with new schedule: $new_schedule."
        echo "Cron job updated to run the script with the new schedule."
    fi
}

# Function to remove the script and cron job
remove_script() {
    rm -f $SCRIPT_DIR/$SCRIPT_NAME
    handle_error $? "Failed to remove script file $SCRIPT_DIR/$SCRIPT_NAME."

    rm -f $CRON_JOB_FILE
    handle_error $? "Failed to remove cron job file $CRON_JOB_FILE."

    log_message "Script and cron job removed."
    echo "Script and cron job removed."
}

# Function to show the menu
show_menu() {
    echo "Menu:"
    echo "1. Install Script"
    echo "2. Update Cron Job Schedule"
    echo "3. Remove Script and Cron Job"
    echo "4. Exit"
    read -p "Choose an option [1-4]: " choice

    case $choice in
        1)
            install_script
            ;;
        2)
            update_cron_job
            ;;
        3)
            remove_script
            ;;
        4)
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose a number between 1 and 4."
            ;;
    esac
}

# Ensure the log file exists and is writable
touch $LOG_FILE
chmod 644 $LOG_FILE
handle_error $? "Failed to create or set permissions for log file $LOG_FILE."

# Main loop
while true; do
    show_menu
done
