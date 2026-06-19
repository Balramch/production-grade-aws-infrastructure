#!/bin/bash -xe

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
    # === System Prep ===
    apt update && apt upgrade -y
    apt install -y unzip zip curl wget software-properties-common gnupg2
    # === PHP-FPM 8.4 ===
    add-apt-repository ppa:ondrej/php -y
    apt update
    apt install -y php8.4-fpm php8.4-cli php8.4-common php8.4-mysql php8.4-curl php8.4-zip php8.4-soap \
        php8.4-xml php8.4-mbstring php8.4-intl php8.4-readline php8.4-bcmath php8.4-opcache php8.4-gd \
        php8.4-fileinfo php8.4-dom php8.4-pdo php8.4-posix php8.4-gettext php8.4-xsl php-apcu
    systemctl enable php8.4-fpm
    # === NGINX ===
    apt install -y nginx
    cat <<EOF > /etc/nginx/sites-available/default
server {
    listen 80 default_server;
    root /var/www/html;
    index index.php index.html;
    location / {
        try_files \$uri \$uri/ =404;
    }
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
    client_max_body_size 2048M;
}
EOF
    systemctl enable nginx && systemctl restart nginx
    # === MySQL Client ===
    apt install -y mysql-client
    # === PHP Configuration ===
    cat <<EOF > /etc/php/8.4/fpm/conf.d/99-custom.ini
display_errors = Off
error_reporting = 22519
memory_limit = 1024M
upload_max_filesize = 2048M
post_max_size = 2048M
max_execution_time = 120
max_input_vars = 20000
session.cookie_lifetime = 0
short_open_tag = On
bcmath.enable = On
EOF
    cp /etc/php/8.4/fpm/conf.d/99-custom.ini /etc/php/8.4/cli/conf.d/99-custom.ini
    systemctl restart php8.4-fpm

# === Disable SSH Password Authentication ===
sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#PasswordAuthentication no/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh