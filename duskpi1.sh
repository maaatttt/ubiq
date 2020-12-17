#!/bin/bash

# As "root" user.

if [ $hardware = RaspberryPi ]; then
sudo -i
fi

# Set variable containing the system's IP Address.
node_ip=$(hostname -I|cut -d" " -f 1)

# Install Supervisor, edit the conf file, restart the application.
apt install supervisor
sed -i "6i chown=dusk:dusk" /etc/supervisor/supervisord.conf
sed -i '29s#.*#files = /home/dusk/.dusk/supervisor/*.conf#' /etc/supervisor/supervisord.conf
service supervisor restart


# Download and install Node.js.
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt install -y nodejs
apt install -y build-essential
apt install -y npm

# Download and set up Caddy, edit relevent conf files.
wget "https://caddyserver.com/api/download?os=linux&arch=arm64&idempotency=38152918486201" -O caddy
mv ./caddy /usr/bin/
chmod +x /usr/bin/caddy
mkdir /etc/caddy
sudo tee /etc/caddy/caddy.conf &>/dev/null <<"EOF"
[IPADDRESS]
reverse_proxy http://127.0.0.1:3000 {
  header_up X-Forwarded-Ssl on
  header_up Host {host}
  header_up X-Real-IP {remote}
  header_up X-Forwarded-For {remote}
  header_up X-Forwarded-Port {server_port}
  header_up X-Forwarded-Proto {scheme}
  header_up X-Url-Scheme {scheme}
  header_up X-Forwarded-Host {host}
}
encode gzip

EOF

# Insert system IP Address in caddy.conf file
sudo sed -i -e "s/IPADDRESS/$node_ip/" /etc/caddy/caddy.conf

# Exit back out to "master" script, which then executes Part 2 script.
exit
