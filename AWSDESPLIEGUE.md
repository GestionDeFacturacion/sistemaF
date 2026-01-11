# 📘 Guía de Despliegue AWS: FacturadorPro5 (Ubuntu 22.04)

> **Infraestructura:** AWS Lightsail
> **OS:** Ubuntu 22.04 LTS (Jammy Jellyfish)
> **Stack:** Apache 2.4, MySQL 5.7, PHP 7.4
> **Dominio:** A elección

---

Antes de ingresar a la terminal, se deben realizar ajustes en la consola de AWS Lightsail.

### - IP Estática (Networking)
Es obligatorio crear y adjuntar una IP estática a la instancia para evitar que la IP pública cambie al reiniciar.
1. Ir a la pestaña **Networking**.
2. Click en **Create static IP**.
3. Asignar un nombre y vincularla a la instancia creada.

### - Firewall (IPv4 Firewall)
Se deben abrir los puertos para permitir el tráfico web y de base de datos.
Agregar las siguientes reglas en **Networking > IPv4 Firewall**:

| Application | Protocol | Port / Range |
| :--- | :--- | :--- |
| **SSH** | TCP | 22 |
| **HTTP** | TCP | 80 |
| **HTTPS** | TCP | 443 |
| **MySQL** | TCP | 3306 (Restringir a IP de administración si es posible) |



## 📌 Tabla de Contenidos
1. [Preparación del Sistema](#1-preparación-del-sistema)
2. [Instalación MySQL 5.7 (Legacy)](#2-instalación-mysql-57-legacy)
3. [Instalación de PHP 7.4](#3-instalación-de-php-74)
4. [Instalación de Apache y Módulos](#4-instalación-de-apache-y-módulos)
5. [Despliegue del Proyecto](#5-despliegue-del-proyecto)
6. [Configuración de Base de Datos y Migraciones](#6-configuración-de-base-de-datos-y-migraciones)
7. [Configuración del Virtual Host](#7-configuración-del-virtual-host)
8. [Corrección de Tenants y API Peru](#8-corrección-de-tenants-y-api-peru)
9. [Gestión de Costos AWS](#9-gestión-de-costos-aws)

---

## 1. Preparación del Sistema

Acceder como usuario root/sudoer y actualizar repositorios básicos.

```bash
# Actualizar lista de paquetes
sudo apt update && sudo apt upgrade -y

# Instalar herramientas esenciales
sudo apt install software-properties-common git unzip curl nano wget -y
```

## 2. Instalación MySQL 5.7 (Legacy)

**Nota Crítica:** Ubuntu 22.04 no soporta MySQL 5.7 nativamente. Se requiere configuración manual de repositorios bionic y gestión de llaves GPG obsoletas.

### 2.1 Configuración de Repositorio MySQL 5.7

```bash
# Importar llave GPG manual (Solución a error NO_PUBKEY B7B3B788A8D3785C)
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B7B3B788A8D3785C

# Crear archivo de lista de fuentes manual
sudo nano /etc/apt/sources.list.d/mysql.list
```

**Contenido del archivo** ```/etc/apt/sources.list.d/mysql.list``` :

```
deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-5.7
deb http://repo.mysql.com/apt/ubuntu/ bionic mysql-tools
```

### 2.2 Instalación de Librerias y Binarios

Se deben instalar librerias antiguas (```libmecab2```, ```libtinfo5``` ) antes del servidor.

```bash
sudo apt update

# Instalar dependencias previas
sudo apt install libmecab2 libaio1 libtinfo5 -y

# Instalar MySQL forzando versión 5.7
sudo apt install mysql-client=5.7* mysql-community-server=5.7* mysql-server=5.7* -y
```
### 2.3 Creacion de Usuario Administrativo

```bash
sudo mysql -u root -p
```

**SQL**:

```sql
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'contraseña';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EXIT;
```

## 3. Instalación de PHP 7.4
Uso del PPA ```ondrej/php``` para instalar PHP 7.4 en Ubuntu 22.04.

```bash
# Agregar repositorio
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# Instalar PHP y extensiones
sudo apt install php7.4 php7.4-cli php7.4-fpm php7.4-mysql php7.4-xml php7.4-gd php7.4-mbstring php7.4-curl php7.4-zip php7.4-bcmath php7.4-soap php7.4-json libapache2-mod-php7.4 -y

# Instalar Composer Globalmente
cd /tmp
curl -sS https://getcomposer.org/installer -o composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
```

## 4. Instalación de Apache y Módulos

```bash
sudo apt install apache2 -y

# Habilitar módulos requeridos por Laravel
sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2enmod php7.4

# Reiniciar servicio
sudo systemctl restart apache2
```

## 5. Despliegue del Proyecto

```bash
cd /var/www/
sudo git clone https://github.com/GestionDeFacturacion/sistemaF.git facturadorpro5

# Permisos de propietario y escritura (Crucial para evitar Error 500)
sudo chown -R www-data:www-data /var/www/facturadorpro5
sudo chmod -R 775 /var/www/facturadorpro5/storage bootstrap/cache
```

### 5.1 Configuración de Entorno (.env)

```bash
cd /var/www/facturadorpro5
sudo composer install
sudo cp .env.example .env
sudo nano .env
```

**Variables a  modificar:**

```bash
APP_ENV=production
APP_DEBUG=false
APP_URL_BASE=dominio.com
APP_URL= http:dominio.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=tenancy
DB_USERNAME=admin
DB_PASSWORD=contraseña
```

## 6. Configuración de Base de Datos y Migraciones

```bash
# 1. Crear BD
mysql -u admin -p -e "CREATE DATABASE tenancy CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 2. Migrar Tablas System
php artisan migrate --database=system

# 3. Seeders (Datos iniciales)
php artisan db:seed --database=system

# 4. Storage Link (Imágenes)
php artisan storage:link

# De salir algun mensaje que indica que ya esta vinculado, ignorar.
```

## 7. Configuración del Virtual Host
Configuración de Apache para manejar el dominio y subdominios.

```bash
sudo nano /etc/apache2/sites-available/facturadorpro5.conf
```

**Contenido:**

```bash
<VirtualHost *:80>
    ServerName rj45utp.systems
    ServerAlias *.rj45utp.systems
    
    DocumentRoot /var/www/facturadorpro5/public

    <Directory /var/www/facturadorpro5/public>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/facturadorpro5-error.log
    CustomLog ${APACHE_LOG_DIR}/facturadorpro5-access.log combined
</VirtualHost>
```

**Activar:**

```bash
sudo a2dissite 000-default.conf
sudo a2ensite facturadorpro5.conf
sudo systemctl reload apache2
```

## 8. Configuración API Peru
Ajuste final para inyectar el token de consulta RUC/DNI. Se realiza directo en BD para asegurar persistencia.

```bash
mysql -u admin -p
```

**SQL:**

```sql
USE tenancy;

UPDATE configurations 
SET token_apiruc = 'TOKEN_APIPERUDEV',
    url_apiruc = 'https://apiperu.dev'
WHERE id = 1;
```
 
**Limpiar caché:**

```bash
cd /var/www/facturadorpro5
php artisan config:clear
```