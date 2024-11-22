# Instalación de LAMP con unos scripts Personalizados 
### Despliegue de Aplicaciones Web: Adrián Ucha Sousa

## ¿Qué es LAMP?
**LAMP** es un conjunto de tecnologías de software de código abierto utilizado comúnmente para implementar aplicaciones 
web. El acrónimo LAMP se refiere a las siguientes **tecnologías**:

- **Linux:** Sistema operativo. 
- **Apache:** Servidor web. 
- **MySQL/MariaDB:** Sistema de gestión de bases de datos. 
- **PHP:** Lenguaje de programación para desarrollo web.

Juntas, estas tecnologías forman una pila que permite la creación de aplicaciones web dinámicas y potentes, 
proporcionando un entorno robusto, flexible y escalable para desarrolladores, por lo tanto, vamos a ver un paso a paso 
de como utilizar e instalar estas herramientas y crearemos un **script** para automatizar su instalación y configuración.

### Mantener el sistema Actualizado

Lo primero a tener en cuenta en el script es actualizar todos los paquetes del ordenador antes de realizar cualquier 
instalación o configuración de paquetes, por lo tanto, utilizaremos el siguiente comando para la actualización de 
repositorios y paquetes de nuestro ubuntu server:

```shell
sudo apt update && sudo apt upgrade
```

## ¡IMPORTANTE!!! Variables de entorno
Las claves y contraseñas que utilicemos en nuestro script tendremos que agregarlas en un archivo `.env` cuya plantilla
será `.env_example` que podemos copiar o utilizar como guía este archivo es **personal** y por seguridad no se debe 
mostrar, de ahi que cada usuario se genere el suyo para adaptarlo al script
 
## Instalación de Apache
Instalar apache es muy sencillo lanzamos el siguiente comando:
```shell
sudo apt install apache2 -y
```

Podemos configurar apache2 de manera personalizada con multiples funciones desde sus archivos de configuración.
Por predeterminado lo podemos encontrar en el **puerto 80** una vez ha sido instalado, en principio solo lo instalaremos
por ahora más adelante aplicaremos más configuraciónes.

#### Comandos para gestionar el servicio de apache
```shell
sudo systemctl start apache2 # Inicia
sudo systemctl stop apache2 # Para 
sudo systemctl restart apache2 # Reinicia
sudo systemctl reload apache2 # Recarga
sudo systemctl status apache2 # Ver estado
```

## Instalación de MySQL server
Para instalar MySQL utilizaremos el siguiente comando:
```shell
sudo apt install mysql-server -y
```

Para acceder a MySQL como **Root** es necesario saber la contraseña de root del sistema, ya que por predeterminado mysql 
toma la contraseña de root.

Modificaremos esto para que tenga la que nosotros le queramos dar, si no sabemos la 
contraseña de root podemos cambiarla con el siguiente comando:
```shell
sudo passwd root
```
Una vez sepamos la contraseña, la almacenamos en una variable de entorno y ya podemos proceder, 
accedemos a la consola como root.

```shell
# Iniciamos sesión y cambiamos la contraseña
mysql -u root -p"$ROOT_PASSWORD" <<EOF
  ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY "$MYSQL_ROOT_PASSWORD";
  FLUSH PRIVILEGES;
EOF
# Salimos de MySQL
quit
```
Y habríamos cambiado la contraseña del **root** de MySQL, para tener la nuestra propia
Con esto tendríamos la configuración básica de MySQL.

#### Comandos para gestionar el servicio de MySQL
```shell
sudo systemctl start mysql
sudo systemctl stop mysql
sudo systemctl restart mysql
sudo systemctl status mysql
```

## Instalación de módulos PHP
Para que el servidor instalado de apache pueda servir servicio funcional de PHP necesitamos instalar ciertos módulos y 
el intérprete para poder trabajar con él, vamos a instalar los siguientes paquetes;

- **php:** Intérprete de PHP. 
- **libapache2-mod-php:** Permite servir páginas PHP desde el servidor web apache. 
- **php-mysql:** Permite conectar a una base de datos MySQL desde código PHP.

Para ello lanzamos el siguiente comando;
```shell
sudo apt install php libapache2-mod-php php-mysql -y
```

Para comprobar que ha funcionado generemos un archivo de `info.php` y se lo pasamos a `/var/www/html/info.php`, si 
funcionó podremos acceder desde `http://IP/info.php` y ver la información del módulo php.

Recuerda reiniciar el servicio para aplicar los cambios.

### Y con esto ya tendríamos instalado LAMP al completo y con una breve configuración básica


# Funcionalidades Extras
## Instalación de phpMyAdmin
**phpMyAdmin** es un gestor de la base de datos MySQL, pero, con un entorno gráfico desde la web, esto nos permite una 
gestión como y visual para gestionar la base de datos por eso puede ser util instalarlo, para ello lo instalamos con:

````shell
sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y
````

Con este comando instalamos todos los servicios para poder tener el pack de funcionalidad completa, pero si queremos
configurarlo en un script tendremos que utilizar `debconf-set-selections`, con esto podemos configurar todo lo que 
necesita phpMyAdmin, y variables de entorno para las contraseñas.

## Instalación de Adminer
Una alternativa a phpMyAdmin, la ventaja es que se maneja en un solo `.php`, su instalación es mucho más sencilla:

`````shell
# Creamos el directorio en el que instalar adminer
sudo mkdir -p /var/www/html/adminer

#Instalamos le paquete con wget
sudo wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php -P /var/www/html/adminer
`````

## Instalación de GoAccess
Este es muy util para ver los registros de apache junto con `.htacces` y poder controlarlo, por lo tanto, vamos a 
configurarlos, lo instalamos con:

````shell
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
````

Lo instalamos pasamos el fichero de registros de apache para que trabaje con él, habilitamos el puerto que utiliza 
GoAccess para generar el html en tiempo real, lo lanzamos en segundo plano y creamos el usuario par a utilizar con sus 
respectivas variables de entorno.

Tenemos que editar el fichero de configuración de `apache2`, nos debe quedar algo así:

````shell
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
````
Y reiniciamos el servicio para aplicar la configuración.

## Configuración de .htaccess
Reutilizaremos parte de la configuración de `GoAccess`,
````shell
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

````

Y ya reiniciamos el servicio con, esto ya estaría finalizado todo.