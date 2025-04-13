node nginx install

 # Install prerequites, Node20, Nginx

```bash
sudo apt update
sudo apt upgrade
sudo apt install curl wget net-tools dnsutils build-essential git gnupg lsb-release ca-certificates software-properties-common nginx
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```

# Create user, d

```bash
USERNAME=faruk && \
sudo useradd -m -d /home/$USERNAME -s /bin/bash -U $USERNAME && \
sudo mkdir -p /home/$USERNAME/public_html && \
sudo chmod -R 750 /home/$USERNAME && \
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME && \
sudo usermod -aG $USERNAME www-data
```


