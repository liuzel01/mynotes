# linux security -- best practices for 2020

1. `nmap localhost`，                                       相当从外部检测服务器端口情况

2. `sestatus`，                                             查看SELinux status

3. 用户权限，

   `rpm -qc openssh-server,vim /etc/ssh/sshd_config`,       修改SSH参数，

   `rpm -qa | grep openssh-server`

   `rpm -ql aide`

    1. PasswordAuthentication no                             # 是否启用密码认证，no 表示不起用

         PermitRootLogin no                                  # 是否允许root远程登录，no表示禁止

         AddressFamily inet                                  # 通过修改此选项，将ssh服务限制为ipv4或
         ipv6，inet表示更改为仅使用ipv4

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
        编辑文件，/etc/fstab，boot挂载的那行，将defaults改为ro，重新挂载即可生效
        不过，大部分都没有 /boot 这个分区。所以这就和下面的 Disk Partitions，相切合。

4. `ss -autp | grep -i listen`，                          筛选未使用的面向网络的服务，并删除
    u 代表UDP
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

5. 删除内置账户，举个例子。`adm,halt,game,amanda,apache`，这些经常被用于服务器黑客，因此可用userdel 删除服务器上无用账户。
    `userdel -r postfix`，                                举个例子，postfix服务
    可以把无用账户直接注释掉

6. 防火墙设定。不使用时，停用网络端口
    `systemctl enable firewalld`
    `firewall-cmd --list-ports` 或者，--list-all

    1. 自定义端口和服务，举个例子。
    如若不使用postfix服务，`systemctl disable postfix`, `yum remove postfix`，这个也就是上面扫描出的25端口

7. 调整网络参数，

8. 防入侵，
    1. Advanced Intrusion Detection Environment (AIDE)
    2. Auditd

9. Update Linux Software and Kernel
10. 配置对重要文件的备份（定期）

###### linux -- server hardening security tips

