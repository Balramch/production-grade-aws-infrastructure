#!/bin/bash -xe

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
  # === System Prep ===
  apt update && apt upgrade -y
  apt install -y unzip zip curl wget software-properties-common gnupg2 mc
  # === PHP 8.3 ===
  add-apt-repository ppa:ondrej/php -y
  apt update
  apt install -y php8.3 php8.3-cli php8.3-common php8.3-mysql php8.3-curl php8.3-zip php8.3-soap \
    php8.3-xml php8.3-mbstring php8.3-intl php8.3-opcache php8.3-bcmath php8.3-dom php8.3-gd \
    php8.3-fileinfo php8.3-readline php8.3-posix php8.3-iconv php8.3-pdo

  # === Apache Setup ===
  apt install -y apache2 libapache2-mod-php8.3
  a2enmod rewrite headers
  systemctl enable apache2
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
  # === PHP Configuration ===
  cat <<EOF > /etc/php/8.3/apache2/conf.d/99-tina.ini
display_errors = Off
error_reporting = E_ALL & ~E_NOTICE
memory_limit = 512M
upload_max_filesize = 20M
post_max_size = 20M
max_execution_time = 60
max_input_vars = 20000
session.cookie_lifetime = 0
session.gc_maxlifetime = 1800
soap.wsdl_cache_limit = 50
expose_php = Off
zlib.output_compression = Off
EOF
  cp /etc/php/8.3/apache2/conf.d/99-tina.ini /etc/php/8.3/cli/conf.d/99-tina.ini
  systemctl restart apache2

# === Disable SSH Password Authentication ===
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication no/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh