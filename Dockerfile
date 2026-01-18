# Imagen base: PHP 7.4 con Apache
FROM php:7.4-apache

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    libonig-dev \
    curl \
    zip \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalar extensiones PHP requeridas
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    pdo \
    pdo_mysql \
    mysqli \
    gd \
    zip \
    xml \
    mbstring \
    bcmath \
    soap

# Habilitar módulos Apache
RUN a2enmod rewrite ssl

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Configurar directorio de trabajo
WORKDIR /var/www/html

# Copiar código del proyecto
COPY . /var/www/html

# Configurar permisos
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Configurar Apache para Laravel
RUN sed -i 's|/var/www/html|/var/www/html/public|g' /etc/apache2/sites-available/000-default.conf

# Exponer puerto 80
EXPOSE 80
