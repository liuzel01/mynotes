# linux security -- best practices for 2020 

1. `nmap localhost`，                                     相当从外部检测服务器端口情况
2. `sestatus`，                                           查看SELinux status
3. 用户权限，
    `rpm -qc openssh-server,vim /etc/ssh/sshd_config`,     修改SSH参数，
        `rpm -qa | grep openssh-server` 
        `rpm -ql aide` 

    1. PasswordAuthentication no                        # 是否启用密码认证，no 表示不起用
    PermitRootLogin no                                  # 是否允许root远程登录，no表示禁止
    AddressFamily inet                                  # 通过修改此选项，将ssh服务限制为ipv4或ipv6，inet表示更改为仅使用ipv4
    修改ssh 远程端口，默认22

    2. 禁用777 权限。如若具有777权限，对文件和目录的完全许可，意味着即使是web用户也可执行文件。
        find . -type f -perm 777                            查找home 目录下具有完全权限的文件
    
    3. 锁住关键文件
    `chattr +i /etc/resolv.conf`，`/etc/services /etc/passwd /etc/shadow` 添加属性。这样，文件为只读文件，无法修改内容
        +<属性>，开启文件或目录的该项属性；-<属性>关闭该项属性；=<>指定该项属性
        这样，避免了自动将新用户添加到系统中，或者入侵者无法安装，会添加新用户的程序

    `lsattr /etc/resolv.conf`，                           查看
    `chattr +a /var/log/messages`，                       让文件只能往里面追加数据，但不能删除。适用于服务器日志文件安全

    4. 设置 /boot 为read-only
        文件，/etc/fstab，boot挂载的那行，将defaults改为ro，重新挂载即可生效

4. `ss -autp | grep -i listen`，                          删除未使用的面向网络的服务，
    
    1. 举个例子。smtp 这个服务（邮件服务），其实大多服务器是不需要这个功能的。。。应该要禁用， `systemctl status 1128`, `systemctl status postfix` 
    2. 避免使用telnet，ftp，rlogin/ rsh 服务 
        `yum erase xinetd ypserv tftp-server telnet-server rsh-server telnet`
    为避免损害服务器的安全性，尝试使用openssh，sftp，或ftps
    
    3. 配置安全的apache/PHP/NGINX Server， 
        编辑httpd.conf 
        ServerTokens Prod
        ServerSignature Off
        TraceEnable Off
        Options all -Indexes
    Header always unset X-Powered-By
    
6. 删除内置账户，举个例子。`adm,halt,game,amanda,apache`，这些经常被用于服务器黑客，因此可用userdel 删除服务器上无用账户。
    `userdel -r postfix`，                                举个例子，postfix服务
    可以注释掉无用账号

8. 防火墙设定。不使用时，停用网络端口
    `systemctl enable firewalld` 
    `firewall-cmd --list-ports` 或者，--list-all 
    
    1. 自定义端口和服务，举个例子。
如若不使用postfix服务，`systemctl disable postfix`, `yum remove postfix`，这个也就是上面扫描出的25端口
    
9. 调整网络参数，

10. 防入侵，
    1. Advanced Intrusion Detection Environment (AIDE)
    2. Auditd

11. Update Linux Software and Kernel
    
1. 
    
11. 配置对重要文件的备份（定期）

12. linux -- server hardening security tips, 参考，[40 linux server hardening security tips](https://www.cyberciti.biz/tips/linux-security.html),
    [25 hardening security tips for linux Servers ](https://www.tecmint.com/linux-server-hardening-security-tips/)

---

# 其他实践（方法论）

## 25 hardening security tips for linux servers 

- physcal system security

  - ###### Configure the **BIOS** to disable booting from **CD/DVD**, **External Devices**, **Floppy Drive** in **BIOS**. Next, enable **BIOS** password & also protect **GRUB** with password to restrict physical access of your system

  - 设置GRUB密码，来保护Linux Servers

1. 设置，修改菜单条目时的密码，
   1. `grub2-setpassword`， 会创建文件， /boot/grub2/user.cfg ，其中包含已加密的密码。这个密码的用户是root，在/boot/grub2/grub.cfg  文件中已定义。
   2. 然后重启，在引导期间修改引导条目需要指定root用户名和密码
2. 设置，启动菜单条目时的密码，
   1. vim /boot/grub2/grub.cfg， 搜索 10_linux，然后修改条目中的，--unrestricted 参数
   2. 你有几个menuentry， 就都需要去掉
   3. 重启，验证。在启动系统的时候，就会提示输入用户名/密码，

3. 将root用户修改成其他的用户

   1. 修改文件，`vim /boot/grub2/grub.cfg` ，搜索 01_user，将root 修改为 liuzel01

   set superusers="liuzel01"

   password_pbkdf2 liuzel01 ${GRUB2_PASSWORD}

   2. 重启，验证。在刚刚启动菜单的时候，就应该是输入用户名为liuzel01 了

4. 删除密码，`mv /boot/grub2/user.cfg /tmp` 

- Disk Partitions

1. 重要的是，要有不同的分区，以提高数据安全性，以防万一发生灾难。通过创建不同的分区，可以对数据进行分离和分组。发生意外时，仅该分区的数据被损坏，其他分区上的数据则得以保留。
2. 建议分区，/ /boot /usr /var /home /tmp /opt  
   1. 应将第三方应用程序安装在 /opt 下的单独文件系统上。

- 最小化软件包以最小化漏洞

1. `chkconfig --list | grep '3:on'`
2. `chkconfig serviceName off` 
3. `yum -y remove pack` 

- 检查监听网络端口

1. `netstat -tulnp` 
2. `netstat -at` 列出仅TCP端口连接
3. `netstat -au` 列出仅UDP端口连接
4. `netstat -l`    列出所有活动的侦听端口连接

- 使用安全shell

1. 主要是ssh，远程登录，编辑 /etc/ssh/sshd_config 

2. PermitRootLogin no

   AllowUsers username

   Protocol 2

- 保持系统更新

1. `yum updates` 
2. `yum check-update` 

- 锁定 cronjobs

1. 禁止所有用户使用cron，

   echo ALL >>/etc/cron.deny

- disable USB stick to detect 

1. 要限制用户在系统中使用USB记忆棒来保护、避免安全数据被窃取。创建文件 /etc/modprobe.d/no-usb， 添加内容

install usb-storage /bin/true

- 打开 SELinux

1. `sestatus` 查看SELinux状态

- Remove KDE/GNOME Desktops

1. 





















## 40 linux server hardening tips 

