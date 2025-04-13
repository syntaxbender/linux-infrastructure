node nginx install

 # Install prerequites, Node20, Nginx

```bash
sudo apt update
sudo apt upgrade
sudo apt install curl wget net-tools dnsutils build-essential git gnupg lsb-release ca-certificates software-properties-common nginx
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
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

cd /var/www/html
sudo wget -O /var/www/html/nothing.jpg https://raw.githubusercontent.com/syntaxbender/linux-infrastructure/refs/heads/main/data/nginx/var_html/nothing.jpg
sudo wget -O /var/www/html/index.html https://raw.githubusercontent.com/syntaxbender/linux-infrastructure/refs/heads/main/data/nginx/var_html/index.html
sudo rm /etc/nginx/sites-enabled/default
sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

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


```


