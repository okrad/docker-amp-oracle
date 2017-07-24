FROM nimmis/apache-php5  

MAINTAINER enrico.triolo@gmail.com

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
	php5-xsl \
	php5-cli \
	php5-ldap \ 
	php5-xdebug \
	php5-tidy \
	php5-dev \
	libaio-dev

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#COPY php.ini /etc/php5/apache2
#COPY teranet_apps.conf /etc/apache2/conf-available

RUN echo "IncludeOptional conf-enabled-docker/*.conf" >> /etc/apache2/apache2.conf

RUN mkdir /etc/apache2/conf-enabled-docker

#Make php.ini a link to user supplied file in volume /etc/php5/conf.d 
RUN rm /etc/php5/apache2/php.ini
RUN rm /etc/php5/cli/php.ini
RUN ln -s /etc/php5/conf.d/php.ini /etc/php5/apache2/php.ini
RUN ln -s /etc/php5/conf.d/php.ini /etc/php5/cli/php.ini

RUN rm /etc/php5/apache2/conf.d/20-intl.ini

#RUN a2enconf teranet_apps
RUN a2enmod rewrite
RUN a2enmod ssl

# Oracle instantclient
ADD oracle-instantclient/instantclient-basic-linux.x64-12.1.0.2.0.zip /tmp/
ADD oracle-instantclient/instantclient-sdk-linux.x64-12.1.0.2.0.zip /tmp/

RUN unzip /tmp/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /usr/local/
RUN unzip /tmp/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /usr/local/

RUN ln -s /usr/local/instantclient_12_1 /usr/local/instantclient
RUN ln -s /usr/local/instantclient/libclntsh.so.12.1 /usr/local/instantclient/libclntsh.so

RUN echo 'instantclient,/usr/local/instantclient' | pecl install oci8-2.0.10
RUN echo "extension=oci8.so" > /etc/php5/apache2/conf.d/30-oci8.ini

RUN service apache2 restart