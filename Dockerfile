
FROM php:8.3.36-fpm-alpine
# FROM 656940095238.dkr.ecr.eu-central-1.amazonaws.com/php:8-fpm-alpine
# ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php Ya no hace falta
# la extension iconv ya viene incluida con la imagen de alpine desde la 8.1

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_DISABLE_XDEBUG_WARN=1 \
    PHPREDIS_VERSION=5.1.1
RUN set -xe \
  && apk add --no-cache --virtual .build-deps \
    tzdata \
    $PHPIZE_DEPS \
  && apk add gnu-libiconv --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ --allow-untrusted \
  && apk add --no-cache \
    openssl-dev \
    bash \
    curl  \
    tzdata \
    nginx \
    zabbix-utils \
    supervisor  \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    sqlite-dev \
    curl-dev \
    libsodium-dev \
    icu-dev \
    libxml2-dev \
    recode-dev \
    libxslt-dev \
    git \
    postgresql-client \
    postgresql-dev \
    openssh-client \
    libmcrypt-dev \
    libmcrypt \
    libzip-dev \
    libgcrypt-dev \
    oniguruma-dev \
  && apk --update --no-cache add grep \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install \
    gd \
    bcmath \
    opcache \
    mysqli \
    pdo_mysql \
    pdo_pgsql \
    zip \
    xsl \
    intl \
    soap \
    bcmath \
    && apk del .build-deps \
  && rm -rf /tmp/* /var/cache/apk/* \
     && mkdir -p /run/nginx /run/mysqld /var/log/supervisor /etc/nginx/conf.d
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN apk --no-cache add pcre-dev ${PHPIZE_DEPS} \
  && pecl install redis \
  && docker-php-ext-enable redis \
  && apk del pcre-dev ${PHPIZE_DEPS} \
  && rm -rf /tmp/pear
RUN install-php-extensions amqp
RUN install-php-extensions sockets
RUN docker-php-ext-install sysvmsg sysvsem sysvshm
RUN docker-php-ext-configure intl
RUN docker-php-ext-install intl
COPY . /var/www
WORKDIR /var/www

#Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

#Install supervisor
#RUN mkdir /etc/supervisor.d/
#RUN apk update && apk add --no-cache supervisor


# Set TimeZone
ENV TZ=Europe/Madrid
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN ls -la /var/www



