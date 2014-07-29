###Puppet_Atlassian###
================
#Coté agent#

-commencez par faire un update de la base de paquet grâce à la commande 
sudo apt-get update

-Installez ensuite puppet:
sudo apt-get install puppet

-modifier le fichier /etc/hosts pour rajouter le serveur puppet en tant que serveur dns:
ipduserveur	puppet.puppetmaster

-enfin dans /etc/puppet/puppet.conf ajouter la ligne indiquant l'adresse du master dans la partie [main]:
server=puppet.puppetmaster

-vous pouvez maintenant lancer l'installation des outils atlassian avec la commande:
sudo puppet agent --waitforcert 60 --test

#coté serveur#

-commencez par faire un update de la base de paquet grâce à la commande 
sudo apt-get update

-Installez ensuite puppet:
sudo apt-get install puppetmaster

-Il faut ensuite ouvrir le port 8140 soit directement dans le gestionnaire windows azure soit grâce à iptables:
sudo iptables -A INPUT -p tcp -m tcp --dport 8140 -j ACCEPT