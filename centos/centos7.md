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

- 其实也就是映射到本地了的

2. 

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

##### 开启accelerate模式

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

- 



























# 技巧技巧 :medal_sports:  :spon

## PC和手机快速文件传输

1. 使用python3的模块，`python3 -m http.server`   

2. 如果希望换个端口，`python3 -m http.server 1234 --bind 127.0.0.1`   绑定后就不能用本机ip访问
3. 可以不使用weixin等第三方工具，随时随地传

# FAQ

1. 