- 参考，[40 linux server hardening security tips](https://www.cyberciti.biz/tips/linux-security.html),
   [25 hardening security tips for linux Servers](https://www.tecmint.com/linux-server-hardening-security-tips/)

---

# 其他实践（方法论）

## 25 hardening security tips for linux servers

- physcal system security

  > Configure the **BIOS** to disable booting from **CD/DVD**, **External Devices**, **Floppy Drive** in **BIOS**. Next, enable **BIOS** password & also protect **GRUB** with password to restrict physical access of your system

  - 设置GRUB密码，来保护Linux Servers

1. 设置，修改菜单条目时，需要输入的密码，
   1. `grub2-setpassword`， 会创建文件， /boot/grub2/user.cfg ，其中包含已加密的密码。这个密码的用户是root，在/boot/grub2/grub.cfg  文件中已定义。
   2. 然后重启，在引导期间修改引导条目需要指定root用户名和密码
2. 设置，启动菜单条目时，需要输入的密码，
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
2. 建议分区为，/ /boot /usr /var /home /tmp /opt  
   1. 应将第三方应用程序安装在 /opt 下的单独文件系统上。

- 最小化软件包以最小化漏洞

1. `chkconfig --list | grep '3:on'`
2. `chkconfig 'serviceName' off`
3. `yum -y remove 'packname'`

- 检查监听网络端口

1. `netstat -tulnp`
2. `netstat -at`              列出仅TCP端口连接
3. `netstat -au`              列出仅UDP端口连接
4. `netstat -l`               列出所有活动的侦听端口连接

- 使用安全shell

1. 主要是ssh，远程登录，编辑 /etc/ssh/sshd_config

2. PermitRootLogin no
   AllowUsers username
   Protocol 2

- 保持系统更新

1. `yum updates -y`
2. `yum check-update`
3. `yum install -y yum-cron`
   `rpm -ql yum-cron`         编辑配置文件，`vim /etc/yum/yum-cron.conf`

   ```bash
      # 不要安装，只做检查（有效值： yes|no）
      CHECK_ONLY = yes
      # check to see if you can reach the repos before updating 
      # CHECK_FIRST=yes
      # 不要安装，只做检查和下载。要求 CHECK_ONLY=yes（先要检查后，才可以知道要下载什么）
      DOWNLOAD_ONLY = yes
      # 设置一个有效的邮件地址
      MAILTO = "zelin.liu@sipingsoft.com"
   ```

4. `systemctl restart|enable yum-cron`
5. 使用cron通知何时有可用更新

- 锁定 cronjobs

1. 禁止所有用户使用cron，
   echo ALL >>/etc/cron.deny

- disable USB stick to detect

1. 要限制用户在系统中使用USB记忆棒来保护、避免安全数据被窃取。创建文件 /etc/modprobe.d/no-usb， 添加内容
   install usb-storage /bin/true

- 打开 SELinux

1. `sestatus` 查看SELinux状态

- Remove KDE/GNOME Desktops（**这里，我司有几台服务器还是装的桌面化**）

1. 对于LAMP服务器,运行KDE或GNOME之类的X Window桌面,没有必要. 可以删除以提高服务器的安全性和性能.要禁用,编辑 /etc/inittab
   ​将运行级别设置为3,
   不过,发现,被 multi-user.target, 和 graphical.target 替代了
   `systemctl get-default` 查看默认启动的target
   `systemctl set-default multi-user.target` 将默认的修改为多用户状态(字符界面)
   `systemctl set-default graphical.target` 将默认的修改为图形界面执行

2. yum groupremove 'X Window System',  完全删除X Window 桌面

- turn off ipv6

1. 未使用IPv6协议,应将其禁用.因为大多数应用程序或策略不需要IPv6协议,并确保当前服务器不需要它.编辑文件 /etc/sysconfig/network
   NETWORKING_IPV6=no
   IPV6INIT=no

- Restrict Users to Use Old Passwords

1. vim /etc/pam.d/system-auth

   auth sufficient pam_unix.so likeauth nullok

   passwd sufficient pam_unix.so nullok use_authtok md5 shadow remember=5

- hwo to check password expiration of user

1. `chage -l liuzel01`

2. 要更改任何用户的密码使用期限,使用命令

   `chage -M 60 liuzel01`

   `chage -M 60 -m 7 -W 7 liuzel01`

   -M 两次改变密码之间相距的最大天数

   -m两次改变密码之间相距的最小天数

   -W 在密码过期之前警告的天数

- lock and unlock account manually

1. passwd -l liuzel01

   ​-l, --lock 锁定指定账户的密码(对root用户仍可用)

2. passwd -u liuzel01

   ​-u, --unlock 解锁指定账户的密码(对root用户仍可用)

- enforcing stronger passwords
- enable iptables (firewall)
- disable Ctrl+Alt+Delete in inittab

1. 编辑文件, /etc/inittab 发现 有一行描述 Ctrl+Alt+Delete is handled by /usr/lib/systemd/system/ctrl-alt-del.target
   经过观察,文件 /usr/lib/systemd/system/ctrl-alt-del.target  为文件 reboot.target 的软链接,
   删除掉链接文件即可,
   init q 重新加载配置文件使配置生效,
   ctrl+alt+delete 测试,reboot 测试

- 检查账户中的空密码

1. sudo cat /etc/shadow | awk -F: '($2==""){print $1}'

- display ssh banner before login
- monitor user activities

1. [linux下用户操作记录审计环境的部署记录](https://www.cnblogs.com/kevingrace/p/7373146.html),
2. 参考, [linux-记录远程登陆IP及操作记录](https://blog.51cto.com/cdtech/1612878),[linux系统监控-记录用户操作轨迹](https://blog.51cto.com/ganbing/2053636), [linux记录所有用户登录和操作](https://blog.csdn.net/guancong3412/article/details/88532491),

3. 在服务器创建日志，记录用户操作，脚本参考如下，vim /etc/profile

```bash
USER_IP=`who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g'`
DT=`date "+%Y-%m-%d_%H:%M:%S"`
if [ "$USER_IP" = "" ]
then
        USER_IP=`hostname`
fi
        if [ ! -d /tmp/dbasky ]
        then
                mkdir /tmp/dbasky
                chmod 777 /tmp/dbasky
        fi
               if [ ! -d /tmp/dbasky/${LOGNAME} ]
               then
                        mkdir /tmp/dbasky/${LOGNAME}
                        chmod 300 /tmp/dbasky/${LOGNAME}
               fi
export HISTSIZE=4096
export HISTFILE="/tmp/dbasky/${LOGNAME}/${USER_IP}_dbasky.$DT"
chmod 600 /tmp/dbasky/${LOGNAME}/*dbasky* 2>/dev/null
```

4. `source /etc/profile` 生效，退出当前用户，登录后，检查下目录 /tmp/dbasky/root 下的内容

- review logs regularly

1. 将日志移动到专用服务器去,这可能会阻止入侵者轻松修改本地日志...以下是通用默认日志文件名称

2. /var/log/message
   /var/log/auth.log
   /var/log/kern.log
   cron.log
   maillog
   boot.log
   mysqld.log
   secure
   utmp, 或 wtmp
   yum.log

- 重要文件备份(上有提及)

1. 在生产系统中,必须备份重要文件并将其保存在安全仓库/远程站点或异地中,以进行灾难恢复

- NIC Bonding
- 保证 /boot 为只读(上有提及)
- ignore ICMP or Broadcast Request

1. vim /etc/sysctl.conf
   Ignore ICMP request:
   net.ipv4.icmp_echo_ignore_all = 1
   Ignore Broadcast request:
   net.ipv4.icmp_echo_ignore_broadcast = 1

2. `sysctl -p` 加载配置文件

- apply strong network security

1. `vim /etc/sysctl.conf`
   加强与网络相关的linux内核参数

2. `vim /etc/hosts.allow  和 /etc/hosts.deny`
   限制对服务的访问，使用 SSH TCP Wrappers

3. 使用iptables 配置强防火墙策略

`sysctl -n net.ipv4.tcp_syncookies`
`sysctl -w net.ipv4.tcp_syncookies=1`
`sysctl -n net.ipv4.tcp_syncookies`

- 应用强大的用户登录名和密码策略

1. 应用强密码。密码长度至少应超过12个字符
2. 改变你的旧密码。
3. N次尝试登录后锁定账户。如果在N次登录尝试后锁定账户，暴力攻击将失败
4. 尽可能使用IP基础限制。可为您的敏感服务（例如SSH，数据库）基于IP的限制

- Restrict User Privileges Using the File-System

1. chattr。 通过使其不可变，来防止，修改核心系统二进制文件
2. 将限制访问权限应用于 root用户和，/boot 部分， vim /etc/fstab

```bash
UUID=032231b0-b786-426e-9c86-729ddcb64d51 /boot                   xfs     defaults,nodev,nosuid,noexec        0 0
```

   1. noexec, Do  not  allow  direct  execution of any binaries on the mounted filesystem. 不允许在已挂载的系统上执行二进制文件
   2. nodev, Don't interpret block special devices on the filesystem
   3. nosuid, Block the operation of suid, and sgid bits

3. Block “SetUID” and “SetGID” file creation in world writable and web document root folders

- harden the linux kernel
- enable malware scanning，      启用恶意软件扫描

- setup an intrusion detection system

1. A^^A
2. 使用linux FHS的inotify 功能，在创建新文件时触发扫描
3. 使用web应用程序防火墙+防病毒来扫描web流量
4. 使用多个防病毒签名数据库来确保没有恶意软件通过您的过滤器

- 增减系统登录欢迎信息

1. 为了保证系统的安全，可以修改或删除某些系统文件，涉及到的文件有：
   /etc/issue                    记录了OS的名称和版本号
   /etc/issue.net                记录了OS的名称和版本号，内容会在登录后显示（默认不显示）
   /etc/redhat-release           记录了OS的名称和版本号。为安全起见，可将此文件中的内容删除
   /etc/motd                     系统的公告信息。每次用户登录后，会显示在用户终端。这里文件，最大的作用就是发布一些警告信息，在攻击者登录后产生一些震慑

- 检查并关闭系统可疑进程

1. ps、top 只知进程的名称而无法得知路径，
   pidof sshd                    查找正在运行的进程PID
   ls -al /proc/exe              进入内存目录，查看对应PID目录下 exe 文件的信息。这就找到了进程对应的完整执行路径
   ls -al /proc/981/fd           还可查看文件的句柄

### linux 安全加固基本方向

- 不同发行版之间，命令及文件都有差异，但包含基本的方向

1. 身份鉴别
   1. 口令复杂度。口令长度至少8位，并包括数字、小写字母、大写字母和特殊符号4类中至少2类
   2. 多次登录（远程）失败锁定策略。应配置，当用户连续认证失败次数超过6次，锁定该用户使用的账号，root不适用此配置
   3. 口令最长生存期策略。要求OS的账户口令，最长生存期不长于90天
   4. 修改banner信息。配置文件， /etc/issue 和 /etc/issue.net

2. 访问控制
   1. 多余账户锁定策略。应锁定与设备运行、维护等工作无关的账号。 /etc/passwd 文件，在需要锁定的用户的 shell 域后添加 nologin
   2. 共享账号检查。应按照不同的用户分配不同的账号，避免不同用户间共享账号。避免用户账号和服务器间通信，使用的账号共享
   3. 关键目录权限控制。配置某些关键目录其所需的最小权限
   4. 用户缺省权限控制。umask值应为027或更小权限
   5. 禁用control+alt+delete 快捷键关闭
   6. 日志文件权限。只能追加数据，不能删除日志文件
   7. 历史命令设置。

3. 安全审计
   审计内容应包括重要用户行为、系统资源的异常使用和重要系统命令的使用、账号的分配、创建与变更、审计策略的调整、审计系统功能的关闭与启动等系统内重要的安全相关事件；
   审计记录应包括事件的日期、时间、类型、主体标识、客体标识和结果等
   1. 安全日志完备性要求。系统应配置完备日志记录，记录对与系统相关的安全事件
   2. 统一远程日志服务器配置。当前系统应配置远程日志功能，将需要重点关注的日志内容传输到日志服务器进行备份
   3. 日志文件权限控制。系统应合理配置日志文件权限，控制对日志文件读取、修改和删除等操作
   4. NTP服务器，保证时间同步

4. 资源控制
   1. 字符操作界面账户定时退出。对于具备字符交互界面的系统，应配置定时帐户自动登出，超时时间为300秒。如不使用字符交互界面，该配置可忽略
   2. root账户远程登录账户限制（一般不做）
   3. 防止堆栈溢出。配置文件， /etc/security/limit.conf 增加一行， *  hard core 0

5. 入侵防范
   操作系统应遵循**最小安装**的原则，仅安装需要的组件和应用程序，并通过设置升级服务器、系统软件预防性维护服务等方式保持系统补丁及时得到更新
   1. 关闭不必要的网络和系统服务
   如无特殊需要，应关闭lpd,telnet,routed,sendmail,bluetooth,identd,xfs,rlogin,rwho,rsh,rexec服务

## 40 linux server hardening tips

- encrypt data communication for linux server
- avoid using FTP, Telnet and rlogin /Rsh Services on linux (上有提及)
- minimize software to minimize vulnerability in linux (上有提及)
- one network service per system or vm instance
- keep linux kernel and software up to date (上有提及)
- use linux security extensions
- SELinux()
- linux user accounts and strong password policy ()
- set up password aging for linux users for better security (上有提及)
- restricting use of previous password on linux (上有提及)
- locking user accounts after login failures
- how do i verify no accounts have empty passwords ()
- make sure no non-root accounts have uid set to 0
- disable root login ()
- physical server security
- disable unwanted linux services ()
- find listening network ports
- delete X Window Systems (X11) ()
- configure iptables and TCPWrappers based firewall on linux
- linux kernel /etc/sysctl.conf hardening
- separate disk partitions for linux system ()
- disk quotas
- turn off ipv6 only if you are not using it on linux (上有提及)
- disable unwanted SUID and SGID binaries
- world-writable files on Linux Server
- noowner files
- use a centralized authentication service
- kerberos
- logging and auditing
- monitor suspicious log messages with logwatch/ logcheck
- system accounting with auditd
- secure openssh server
- install and use intrusion detection system
- disable USB/firewire/thunderbolt devices
- disable unused services (上有提及)
- use fail2ban/ denyhost as IDS (install an intrusion detection system )
- secure Apache/ PHP/ Nginx server (上有提及)
- protecting files ,directories and email
- backups
- other recommendation and conlcusion
