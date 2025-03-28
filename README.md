# aezacli

CLI tool to create and manage [aeza.net](https://aeza.net/?ref=397668) virtual machines.

![screenshot](screenshot.png)

# Usage

```
aeza os - list available operating systems
aeza limits - list resource limits
aeza products - list available products

aeza list / aeza ps - list all virtual machines
aeza create [plan] [os_id] - create a new virtual machine
aeza start [vm_id/name] - start a virtual machine
aeza stop [vm_id/name] - stop a virtual machine
aeza delete [vm_id/name] - delete a virtual machine
aeza reboot [vm_id/name] - reboot a virtual machine
aeza rename [vm_id/name] [new_name] - rename a virtual machine
aeza ssh [vm_id/name/] [command] - connect to a virtual machine via SSH or execute a command
aeza wait [vm_id/name] - wait for a virtual machine to become active
aeza ip [vm_id/name] - get the IP address of a virtual machine
```

# Installation

```shell
# macOS
brew install jq curl sshpass bc
sudo wget https://raw.githubusercontent.com/drushadrusha/aezacli/refs/heads/master/aezacli -O /usr/local/bin/aeza
sudo chmod +x /usr/local/bin/aeza

# Ubuntu/Debian
apt install jq curl sshpass bc
sudo wget https://raw.githubusercontent.com/drushadrusha/aezacli/refs/heads/master/aezacli -O /usr/bin/aeza
sudo chmod +x /usr/bin/aeza
```

# Configuration

API key is stored in .aezacli file in home directory.

# Usage Example

```bash
# Create new VM
server_name=$(aeza create HELs-1 ubuntu_2204)
# Wait until activation is complete
aeza wait "$server_name"
# Update and install nginx
aeza ssh "$server_name" apt update
aeza ssh "$server_name" apt install -y nginx
aeza ssh "$server_name" systemctl start nginx
# Get server IP
server_ip=$(aeza ip "$server_name")
# Check nginx is installed correctly
curl "$server_ip"
# Delete the server
aeza delete "$server_name"
```

Script below checks for SWE-PROMO every 30 minutes and executes a command to purchase it if available, then exits.

```bash
while true; do
    aeza products | grep -q "SWE-PROMO" && { aeza create SWE-PROMO ubuntu_2404 month; exit; }
    sleep 1800
done
```

# Autocompletions

```shell
# Autocompletion for fish
wget https://raw.githubusercontent.com/drushadrusha/aezacli/refs/heads/master/aeza.fish -O ~/.config/fish/completions/aeza.fish
# Autocompletion for bash
wget https://raw.githubusercontent.com/drushadrusha/aezacli/refs/heads/master/aeza.fish -O ~/.bash_completion_aeza
echo "source ~/.bash_completion_aeza" >> ~/.bashrc
```