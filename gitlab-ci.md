# gitlab-ci

- 记录下gitlab-ci 实践的操作过程，以及遇到的问题
- 想了想，还是单独列个文档划算。。。

---

## 前期环境准备

- docker创建环境

1. gitlab-ce

```
sudo docker run --detach \
  --hostname gitlab-l01 \
  --publish 443:443 --publish 80:80 --publish 22:22 \
  --name gitlab-l01 \
  --restart always \
  --volume /opt/gitlab/config:/etc/gitlab \
  --volume /opt/gitlab/logs:/var/log/gitlab \
  --volume /opt/gitlab/data:/var/opt/gitlab \
  gitlab/gitlab-ce:latest
```

1. gitlab-runner

```
docker run -it --name gitlab-runner-l01 --restart always \
    -v /srv/gitlab-runner/config:/etc/gitlab-runner \
    -v /var/run/docker.sock:/var/run/docker.sock \
    gitlab/gitlab-runner:latest
```

2. `docker exec -it gitlab-runner-l01 /bin/bash`

3. 创建一个group，user，project，将l01 添加进项目中，并授权为maintainer

4. 然后，用户l01登录，去对应的项目下，拿到 "registration token"

![img](https://gitee.com/liuzel01/picbed/raw/master/data/20210326114428_gitlab_ci_runnertoken.png)

![image-20210326135344896](https://gitee.com/liuzel01/picbed/raw/master/data/20210326135344_gitlab_ci_runnerregist.png)

- 这里填的"tags for the runner(comma-separated)" 没必要写多多，而且这里的tags 在 yml配置文件中还要引用

走完步骤后，在gitlab就能看到有一个runner了，（l01能看到，因为我对他授权了~）

![image-20210326135716454](https://gitee.com/liuzel01/picbed/raw/master/data/20210326135716_gitlab_ci_runnerr.png)

## 操作

- 持续集成工具，大都有类似的结构
  - 一个master监听远程代码库的变动。一旦发生变动，根据预先的配置进行操作
  - 一到多个slave，接受并在执行master分配的工作
- gitlab 与runner 无需部署在同一台机器上，二者只要保持长连接即可

### docker in docker

- 需要挂载docker.sock， 对于Job Container 的镜像来讲，需配置config.toml完成挂载

whereis file: /srv/gitlab-runner/config/config.toml 

![image-20210401140656739](https://gitee.com/liuzel01/picbed/raw/master/data/20210401140656_gitlab_ci_config.png)

- 编写配置， .gitlab-ci.yml 



### example

- 一个工程项目可分为三部分
  - 测试。包括代码静态检查(pylint), 执行单元测试(pytest), 查看覆盖率(coverage)
  - 构建。使用源代码构建 docker image
  - 发布。将新版代码发布到开发环境或生产环境.
- 检查你的 .gitlab-ci.yml 文件正确与否， [validate your configuration](http://192.168.10.27/l01/meet-l02/-/ci/lint)
  - 对配置文件 .gitlab-ci.yml 进行语法验证,
  - To access the CI Lint tool, navigate to CI/CD > Pipelines or CI/CD > Jobs in your project and click CI lint.

<img src="https://gitee.com/liuzel01/picbed/raw/master/data/20210415173907_gitlab_ci_lint.png" alt="image-20210415173906978" style="zoom:80%;" />

- 正常后，在pipeline 发现已成功执行~

<img src="https://gitee.com/liuzel01/picbed/raw/master/data/20210415174419_gitlab_ci_pipeline.png" alt="image-20210415174419178" style="zoom:80%;" />

- 以meeting 为例，
  - build：打包
  - test：沿用上面的
  - deploy：部署、发布

### 直接打包部署

### docker打包部署？？

1. git push 代码后，自动发布release 版本包

---

- 先来讨论下，基础的api姿势~

  - <font color=red>**可以参考postman上面，需要补充过来**</font>

  ```bash
  curl --header "PRIVATE-TOKEN: d-swU128VWosJySssz7u" "http://192.168.10.27/api/v4/projects/5/releases"    实际上，在postman直接GET 方法调用url也可以看到
  curl --header "PRIVATE-TOKEN: d-swU128VWosJySssz7u" "http://192.168.10.27/api/v4/projects/5/releases/jiaoyuju"  OR "http://192.168.10.27/api/v4/projects/5/releases/v3.1-zhujianju"
  
  # create a release
  curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: d-swU128VWosJySssz7u" \
       --data '{ "name": "test-l01", "tag_name": "test-fromBashCurl", "ref":"meeting_standard_v3.1","description": "test-fromBashCurl release-l01", "assets": { "links": [{ "name": "测试用-l01", "url": "http://meeting.sipingsoft.com/apk-static/app-10.1.apk", "filepath": "/binaries/linux-amd64", "link_type":"other" }] } }' \
       --request POST "http://192.168.10.27/api/v4/projects/5/releases"
  
  curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: d-swU128VWosJySssz7u"      --data '{ "name": "测试-温江区", "tag_name": "温江区教育局_v1.1", "ref":"meeting_standard_v3.1","description": "测试-温江区 autorelease-l04\n - 此次release作为测试用xxx\n\n 1. 此次更新解决了xxxx\n2. 修复了xxxx问题\n3. 优化zzzzzz", "assets": { "links": [{ "name": "温江区-v3.1", "url": "http://meeting.sipingsoft.com/apk-static/app-10.1.apk", "filepath": "/binaries/wenjiang_app_stable", "link_type":"other" }] } }'      --request POST "http://192.168.10.27/api/v4/projects/5/releases"
  
  # update a release
  
  
  ```

  - 在每次POST调接口时，可以使用相同的name， tag_name必须不能相同，description、links中的name、url、filepath、link_type可根据版本包需要来变更
  - 









# 补充-参考

1. gitlab+ jenkins 自动触发构建功能。webhooks

​    [gitlab webhook failed](https://github.com/jenkinsci/gitlab-plugin#gitlab-to-jenkins-authentication)

2. 获取gitlab上的release 信息

```bash
curl --header "PRIVATE-TOKEN: kRFPDRmWNRp-kAoia74e" http://192.168.10.27:8000/api/v4/projects/2/releases/xinjinrenda
curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: kRFPDRmWNRp-kAoia74e" \
     --data '{ "name": 新津人大", "tag_name": "xinjinrenda", "description": "Super nice release-新津人大，修复了以下：...", "assets": { "links": [{ "name": "xinjinrenda_v3.0", "url": "http://meeting.sipingsoft.com", "filepath": "/apk/jiaoyu_apk_3.1.apk", "link_type":"other" }] } }' \
     --request POST "http://192.168.10.27:8000/api/v4/projects/2/releases"
```

3. 发布release版本，

   可以用API，看[官方API文档](https://docs.gitlab.com/ee/api/releases/#releases-api)，或是直接web页面上，

   参考[官方文档](https://www.bookstack.cn/read/gitlab-doc-zh/269860#tag-name)

- [docker安装gitlab-runner](https://docs.gitlab.com/runner/install/docker.html#option-1-use-local-system-volume-mounts-to-start-the-runner-container)

- [docker安装gitlab-ce](https://docs.gitlab.com/omnibus/docker/#install-gitlab-using-docker-engine)

- [gitlab-ci& gitlab-runner完整自动化部署](https://zhuanlan.zhihu.com/p/109820989)



## 再一个补充

- push an existing git repository

```bash
cd existing_repo
git remote rename origin old-origin
git remote add origin http://gitlab-l01/root/meet.git
git push -u origin --all
git push -u origin --tags
```

---



- 如果要修改配置，会发现重启后，网页上对应的配置不生效。

1. 注意看文件的注释部分 /var/opt/gitlab/gitlab-rails/etc/gitlab.yml(容器内路径)，有写到:

```
# This file is managed by gitlab-ctl. Manual changes will be
# erased! To change the contents below, edit /etc/gitlab/gitlab.rb
# and run `sudo gitlab-ctl reconfigure`.

意思就是，此配置文件不能通过手动来修改，要改这个文件 /etc/gitlab/gitlab.rb(容器内路径)，添加一行
external_url 'http://192.168.10.27'
```

2. 删除旧的容器，重新创建、启动就好了~
   1. 再 grep 查找下，就没含有gitlab-l01 的文件了

---

