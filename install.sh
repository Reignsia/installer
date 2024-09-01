#!/bin/bash

update_system() {
    sudo apt -y update
    sudo apt -y upgrade
}

install_panel() {
    sudo apt install -y bc
    sudo apt-get -y install apache2 curl subversion php7.4 php7.4-gd php7.4-zip libapache2-mod-php7.4 php7.4-curl php7.4-mysql php7.4-xmlrpc php-pear phpmyadmin mariadb-server-10.3 php7.4-mbstring git php-bcmath

    wget -N "https://github.com/OpenGamePanel/Easy-Installers/raw/master/Linux/Debian-Ubuntu/ogp-panel-latest.deb" -O "ogp-panel-latest.deb"
    sudo dpkg -i "ogp-panel-latest.deb"

    sudo sed -i "s/^bind-address.*/bind-address=0.0.0.0/g" "/etc/mysql/mariadb.conf.d/50-server.cnf"

    sudo mysql_secure_installation

    sudo cat /root/ogp_user_password
    sudo cat /root/ogp_panel_mysql_info
}

install_agent() {
    sudo apt-get -y install libxml-parser-perl libpath-class-perl perl-modules screen rsync sudo e2fsprogs unzip subversion libarchive-extract-perl pure-ftpd libarchive-zip-perl libc6 libgcc1 git curl
    sudo apt-get -y install libc6-i386 libgcc1:i386 lib32gcc1 libhttp-daemon-perl

    wget -N "https://github.com/OpenGamePanel/Easy-Installers/raw/master/Linux/Debian-Ubuntu/ogp-agent-latest.deb" -O "ogp-agent-latest.deb"
    sudo dpkg -i "ogp-agent-latest.deb"

    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install -y libstdc++6:i386

    sudo sed -i 's/^post_max_size = 8M/post_max_size = 900M/' /etc/php/7.4/apache2/php.ini
    sudo sed -i 's/^upload_max_filesize = 2M/upload_max_filesize = 900M/' /etc/php/7.4/apache2/php.ini

    sudo sed -i '$a Alias /pma /usr/share/phpmyadmin' /etc/apache2/sites-available/000-default.conf

    cd /var/www/html/themes/
    sudo git clone https://github.com/Reignsia/Obsidian
    sudo mv Obsidian/themes/Obsidian/* Obsidian/
    sudo rmdir Obsidian/themes/Obsidian

    sudo apt-get install -y iptables-persistent
    sudo iptables -A INPUT -p tcp -j ACCEPT
    sudo iptables -A INPUT -p udp -j ACCEPT
    sudo iptables -A OUTPUT -p tcp -j ACCEPT
    sudo iptables -A OUTPUT -p udp -j ACCEPT
    sudo iptables-save > /etc/iptables/rules.v4

    cd && sudo git clone https://github.com/friendly-bits/geoip-shell && cd geoip-shell
    sudo sh geoip-shell-install.sh
    sudo geoip-shell configure -p tcp:block:all
    sudo geoip-shell configure -p udp:block:all

    sudo cat /root/ogp_user_password
    sudo cat /root/ogp_panel_mysql_info
}

echo "Welcome to the revised Open Game Panel installation script! Please select an option:"
echo "1. Install OGP Panel"
echo "2. Install OGP Agent"
echo "3. Install Both"
echo "4. Script Credits"
echo "5. Fix MySQL Offline"
echo "6. Exit"

read -p "Enter your choice [1-6]: " choice

case $choice in
  1)
    echo "Installing OGP Panel..."
    update_system
    install_panel
    echo "[OGP INSTALLER] OGP Panel Installation Complete"
    ;;
  2)
    echo "Installing OGP Agent..."
    update_system
    install_agent
    echo "[OGP INSTALLER] OGP Agent Installation Complete!"
    ;;
  3)
    echo "Installing Both..."
    update_system
    install_panel
    install_agent
    echo "[OGP INSTALLER] Both OGP Panel and Agent Installation Complete!"
    ;;
  4)
    echo "This automatic open game panel installation script is made by CarlR"
    echo "All rights have been reserved 2023"
    ;;
  5)
    echo "Fixing MySQL"
    sudo mysql -u root -p <<EOF
USE mysql;
UPDATE user SET plugin='' WHERE User='root';
FLUSH PRIVILEGES;
EXIT;
EOF
    sudo mysql_secure_installation
    sudo reboot
    ;;
  6)
    echo "Exiting..."
    exit 0
    ;;
  *)
    echo "Invalid choice. Please select an option [1-6]."
    ;;
esac

echo "Run ./install.sh to access the installation script"
