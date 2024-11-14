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