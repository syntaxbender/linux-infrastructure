node nginx install

 # Install prerequites, Node20, Nginx, certbot

```bash
sudo apt update
sudo apt upgrade
sudo apt install -y curl wget net-tools dnsutils build-essential git gnupg lsb-release ca-certificates software-properties-common nginx certbot python3-certbot-nginx
sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

# Create user, directories, permissions

```bash
USERNAME=faruk && \

sudo useradd -m -d /home/$USERNAME -s /bin/bash -U $USERNAME && \
sudo mkdir -p /home/$USERNAME/public_html && \
sudo chmod -R 750 /home/$USERNAME && \
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME && \
sudo usermod -aG $USERNAME www-data
```

# default index, https_redirect

```bash
SERVER_IP=192.168.1.100

[ -f "/var/www/html/nothing.jpg" ] && \
  sudo mv /var/www/html/nothing.jpg /var/www/html/nothing-$(uuidgen).jpg.bak
[ -f "/var/www/html/index.html" ] && \
  sudo mv /var/www/html/index.html /var/www/html/index-$(uuidgen).html.bak

sudo wget -q -O /var/www/html/nothing.jpg https://raw.githubusercontent.com/syntaxbender/linux-infrastructure/refs/heads/main/data/nginx/var_html/nothing.jpg
sudo wget -q -O /var/www/html/index.html https://raw.githubusercontent.com/syntaxbender/linux-infrastructure/refs/heads/main/data/nginx/var_html/index.html

[ -f "/etc/nginx/sites-enabled/default" ] && \
  sudo rm /etc/nginx/sites-enabled/default || \
  echo "Default is not enabled in nginx"
[ -f "/etc/nginx/sites-available/default" ] && \
  sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default-$(uuidgen).bak || \
  echo "Default is not available in nginx"

cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80;
    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name $SERVER_IP;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ /\.ht {
        deny all;
    }
}

server {
    listen 80 default_server;
    server_name _;
    return 301 https://\$host\$request_uri;
}
EOF

sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
echo "Testing nginx..."
sudo nginx -t && \
  {
    sudo systemctl restart nginx && \
      echo "Nginx restarted successfully!";
  } || \
  echo "Nginx configuration failed!"
```

