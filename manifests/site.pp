import 'java.pp'
import 'postgresql.pp'
import 'jira.pp'
import 'crowd.pp'

class git{
		package{ 'git':
        ensure => installed,
		require => Class['postgresql'],
        }
}


node default {
	include java
	include postgresql
	include git
	include jira
	include crowd
}
