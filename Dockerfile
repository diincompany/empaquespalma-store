FROM yiisoftware/yii2-php:8.4-apache

WORKDIR /app

COPY . /app

RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev \
    && docker-php-ext-install gd

RUN composer install --prefer-dist --no-progress --no-suggest --no-interaction

RUN chown -R www-data:www-data /app/runtime /app/web/assets

EXPOSE 80