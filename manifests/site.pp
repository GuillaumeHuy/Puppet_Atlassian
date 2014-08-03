import 'java.pp'
import 'postgresql.pp'
import 'jira.pp'
import 'crowd.pp'
import 'stash.pp'

class ssh{
	package{ 'ssh':
        ensure => installed,
	require => Class['postgresql'],
        }
}


class git{
	package{ 'git':
        ensure => installed,
	require => Class['ssh'],
        }
}

node default {
	include java
	include postgresql
	include ssh
	include git
	include jira
	include crowd
	include stash
}
