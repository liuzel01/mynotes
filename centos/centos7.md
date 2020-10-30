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
3. 啊啊



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

# 技巧技巧 :medal_sports:  

## PC和手机快速文件传输

1. 使用python3的模块，`python3 -m http.server`   

2. 如果希望换个端口，`python3 -m http.server 1234 --bind 127.0.0.1`   绑定后就不能用本机ip访问
3. 可以不使用weixin等第三方工具，随时随地传

# FAQ

1. 

