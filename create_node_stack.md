# Create Node Stack
- node20
- nginx
- certbot

# Install prerequites, Node20, Nginx, certbot

```bash
#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root! exiting..."
  exit 1
fi

apt update && apt upgrade -y
apt install -y curl wget net-tools dnsutils build-essential git gnupg lsb-release ca-certificates software-properties-common openssl nginx certbot python3-certbot-nginx uuid-runtime
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt install -y nodejs
```

# Create user, directories, permissions

```bash
#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root! exiting..."
  exit 1
fi

USERNAME=faruk && \

useradd -m -d /home/$USERNAME -s /bin/bash -U $USERNAME && \
mkdir -p /home/$USERNAME/public_html && \
chmod -R 750 /home/$USERNAME && \
chown -R $USERNAME:$USERNAME /home/$USERNAME && \
usermod -aG $USERNAME www-data
```

# default index, https_redirect

```bash
#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root! exiting..."
  exit 1
fi

SERVER_IP=192.168.1.100

[ -f "/var/www/html/nothing.jpg" ] && \
  mv /var/www/html/nothing.jpg /var/www/html/nothing-$(uuidgen).jpg.bak
[ -f "/var/www/html/index.html" ] && \
  mv /var/www/html/index.html /var/www/html/index-$(uuidgen).html.bak

wget -q -O /var/www/html/nothing.jpg https://raw.githubusercontent.com/syntaxbender/linux-infrastructure/refs/heads/main/data/nginx/var_html/nothing.jpg
wget -q -O /var/www/html/index.html https://raw.githubusercontent.com/syntaxbender/linux-infrastructure/refs/heads/main/data/nginx/var_html/index.html

mkdir -p /etc/nginx/ssl/ && \
  openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt

[ -f "/etc/nginx/sites-enabled/default" ] && \
  rm /etc/nginx/sites-enabled/default || \
  echo "Default is not enabled in nginx"
[ -f "/etc/nginx/sites-available/default" ] && \
  mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default-$(uuidgen).bak || \
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

ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
echo "Testing nginx..."
nginx -t && \
  {
    systemctl restart nginx && \
      echo "Nginx restarted successfully!";
  } || \
  echo "Nginx configuration failed!"
```

# certbot renewal

```bash
#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root! exiting..."
  exit 1
fi

DOMAINS=""
WEB_SERVER="nginx"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d|--domains)
      if [[ -n "$2" ]]; then
        DOMAINS="$2"
        PRIMARY_DOMAIN=$(echo "$DOMAINS" | cut -d',' -f1)
        shift
      else
        echo "Error: --domains requires a value."
        exit 1
      fi
      ;;
    -w|--web-server)
      if [[ -n "$2" ]]; then
        WEB_SERVER="$2"
        shift
      else
        echo "Error: --web-server requires a value."
        exit 1
      fi
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

if [[ -z "$DOMAINS" ]]; then
    echo "Error: --domains arg required."
    echo "Usage: [...] --domains "example.com,www.example.com" [--web-server nginx|apache]"
    exit 1
fi

if [[ "$WEB_SERVER" != "apache" && "$WEB_SERVER" != "nginx" ]]; then
    echo "Error: --web-server arg must be nginx or apache"
    exit 1
fi

certbot certonly -a $WEB_SERVER --agree-tos --no-eff-email --staple-ocsp --force-renewal --email info@$PRIMARY_DOMAIN -d $DOMAINS
```

# create nginx config

```bash
#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root! exiting..."
  exit 1
fi

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
    mv /etc/nginx/sites-available/$DOMAIN.conf /etc/nginx/sites-available/deadsites/$DOMAIN-$(uuidgen).conf.bak
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

ln -s /etc/nginx/sites-available/$DOMAIN.conf /etc/nginx/sites-enabled/

echo "Testing nginx..."
nginx -t && \
  {
    systemctl restart nginx && \
      echo "Nginx restarted successfully!";
  } || \
  echo "Nginx configuration failed!"

```

# create node(next) service

``` bash
#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root! exiting..."
  exit 1
fi

SVC_NAME=""
USER=""
EXEC_NPM=""
PORT=""
DESC=""
ENV_FILE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    -sn|--svc-name)
      if [[ -n "$2" ]]; then
        SVC_NAME="$2"
        shift
      else
        echo "Error: --svc-name requires a value."
        exit 1
      fi
      ;;
    -u|--user)
      if [[ -n "$2" ]]; then
        USER="$2"
        shift
      else
        echo "Error: --user requires a value."
        exit 1
      fi
      ;;
    -enpm|--exec-npm)
      if [[ -n "$2" ]]; then
        EXEC_NPM="$2"
        shift
      else
        echo "Error: --exec-npm requires a value."
        exit 1
      fi
      ;;
    -p|--port)
      if [[ -n "$2" ]]; then
        PORT="$2"
        shift
      else
        echo "Error: --port requires a value."
        exit 1
      fi
      ;;
    -d|--description)
      if [[ -n "$2" ]]; then
        DESC="$2"
        shift
      else
        echo "Error: --description requires a value."
        exit 1
      fi
      ;;
    -envf|--env-file)
      ENV_FILE=true
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

if [[ -z "$SVC_NAME" || -z "$USER" || -z "$EXEC_NPM" || -z "$DESC" ]]; then
    echo "Error: --user, --exec-npm, --port, --description, --env-file args required."
    echo "Usage: [...] --user username --exec-npm "run start" --description "prod service" [--port 3000] [--env-file]"
    exit 1
fi

cat > "/etc/systemd/system/$SVC_NAME.conf" <<EOF
[Unit]
Description=$DESC

[Service]
User=$USER
Group=$USER
WorkingDirectory=/home/$USER/app
ExecStart=/usr/bin/npm $EXEC_NPM
Restart=on-failure
Environment=NODE_ENV=production
[Install]
WantedBy=default.target
EOF

ENV_FILE_LINE="EnvironmentFile=/home/$USER/app/.env"
PORT_LINE="Environment=PORT=$PORT"
[ -n "$PORT" ] && \
    sed -i '/Restart/a $PORT_LINE' /etc/systemd/system/$SVC_NAME.conf

[ "$ENV_FILE" = true ] && \
    sed -i '/Restart/a $ENV_FILE_LINE' /etc/systemd/system/$SVC_NAME.conf
```
