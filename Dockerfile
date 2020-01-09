#Image de base
FROM debian:buster

#Qui a fait le Dockerfile
MAINTAINER tbigot <tbigot@student.42.fr>

#Minimum dans un docker pour installer sur internet
RUN apt-get update \
&& apt-get -y install wget

#installer nginx
RUN apt-get -y install nginx

#installer MYSQL
RUN apt-get install mariadb-server -y  

#PHP_MY_ADMIN
RUN apt install -y php-fpm php-mysql \
&& wget https://files.phpmyadmin.net/phpMyAdmin/4.9.0.1/phpMyAdmin-4.9.0.1-all-languages.tar.gz \
&& tar xvf phpMyAdmin-4.9.0.1-all-languages.tar.gz \
&& rm -f phpMyAdmin-4.9.0.1-all-languages.tar.gz \
&& mkdir /var/www/ft_server/ \
&& mv phpMyAdmin-4.9.0.1-all-languages/ var/www/ft_server/phpmyadmin

#WORD_PRESS

RUN wget -c https://wordpress.org/latest.tar.gz \
&& tar -xvzf latest.tar.gz \
&& rm -f latest.tar.gz \
&& mv /wordpress /var/www/ft_server/wordpress/

#SSL
RUN echo "\n\n\n\n\n127.0.0.1\n" | openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt \
&& openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

#Fichier a modifier
ADD wp-config.php ./var/www/ft_server/wordpress/wp-config.php
ADD nginx.html /var/www/ft_server
ADD wordpress /etc/nginx/sites-available/default
ADD self-signed.conf /etc/nginx/snippets/
ADD ssl-params.conf /etc/nginx/snippets/

#Port HTTP HTTPS
EXPOSE 80 443

#Lancer service installer + creation base de donne mysql
CMD service php7.3-fpm start \
&& service mysql start \
&& mysql -u root -e "CREATE USER 'ft_server_god' identified by 'mp';" \
&& mysql -u root -e "CREATE DATABASE wordpress;" \
&& mysql -u root -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'ft_server_god';" \
&& mysql -u root -e "FLUSH PRIVILEGES;" \
&& service nginx start \
&& bash
