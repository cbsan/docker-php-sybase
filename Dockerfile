FROM php:7.1-fpm

MAINTAINER Cristian B. Santos <cbsan.dev@gmail.com>

LABEL description="Oficial pack php 7.1-fpm for projects with use of sybase16"

RUN set -xe \
	&& DEP_BUILD="\
		git \
		build-essential \
		automake \
		bison \
		flex \
		libtool \
		re2c" \
	&& apt update && apt update \
	&& apt install -y $DEP_BUILD --no-install-recommends --no-install-suggests \
	&& mkdir -p /opt/sqlanywhere16 \
	&& cd /tmp \
	&& git clone -b php-7.1 --depth 1 https://github.com/cbsan/sdk-sqlanywhere-php.git sdk \
	&& cd ./sdk \
	&& tar -xvzf dep.tar.gz --strip=1 -C /opt/sqlanywhere16 \
	&& tar -xvzf sasql_php.tar.gz \
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
