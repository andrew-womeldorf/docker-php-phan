FROM php:7
MAINTAINER Matthias Endler <matthias.endler@trivago.com>

RUN DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y git curl redis-server

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /usr/src/php/ext/redis \
	&& curl -L https://github.com/phpredis/phpredis/archive/3.1.4.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
	&& echo 'redis' >> /usr/src/php-available-exts \
	&& docker-php-ext-install redis

RUN git clone https://github.com/nikic/php-ast.git \
    && cd php-ast \
    && phpize \
    && ./configure \
    && make install \
    && echo 'extension=ast.so' > /usr/local/etc/php/php.ini \
    && cd .. && rm -rf php-ast

RUN git clone https://github.com/etsy/phan.git \
    && cd phan \
    && git checkout tags/1.1.1 \
    && composer install \
    && ./test \
    && chmod a+x phan \
    && ln -s /phan/phan /usr/local/bin/phan

ADD run.sh run.sh
RUN chmod +x run.sh
CMD ["./run.sh"]
