#!/bin/bash

# Define variables
SCRIPT_DIR="/opt/Tunnel-Monitors"
SCRIPT_NAME="tunnel_monitor.sh"
CRON_JOB="0 */6 * * * root /opt/Tunnel-Monitors/tunnel_monitor.sh"


    # Ensure the script directory exists
if [ ! -d "$SCRIPT_DIR" ]; then
  mkdir -p "$SCRIPT_DIR"
fi

# Create the script content
read -r -d '' SCRIPT_CONTENT << 'EOF'
  #!/bin/bash

  SCRIPT_DIR="/opt/Tunnel-Monitors"
  SCRIPT_NAME="tunnel_monitor.sh"
  LOG_FILE="/var/log/tunnel_monitor.log"

  # Function to log messages
  log_message() {
      local message=$1
      echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" >> $LOG_FILE
  }

  # Function to get the connected IPv6 address
  get_connected_ipv6() {
      local ipv6_addr=$1
      local base_addr=$(echo $ipv6_addr | sed 's/:[0-9a-f]*$//')
      local last_segment=$(echo $ipv6_addr | awk -F: '{print $NF}')

      if [[ "$last_segment" == "1" ]]; then
          echo "${base_addr}:2"
      elif [[ "$last_segment" == "2" ]]; then
          echo "${base_addr}:1"
      else
          log_message  "error" "Unknown segment: $last_segment for IPv6 address $ipv6_addr"
          return 1
      fi
  }

  # Find interfaces with 'tun' or 'tunnel' in their name and get their IPv6 addresses
  interfaces=$(ip -6 addr show | grep -E 'tun|tunnel' | grep -oP '(?<=inet6 )[^/]+(?= scope global)')

  # Ping the connected server's IPv6 address
  for ipv6_addr in $interfaces; do
      connected_ipv6=$(get_connected_ipv6 $ipv6_addr)
      if [ ! -z "$connected_ipv6" ]; then
          log_message  "info" "Pinging connected server's IPv6 address $connected_ipv6 from local IPv6 address $ipv6_addr"
          ping6 -c 5 $connected_ipv6 > /dev/null 2>&1
          if [ $? -eq 0 ]; then
              log_message  "info" "Ping to $connected_ipv6 successful"
          else
              log_message  "error" "Ping to $connected_ipv6 failed"
          fi
      fi
  done

EOF

    # Create the script file
    echo "$SCRIPT_CONTENT" > $SCRIPT_DIR/$SCRIPT_NAME

    # Make the script executable
    chmod +x $SCRIPT_DIR/$SCRIPT_NAME

    # Create a cron job
    echo "$CRON_JOB" | crontab -

    echo "Installation complete. The script has been installed to $SCRIPT_DIR and a cron job has been created to run it every 6 hours."

