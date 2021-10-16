#!/bin/bash

# Vérification de la connexion internet
if ping -q -c 1 -W 1 8.8.8.8 >/dev/null;then
	# Demande de renseignement de la Base de données au user
	echo ""
	read -p "Entrez le nom de la Database : " BDDNAME
	read -p "Entrez le nom de l'utilisateur SQL : " BDDUSER
	read -sp "Créer le MDP de l'utilisateur SQL : " BDDPASSWD
	echo ""

	# Boucle pour installer ou non un serveur LAMP
	isvalid=true

	while [ $isvalid ]
	do
	read -p "Souhaitez vous installer un serveur LAMP ? (y/n) " INSTALLLAMP
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
		echo "Erreur : Veuillez répondre avec (y/n) "
	fi
	done
	
	# Création des paramètres SQL 
	mysql -e "create database ${BDDNAME};"
	mysql -e "create user ${BDDUSER}@localhost identified by '${BDDPASSWD}';"
	mysql -e "grant all privileges on ${BDDNAME}.* to ${BDDUSER}@localhost;"
	mysql -e "flush privileges;"

	# Installation de Wordpress
	cd /tmp
	wget https://wordpress.org/latest.tar.gz --no-check-certificate
	tar xvf latest.tar.gz
	cp -r /tmp/wordpress/ /var/www/html/
	chown -R www-data.www-data /var/www/html/wordpress
	systemctl reload apache2
	echo "cleaning ..."
	rm -fr latest.tar.gz wordpress
	

	# Renseignement des informations de la base de données à Wordpress
	cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
	perl -pi -e "s/database_name_here/$BDDNAME/g" /var/www/html/wordpress/wp-config.php
	perl -pi -e "s/username_here/$BDDUSER/g" /var/www/html/wordpress/wp-config.php
	perl -pi -e "s/password_here/$BDDPASSWD/g" /var/www/html/wordpress/wp-config.php

echo ""
echo "========================="
echo "Installation terminé."
echo "========================="
echo ""
echo "Script réalisé par Zatoufly"
echo "Website : https://zatoufly.fr"

	# Affiche l'URL pour se connecter à l'interface de wordpress
	IP=$(hostname -I)
	URL="http://$IP/wordpress"
	URL=$(echo $URL | tr -d ' ')
	echo ""
	echo "Tappez cette url dans votre navigateur : $URL"
	echo ""
	
else
	echo "Connexion failed"
fi


