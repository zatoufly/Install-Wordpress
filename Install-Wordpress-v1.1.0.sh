#!/bin/bash

# Check Internet connexion
if ping -q -c 1 -W 1 8.8.8.8 >/dev/null;then
	# Request for information from the Database to the user
	echo ""
	read -p "Enter the Database name : " BDDNAME
	read -p "Enter the name of the SQL user : " BDDUSER
	read -sp "Create Password for SQL user : " BDDPASSWD
	echo ""

	# Install or not LAMP server
	isvalid=true

	while [ $isvalid ]
	do
	read -p "Do you want to install a LAMP server ? (y/n) " INSTALLLAMP
	if [ $INSTALLLAMP = "y" ];then
		apt update
		apt install -y apache2 php php-mysql mariadb-server
		systemctl enable apache2.service
		systemctl enable mariadb.service
		rm /var/www/html/index.html
		break
	elif [ $INSTALLLAMP = "n" ];then
		echo "no install"
		break
	else
		echo "Error : Please answer with 'y' or 'n'."
	fi
	done
	
	# Where to install wordpress
	isvalid=true
	
	while [ $isvalid ];do
	echo ""
	echo "Indicate the installation path of Wordpress"
	echo "Choise 1 : /var/www/"
	echo "Choise 2 : /var/www/html/"
	read -p "Your Choise : " CWPPATH
	if [ $CWPPATH = "1" ];then
		WPPATH=/var/www/
		break
	elif [ $CWPPATH = "2" ];then
		WPPATH=/var/www/html/
		break
	else
		echo "Error : Please answer with '1' or '2'."
	fi
	done

	# Creation of the database and its user
	mysql -e "create database ${BDDNAME};"
	mysql -e "create user ${BDDUSER}@localhost identified by '${BDDPASSWD}';"
	mysql -e "grant all privileges on ${BDDNAME}.* to ${BDDUSER}@localhost;"
	mysql -e "flush privileges;"

	# Installing wordpress
	cd /tmp
	wget https://wordpress.org/latest.tar.gz --no-check-certificate
	tar xvf latest.tar.gz
	mv /tmp/wordpress/ $WPPATH
	chown -R www-data.www-data $WPPATH\wordpress
	systemctl reload apache2
	rm -fr /tmp/latest.tar.gz

	# Filling database information to wp-config.php
	cp $WPPATH\wordpress/wp-config-sample.php $WPPATH\wordpress/wp-config.php
	perl -pi -e "s/database_name_here/$BDDNAME/g" $WPPATH\wordpress/wp-config.php
	perl -pi -e "s/username_here/$BDDUSER/g" $WPPATH\wordpress/wp-config.php
	perl -pi -e "s/password_here/$BDDPASSWD/g" $WPPATH\wordpress/wp-config.php
	rm $WPPATH\wordpress/wp-config-sample.php
	chmod 400 /var/www/html/wordpress/wp-config.php

	echo ""
	echo "========================="
	echo "Installation complete."
	echo "========================="
	echo ""
	echo "Script made by Zatoufly"
	echo "Website : https://zatoufly.fr"

	# Show url to connect to wordpress interface
	IP=$(hostname -I)
	URL="http://$IP/wordpress"
	URL=$(echo $URL | tr -d ' ')
	echo ""
	echo "Type this url in your browser : $URL"
	echo ""
	
else
	echo "Connexion failed"
fi