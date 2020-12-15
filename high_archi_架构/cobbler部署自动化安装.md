## cobbler概述

1. pxe-kickstart，

- 启动计算机选择网卡启动
- pxe上的DHCP客户端会向DHCP服务端，申请IP地址
- DHCP服务端分配给它IP地址的同时，通过以下字段，告诉pxe，tftp的地址和它要下载的文件
  - next-server 192.168.0.12
  - filename "pxelinux.0"
- pxelinux.0告诉pxe要下载的配置文件是pxelinux.cfg目录下的default
- pxe下载并依据配置文件的内容下载启动必须的文件，并通过ks.cfg开始系统安装

---

# cobbler介绍与部署

- 使用一个以前定义的模板来配置DHCP服务（如果启用了管理DHCP）
- 将一个存储库（yum或rsync）建立镜像或解压缩一个媒介，以注册一个新操作系统
- 在DHCP配置文件中为需要安装的机器创建一个条目，并使用您指定的参数（IP和MAC地址）
- 在TFTP服务目录下创建适当的PXE文件
- 重新启动DHCP服务以反映更改
- 重新启动机器以开始安装（如果电源管理已启用）

# 使用cobbler进行linux安装

1. centos7

- `http://mirrors.aliyun.com/epel/epel-release-latest-7.noarch.rpm`
- `yum -y install httpd dhcp tftp cobbler cobbler-web pykickstart xinetd`  
- `systemctl start httpd `  `systemctl start cobblerd`  `cobbler check`  

2. 根据上面说明修改配置文件，`vim /etc/cobbler/settings`  ，D删除到行尾

- 272行，next_server: 192.168.56.11
- 384行，server: 192.168.56.11

3. `vim /etc/xinetd.d/tftp`  

- disable	= no
- `systemctl start rsyncd`  

4. `cobbler get-loaders`  
5. `openssl passwd -1 -salt 'cobbler' 'cobbler' `  
6. `vim /etc/cobbler/settings`  

- 101行，default_password_crypted:    将上面生成的密码粘贴过来

7. `systemctl restart cobblerd`  `cobbler check`  
8. cobbler设置管理dhcp，`vim /etc/cobbler/settings`  

- 242行，manage_dhcp:  数值改成1
- 会生成一个模板，`vim /etc/cobbler/dhcp.template`  ，更改subnet子网，下面几行的routers网关、domain-name-servers，range dynamic-bootp分配的IP地址段

