class stash {
	exec{ 'createdatastash':
        command => 'sudo mkdir -p /data/atlassian/stash',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        logoutput =>true,
        onlyif => '[ ! -d /data/atlassian/stash ]',
        before  => Exec['adduserstash'],
		require => Class['crowd'],
        }

	exec {'adduserstash':
        command => 'sudo adduser stash',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        logoutput =>true,
        onlyif => '[ ! -e "/home/stash" ]',
        before => Exec['usermodstash'],
        }

	exec {'usermodstash':
        command => 'sudo usermod -a -G atlaslog stash',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
		before => Exec['createuserstash'],
        }	

#création de l'utilisateur postgres stash et création de sa base de données associé
	exec {'createuserstash':
        command => 'psql postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname=\'stash\'" | grep -q 1 || createuser -D -P stash',
		user=>'postgres',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
		before => Exec['createdbstash'],
        }
	
	exec {'createdbstash':
        command => 'createdb -O stash stash',
		user=>'postgres',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
		onlyif => '[ ! psql -l | grep <exact_dbname> | wc -l ]',
		before => Exec['sshd_configstash'],
        }
	
#configuration et redémarrage du service ssh	
	exec {'sshd_configstash':
        command => 'sudo sed -i -e "s/DenyUsers jira crowd/DenyUsers jira crowd stash/g" /etc/ssh/sshd_config',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['restartstash'],
        }
		
	exec {'restartstash':
        command => 'sudo service ssh restart',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['wgetstash'],
        }

#téléchargement, extraction et suppression de l'archive stash		
	exec {'wgetstash':
        command => 'sudo wget http://www.atlassian.com/software/stash/downloads/binary/atlassian-stash-3.0.4.tar.gz',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "atlassian-stash-3.0.4-standalone" ]',
		before => Exec['tarstash'],
        }

	exec {'tarstash':
        command => 'sudo tar -zxvf atlassian-stash-3.0.4.tar.gz',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "atlassian-stash-3.0.4-standalone" ]',
		before => Exec['rmstashgz'],
        }

	exec {'rmstashgz':
        command => 'sudo rm atlassian-stash-3.0.4.tar.gz',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "atlassian-stash-3.0.4-standalone" ]',
		before => Exec['lnstash'],
        }

#création du lien symbolique stash pointant sur le dossier extrait
	exec {'lnstash':
        command => 'sudo ln -s atlassian-stash-3.0.4-standalone/ stash',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "stash" ]',
		before => Exec['chownstash'],
        }

#attribution des droits sur les dossiers
	exec {'chownstash':
        command => 'sudo chown -RH stash:stash /opt/atlassian/stash /data/atlassian/stash',
        cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "stash" ]',
		before => Exec['setenv1stash'],
        }

#configuration fichiers de log		
	exec {'setenv1stash':
        command => 'sudo echo 'STASH_HOME="/data/atlassian/stash' >> stash/bin/setenv.sh',
		cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
		before  => Exec['setenv2stash'],
	}
	
	exec {'setenv2stash':
        command => 'sudo echo 'CATALINA_OUT="/data/logs/atlassianstashcatalina.log"' >> stash/bin/setenv.sh',
		cwd => '/opt/atlassian',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
		before => File['/data/atlassian/stash/logback.xml'],
	}
	
	file {'/data/atlassian/stash/logback.xml':
        source => 'puppet:///files/logback.xml',
        replace =>true,
		before => Group['atlaslog'],
    }
}
