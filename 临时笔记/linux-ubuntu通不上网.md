- 首先检查网卡状态，

1. no carrier  注意下面的网卡eno1 状态，
   1. 此机器有两张网卡，enp14s0 明显没有插上网线，并且并未启用。
   2. 因此，要首先确保硬件（网线）部分没问题。
   3. 并且，确保网线所插网口、和启用的网卡是一致的。接下来，才是从软件（服务）方面来配置网络。

![12312132](https://gitee.com/liuzel01/picbed/raw/master/data/20211021211625_linux_network_ip2.png) 

2. `systemctl status NetworkManager `  推荐还是使用NetworkManager 比较强大
   1. enable  设置为开机自启
   2. `sudo ip link set eno1 up`  确保网卡启动正确，
   3. 使用NetworkManager 附带的 nmtui 来配置网络信息，
3. nslookup  查询DNS 记录，查询域名解析是否正常
4. 暂时记录于此。后面不知是否还会出问题。。