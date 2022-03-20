# # 系统组的创建
# group {'nginx':
# 	gid => 2222,
# 	system => true,
# 	ensure => present,
# }

# # 用户的创建##################################
# user {'nginx':
# 	ensure => present,
# # 不指定gid，创建一个同名用户组
# 	gid => 2222,
# 	system => true,
# 	shell => '/sbin/nologin',
# }

# # 资源间的依赖#########################################
# # 下面表示group 是 user 的依赖
# user {'redis':
# 	ensure => present,
# 	gid => 901,
# 	uid => 901,
# 	system => true,
# # 	require => Group['redis'],
# }
# group {'redis':
# 	ensure => present,
# 	system => true,
# 	gid => 901,
# 	before => User['redis'],
# }

# # 软件包的安装#########################################
# package {'memcached':
# 	ensure => installed,
# # 	before => Service['memcached'],
# } ->
# 
# file {'memecached':
# 	path => '/etc/sysconfig/memcached',
# 	ensure => file,
# #	notify => Service['memcached'],
# # ~ 会监控file 的变化，并refresh， 也可以subscribe 检测某个资源，当发生变化时，该资源重新加载
# } ~>
# 
# service {'memcached':
# 启动且开机自启
# 	ensure => running,
# 	enable => true,
# 	restart => 'systemctl restart memcached.service',
# #  	require => [ Package['memcached'], File['memcached']],
# # 	subscribe => File["/etc/sysconfig/memcached"]
# }
# 或者定义一个依赖链
# Package['memcached'] -> File['memcached'] -> Service['memchaced']

# 文件的新建，复制，#########################################
# file {'test.txt':
# 	path => '/tmp/test.txt',
# 	ensure => file,
# 	content => "hello,there\nMy God",
# 	owner => 'redis',
# 	group => 'puppet',
# 	mode => '0644',
# }
# file {'fstab':
# 	ensure => file,
# 	path => '/tmp/fstab',
# 	source => '/etc/fstab',
# }
# 复制目录
# file {'mydir':
# 	ensure => directory,
# 	path => '/tmp/mydir',
# 	source => '/etc/puppet',
# 	recurse => true,
# }
# # 链接文件
# file {'fstab.link':
# 	path => '/tmp/fstab.link',
# 	target => '/tmp/fstab',
# 	ensure => link,
# }

# exec，#########################################
# file {'/tmp/fstab':
# 	ensure => present,
# 	source => '/root/fstab',
# 	notify => Exec['makedir'],
# }
# exec {'makedir':
# 	command => 'test -d /tmp/mytestdir || mkdir /tmp/mytestdir',
# 	path => '/bin:/usr/bin',
# 	refresh => "echo '12312'>/tmp/echo.txt",
# }

# cron #########################################
# cron {'synctime':
# 	command => 'ntpdate pool.ntp.org &>/dev/null',
# 	ensure => present,
# 	minute => '*/5',
# # 以哪个用户的身份运行命令
# 	user => 'root',
# # 添加为哪个用户的任务
# 	target => 'redis',
# }

# # notify #########################################
# notify {'redalert':
# 	message => 'Warning!!!Warning!!!Warning!!!Warning!!!Warning!!!Warning!!!Warning!!!Warning!!!!!!!',
# }

# #条件 
# if $osfamily == 'Debian' {
# 	$webpkg = 'apache2'
# } else {
# 	$webpkg = 'httpd'
# }
# package {"$webpkg":
# 	ensure => present,
# }

# case $operationsystem， 同样是条件
case $osfamily {
	"RedAht": { $webpkg = 'httpd' }
# 第二个条件, debian系
	/(?i-mx:debian)/: { $webpkg = 'apache2' }
	default: { $webpkg = 'httpd' }
}
package {"$webpkg":
	ensure => present,
}


