class jira {
#creation des dossiers
        exec{ 'createoptatla':
        command => 'sudo mkdir -p /opt/atlassian',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        logoutput =>true,
        onlyif => '[ ! -d /opt/atlassian ]',
        before  => Exec['createdataatla'],
	require => Class['git'],
        }

	exec{ 'createdataatla':
        command => 'sudo mkdir -p /data/atlassian',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        logoutput =>true,
        onlyif => '[ ! -d /data/atlassian ]',
        before  => Exec['createdatajira'],
        }

	exec{ 'createdatajira':
        command => 'sudo mkdir -p /data/atlassian/jira',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        logoutput =>true,
        onlyif => '[ ! -d /data/atlassian/jira ]',
        before  => Exec['adduserjira'],
        }

#creation et configuration de l'utilisateur jira
    exec {'adduserjira':
        command => 'sudo adduser jira',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        logoutput =>true,
        onlyif => '[ ! -e "/home/jira" ]',
        before => File['/home/jira/.profile'],
        }
		
#.profile contient les informations de l'environnement java
	file {'/home/jira/.profile':
        source => 'puppet:///files/.profile',
        replace =>true,
	before => Group['atlaslog'],
        }

#creation du groupe atlaslog et ajout de l'utilisateur jira a ce groupe
	group {'atlaslog':
        ensure => present,
        before => Exec['usermodjira'],
        }

	exec {'usermodjira':
        command => 'sudo usermod -a -G atlaslog jira',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
	before => Exec['createuserjira'],
        }

#creation de l'utilisateur postgres jira et creation de sa base de donnees associe
	exec {'createuserjira':
        command => 'psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname=\'jira\'" | grep -q 1 || createuser -D -P jira',
	user=>'postgres',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
	before => Exec['createdbjira'],
        }
	
	exec {'createdbjira':
        command => 'createdb -O jira jira',
	user=>'postgres',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
	onlyif => '[ ! psql -l | grep <exact_dbname> | wc -l ]',
	before => Exec['sshd_configjira'],
        }

#configuration et redemarrage du service ssh
	exec {'sshd_configjira':
        command => 'sudo echo "DenyUsers jira" >> /etc/ssh/sshd_config',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['restartjira'],
        }

	exec {'restartjira':
        command => 'sudo service ssh restart',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['wgetjira'],
        }

#telechargement, extraction et suppression de l'archive jira
	exec {'wgetjira':
        command => 'sudo wget http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-6.1.7.tar.gz',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "atlassian-jira-6.1.7-standalone" ]',
	before => Exec['tarjira'],
        }

	exec {'tarjira':
        command => 'sudo tar -zxvf atlassian-jira-6.1.7.tar.gz',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "atlassian-jira-6.1.7-standalone" ]',
	before => Exec['rmjiragz'],
        }

	exec {'rmjiragz':
        command => 'sudo rm atlassian-jira-6.1.7.tar.gz',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "atlassian-jira-6.1.7.tar.gz" ]',
	before => Exec['lnjira'],
        }

#creation du lien symbolique jira pointant sur le dossier extrait
	exec {'lnjira':
        command => 'sudo ln -s atlassian-jira-6.1.7-standalone/ jira',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "jira" ]',
	before => Exec['chownjira'],
        }

#attribution des droits sur les dossiers
	exec {'chownjira':
        command => 'sudo chown -RH jira:jira /opt/atlassian/jira /data/atlassian/jira',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
	before => Exec['home-rollingjira'],
        }

#modification du fichier de configuration de log
	exec {'home-rollingjira':
        command => 'sudo sed -i -e "s/log4j.appender.filelog=com.atlassian.jira.logging.JiraHomeAppende/log4j.appender.filelog=com.atlassian.jira.logging.RollingFileAppender/g" jira/atlassian-jira/WEB-INF/classes/log4j.properties',
        logoutput =>true,
	cwd => '/opt/atlassian',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['home-rollingp2jira'],
        }


	exec {'home-rollingp2jira':
        command => 'sudo sed -i -e "s/log4j.appender.filelog.File=atlassianjira.log/log4j.appender.filelog.File=\/data\/logs\/atlassianjira.log/g" jira/atlassian-jira/WEB-INF/classes/log4j.properties',
        logoutput =>true,
	cwd => '/opt/atlassian',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['setenvjira'],
        }

	exec {'setenvjira':
        command => 'sudo echo CATALINA_OUT="/data/logs/atlassianjiracatalina.out" >> jira/bin/setenv.sh',
	cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
	before  => Exec['createoptservicejira'],
	}

	exec{ 'createoptservicejira':
	command => 'sudo mkdir -p /data/logs',
	path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
	logoutput =>true,
	onlyif => '[ ! -d /data/logs ]',
	}
}

