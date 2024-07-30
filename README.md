# Tunnel Monitor

This repository contains a bash script for monitoring IPv6 tunnels on a Linux server. The script pings connected servers via their IPv6 addresses and is designed to be scheduled using cron jobs.

## Features

- Monitors network tunnels with names containing `tun` or `tunnel`.
- Pings connected servers via their IPv6 addresses.
- Logs activities and errors to a specified log file.
- Provides an interactive menu for installation, cron job updates, and script removal.

## Installation

To install and set up the Cloudflare Utils on an Ubuntu server, follow these steps:

### Using cURL

Run the following command to download and execute the installation script using `curl`:

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/Issei-177013/Tunnel-Monitor/main/install.sh)"
```

### Using wget

Alternatively, you can use `wget` to download and execute the installation script:

```bash
sudo bash -c "$(wget -O- https://raw.githubusercontent.com/Issei-177013/Tunnel-Monitor/main/install.sh)"
```