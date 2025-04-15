# Create Node Stack
- node20
- nginx
- certbot

# Install prerequites, Node20, Nginx, certbot

```bash
#!/bin/bash

sudo apt update
sudo apt upgrade
sudo apt install -y curl wget net-tools dnsutils build-essential git gnupg lsb-release ca-certificates software-properties-common openssl nginx certbot python3-certbot-nginx
sudo curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

# Create user, directories, permissions

```bash
#!/bin/bash

USERNAME=faruk && \

sudo useradd -m -d /home/$USERNAME -s /bin/bash -U $USERNAME && \
sudo mkdir -p /home/$USERNAME/public_html && \
sudo chmod -R 750 /home/$USERNAME && \
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME && \
sudo usermod -aG $USERNAME www-data
```

# default index, https_redirect

```bash
#!/bin/bash

SERVER_IP=192.168.1.100

[ -f "/var/www/html/nothing.jpg" ] && \
  sudo mv /var/www/html/nothing.jpg /var/www/html/nothing-$(uuidgen).jpg.bak
[ -f "/var/www/html/index.html" ] && \
  sudo mv /var/www/html/index.html /var/www/html/index-$(uuidgen).html.bak

sudo wget -q -O /var/www/html/nothing.jpg https://raw.githubusercontent.com/syntaxbender/linux-infrastructure/refs/heads/main/data/nginx/var_html/nothing.jpg
sudo wget -q -O /var/www/html/index.html https://raw.githubusercontent.com/syntaxbender/linux-infrastructure/refs/heads/main/data/nginx/var_html/index.html

mkdir -p /etc/nginx/ssl/ && \
  sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

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

server{
    listen 443 ssl default_server;
    server_name _;
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    return       404;
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

# certbot renewal

```bash
DOMAINS=example.com,www.example.com
PRIMARY_DOMAIN=$(echo "$SERVER_NAME" | cut -d',' -f1)

certbot certonly -a nginx --agree-tos --no-eff-email --staple-ocsp --force-renewal --email info@$PRIMARY_DOMAIN -d $DOMAINS
```

# create nginx config

```bash
#!/bin/bash

PROXY_PASS=""
DOMAIN=""
WWW_REDIRECT=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -p|--proxy-pass)
      if [[ -n "$2" ]]; then
        PROXY_PASS="$2"
        shift
      else
        echo "Error: --proxy-pass requires a value."
        exit 1
      fi
      ;;
    -d|--domain)
      if [[ -n "$2" ]]; then
        DOMAIN="$2"
        shift
      else
        echo "Error: --domain requires a value."
        exit 1
      fi
      ;;
    -r|--www-redirect)
      WWW_REDIRECT=true
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

if [[ -z "$PROXY_PASS" || -z "$DOMAIN" ]]; then
    echo "Error: --proxy-pass ve --domain required."
    echo "Usage: [...] --proxy-pass http://127.0.0.1:3000 --domain example.com [--www-redirect]"
    echo "Usage: [...] -p http://127.0.0.1:3000 -d example.com [-r]"
    exit 1
fi



[ -f "/etc/nginx/sites-enabled/$DOMAIN.conf" ] && \
    rm "/etc/nginx/sites-enabled/$DOMAIN.conf"

[ -f "/etc/nginx/sites-available/$DOMAIN.conf" ] && \
  {
    mkdir -p /etc/nginx/sites-available/deadsites
    sudo mv /etc/nginx/sites-available/$DOMAIN.conf /etc/nginx/sites-available/deadsites/$DOMAIN-$(uuidgen).conf.bak
  }

cat > "/etc/nginx/sites-available/$DOMAIN.conf" <<EOF
server {
    listen 443 ssl;
    server_name www.$DOMAIN;

    location / {
        proxy_pass       $PROXY_PASS;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    ssl_certificate         /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key     /etc/letsencrypt/live/$DOMAIN/privkey.pem;
    include                 /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam             /etc/letsencrypt/ssl-dhparams.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/$DOMAIN/chain.pem;
    ssl_stapling on;
    ssl_stapling_verify on;
}
EOF

if [ "$WWW_REDIRECT" = true ]; then
cat >> "/etc/nginx/sites-available/$DOMAIN.conf" <<EOF

server {
    listen 443 ssl;
    server_name $DOMAIN;

    ssl_certificate     /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

    return 301 https://www.$DOMAIN\$request_uri;
}
EOF
fi

sudo ln -s /etc/nginx/sites-available/$DOMAIN.conf /etc/nginx/sites-enabled/

echo "Testing nginx..."
sudo nginx -t && \
  {
    sudo systemctl restart nginx && \
      echo "Nginx restarted successfully!";
  } || \
  echo "Nginx configuration failed!"

```