![TIM图片20200506214340](https://cdn.jsdelivr.net/gh/liuzel01/MyPicBed@master/data/20200506214353.png)

- `systemctl restart cobblerd`  `cobbler sync`  

- `cat /etc/dhcp/dhcpd.conf`  

9. 

- `mount /dev/cdrom /mnt`  `cobbler import --path=/mnt/ --name=centos-7-x86_64 --arch=x86_64`  ，会将镜像导入到 /var/www/cobbler/ks-mirror/ 目录下
- `umount /dev/cdrom`  卸载了，然后重新挂载centos6 的镜像文件，再用cobbler导入
- centos-7-x86_64.cfg文件，进行编辑内容

10. `cobbler profile`  查看cobbler都有什么命令

- `cobbler profile list`  `cobbler profile report`  
- 将自己的文件移动到kickstart默认的目录下，`cobbler profile edit --name=centos-7-x86_64 --kickstart=/var/lib/cobbler/kickstarts/centos-7-x86_64.cfg`  
- centos6的一样按需编辑
- 将centos7上的网卡改成eth0，`cobbler profile edit --name=centos-7-x86_64 --kopts='net.ifnames=0 biosdevname=0'`   
  - `cobbler profile report centos-7-x86_64`  ，看"Kernel Options"这个参数
  - `cobbler sync`  会重新创建hard link，相当于生效

11. `tail -f /var/log/messages`  ，再创建一个虚拟机，看日志打印情况，能看到DHCP4个步骤 DHCPDISCOVER, DHCPOFFER , DHCPREQUEST, DHCPACK 

- 一个新虚拟机，默认是从local本地磁盘启动，安全。会进入选择系统页面



# 深入理解cobbler

## 自动重装和cobbler-web

1. 

- `yum install -y koan`  
- `koan --server=192.168.56.11 --list=profiles`  列出server端可供重装的OS
- `koan --replace-self --server=192.168.56.11 --profile=centos-6-x86_64`  
  - 注意执行的机器，否则很容易造成：koan安装错误机器或者cobbler自动化安装错误机器

2. 浏览器访问，https://192.168.56.11/cobbler_web，用户名密码默认都是cobbler
3. 更改用户名/密码，`cat /etc/cobbler/users.conf`  密码是在 users.digest

- `htdigest /etc/cobbler/users.digest "Cobbler" cobbler`  用户描述 用户名

4. cobbler工作模式

<img src="https://cdn.jsdelivr.net/gh/liuzel01/MyPicBed@master/data/20200506224808.png" alt="TIM图片20200506224622" style="zoom:80%;" />

## 自定义yum源

1. `cd /var/www/cobbler/ks-mirror/`  存放所有镜像

- `cd /var/www/cobbler/repo_mirror/`  存放仓库镜像
- `cd /var/lib/cobbler/`  存放kickstarts文件
- `cd /etc/cobbler/`  存放所有的配置文件 dhcp.template ~~dnsmasq.template~~  

2. 添加一个openstack的stein版本的源

- `cobbler repo add --name=openstack-stein --mirrot=http://mirrors.aliyun.com/centos/7.8.2003/cloud/x86_64/openstack-stein/Packages/ --arch=x86_64 --breed=yum`  
- `cobbler reposync`  同步repo，会自动创建repo文件

3. 将openstack的仓库repo文件安装到新机器上，（repo添加到对应的profile）

- `cobbler profile edit --name=centos-7-x86_64 --repos="openstack-stein"`  
- `cat /etc/cobbler/settings`  文件中，yum_post_install_mirror: 1  默认是开启的

4. 修改kickstart文件，

- `vim /var/lib/cobbler/kickstarts/centos-7-x86_64.cfg`，添加一条 $yum_config_stanza  

5. 添加定时任务，定期同步repo，

- `echo "1 3 * * * /usr/bin/cobbler reposync --tries=3 --no-fail" >> /var/spool/cron/root`  

## 自定义系统安装

1. 服务器采购
2. 服务器验收并设置raid
3. 服务商提供验收单，运维验收负责人签字
4. 服务器上架
5. 资产录入
6. **开始自动化安装**

- 将新服务器划入装机vlan
- 根据资产清单上的mac地址，自定义安装
  - 机房；机房区域；机柜；服务器位置；服务器网线接入端口；该端口mac地址；操作系统，分区等；预分配的ip地址，主机名，子网，网关，dns，角色
- 自动化装机平台（cobbler），安装

```shell
cobbler system add --name=linux-node2.xxxx --mac=00:50:xxxx --profile=centos-7-x86_64 \
--ip-address=192.168.56.12 --subnet=255.255.255.0 --gateway=192.168.56.2 \
--interface=eth0 --static=1 --hostname=linux-nodex.xxxx --name-servers="192.168.56.2" \
--kickstart=/var/lib/cobbler/kickstarts/centos-7-x86_64.cfg  
```

- `cobbler system list`  就能查看到了。`cobbler sync`  不执行也可
  - 接通电源（开启虚拟机），就可自动配置ip等信息

7. cobbler做电源的管理

## 使用api自定义安装

1. `vim /etc/httpd/conf.d/cobbler_web.conf`  

- 可以创建profile，创建主机...
- 使用python编写脚本，
- cobble



# cobbler自动化安装生产实践



# 操作系统安装及初始化规范

# 初始化操作

1. 设置DNS  192.168.56.xx
2. 安装zabbix agent：Server 192.168.56.xx
3. 安装saltstack minion：saltstack master：192.168.56.xx
4. history记录时间

- ``export HISTTIMEFORMAT="%F %T `whoami` "``  
  - ~~用两个反引号引起就ok~~  
- <u>**或是下载脚本**</u>，`https://github.com/liuzel01/Command-file/blob/master/centos7init.sh`  

5. 日志记录操作

<pre>
    export PROMPT_COMMAND='{ msg=$(history 1 | {read x y;echo $y; });logger "[ euid=$(whoami)]";$(whoami):[`pwd`] "$msg";}'
</pre>

6. 内核参数优化
7. yum仓库

## 目录规范

1. 脚本防止目录：/opt/shell
2. 脚本日志目录：/opt/shell/log
3. 脚本锁文件目录：/opt/shell/lock

## 服务安装规范

1. 源码安装路径：/usr/local/appname.version
2. 创建软链接：`ln -s /usr/local/appname.version /usr/local/appname`  



## 主机名命名规范

1. **机房名称-项目-角色-服务-集群-节点.域名**
   - idc01-xxshop-api-nginx-bj-node1.shop.com
2. A^A^A  

## 服务启动用户规范

所有服务，统一使用www用户，uid为666，除负载均衡需要监听80端口使用root启动外，所有服务必须使用www用户启动，使用大约1024端口