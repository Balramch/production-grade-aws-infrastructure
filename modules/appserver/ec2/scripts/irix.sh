#!/bin/bash -xe

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
  # === System Preparation ===
  apt update && apt upgrade -y
  apt install -y software-properties-common curl wget unzip zip gnupg2 imagemagick mc unrar-free poppler-utils
  # === PHP Setup ===
  add-apt-repository ppa:ondrej/php -y
  apt update
  apt install -y php8.3 php8.3-cli php8.3-common php8.3-mysql php8.3-curl php8.3-gd php8.3-mbstring \
    php8.3-xml php8.3-zip php8.3-soap php8.3-intl php8.3-opcache php8.3-bcmath php8.3-readline \
    php8.3-imagick php8.3-redis php8.3-dev php-pear
  # === Apache Setup ===
  apt install -y apache2 libapache2-mod-php8.3
  a2enmod rewrite headers
  systemctl enable apache2
# Apache Hardening
  cat <<EOF > /etc/apache2/conf-available/hardening.conf
ServerTokens Prod
ServerSignature Off
<Directory /var/www/>
    Options -Indexes
    AllowOverride All
</Directory>
EOF
  a2enconf hardening
  systemctl restart apache2
  # === MySQL Client ===
  apt install -y mysql-client
  # === Redis Server (Local) ===
  apt install -y redis-server

  sed -i 's/^protected-mode .*/protected-mode no/' /etc/redis/redis.conf
  systemctl enable redis-server && systemctl start redis-server
  # === PHP Configuration ===
  cat <<EOF > /etc/php/8.3/apache2/conf.d/99-custom.ini
display_errors = Off
error_reporting = E_ALL & ~E_NOTICE
memory_limit = 512M
upload_max_filesize = 200M
post_max_size = 200M
max_execution_time = 60
session.cookie_lifetime = 0
session.gc_maxlifetime = 1800
max_input_vars = 20000
soap.wsdl_cache_limit = 50
expose_php = Off
EOF
  cp /etc/php/8.3/apache2/conf.d/99-custom.ini /etc/php/8.3/cli/conf.d/99-custom.ini
  systemctl restart apache2

# === Disable SSH Password Authentication ===
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication no/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh