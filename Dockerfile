FROM php:7.3-fpm

LABEL maintainer Cristian B. Santos <cbsan.dev@gmail.com>
LABEL description="Environment PHP-7.3 with sybase 16"

RUN set -xe \
	&& DEP_BUILD="\
	git \
	build-essential \
	automake \
	bison \
	flex \
	libtool \
	unzip \
	re2c" \
	&& apt update && apt update \
	&& apt install -y $DEP_BUILD --no-install-recommends --no-install-suggests \
	&& mkdir -p /tmp/sdk \
	&& mkdir -p /opt/sqlanywhere16 \
	&& cd /tmp \
	&& curl -fSL https://s3.amazonaws.com/sqlanywhere/drivers/php/sasql_php.zip -o ./sdk/sasql_php.zip \
	&& git clone --depth 1 https://github.com/cbsan/sdk-sqlanywhere-php.git dep_sdk \
	&& cp -r ./dep_sdk/dep_lib/* /opt/sqlanywhere16 \
	&& cd ./sdk \
	&& unzip sasql_php.zip \
	&& phpize \
	&& ./configure --with-sqlanywhere \
	&& make \
	&& make install \
	&& docker-php-ext-enable sqlanywhere \
	&& ln -sF /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
	&& sed -i "s/;date.timezone =.*/date.timezone = America\/Sao_Paulo/" /usr/local/etc/php/php.ini \
	&& rm -rf /tmp/* \
	&& echo "/opt/sqlanywhere16/lib64" >> /etc/ld.so.conf.d/sqlanywhere16.conf \
	&& ldconfig \
	&& cd / && ln -sF /opt/sqlanywhere16/dblgen16.res dblgen16.res \
	&& apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false $DEP_BUILD
