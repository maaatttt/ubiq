#!/bin/bash

# As "dusk" user

# Set variable containing the system's IP Address.
node_ip=$(hostname -I|cut -d" " -f 1)

# Download Dusk repository and install.
git clone https://github.com/octanolabs/dusk.git
cd dusk
npm install
export BASE_URL="https://ipaddress"
npm run build

# Create & edit the .dusk Supervisor dir, and related file to manage Caddy
mkdir -p ~/.dusk/supervisor
sudo touch ~/.dusk/supervisor/caddy.conf
sudo tee ~/.dusk/supervisor/caddy.conf &>/dev/null <<"EOF"
[program:caddy]
command=/usr/bin/caddy run --config /etc/caddy/caddy.conf --adapter=caddyfile
autostart=true
autorestart=true
stderr_logfile=/var/log/caddy.err.log
stdout_logfile=/var/log/caddy.out.log

EOF

# Create & edit the Supervisor file to manage Dusk
sudo touch ~/.dusk/supervisor/dusk.conf
sudo tee ~/.dusk/supervisor/dusk.conf &>/dev/null <<"EOF"
[program:dusk]
command=/usr/bin/npm run start
directory=/home/dusk/dusk
user=dusk
autostart=true
autorestart=true
stderr_logfile=/var/log/dusk.err.log
stdout_logfile=/var/log/dusk.out.log

EOF

# Exit Part 2 script back to Master script to complete setup.
exit
