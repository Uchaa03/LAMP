#!/bin/bash
# La utilización de barras invertidas es para mejorar la legibilidad del script

# Actualización de paquetes del sistema
sudo apt update && \
sudo apt upgrade -y && \
echo "" && \
echo "Sistema actualizado correctamente"
sleep 2  # Espera 2 segundos para que de tiempo a leer los echo

# Instalación de Apache
sudo apt install apache2 -y && \
echo "" && \
echo "Apache fue instalado correctamente"
sleep 2


