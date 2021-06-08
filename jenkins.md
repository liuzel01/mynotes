> 此文件用作记录，jenkins遇到的一些问题

##### 环境变量

- 感觉还是用服务器本机上的环境变量比较好。用jenkins自动安装的，那是jenkins自己的一套变量

##### 更换jenkins的源,

- 编辑 /home/jenkins_home/updates/default.json
- `sed -i 's#http:\/\/updates.jekins-ci.org\/download#https:\/\/mirrors.ustc.edu.cn\/jenkins#g' default.json && sed -i '#/http:\/\/www.google.com#https:\/\/www.baidu.com#g' default.json`

在Dashboard-插件管理-高级-升级站点，改成中文社区的URL
    输入这个[地址](https://mirrors.ustc.edu.cn/jenkins/updates/update-center.json)，或是http://mirrors.ustc.edu.cn/jenkins/updates/update-center.json

- 中文社区,[镜像地址](https://jenkins-zh.cn/tutorial/management/plugin/update-center/)

##### jenkins时间，

1. 运行job时fld-linux间和系统时间不一致
2. 在“系统管理”-“脚本命令行”，运行命令，

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

#### 深信服EasyConnect

centos7 使用深信服（ EasyConnect ）连接客户vpn，访问到内网服务器，并准备后续的配置jenkins

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

##### xdotool 实现每日重启并登录

- 隔了几天，回头再解决此问题。google大神有提到用xdotool来做桌面软件 自动登录的。 也算是有了点头绪

1. xdotool，可用于获取鼠标坐标，模拟鼠标（实际上是指针）移动和点击动作，获取窗口焦点等

- 开始操作

首先，装了桌面化后，centos7 里的easyconnect 是酱婶的，

![image-20210608110426608](https://gitee.com/liuzel01/picbed/raw/master/data/20210608110426_jenkins_EasyConnect_home.png)

1. 首选获取指针位置， `xdotool getmouselocation` 
   1. 结果类似  x:654 y:417 screen:0 window:35663115， 可以得到x 坐标，y 坐标
2. 模拟指针移动到输入框，xdotool mousemove ${MOUSE_X} ${MOUSE_Y}
3. 模拟指针点击， xdotool click 1  目前这几个指令就够完成此脚本
4. 脚本可参考仓库内的，less /home/lzl/command-file/shellInstall/check_Easycont.sh
5. 最后，测试脚本可用之后，写入定时任务，每天8:20 实现自动重启vpn强制刷新连接时间  :laughing: 
   1. 20 8 * * *    sh /home/backup/restart_Easycont.sh



- 可用于参考，

1. [一种自动登录EasyConnect的思路](https://zhuanlan.zhihu.com/p/339953626)，[xdotool一个神器](https://www.cnblogs.com/winafa/p/14230029.html)，  [use xdotool to stimulate mouse clicks and ketstrokes in linux](https://linuxhint.com/xdotool_stimulate_mouse_clicks_and_keystrokes/), 

#### jenkins报错

- （准确的说，是jenkins打完了包，在远程服务器上运行时报错）

1. 报错内容，

```txt
Caused by: org.springframework.beans.factory.UnsatisfiedDependencyException: Error creating bean with name 'soneTokenService': Unsatisfied dependency expressed through field 'tokenStore'; nested exception is org.springframework.beans.factory.BeanCurrentlyInCreationException: Error creating bean with name 'tokenStore': Requested bean is currently in creation: Is there an unresolvable circular reference?
```

- 将对应的job重新建一次，

1. 注意，在 /etc/resolv.conf DNS文件添加，nameserver 61.139.2.69

#### active(exited)

1. `systemctl restart jenkins `   启动后不报错，看日志也未打印出，

- `systemctl status jenkins `   查询状态，同时刷新网页，一会就变成 active(exited)  了

- 解决办法：

1. 给用户jenkins授权，

- `chown -R jenkins: /var/lib/jenkins`  
- `chown -R jenkins: /var/cache/jenkins`  
- `chown -R jenkins: /var/log/jenkins `

2. 重启，并刷新网页



#### 打包失败（缺少依赖）

- 描述：~~之前打包都是打的jar包，这次是war包~~，

1. 可能和这没关系。jenkins页面报错，如下

```txt
[ERROR] Failed to execute goal on project hrFile: Could not resolve dependencies for project com.springboot:hrFile:war:0.0.1-SNAPSHOT: Failure to find net.sf.json-lib:json-lib:jar:JDK15:2.4 in http://192.168.10.68:8081/nexus/content/groups/public/ was cached in the local repository, resolution will not be reattempted until the update interval of nexus has elapsed or updates are forced -> [Help 1]
[ERROR] 
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
[ERROR] 
[ERROR] For more information about the errors and possible solutions, please read the following articles:
[ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/DependencyResolutionException
```

2. 后，我在服务器上直接手动打包，仍然是相类似的报错，如下
   1. `/var/jenkins_home/apache-maven-3.6.3/bin/mvn clean`
   2. `/var/jenkins_home/apache-maven-3.6.3/bin/mvn clean install`
   3. `/var/jenkins_home/apache-maven-3.6.3/bin/mvn -X`

![image-20210607110908315](https://gitee.com/liuzel01/picbed/raw/master/data/20210607110910_jenkins_mvn-X.png)

3. 然后，最开始还有报错提示，[gemfire-8.2.4.jar](http://192.168.10.68:8081/nexus/content/groups/public/com/gemstone/gemfire/8.2.4/gemfire-8.2.4.jar), 
   1. <font color=red>**同时，必须仔细看打印出来的报错信息，会提示你 在download 某依赖时所请求的地址**</font> 

- 解决：

1. 缺少的依赖包，需要找研发给，然后上传到nexus对应的目录下。
   1. 目录可以根据文件，json-lib-2.4.pom 来查看，也可以上传的时候，指定 pom 文件
   2. 我这里的 pom 文件中的内容是酱婶滴，

```
<dependency>
	<groupId>net.sf.json-lib</groupId>
	<artifactId>json-lib</artifactId>
	<version>2.4</version>
	<classifier>JDK15</classifier><!-- json-lib提供了两个jdk版本的实现， json-lib-2.1-jdk13.jar和json-lib-2.1-jdk15.jar -->
</dependency>
```

![image-20210607113015978](https://gitee.com/liuzel01/picbed/raw/master/data/20210607113016_jenkins_mvn_nexus_upload.png)



2. 在之前的报错中，已知请求的下载路径，是  http://192.168.10.68:8081/nexus/content/groups/public/net/sf/json-lib/json-lib/2.4/json-lib-2.4-JDK15.jar
   
1. 然后，上传后，可以在对应路径进行查找，注意jar包大小写也要对，不可为  http://192.168.10.68:8081/nexus/content/groups/public/net/sf/json-lib/json-lib/2.4/json-lib-2.4-jdk15.jar
   
3. 在生效前，需要 <font color=red>**强制更新maven缓存库**</font>

   1. `/var/jenkins_home/apache-maven-3.6.3/bin/mvn dependency:purge-local-repository`
   2. `/var/jenkins_home/apache-maven-3.6.3/bin/mvn dependency:resolve -U`
   3. [maven类包冲突终极三大解决技巧](https://blog.csdn.net/sun_wangdong/article/details/51852113) 

4. 最后，clean ; clean install 进行打包验证

   打印记录，如下

   ```txt
   [INFO] Building hrFile 0.0.1-SNAPSHOT
   [INFO] --------------------------------[ war ]---------------------------------
   [INFO] 
   [INFO] --- maven-clean-plugin:2.6.1:clean (default-clean) @ hrFile ---
   [INFO] 
   [INFO] --- maven-resources-plugin:2.6:resources (default-resources) @ hrFile ---
   [INFO] Using 'UTF-8' encoding to copy filtered resources.
   [INFO] Copying 1 resource
   [INFO] Copying 36 resources
   [INFO] 
   [INFO] --- maven-compiler-plugin:3.1:compile (default-compile) @ hrFile ---
   [INFO] Changes detected - recompiling the module!
   [INFO] Compiling 341 source files to /var/jenkins_home/workspace/sp-capital-mgment/target/classes
   Downloaded from nexus:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   ...skipping...
   [INFO] Packaging webapp
   [INFO] Assembling webapp [hrFile] in [/var/jenkins_home/workspace/sp-capital-mgment/target/hrFile-0.0.1-SNAPSHOT]
   [INFO] Processing war project
   [INFO] Copying webapp resources [/var/jenkins_home/workspace/sp-capital-mgment/src/main/webapp]
   [INFO] Webapp assembled in [2442 msecs]
   [INFO] Building war: /var/jenkins_home/workspace/sp-capital-mgment/target/hrFile-0.0.1-SNAPSHOT.war
   [INFO] 
   [INFO] --- spring-boot-maven-plugin:1.5.7.RELEASE:repackage (default) @ hrFile ---
   基本上下面就输出正确结果了
   ```

