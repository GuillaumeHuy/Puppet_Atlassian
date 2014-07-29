class postgresql{

        package{ 'ssl-cert':
        ensure => installed,
        before => Package['postgresql'],
	require => Class['java'],
        }

        package{ 'postgresql':
        ensure => '9.3+153bzr1',
        before => File['/data'],
        }

        file{ '/data':
        ensure => directory,
        before => File['/data/postgres'],
        }


        file{ '/data/postgres':
        ensure => directory,
        owner => 'postgres',
        group => 'postgres',
        before => File['/data/postgres/main'],
	}

        file{ '/data/postgres/main':
        ensure => directory,
        owner => 'postgres',
        group => 'postgres',
        before => Exec['stop-postgresql'],
        }

        exec {'stop-postgresql':
        command => 'sudo service postgresql stop',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['add-conf-post'],
        }

        exec {'add-conf-post':
        command => 'sudo echo "data_directory = \'/data/postgres/main\'" >> /etc/postgresql/9.3/main/postgresql.conf',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['usr-lib-post'],
        }
	
	exec {'usr-lib-post':
        command => 'sudo -u postgres /usr/lib/postgresql/9.3/bin/initdb -D /data/postgres/main',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['peer-md5'],
        onlyif => '[ ! -e "/data/postgres/main/pg_hba.conf" ]',
        }

#       exec {'var-post-crt':
#       command => 'cp /var/lib/postgresql/9.3/main/server.crt .',
#       cwd => '/data/postgres/main/',
#       user => 'postgres',
#       logoutput =>true,
#       path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
#       before => Exec['var-post-key'],
#       }

#       exec {'var-post-key':
#       command => 'cp /var/lib/postgresql/9.3/main/server.key .',
#       cwd => '/data/postgres/main/',
#       user => 'postgres',
#       logoutput =>true,
#       path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
#       before => Exec['peer-md5'],
#       }

        exec {'peer-md5':
        command => 'sudo sed -i -e "s/local all all peer/local all all md5/g" /etc/postgresql/9.3/main/pg_hba.conf',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        before => Exec['post-start'],
        }

        exec {'post-start':
        command => 'sudo /etc/init.d/postgresql start',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        }
}
