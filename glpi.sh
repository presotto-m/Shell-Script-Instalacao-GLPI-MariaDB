#!/bin/bash

# Atualizando repo
apt update -y
apt upgrade -y


# Instalando pacotes de utilitarios
apt install -y xz-utils bzip2 unzip curl

# Instalando apache2 e componentes PHP
apt install -y apache2 libapache2-mod-php php-soap php-cas php php-{apcu,cli,common,curl,gd,imap,ldap,mysql,xmlrpc,xml,mbstring,bcmath,intl,zip,bz2}

# Baixando e descompactando o GLPI na pasta /var/www/html
wget -O- https://github.com/glpi-project/glpi/releases/download/10.0.2/glpi-10.0.2.tgz | tar -zxv -C /var/www/html/

# Configurando permissões dos diretorios
chown www-data. /var/www/html/glpi -Rf
find /var/www/html/glpi -type d -exec chmod 755 {} \;
find /var/www/html/glpi -type f -exec chmod 644 {} \;

# Instalando e configurando DB
apt install -y mariadb-server

# Criação do banco de dados
mysql -e "create database glpidb character set utf8"
mysql -e "create user 'glpi'@'localhost' identified by '123456'"
mysql -e "grant all privileges on glpidb.* to 'glpi'@'localhost' with grant option";
mysql_tzinfo_to_sql /usr/share/zoneinfo | mysql -p -u root mysql
mysql -e "GRANT SELECT ON mysql.time_zone_name TO 'glpi'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Instalando GLPI
php /var/www/html/glpi/bin/console glpi:database:install --db-host=localhost --db-name=glpidb --db-user=glpi --db-password=123456

#Reajustar permissões
chown www-data. /var/www/html/glpi/files -Rf

# Removendo diretorio install.php
rm -fr /var/www/glpi/install/install.php

#habilitando e reiniciando apache2
systemctl enable apache2
systemctl restart apache2
