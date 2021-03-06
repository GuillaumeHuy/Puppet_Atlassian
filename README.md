#Puppet Atlassian#

Sur ubuntu 14.04

##Coté serveur##

- Commencez par faire un update de la base de paquet grâce à la commande 
sudo apt-get update

- Installez ensuite puppet:
sudo apt-get install puppetmaster

- Il faut ensuite ouvrir le port 8140 soit directement dans le gestionnaire windows azure soit grâce à iptables:
sudo iptables -A INPUT -p tcp -m tcp --dport 8140 -j ACCEPT

- Dans /etc/puppet/fileserver.conf ajoutez la ligne suivante dans la partie [files]:
allow *

- Créez le fichier /etc/puppet/autosign.conf et ajoutez la ligne indiquant qu'on autorise toutes les demandes certificats automatiquement:
*

- Dans /etc/puppet/puppet.conf supprimez le contenu et le remplacez par celui de :
puppet_conf_master.txt

- Dans le répertoire /etc/puppet/manifest/ ajoutez l'ensemble des fichiers :
	-site.pp
	-java.pp
	-postgresql.pp
	-jira.pp
	-crowd.pp
	-stash.pp

- Dans le répertoire /etc/puppet/files/ ajoutez l'ensemble des fichiers :
	-.profile
	-logback.xml
	
	
##Coté agent##

- Commencez par faire un update de la base de paquet grâce à la commande 
sudo apt-get update

- Installez ensuite puppet:
sudo apt-get install puppet

- Modifiez le fichier /etc/hosts pour rajoutez le serveur puppet en tant que serveur dns:
ipduserveur	puppet.puppetmaster puppet

- Dans /etc/puppet/puppet.conf supprimez le contenu et remplacez le par celui de :
puppet_conf_agent.txt

- Il faut ensuite ouvrir le port 8139 soit directement dans le gestionnaire windows azure soit grâce à iptables:
sudo iptables -A INPUT -p tcp -m tcp --dport 8139 -j ACCEPT

- Pour rendre possible l'utilisation de puppet agent, utilisez la commande suivante:
sudo puppet agent --enable

- Vous pouvez maintenant lancer l'installation des outils atlassian avec la commande:
sudo puppet agent --waitforcert 60 --test

###Jira###

- Lancez /opt/atlassian/jira/bin/config.sh. Une fenêtre va s'ouvrir. 

- Dans l'onglet JIRA Home, dans le champs JIRA Home directory ajoutez  : '/data/atlassian/jira'

- Démarrez jira avec le script /opt/atlassian/jira/bin/start-jira.sh

- Il faut ensuite ouvrir le port 8080 soit directement dans le gestionnaire windows azure soit grâce à iptables:
sudo iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT

###Stash###

- Démarrez stash avec le script /opt/atlassian/stash/bin/start-stash.sh

- Il faut ensuite ouvrir le port 7990 soit directement dans le gestionnaire windows azure soit grâce à iptables:
sudo iptables -A INPUT -p tcp -m tcp --dport 7990 -j ACCEPT

###Crowd###

- Démarrez crowd avec le script /opt/atlassian/crowd/start-crowd.sh

- Il faut ensuite ouvrir le port 8095 soit directement dans le gestionnaire windows azure soit grâce à iptables:
sudo iptables -A INPUT -p tcp -m tcp --dport 8095 -j ACCEPT