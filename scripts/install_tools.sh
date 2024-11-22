#!/bin/bash

##Instalación de phpMyAdmin

##Comando para configurar apache2 en phpmyAdmin por predeterminado
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | sudo debconf-set-selections

##Configurar base de datos
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections

##Configurar Contraseña de phpMyAdmin utilizando variable de entorno
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | sudo debconf-set-selections

##Lanazamos el comando de instalación
sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y && echo ""
echo "phpMyAdmin fue instalado correctamente"
sleep 2

### Instalación de Adminer
# Creamos el directorio en el que instalar adminer
sudo mkdir -p /var/www/html/adminer

#Instalamos le paquete con wget
sudo wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer && echo ""
echo "phpMyAdmin fue instalado correctamente"
sleep 2


# Instalación de GoAccess
sudo apt install goaccess -y

#Parseamos el fichero de log de apache para que trabaje desde GoAccess
sudo goaccess /var/log/apache2/access.log -c

#Habilitamos el puerto 7890 para el html en tiempo real
sudo ufw allow 7890

# Creamos un html de muestro en tiempo real
sudo goaccess /var/log/apache2/access.log -o /var/www/html/report.html --log-format=COMBINED --real-time-html

# Configuración de directorio stats
mkdir -p /var/www/html/stats

# Lanzamiento del proceso en segundo plano con --daemonize
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --daemonize

# Creación de archivo de usuario y contraseña con variables de entrono
sudo htpasswd -bc /etc/apache2/.htpasswd $STATS_USERNAME $STATS_PASSWORD

# Editamos el archivo de configuración de Apache para proteger el directorio "stats"
echo "Modificando la configuración de Apache para restringir acceso a /var/www/html/stats"
sudo bash -c 'cat <<EOL >> /etc/apache2/sites-available/000-default.conf

<VirtualHost *:80>
        DocumentRoot /var/www/html

        <Directory "/var/www/html/stats">
          AuthType Basic
          AuthName "Acceso restringido"
          AuthBasicProvider file
          AuthUserFile "/etc/apache2/.htpasswd"
          Require valid-user
        </Directory>

        ErrorLog /var/log/apache2/error.log
</VirtualHost>
EOL'

# Reiniciamos Apache para que los cambios surtan efecto
sudo systemctl restart apache2 && echo ""
echo "GoAccess instalado, configurado correctamente y autenticación en /stats activada"
sleep 2

# Control de acceso a un directorio .htaccess
#Ya tenemos ceado el directorio stats y lanzado el goacces para log en segundo plano

# Creamos el archivo de usuario y contraseñas reutilizamos las variables de goacces o creamos unas nuevas
sudo htpasswd -c /etc/apache2/.htpasswd usuario
sudo htpasswd -bc /etc/apache2/.htpasswd $STATS_USERNAME $STATS_PASSWORD

sudo cp ./htaccess/.htaccess /var/www/html/stats/

echo "Modificando la configuración de Apache para restringir acceso a /var/www/html/stats"
sudo bash -c 'cat <<EOL >> /etc/apache2/sites-available/000-default.conf

<VirtualHost *:80>
    DocumentRoot /var/www/html

    # Configuración de GoAccess (ya configurado previamente en /stats)
    <Directory "/var/www/html/stats">
        AllowOverride All
        AuthType Basic
        AuthName "Acceso restringido"
        AuthBasicProvider file
        AuthUserFile "/etc/apache2/.htpasswd"
        Require valid-user
    </Directory>

        ErrorLog /var/log/apache2/error.log
</VirtualHost>
EOL'

# Reiniciamos Apache para que los cambios surtan efecto
sudo systemctl restart apache2 && echo ""
echo ".htaccess, configurado correctamente y autenticación en /stats activada"
sleep 2
