## puppetmaster

安装环境： yum install puppet puppet-server facter -y		#系统会自己安装一些ruby依赖包环境
配置文件： /etc/puppet/puppet.conf 
启动服务： systemctl start puppetmaster
tree /var/lib/puppet/ssl/		# 查看本地证书情况
puppet cert --list --all		# 带+ 标识，说明已注册成功

grep -Ev "^$|#" puppet.conf.out.bak  > puppet.conf.out
cat /etc/puppet/puppet.conf.out | grep modulepath
mkdir modules/puppet
cd !$ 
mkdir -p files mainfests templates
cd mainfests
touch {init,config,install,service,params}.pp		# 创建puppet配置文件

- 基操
  puppet describe group		# 查看有关group 的描述
  puppet describe user | less
  puppet apply -v --test --noop l01.pp		本地运行，测试， nooperation 
  	should be present (noop)		# 出现这句,可以运行创建了
  puppet apply --test -v l01.pp				本地运行，生效









## 客户端

client01
yum install puppet facter		#系统会安装一些ruby依赖包环境
puppet  agent --test
puppet cert --sign pptclient01		# 注册agent01
puppet cert --list --all		# 再次查看认证情况
tree /var/lib/puppet/ssl | less

client02
puppet  agent --test
puppet cert --sign --all		# 注册所有请求的节点，之后会新增pptmaster_cert  SHA256 XXXXXXX
puppet cert --list --all		# 查看所有节点认证，输出内容如下
	+ "master"         (SHA256) 57:30:93:D3:4A:B8:14:11:DC:73:10:89:68:05:0E:B5:DD:68:AA:B2:5C:14:A4:2D:9F:67:7F:04:46:08:47:D0
	+ "pptclient01"    (SHA256) FD:9C:45:17:1D:FF:C8:34:47:83:B3:BA:90:75:82:7B:43:4D:05:4E:84:94:87:67:20:BD:84:B7:BC:04:1C:8A
	+ "pptclient02"    (SHA256) 4F:38:EA:24:92:5D:1A:5E:96:24:30:73:ED:E9:90:A0:3E:27:B7:45:39:D2:17:B4:89:08:93:DA:12:8A:64:A3
	+ "pptmaster_cert" (SHA256) F9:EA:2A:A1:C4:DE:CC:B4:79:6C:04:6F:29:76:D5:19:5F:89:B4:A7:A4:64:76:0B:FE:60:51:0A:BC:F6:63:5E