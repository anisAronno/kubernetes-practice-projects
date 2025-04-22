FROM php:8.3-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    git \
    libzip-dev \
    libpq-dev \
    libssl-dev \
    libreadline-dev \
    libmcrypt-dev \
    libxslt1-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip sockets \
    && pecl install redis && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

COPY . .

RUN composer install

RUN chown -R www-data:www-data /var/www && chmod -R 755 /var/www

EXPOSE 9001

CMD ["php-fpm"]
