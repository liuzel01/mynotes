# prometheus

## 几个unit file，:chestnut:  

- 如若你是部署服务的话，下面还是有必要参考的
- `cat /usr/lib/systemd/system/prometheus.service`

```bash
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/
After=network.target
[Service]
Type=simple
User=prometheus
ExecStart=/opt/prometheus/prometheus             \
    --config.file=/opt/prometheus/prometheus.yml \
	--web.enable-lifecycle                       \
	--storage.tsdb.path=/opt/prometheus/data     \
	--storage.tsdb.retention=60d
Restart=on-failure
[Install]
WantedBy=multi-user.target
```

- `cat /usr/lib/systemd/system/grafana-server.service`  

```bash
[Unit]
Description=Grafana instance
Documentation=http://docs.grafana.org
Wants=network-online.target
After=network-online.target
After=postgresql.service mariadb.service mysqld.service

[Service]
EnvironmentFile=/etc/sysconfig/grafana-server
User=grafana
Group=grafana
Type=notify
Restart=on-failure
WorkingDirectory=/usr/share/grafana
RuntimeDirectory=grafana
RuntimeDirectoryMode=0750
ExecStart=/usr/sbin/grafana-server                                                  \
                            --config=${CONF_FILE}                                   \
                            --pidfile=${PID_FILE_DIR}/grafana-server.pid            \
                            --packaging=rpm                                         \
                            cfg:default.paths.logs=${LOG_DIR}                       \
                            cfg:default.paths.data=${DATA_DIR}                      \
                            cfg:default.paths.plugins=${PLUGINS_DIR}                \
                            cfg:default.paths.provisioning=${PROVISIONING_CFG_DIR}  

LimitNOFILE=10000
TimeoutStopSec=20

[Install]
WantedBy=multi-user.target
```

- `cat /usr/lib/systemd/system/node_exporter.service`  

```bash
[Unit]
Description=node_exporter
After=network.target
[Service]
Type=simple
User=prometheus
ExecStart=/usr/local/node_exporter/node_exporter
Restart=on-failure
[Install]
WantedBy=multi-user.target
```

- `cat /usr/lib/systemd/system/process_exporter.service`  

```bash
[Unit]
Description=process_exporter
After=network.target
[Service]
Type=simple
User=prometheus
ExecStart=/usr/local/process_exporter/process-exporter -config.path /usr/local/process_exporter/config.yml
Restart=on-failure
[Install]
WantedBy=multi-user.target
```

- 查看 系统上所有已加载的服务，

1. `systemctl --type=service`  --state=active

## docker 部署-作参考

1. `docker run -d -p 9090:9090 -v /opt/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml  -v /opt/prometheus/rules/node_alerts.yml:/etc/prometheus/rules/node_alerts.yml  --name prometheus -v /etc/localtime:/etc/localtime:ro --hostname prometheus prom/prometheus`   注意宿主机和容器内的时区

- 还可以指定本地数据存储的路径

2.`docker run -d -p 9100:9100 -v "/proc:/host/proc:ro" -v "/sys:/host/sys:ro" -v "/:/rootfs:ro" --net="host" --name node_exporter prom/node-exporter`   

- `curl 127.0.0.1:9100/metrics`   访问获取的指标

3.`docker run -d -p 9256:9256 --privileged -v /proc:/host/proc -v /opt/prometheus/process_exporter:/config --name process_exporter ncabatoff/process-exporter -config.path /config/config.yml  --procfs /host/proc`  

