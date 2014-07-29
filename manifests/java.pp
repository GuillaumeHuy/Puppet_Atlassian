class java {
    exec{ 'create':
        command => 'sudo mkdir /opt/jvm',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        logoutput =>true,
        onlyif => '[ ! -d /opt/jvm/ ]',
        before  => Package['openjdk-7-jre'],
        }

    package{ 'openjdk-7-jre':
        ensure => installed,
        before => Exec['mv-java']
        }

    exec {'mv-java':
        command => 'sudo cp -r /etc/java-7-openjdk /opt/jvm/java-7-openjdk',
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        logoutput =>true,
        onlyif => '[ ! -e "/opt/jvm/java-7-openjdk" ]',
        before => Exec['ln-java'],
        }

	exec {'ln-java':
        command => 'sudo ln -s java-7-openjdk 7',
        cwd => '/opt/jvm',
        logoutput =>true,
        path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ],
        onlyif => '[ ! -e "/opt/jvm/7" ]',
        }

    file {'/etc/.profile':
        source => 'puppet:///files/.profile',
        replace =>true,
        }
}
