# VMware ESXI

#### 前期准备

VMware_ESXi_7.0.2_17867351_LNV_20210717.iso
VMware-VCSA-all-6.7.0-18485166.iso  （VCSA: VMware vCenter Server Appliance）

1. 部署完成后，

- 网页上登录地址： https://192.168.10.25/ui/#/login 
  - 记录新的SSO域： vsphere.local
    								administrator
          								Siping123!@#
- 创建的VCSA名称：       VMware vCenter Server Appliance
  	  密码：	                  Siping123!@#
- 设备入门页面：		https://192.168.10.40:443
  	跳转页面：		   [前往](https://192.168.10.40/websso/SAML2/SSO/vsphere.local?SAMLRequest=zVRbb5swFP4ryO9gTC4lVkiVNasWqV2zkk3TXiYHThJLYDMfA%2Bm%2FryHJFlVt1ce9mnO%2B6xHT60NZeA0YlFolhAUh8UBlOpdql5Dv61s%2FJtezKYqyqPi8tnv1CH9qQOu5PYW8%2F5CQ2iiuBUrkSpSA3GY8nd%2Ff8SgIeWW01ZkuiDdHBGMd0Y1WWJdgUjCNzGCpcjgkxFEvHLJUwvZi9tZWyCllkyhg4zhgYTAMaQsbRE07%2BIim6QNtsNqDgaDQmXAkt9pk0CtNyFYUCMRbLhLyOxSbyZixK4jyKIN4ux1NNoP8ahCLQRyzUezGcCUQZQP%2FFhFrpw6tUDYhURgxnzE%2FHK7ZiIcTzsZBNBj9It7qZPGTVMfg3stjcxxC%2FmW9Xvmrh3TdAzQyB%2FPVTbsWLg3z4XBAvB%2FnhhwCOffRyzMfb0Kc8yez17OtJe1gzhmXYEUurJjSS74je1TxTuxysdKFzJ4uREQfv4ei0O2NAWGdaWtq6NsrhX0foHuRub%2FtR3nVJYMWlCVeuuo0fatFIbcSzFsn9IZNQk%2FWuLvPXHZB4aWvD4f7EuUE0riVoySnqClb4Y420yXFbA%2BlQCqsNX4PTKOQRTQc0s8HZ6wrHskJ5IDyL0bbtkE7CLTZuYWQ0Z%2F3d2mP5cv%2BZjMXqJvn9qlyAXf0%2FBEUtGJTwNq9vWL4P5K6gAJ2l1Lpy3Jm58O8%2FDHNngE%3D&SigAlg=http%3A%2F%2Fwww.w3.org%2F2001%2F04%2Fxmldsig-more%23rsa-sha256&Signature=5tymw8Nv2V3vOewDrUNgv7I2rtJfTLn4i2h3ql%2F62R7iIZeRdh%2FDfoGT9tYR%2BfgS6u4HWx1wGWjLM%2FBEwGWWCQbJZ8vXwEevTe5eH5TlfRDZxHDjYC3fu2PVBMUhKuN5KIONZbn1PY48CMo9sG0LnhFlRNfhvft3K9BtxeKukgzGxWnaAqCm3vcOzo2mtT58SUJTe%2BrwbORkB0jqxRpQFRhm8fmbpuclmX2x2ZUGrD2IbOKaGMbmNB96EHBUFzSMN5adXxXTw6krJDdKZqh9rsDKRyx9mRbj51pp4ADUk1vRFnSm2S1RlOkohmfvfFTTM%2Bz0vkAWk29fZvZ%2Bdoig9Q%3D%3D) 
  登录账户密码：		administrator@vsphere.local
  					               Siping123!@#

2. 10.40 可以认为是统一管理的一个地方

   10.25，可以对网络、虚拟交换机等信息进行编辑~

   

3. 规则：

- 虚拟机命名规则： 项目名-操作系统名-ip
- 模板命名规则：      tmplt-操作系统名-xCy运存z存储

3. 以模板创建虚拟机：

   很完美，创建了ip为 10.98 的虚拟机， 而且不需要修改mac地址啥的。能够ping通外网~
   从模板， tmplt-c7-8C8G200GB 创建的虚拟机，同样能够ping通外网~
   具体，见下截图

   添加主机：

   ![image-20211108091447684](https://gitee.com/liuzel01/picbed/raw/master/data/20211108091447-VMware-ESXI-%E6%B7%BB%E5%8A%A0%E4%B8%BB%E6%9C%BA.png)

   从模板部署：

   ![从模板部署](https://gitee.com/liuzel01/picbed/raw/master/data/20211108091225-VMware-ESXI-tmplt-c7-8C8G200GB.png)  

#### vmware esxi 自动快照

1. 可以在vCenter -虚拟机-配置，点击"已调度任务"，新建-生成快照

![生成快照路径](https://gitee.com/liuzel01/picbed/raw/master/data/20211109110529VMware-ESXI-%E7%94%9F%E6%88%90%E5%BF%AB%E7%85%A7.png)

2. 接着按照步骤，调度新任务即可~

![调度新任务](https://gitee.com/liuzel01/picbed/raw/master/data/20211109111251-VMware-ESXI-%E8%B0%83%E5%BA%A6%E6%96%B0%E4%BB%BB%E5%8A%A1.png)

3. 然后就创建好拉



1. 可[参考](https://codeantenna.com/a/73I5dhvUMn) 

2. 首先，要启动esxi主机的ssh服务，启动路径如下

![启动ssh服务](https://gitee.com/liuzel01/picbed/raw/master/data/20211109094238-VMware-ESXI-ssh.png) 



#### 通过cVenter Server管理多台ESXI主机

1. [参考地址](https://www.yisu.com/zixun/9271.html) 



#### FAQ

1. VMware Appliance Management访问地址： https://192.168.10.40:5480/configure/#/installer?locale=zh_CN
   	**不要直接进第二阶段**，使用https://VCSAip:5480登录进去，

   ​	将系统名称<font color=red>**photon-machine**</font> ，修改成VCSA的IP地址。(当然可以在第一阶段的时候就把地址填成VCSA的ip)

   ​	然后，点击第二阶段-继续配置vCenter Server
   
2. [VMware-VCSA安装到80%卡住](http://blog.itpub.net/31480736/viewspace-2155743/) 

#### 参考资料

- [无DNS环境下使用IP部署VCSA](https://www.cnblogs.com/itfat/p/15234566.html) 
- [VMware vCenter6.7 添加ESXI主机](https://www.cnblogs.com/aqicheng/p/13537874.html) 
- [VCSA7.0部署](https://little-star.love/posts/4bd44b30/#%E6%B7%BB%E5%8A%A0ESXI) 



> esxi7 许可证 Enterprise Plus
> ------------------许可证分享---------------------
> ESXI 6.7 0A65P-00HD0-3Z5M1-M097M-22P7H
> VCSA 6.7 HG612-FH19H-08DL1-V19X2-1VKND
> vSAN 6.7u3 NF4HH-F1K1Q-488R0-3L954-AF828
> Horizon 7.X 9H0AK-4Y192-H8JAR-0H7R0-1RZJM



