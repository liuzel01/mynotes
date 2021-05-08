> 此文件用作记录，jenkins遇到的一些问题

##### 环境变量

- 感觉还是用服务器本机上的环境变量比较好。用jenkins自动安装的，那是jenkins自己的一套变量

##### 更换jenkins的源,编辑 /home/jenkins_home/updates/default.json

- `sed -i 's#http:\/\/updates.jekins-ci.org\/download#https:\/\/mirrors.ustc.edu.cn\/jenkins#g' default.json && sed -i '#/http:\/\/www.google.com#https:\/\/www.baidu.com#g' default.json`

在Dashboard-插件管理-高级-升级站点，改成中文社区的URL
    输入这个[地址](https://mirrors.ustc.edu.cn/jenkins/updates/update-center.json)，或是http://mirrors.ustc.edu.cn/jenkins/updates/update-center.json

- 中文社区,[镜像地址](https://jenkins-zh.cn/tutorial/management/plugin/update-center/)

##### jenkins时间， 运行job时fld-linux间和系统时间不一致

1. 在“系统管理”-“脚本命令行”，运行命令，

System.setProperty('org.apache.commons.jelly.tags.fmt.timeZone','Asia/Shanghai')

2. 有时候，会报错，**报错，/lib/ld-linux.so.2: bad ELF interpreter问题**

这个问题，在[centos7.md](./centos7.md) 文件中有说明，在此不赘述

### FAQ

#### 迁移问题

- meeting项目包在10.68上不能打包，提示缺失的jar等依赖，都已从10.15服务器上scp 过来了，重启后，还是报错

1. 特别需要注意maven 的环境变量，

Dashboard-全局工具配置，“Maven配置”和 下面的“Maven”安装，注意指定 MAVEN_HOME，

即时跟踪检查日志。需要注意他调用的mvn 指向，以及调用的配置文件settings.xml

Executing Maven:  -B -f /var/jenkins_home/workspace/meeting-mvn/pom.xml -s /var/jenkins_home/apache-maven-3.6.3/conf/settings.xml -gs /var/jenkins_home/apache-maven-3.6.3/conf/settings.xml clean install

**不知道为什么which mvn,和此时调用的settings.xml文件，不属同一个mvn？？**

2. 解决方法： ...只是将他调用的配置文件，用修改之后的文件，强行替换了

**根源还是没有解决！！！！**

#### centos7使用深信服（ EasyConnect ）连接客户vpn，访问到内网服务器，并准备后续的配置jenkins

EasyConnect 暂不支持centos，（且，使用浏览器登录只能访问WEB资源，只支持简单的静态网页，不推荐admin发布WEB资源~）
    但是，centos安装图形化，通过手动处理，还是可以满足的。且，使用客户端要好一点。
vncserver :1
vncpasswd root
systemctl status EasyMonitor.service
/usr/share/sangfor/EasyConnect/resources/shell/sslservice.sh
/usr/share/sangfor/EasyConnect/EasyConnect --enable-transparent-visuals --disable-gpu
查看日志，tail -f /usr/share/sangfor/EasyConnect/resources/logs/ECAgent.log

或是，可以单纯的在ssh 远程部分，保证能连接到客户内网服务器就行（内网穿透，需保证客户端和服务端能够通信）

---

- 后续进展（即解决方案）

```bash
# 创建jenkins命令、指令， docker-jenkins
docker run --net=host -p 8080:8080 -p 50000:5000 --name jenkins001 --hostname 111 -u root -v /etc/localtime:/etc/localtime -v /home/jenkins_home:/var/jenkins_home --privileged=true -e Java_OPTS=-Duser.timezone=Asia/Shanghai -d jenkins/jenkins:2.271-centos7
或可使用jenkins/jenkins:lts, jenkins/jenkins:2.291-centos7
会提示一句，WARNING: Published ports are discarded when using host network mode 说明端口号可能不必写出来
```

参考，[从docker容器内访问宿主机网络](https://nyan.im/posts/3981.html)
    [docker容器与宿主机同网段互相通信](http://www.louisvv.com/archives/695.html)
    [docker容器间直接路由方式实现互联](https://blog.csdn.net/qq_39626154/article/details/96156205)

#### jenkins报错

- （准确的说，是jenkins打完了包，在远程服务器上运行时报错）

1. 报错内容，

```txt
Caused by: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'soneTokenService': Unsatisfied dependency expressed through field 'tokenStore'; nested exception is org.springframework.beans.factory.BeanCurrentlyInCreationException: Error creating bean with name 'tokenStore': Requested bean is currently in creation: Is there an unresolvable circular reference?
```

- 将对应的job重新建一次，

1. 注意，在 /etc/resolv.conf DNS文件添加，nameserver 61.139.2.69

### active(exited)

1. `systemctl restart jenkins `   启动后不报错，看日志也未打印出，

- `systemctl status jenkins `   查询状态，同时刷新网页，一会就变成 active(exited)  了

- 解决办法：

1. 给用户jenkins授权，

- `chown -R jenkins: /var/lib/jenkins`  
- `chown -R jenkins: /var/cache/jenkins`  
- `chown -R jenkins: /var/log/jenkins `

2. 重启，并刷新网页