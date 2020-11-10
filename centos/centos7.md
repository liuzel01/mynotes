# centos7

# docker

1. 普通用户在使用时，添加进docker组即可，不需每次都输入密码，才能`docker images`   `docker ps -a `   

- `sudo usermod -G docker -a xiaobai`   `id xiaobai`   能看到用户小白的主组，以及附加组

<img src="../images/centos7_docker_chusergroup.png" alt="chusergroup" />

- 更改后，需要切换或退出当前用户再重新登入，  `su - xiaobai`  ，才能成功
- `docker images`   进行测试

---

- 其中，usermod  命令，help中明确说明了，-g 以及-G的含义
  - `  -g, --gid GROUP               force use GROUP as new primary group`  
  - `  -G, --groups GROUPS           new list of supplementary GROUPS`  新的补充清单 

2. 查看容器的运行时日志，`docker logs --tail=100 -f process_exporter`   表示从第100行开始

## 本地用数据库

1. DBeaver community 数据库连接工具，数据库地址172.17.0.1:3306 

- 其实也就是映射到本地端口的

2. 

## 使用harbor 搭建私仓

### 常用命令

- harbor的生命周期管理，可以使用docker-compose 来管理，需要在harbor目录中执行
- docker-compose，可以轻松、高效的管理容器，它是一个用于定义和运行多容器docker的应用程序工具。我说怎么有点熟悉。
  - docker compose  是单机管理docker的。k8s是多节点管理docker。虽然还有docker swarm也是多节点，不过基本已弃用

1. 启动：`docker-compose start`   
   1. `docker-compose up -d`  Create and start containers
2. 停止：`docker-compose stop`  
3. 移除：`docker-compose rm `  会保留相关镜像文件
   1. `rm -r /data/database `  `rm -r /data/registry`  删除数据
4. `docker-compose ps`  查看容器状态
5. `docker-compose down`  会删除容器，Stop and remove containers, networks, images, and volumes
   1. 删除后，`docker-compose ps `  你就看不到任何容器了。重新  `./install.sh`  重新安，



### 搭建

- 步骤，:chestnut:  

```bash
##################### 创建CA私钥
openssl genrsa -out ca.key 2048
##################### 制作CA公钥
openssl req -new -x509 -days 36500 -key ca.key -out ca.crt -subj "/C=CN/ST=BJ/L=BeiJing/O=BTC/OU=MOST/CN=liuzel01/emailAddress=ca@sipingsoft.com"
##################### 创建私钥
openssl genrsa -out httpd.key 1024
##################### 生成签发请求 
openssl req -new -key httpd.key -out httpd.csr -subj "/C=CN/ST=BJ/L=BeiJing/O=BTC/OU=OPS/CN=liuzel01/emailAddress=liuzel01@sipingsoft.com"
##################### 使用CA证书进行签发
openssl x509 -req -sha256 -in httpd.csr -CA ca.crt -CAkey ca.key -CAcreateserial -days 36500 -out httpd.crt
##################### 验证签发证书是否有效
openssl verify -CAfile ca.crt httpd.crt
##################### 最后，会显示： httpd.crt: OK
```

1. 

###### 安装docker-ce

1. 

```bash
[root@master harbor]# docker --version
Docker version 19.03.13, build 4484c46d9d
```



###### 安装docker-compose

1. 

```bash
[root@master harbor]# docker-compose --version
docker-compose version 1.18.0, build 8dd22a9
```



###### 安装harbor私仓

