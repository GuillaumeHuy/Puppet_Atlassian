class crowd {
	exec{ 'createdatacrowd':
        command => 'sudo mkdir -p /data/atlassian/crowd',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        logoutput =>true,
        onlyif => '[ ! -d /data/atlassian/crowd ]',
        before  => Exec['addusercrowd'],
		require => Class['jira'],
        }

	exec {'addusercrowd':
        command => 'sudo adduser crowd',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        logoutput =>true,
        onlyif => '[ ! -e "/home/crowd" ]',
        before => Exec['usermodcrowd'],
        }

	exec {'usermodcrowd':
        command => 'sudo usermod -a -G atlaslog crowd',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
		before => Exec['createusercrowd'],
        }	

#création de l'utilisateur postgres crowd et création de sa base de données associé
	exec {'createusercrowd':
        command => 'psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname=\'crowd\'" | grep -q 1 || createuser -D -P crowd',
		user=>'postgres',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
		before => Exec['createdbcrowd'],
        }
	
	exec {'createdbcrowd':
        command => 'createdb -O crowd crowd',
		user=>'postgres',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
		onlyif => '[ ! psql -l | grep <exact_dbname> | wc -l ]',
		before => Exec['sshd_configcrowd'],
        }
	
#configuration et redémarrage du service ssh	
	exec {'sshd_configcrowd':
        command => 'sudo sed -i -e "s/DenyUsers jira/DenyUsers jira crowd/g" /etc/ssh/sshd_config',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['restartcrowd'],
        }
		
	exec {'restartcrowd':
        command => 'sudo service ssh restart',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['wgetcrowd'],
        }

#téléchargement, extraction et suppression de l'archive crowd		
		exec {'wgetcrowd':
        command => 'sudo wget http://downloads.atlassian.com/software/crowd/downloads/atlassian-crowd-2.7.2.tar.gz',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "atlassian-crowd-2.7.2-standalone" ]',
	before => Exec['tarcrowd'],
        }

	exec {'tarcrowd':
        command => 'sudo tar -zxvf atlassian-crowd-2.7.2.tar.gz',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "atlassian-crowd-2.7.2-standalone" ]',
		before => Exec['rmcrowdgz'],
        }

	exec {'rmcrowdgz':
        command => 'sudo rm atlassian-crowd-2.7.2.tar.gz',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "atlassian-crowd-2.7.2-standalone" ]',
		before => Exec['lncrowd'],
        }

#création du lien symbolique crowd pointant sur le dossier extrait
	exec {'lncrowd':
        command => 'sudo ln -s atlassian-crowd-2.7.2-standalone/ crowd',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "crowd" ]',
		before => Exec['chowncrowd'],
        }

#attribution des droits sur les dossiers
	exec {'chowncrowd':
        command => 'sudo chown -RH crowd:crowd /opt/atlassian/crowd /data/atlassian/crowd',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "crowd" ]',
		before => Exec['crowd_properties'],
        }

	exec {'crowd_properties':
        command => 'crowd.home=/data/atlassian/crowd" >> crowd/crowd-webapp/WEB-INF/classes/crowd-init.properties',
        cwd => '/opt/atlassian',
		logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['home-rollingcrowd'],
        }

#modification du fichier de configuration de log		
	exec {'home-rollingcrowd':
        command => 'sudo sed -i -e "s/log4j.appender.crowdlog=com.atlassian.crowd.console.logging.CrowdHomeLogAppender/log4j.appender.crowdlog= org.apache.log4j.RollingFileAppender/g" crowd/crowdwebapp/WEBINF/classes/log4j.properties',
        logoutput =>true,
		cwd => '/opt/atlassian',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['home-rollingp2crowd'],
        }
	
	exec {'home-rollingp2crowd':
        command => 'sudo echo "log4j.appender.crowdlog.File=/data/logs/atlassiancrowd.log" >> crowd/crowdwebapp/WEBINF/classes/log4j.properties',
        logoutput =>true,
		cwd => '/opt/atlassian',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['setenvcrowd'],
        }
		
	exec {'setenvcrowd':
        command => 'sudo echo "CATALINA_OUT=/data/logs/atlassiancrowdcatalina.out" >> crowd/apachetomcat/bin/setenv.sh',
		cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
	}
}