- 有啥问题，直接[官网走起](https://github.com/ncabatoff/process-exporter)  

4.`docker run -d -p 3000:3000 -v /opt/grafana-storage:/var/lib/grafana    --name grafana grafana/grafana`   

- <u>注意本机 /opt/grafana-storage 的权限，对于组外人的权限w</u>

- 这部分配置文件，可详见 ./prometheus/

---

1. 注意的是，prometheus.yml 文件中，如果监控本机，为了**避免问题**，写本机IP,否则在 prometheus/targets 页面会跳转不到metrics指标页面 那里

- 当然，很可能是 /etc/hosts 文件中的，主机名ip的对应没有配好！！！

### 记一次实际操作

- 虽然记录可能不全，但是也够了

###### ansible 准备好远程服务器环境

1. `ansible xijia_extra -v -m shell -a 'yum list docker-ce.x86_64 --showduplicates | sort -r'`
2. `ansible xijia_extra -v -m shell -a 'yum list installed | grep docker'`
3. `ansible xijia_extra -v -m shell -a 'yum update docker-ce docker-ce-cli -y'`
4. `ansible java_server -m copy -a 'src=/etc/docker/daemon_bak.json dest=/etc/docker/daemon.json'`

- 此为将pull 下来的镜像重新打标签，然后删除pull 下来的标签。  再一个，我发现服务器上从同一个地方pull下来的镜像，其ID都一样的

1. `ansible xijia_extra -m shell -a 'docker tag 0e0218889c33 node-exporter:harbor_prome && docker rmi docker.mirrors.ustc.edu.cn/prom/node-exporter'`
2.`docker pull 192.168.10.85/prome/blkboxexporter_lzl@sha256:7a88b0ae8f9671eea87baf888050d9db42e45ddeb3bdd43a417a42922b0f51b5`

- 将整个目录拷贝过去，（包括目录下面的文件，适用于已确定好目录，方便后续操作的情况）

1. `ansible xijia  -m copy -a 'src=/opt/blackbox-exporter/config/ dest=/moni/blackbox-exporter/config/'`

###### 下面是，用docker进行部署

1. `docker pull docker.mirrors.ustc.edu.cn/prom/prometheus'`
    1. `docker pull docker.mirrors.ustc.edu.cn/prom/node-exporter`，一般没有的基本可以google了
    2. 在服务端或是在本地pull下来外部网络的镜像，然后tag 并上传到私仓，之后就可以从私仓pull

2. `docker pull 192.168.10.85/prome/cadvisor_lzl@sha256:46d4d730ef886aaece9e0a65a912564cab0303cf88718d82b3df84d3add6885c`
3. `ansible 192.168.10.85 -m shell -a 'docker tag d24b7db72c99 cadvisor:harbor_prome'`
4. `docker rmi 192.168.10.85/prome/cadvisor_lzl@sha256:46d4d730ef886aaece9e0a65a912564cab0303cf88718d82b3df84d3add6885c`

- 上面这几个命令，可以&& 连在一起，ansible直接执行OK

1. 目的是将pull下来的镜像重新tag，然后删除pull下来的原镜像
2. 否则的话，pull 下来的images tag应该是null

- prometheus/grafana/alertmanager，其实装在一个server上就行，只需一个server端

1. blackbox-exporter应该也是，其用到的module 可以参考[官网](https://github.com/prometheus/blackbox_exporter)，

```bash
docker run --name monitor-prometheus --restart always -d -v moni/prometheus:/etc/prometheus/ \
    -v moni/prometheus/db/:/prometheus -p 9090:9090 prom/prometheus \ --config.file=/etc/prometheus/prometheus.yml \
    --web.listen-address="0.0.0.0:9090"\
    --web.console.libraries=/usr/share/prometheus/console_libraries \
    --web.console.templates=/usr/share/prometheus/consoles \
    --storage.tsdb.path=/prometheus \
    --storage.tsdb.retention=30d

docker run --rm -d -p 9115:9115 --name blackbox_exporter -v /moni/blackbox-exporter/config:/config prom/blackbox-exporter:master --config.file=/config/blackbox.yml
```

---

- 开启端口

1. `firewall-cmd --zone=public --add-port=9090/tcp(prometheus) --add-port=9093/tcp(alertmanager) --add-port=9080/tcp --add-port=9115/tcp --add-port=9100/tcp --permanent`
2. `ansible all -m shell -a \
    'systemctl start firewalld && firewall-cmd --zone=public --add-port=9256/tcp --permanent && firewall-cmd --reload && firewall-cmd --list-ports && systemctl stop firewalld '`
3. `ansible all -m copy -a \
    'src=/opt/prometheus/process_exporter/conf.yml dest=/moni/process-exporter/config.yml'`
4. `ansible all -m shell -a \
'docker run -d -p 9256:9256 --privileged -v /proc:/host/proc -v /moni/process-exporter:/config --name monitor-process-exporter process-exporter:harbor_prome -config.path /config/config.yml  --procfs /host/proc'`
5. `ansible xijia_extra -m copy -a 'src=/opt/blackbox-exporter dest=/moni owner=root group=root mode=0775'`
6. `ansible xijia_extra  -m shell -a \
    'docker run -d -p 9115:9115 --name monitor-blackbox-exporter -v /moni/blackbox-exporter/config:/config blkbox-exporter:harbor_prome --config.file=/config/blackbox.yml'`

- blackbox-exporter，貌似只需部署在server端，淦
- 这个文件，可参考我虚拟机的文件
- blackbox，prom官方提供的exporter之一，可提供http、dns、tcp、icmp的监控数据采集，主动监测主机与服务状态
- 应用场景：http测试：定义request header信息；判断http status/ http response header/ http body 内容
    - tcp测试：业务组件端口状态监听；应用层协议定义与监听
    - icmp测试：主机探活机制
    - post测试：接口连通性
    - ssl证书过期时间

- 可参考[网站](https://awesome-prometheus-alerts.grep.to/rules)，有很多写好的规则

```bash
docker run -d --net="host" --pid="host" -v "/:/host:ro,rslave" --name monitor-node-exporter --restart always docker.mirrors.ustc.edu.cn/prom/node-exporter \
    --path.rootfs=/host --web.listen-address=:9100
    1. quay.io/xxx/yyy:zz，也可用国内镜像加速，可写作 docker pull
    2. docker.mirrors.ustc.edu.cn/xxx/yyy:zz，k8s也适用
```

- [官方地址](https://github.com/google/cadvisor)，不用代理，如下折中方案：

1. `ansible xijia_extra -m shell -a 'curl -s https://zhangguanzhang.github.io/bash/pull.sh | bash -s -- gcr.io/google_containers/cadvisor'`

```bash
docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/$(youtDockerRootDir):/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=9080:8080 \
  --detach=true \
  --name=monitor-cadvisor \
  --privileged \
  --device=/dev/kmsg \
  cadvisor:harbor_prome
```

```bash
docker run -d -v moni/grafana-storage:/var/lib/grafana --name=monitor-grafana -p 3010:3000 grafana/grafana
    
注意授权，chmod 777 -R /opt/grafana-storage  
常用模板编号如下：
    node-exporter： cn/8919,en/11074
    k8s: 13105
    docker: 12831
    alertmanager: 9578
    blackbox_exportre: 9965
```

```bash
docker run -it -d --name monitor-alertmanager \
    -v moni/alertmanager/db:/alertmanager \
    -v moni/alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml \
    -v moni/alertmanager/templates:/etc/alertmanager/templates \
    -p 9093:9093 --restart always --privileged=true prom/alertmanager \
    --config.file="/etc/alertmanager/alertmanager.yml" \
    --storage.path="/alertmanager" \
    --web.listen-address=":9093"
```

- <b>注意挂载文件夹和文件的权限，按照上面的写法，是将这些统一放在根目录的 /moni 下的，注意个别系统的分区大小</b>
    - 如果为了安全起见，建议将配置文件放入专门目录中挂载，并在command 中修改启动参数指定配置文件即可

- 在配置prometheus的targets的时候，可以按照同一指标来监测；或是根据ansible/hosts 文件的服务器组来监测。相当于两个维度吧

## prometheus可靠性

- [这个牛批](http://qiankunli.github.io/2020/07/26/prometheus_practice.html#:~:text=%E6%94%B6%E9%9B%86%E5%99%A8%E5%8F%AF%E9%80%89-,%E5%8F%AF%E9%9D%A0%E6%80%A7%E4%B8%8E%E5%8F%AF%E6%89%A9%E5%B1%95%E6%80%A7,-Prometheus%20%E6%9C%AC%E8%BA%AB%E8%87%AA)，

1.[高可用prometheus：thanos实践](https://yasongxu.gitbook.io/container-monitor/yi-.-kai-yuan-fang-an/di-2-zhang-prometheus/thanos)，



## PromQL探索！！！！！

- 参考，[彻底理解Prometheus查询语法](https://blog.csdn.net/zhouwenjun0820/article/details/105823389) ， [大神的prometheus-book](https://yunlzheng.gitbook.io/prometheus-book/parti-prometheus-ji-chu/quickstart/why-monitor),  
  - query language
- 使用到promQL的组件：

1. prometheus server
   client libraries for instrumenting application c7ode
   push gateway
   exporters
   alertmanager

### metric 介绍

- 类型
- label

###### 常用函数

- rate()函数，专门搭配counter 类型数据使用的函数。功能是按照设置一个时间段，取counter 在这个时间段中的平均每秒的增量

1. 如若放一个 guage类型数据（可自由变化），就不好使（展现的曲线就没意义了）
rate(node_network_receive_bytes_total[1m])，加了一层 rate(.[1m]) 表示1min之内，平均每秒钟的增量

2. 在用counter类型数据时，先给加上一个rate() 或 increase()  

- increase()函数。取一段时间增量的总量。不除以总秒数

1. 看频率。如若是5min来取值，rate()可能会出现断链，就应该用increase
2. rate()，适用于CPU/硬盘/IO/网络流量，瞬息万变

- sum()函数。将结果集，总取和

1. sum(rate(node_network_receive_bytes_total[1m])) 加上 by (instance), 可以按照机器名 拆分出一层来
    1.sum() by (cluster_name)， 按照服务器组来进行拆分，cluster集群
    2. ？？？？？？？？ cluster_name 这个标签需要自定义

- topk()。取最高值，根据给定的数字取数值最高>=x 的数值

1. topk(3,rate(node_network_receive_bytes_total[20m]))
2. 因为是取最高值，必然在graph 中显示的采集数据不连贯。一般用作瞬时报警，而不是观察曲线图

###### pushgateway,灵活采集数据、

- 编写shell脚本

- 使用go开发 exporters,如果是工作中真的需要，比如社区的exporters不能满足需求，且对于监控客户端的规范化比较严格。那么可自行开发新的 exporter
    1. 而且，编写一个exporter 要比写一个 pushgateway 要复杂的多

### promQL表达式

## 四个黄金指标

Four Golden Signals 是google针对大量分布式监控的经验总结。可以在服务级别帮助衡量终端用户体验/服务中断/业务影响等层面的问题。参考上面的[prometheus-book](https://yunlzheng.gitbook.io/prometheus-book/parti-prometheus-ji-chu/promql/prometheus-promql-best-praticase),  

1. 延迟：服务器请求所需时间
2. 通讯量：监控当前系统的流量，用于衡量服务的容量需求
3. 错误：监控当前系统所有发生的错误请求，衡量当前系统错误发生的速率
4. 饱和度：衡量当前服务的饱和度

---

1. 参考，[10个常用监控k8s性能的prometheus oprtator指标](https://mp.weixin.qq.com/s/idQgb0GC2yhaVYwgGj5gcA)，  
   1. [高可用prometheus，问题集锦](http://www.xuyasong.com/?p=1921) 

## FAQ

1. ~~有个问题：~~  

- ~~docker部署的process_exporter，可以获取到指标数据，但是 在使用grafana 相应的仪表盘监控时，发现不到本机的process~~  
- 解决了！因为容器内的配置文件，并未生效。参考上面运行process_exporter的命令，以及github上README

---

- 某一次，一直提示报错，level=error ts=2020-12-11T02:21:55.853Z caller=main.go:289 msg="Error loading config (--config.file=/etc/prometheus/prometheus.yml)" err="open /etc/prometheus/prometheus.yml: no such file or directory"

1. 表示找不到文件，发现是/opt/prometheus/ 下的yml 为链接文件，删掉，然后复制一份过来就OK

#### 配置文件详解

1. 在一个job中，应当普遍使用基于文件的服务发现，

##### 报警rules

- 需要自定义报警规则，看[这里](https://yunlzheng.gitbook.io/prometheus-book/parti-prometheus-ji-chu/alert/prometheus-alert-rule)，

##### cadvisor

- cadvisor其实可以看作和node_exporter 类似，作为"监控数据收集器"。收集和导出数据是其强项，而非展示数据
- 最好，是和grafana配合展示

## 杂项

1. 几款比较好的dashboard,去[官网copy id即可](https://grafana.com/grafana/dashboards)，  

- windows的表盘，windows_exporter for prometheus，id 10467

- linux的，node_exporter for prometheus, id 8919
  - system processes metrics, id 8378

#### 优势-与常见监控的比较

1. 参考，上面的[prometheus-books](https://yunlzheng.gitbook.io/prometheus-book/parti-prometheus-ji-chu/promql/prometheus-promql-best-praticase),  
2. [prometheus替代IBM Monitoring（ITM）可行性分析](https://www.talkwithtrend.com/Article/246769)，  

## 使用go编写exporter

- 参考，[使用Go开发prometheus exporter](https://mp.weixin.qq.com/s/s1nSaC-8ejvM342v5KPdxA)，  