1. 下载地址，[官网](https://github.com/goharbor/harbor/releases/download/v2.0.4-rc1/harbor-offline-installer-v2.0.4-rc1.tgz)，  





- 参考，[harbor介绍与企业级私有docker镜像仓库搭建](https://cloud.tencent.com/developer/article/1718372)，  

- 参考，[使用harbor搭建docker私仓](https://www.jianshu.com/p/e896a2c7b975)，  [docker compose详解](https://www.jianshu.com/p/658911a8cff3)，  

# prometheus--监控系统

## docker 部署

1. `docker run -d -p 9090:9090 -v /opt/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml  -v /opt/prometheus/rules/node_alerts.yml:/etc/prometheus/rules/node_alerts.yml  --name prometheus -v /etc/localtime:/etc/localtime:ro --hostname prometheus prom/prometheus`   注意宿主机和容器内的时区

- 还可以指定本地数据存储的路径

2. `docker run -d -p 9100:9100 -v "/proc:/host/proc:ro" -v "/sys:/host/sys:ro" -v "/:/rootfs:ro" --net="host" --name node_exporter prom/node-exporter`   

- `curl 127.0.0.1:9100/metrics`   访问获取的指标

3. `docker run -d -p 9256:9256 --privileged -v /proc:/host/proc -v /opt/prometheus/process_exporter:/config --name process_exporter ncabatoff/process-exporter -config.path /config/config.yml  --procfs /host/proc  `   

- 有啥问题，直接[官网走起](https://github.com/ncabatoff/process-exporter)  

4. ` docker run -d -p 3000:3000 -v /opt/grafana-storage:/var/lib/grafana    --name grafana grafana/grafana`   

- <u>注意本机 /opt/grafana-storage 的权限，对于组外人的权限w</u>  

```yaml
prometheus.yml		# 注释部分都省略了
# my global config
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093
# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
  - "rules/node_alerts.yml"
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: 'prometheus'
  - job_name: '西藏项目_Linux'
    static_configs:
    - targets: ['192.168.10.167:9100','221.236.26.xx:9100']
  - job_name: '进程监控_linux'
    static_configs:
    - targets: ['192.168.10.167:9256','221.236.26.xx:9256']

  - job_name: '西藏项目_WinServer'
    static_configs:
    - targets: ['221.236.26.xx:9182']
```



---



1. 注意的是，prometheus.yml 文件中，如果监控本机，为了**避免问题**，写本机IP,否则在 prometheus/targets 页面会跳转不到metrics指标页面 那里

- 当然，很可能是 /etc/hosts 文件中的，主机名ip的对应没有配好！！！

2. 

## prometheus的联邦集群支持

1. 



## PrmQL探索

1. ###### 参考，[彻底理解Prometheus查询语法](https://blog.csdn.net/zhouwenjun0820/article/details/105823389) ， [大神的prometheus-book](https://yunlzheng.gitbook.io/prometheus-book/parti-prometheus-ji-chu/quickstart/why-monitor),  



## 四个黄金指标

Four Golden Signals 是google针对大量分布式监控的经验总结。可以在服务级别帮助衡量终端用户体验/服务中断/业务影响等层面的问题。参考上面的[prometheus-book](https://yunlzheng.gitbook.io/prometheus-book/parti-prometheus-ji-chu/promql/prometheus-promql-best-praticase),  

1. 延迟：服务器请求所需时间
2. 通讯量：监控当前系统的流量，用于衡量服务的容量需求
3. 错误：监控当前系统所有发生的错误请求，衡量当前系统错误发生的速率
4. 饱和度：衡量当前服务的饱和度

---

1. 参考，[10个常用监控k8s性能的prometheus oprtator指标](https://mp.weixin.qq.com/s/idQgb0GC2yhaVYwgGj5gcA)，  



## FAQ

1. ~~有个问题：~~  

- ~~docker部署的process_exporter，可以获取到指标数据，但是 在使用grafana 相应的仪表盘监控时，发现不到本机的process~~  
- 解决了！因为容器内的配置文件，并未生效。参考上面运行process_exporter的命令，以及github上README

2. 

## 杂项

1. 几款比较好的dashboard,去[官网copy id即可](https://grafana.com/grafana/dashboards)，  

- windows的表盘，windows_exporter for prometheus，id 10467

- linux的，node_exporter for prometheus, id 8919
  - system processes metrics, id 8378

2. 

### 优势-与常见监控的比较

1. 参考，上面的[prometheus-books](https://yunlzheng.gitbook.io/prometheus-book/parti-prometheus-ji-chu/promql/prometheus-promql-best-praticase),  

## 使用go编写exporter！！！！！

- 参考，[使用Go开发prometheus exporter](https://mp.weixin.qq.com/s/s1nSaC-8ejvM342v5KPdxA)，  

1. 丿

# ansible 笔记

1. `ansible centos_server -m ping `  在尝试连接过程中，会提示，**Permission denied (publickey,gssapi-keyex,gssapi-with-mic)** ，

- 修改 sshd_config 配置，增加，`PasswordAuthentication yes`   

## ansible配置优化

##### 开启SSH长连接，

- `vim  /etc/ansible/ansible.cfg `   `ssh -V`   查看主机上ssh的版本，高于5.6则可以直接添加如下

```
[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=5d
```

- 表示设置整个长连接的保持时间，这里设置的是5天。
- 通过 `netstat | grep container`   能看到会有一个ESTABLISHED状态的连接一直与远端设备进行TCP连接

<img src="../images/centos7_docker_ansible_ssh.png"/>

2. 如果要达到ssh长连接的目的，也可修改主机（控端/中控机）的sshd_config  配置，（没尝试）

```
ServerAliveInterval 30
ServerAliveCountMax 3
ControlMaster auto
ControlPath ~/.ssh/sockets/%r@%h-%p
ControlPersist 5d
```

---

##### 开启pipelining

- pipelining 也是openssh的一个特性，

1. ansible执行流程是这样的，	`▶ ansible centoslzl -m ping  -vvv`  结合命令来看更好看

- 基于调用的模块生成一个python脚本
- 将python复制到主机上
- 最后，在远端服务器上执行此python脚本

2. 同样是在 ansible.cfg  文件中，

```
[ssh_connection]	同样是此节点下
pipelining = True
```

3. 再次执行命令，能观察到打印出来的更少了，

- 少了一个PUT脚本和SFTP脚本去远端server的流程

##### ~~开启accelerate模式~~  

- 和SSH Multiplexing功能类似，accelerate 是使用python在远端server 运行一个守护进程，然后ansible通过这个守护进程监听的端口进行通信
- redhat官方目前不赞成使用accelerate模式，后面的版本中可能要被删除。:seedling:  

1. 需要中控机和远端server都安装 python-keyczar软件包

- `▶ ansible centoslzl -a 'yum install -y python-pyasn1 python python-crypto`  
- `  rpm -ivh ftp://ftp.ntua.gr/pub/linux/centos/7.8.2003/cloud/x86_64/openstack-queens/Packages/p/python-keyczar-0.71c-2.el7.noarch.rpm`  注意，这是centos7 的，如果是其他版本，需要自己识别
- 完成安装后，对 ansible.cfg 进行配置，

```
[accelerate]
accelerate_port = 5099
accelerate_timeout= 30
accelerate_connect_timeout= 5.0
```

##### 修改ansible执行策略

- 有个参数，默认值如下，修改修改成free  

```
# Ansible will use the 'linear' strategy but you may want to try another one.
#strategy = linear
strategy = free,	# 修改成free,
```

1. 默认值是linear,即按批次并行处理；  free 表示的是ansible会尽可能快的切入到下一个主机。所以在执行结果的task 显示顺序就不一样，也就可以理解了
2. playbook中的设置，

```
---
- hosts: all
   strategy: free
tasks:
...
```

##### 任务执行优化

- async，代表这个任务执行时间的上限值，即任务执行时间如果超出这个时间，则认为任务失败。
- 参数async未设置，则为同步执行。可以为执行时间非常长（有可能遭遇超时）的操作使用异步模式
- 为异步启动一个任务，可指定其最大超时时间以及轮询其状态的频率，如若没有为poll指定值，默认轮询频率10s

```
---
  - hosts: all
   remote_user: root
   tasks:
      - name: simulate long running op (15 sec), wait for up to 45 sec, poll every 5 sec
      command: /bin/sleep 15
      async: 45
      poll: 5
```

1. 有以下场景需要使用ansible的异步模式

- 某个tash需要运行很长时间，可能会达到ssh连接的timeout
- 没有任务是需要等待它才能完成的，即没有任务依赖此任务是否完成的状态
- 需要尽快返回当前shell的

2. 一些不适合使用异步模式的

- 这个任务需要运行完后，才能继续另外任务的
- **申请排他锁的任务（如yum）**  



##### 设置facts 缓存

- 在使用ansible-playbook 时，默认第一个task都是 GATHERING FACTS，表示 收集每台主机的facts信息，方便在playbook中直接引用facts里的信息。如若不需要facts的信息，可以在playbook 设置 

  `gather_facts: false`   提高playbook 效率

```
---
- hosts: 10.0.108.2
gather_facts: no
tasks:
...
```

- 也可以在 ansible.cfg  文件中添加如下配置，禁用facts采集

```
[defaults]
gathering = explicit
```

###### json文件缓存facts信息

###### redis缓存facts信息 

###### memcache缓存facts信息

- **未实践！！！**  

## ansible的日常维护使用

##### 利用ssh-agent提升ansible管控的安全性

- 可参考，[使用ssh和ssh-agent实现无密码登陆远程server](http://yysfire.github.io/linux/using-ssh-agent-with-ssh.html)，  



##### 配置ansible 变量环境

1. 编辑 /etc/profiles ，新增一行，`export ANSIBLE_CONFIG=/etc/ansible/ansible.cfg `  

2. 编辑 /etc/ansible/ansible.cfg  文件

```
[defaults]							# 此处只列出了defaults下的配置
inventory = /etc/ansible/hosts    	#主机列表配置文件
library = /usr/share/ansible/    	#库文件存放目录
remote_tmp = $HOME/.ansible/tmp   	#临时py命令文件存放在远程主机目录
local_tmp = $HOME/.ansible/tmp    	#本机的临时命令执行目录
forks = 50     						#默认并发数
sudo_user = root    				#设置默认执行命令的用户，root,可在playbook中重新指定该参数
# ask_sudo_pass = True    			#每次执行ansible命令是否询问ssh密码
# ask_pass = True
remote_port = 22    
# module_lang = C						#设置模块的语言
private_key_file = /root/.ssh/id_rsa	#设置中控机连接客户端的私有ssh-key文件位置
host_key_checking = False   		#检查对应服务器的host_key，建议取消注释，否则就得先一个一个主机连一次
timeout = 60						#设置ssh连接超时时间，单位s
log_path = /var/log/ansible.log   	#日志文件，也是建议取消注释
```

- 可参考，[ansible自动化运维体系在生产环境下实践](https://mp.weixin.qq.com/s?__biz=MjM5NTk0MTM1Mw==&mid=2650634947&idx=2&sn=6e7e72a60fba85ca7f044cd0a258c406&chksm=bef90445898e8d532b95b511810c19a116bf849b644b0fa0d4fa148fa8502e0cc81941225caf&scene=21#wechat_redirect)，  [语雀上ansible](https://www.yuque.com/liuzelin01/linux/linux-ansible#tMKYg)，  

---

##### 配置ansible客户端主机环境

1. 编辑  /etc/ansible/hosts 文件，按照如下格式添加控端

```
[业务系统名称代码_x86]
ip x.x.x.x
[业务系统名称代码_aix]
ip x.x.x.x
```

2. 这样可以区分不同业务系统，不同操作系统类别，

- `ansible 业务系统名称代码* -m module_name -a module_args`  
- `ansible 业务系统名称代码*_x86 -m module_name -a module_args `  

- `ansible *x86 -m module_name -a module_args `

##### 配置ansible ssh 通信

1. `ssh-keygen`  ,生成ssh public 和 private key
2. `for i in $ `cat /tmp/ansible_docker.txt`;do ssh-copy-id root@$i;done`  ，也可以写进脚本执行

- 这个时候需要输入密码，来建立互信过程。。
- **应该可以在脚本中，自动写密码的！！！！**  

##### 常用模块

1. 建议命令，`ansible-doc file`  这里面的都是-a 中可以跟的相关选项，

- 创建文件符号链接，`ansible centoslzl -m file -a 'src=/etc/resolv.conf dest=/tmp/resolv.conf state=link'`  

2. copy：复制文件到远程主机，

- 将本地文件复制到客户端，`ansible centoslzl -m copy -a 'src=/etc/ansible/ansible.cfg dest=/tmp/ansible.cfg owner=root group=root mode=0644'`  

3. command：在远程主机执行命令，因为默认就是command,所以`ansible centoslzl -a 'date' `  
4. shell：参数与上相同，不过可以用管道
5. service,cron,yum,synchronize,user,group
6. `ansible all -a 'hostname' `  

---

##### ansible tower（企业级的ansible）

1. ansible,简单学习一下yaml语法，jinja2语法，能懂得python代码用于分析问题就行。

- 熟练掌握python的话，都不是问题，ansible的一切都可以通过python来解释。

## 演练

1. **开始吧，展示！！！**  













# jenkins

## FAQ

##### active(exited)

1. `systemctl restart jenkins `   启动后不报错，看日志也未打印出，

- `systemctl status jenkins `   查询状态，同时刷新网页，一会就变成 active(exited)  了

---



1. 解决办法：

- 给用户jenkins授权，
  - `chown -R jenkins: /var/lib/jenkins`  
  - `chown -R jenkins: /var/cache/jenkins`  
  - `chown -R jenkins: /var/log/jenkins `
- 重启，并刷新网页  



# golang

## 国内go get无法下载的问题，

- `go get github.com/joho/godotenv`  下载总是超时  i/o timeout,

1. 解决方法：

- 使用国内七牛云或是阿里云的镜像仓库，
- `go env -w GO111MODULE=on`  `go env -w GOPROXY=https://goproxy.cn,direct`  
- 再次使用go get就可以了

2. 参考，[golang 1.13解决go get无法下载](https://www.sunzhongwei.com/problem-of-domestic-go-get-unable-to-download?from=sidebar_new)，  https://github.com/goproxy/goproxy.cn

---





# 技巧技巧 :medal_sports:  

## PC和手机快速文件传输

1. 使用python3的模块，`python3 -m http.server`   
2. 如果希望换个端口，`python3 -m http.server 1234 --bind 127.0.0.1`   绑定后就不能用本机ip访问
3. 可以不使用weixin等第三方工具，随时随地传

## 其他

1. `yay -S vnstat`   安装vnstat,监控网络流量

- 

# FAQ

1. 

