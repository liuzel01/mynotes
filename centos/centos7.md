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



# prometheus--监控系统

1. 

## docker 部署

1. `docker run -d -p 9090:9090 -v /opt/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml  -v /opt/prometheus/rules/node_alerts.yml:/etc/prometheus/rules/node_alerts.yml  --name prometheus --hostname prometheus prom/prometheus`   
2. `docker run -d -p 9100:9100 -v "/proc:/host/proc:ro" -v "/sys:/host/sys:ro" -v "/:/rootfs:ro" --net="host" --name node_exporter prom/node-exporter`   

- `curl 127.0.0.1:9100/metrics`   访问获取的指标

3. `docker run -d -p 9256:9256 -v "/proc:/host/proc:ro" -v "/sys:/host/sys:ro" -v "/:/rootfs:ro" --name process_exporter ncabatoff/process-exporter`   
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
    - targets: ['192.168.10.167:9100','221.236.26.68:9100']
  - job_name: '进程监控_linux'
    static_configs:
    - targets: ['192.168.10.167:9256','221.236.26.68:9256']

  - job_name: '西藏项目_WinServer'
    static_configs:
    - targets: ['221.236.26.70:9182']
```



---



1. 注意的是，prometheus.yml 文件中，如果监控本机，为了**避免问题**，写本机IP,否则在 prometheus/targets 页面会跳转不到metrics指标页面 那里

- 当然，很可能是 /etc/hosts 文件，对ip的对应没有配好！！！



# FAQ

1. 固态硬盘，nvme0n1 可能会出现不稳定的情况，

- 有时候会出现，开机的时候，报错，[failed] failed to mount /boot/efi  ,
- 不过手动重启后，就能重新进去了  :confused::confused:  

