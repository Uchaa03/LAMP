# Instalación de LAMP con unos scripts Personalizados 
### Despligue de Aplicaciones Web: Adrián Ucha Sousa

## ¿Qué es LAMP?
**LAMP** es un conjunto de tecnologías de software de código abierto utilizado comúnmente para implementar aplicaciones 
web. El acrónimo LAMP se refiere a las siguientes **tecnologías**:

- **Linux:** Sistema operativo. 
- **Apache:** Servidor web. 
- **MySQL/MariaDB:** Sistema de gestión de bases de datos. 
- **PHP:** Lenguaje de programación para desarrollo web.

Juntas, estas tecnologías forman una pila que permite la creación de aplicaciones web dinámicas y potentes, 
proporcionando un entorno robusto, flexible y escalable para desarrolladores, por lo tanto vamos a ver un paso a paso 
de como utilizar e intalar estas herramientas y crearemos un **script** para automatizar su instalación y configuración.

### Mantener el sistema Actualizado

Lo primero a tener en cuenta en el script es acutalizar todos los paquetes del ordenador antes de realizar cualquier 
instalación o condifugración de paquetes por lo tanto utilizaremos el siguiente comando para la actualizaión de 
repositorios y paquetes de nuestro ubuntu server:

```shell
sudo apt update && sudo apt upgrade
```

## Instalación de Apache
Instalar apache es muy sencillo lanzamos el siguiente comando:
```shell
sudo apt install apache2 -y
```

Podemos configurar apache2 de manera personalizada con multiples funciones desde sus archivos de configurción.
Por prediterminado lo podemos encontrar en el **puerto 80** una vez a sido instalado, en principio solo lo intalaremos
por ahora más adelante aplicaremos más configuraciónes.

#### Comandos para gestionar el servicio de apache
```shell
sudo systemctl start apache2 # Incia
sudo systemctl stop apache2 # Para 
sudo systemctl restart apache2 # Reincia
sudo systemctl reload apache2 # Recarga
sudo systemctl status apache2 # Ver estado
```