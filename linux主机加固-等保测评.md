##  服务器安全整改（部分）

1. 系统口令复杂度策略不够完善，未设置密码更改周期

  vim /etc/login.defs  # 建议至少每季度更换一次口令；密码不能与账户相同

  PASS_MAX_DAYS  180

  PASS_MIN_DAYS  2

  PASS_MIN_LEN   8

  PASS_WARN_AGE  7

  

  vim /etc/pam.d/system-auth

```
  **#** **尝试次数：5  最少不同字符：3 最小密码长度：8  最少大写字母：1 最少小写字母：3 最少数字：3 密码字典：/usr/share/cracklib/pw_dict**
  password   requisite   pam_cracklib.so retry=5  difok=3 minlen=8 ucredit=-1 lcredit=-3 dcredit=-3 dictpath=/usr/share/cracklib/pw_dict
```



2. 未启动登录失败处理功能，以及超时自动退出功能

  vim /etc/pam.d/system-auth

  auth     required    pam_tally2.so even_deny_root deny=5 unlock_time=600



  vim /etc/profile

  export TMOUT=600  # 用户600秒内用户无操作，即自动断开终端

3. 为防止设备账户权限出现混乱，禁用账户（临时办法）

  usermod -L sync 

  userdel postgres 

  usermod -s /bin/ksh -d /home/z –g developer sam  # 更改用户sam 的登录shell，家目录，所属组



4. chkrootkit 安装使用

  可参考，https://sites.google.com/site/linuxxuexi/wang-luo-an-quan/ru-qin-jian-ce-xi-tong-de-gou-jian-chkrootkit-



5. 为linux系统提供本地镜像备份

6. 系统未设置审计规则
  rpm -qa | grep audit
  如果无法重启，更改auditd.service 此参数 RefuseManualStop=no
  auditctl -w /etc/shadow -p war -k password_file
  auditctl -w /etc/ -p war
  vim /etc/audit/auditd.conf   log文件最大 8M
  ll /var/log/audit/  查看日志

  参考，[如何审计linux系统的操作行为](https://blog.arstercz.com/how-to-audit-linux-system-operation/#auditd-%E8%AE%B0%E5%BD%95%E6%96%B9%E5%BC%8F) ，
    [auditd-best-practice](https://github.com/Neo23x0/auditd/blob/master/audit.rules) 

## 数据库安全

1. 数据库口令强度过低，且未配置密码复杂度要求

  如果提示EMPTY， 需要安装插插件的，  install plugin validate_password soname 'validate_password.so';

  SHOW VARIABLES LIKE 'validate_password'  # 查看密码策略

  set global validate_password_mixed_case_count=1  # 密码中至少包含大小写字母的总个数，1个

  set global validate_password_number_count=1  # 密码中阿拉伯数字的格式，1个

  set global validate_password_policy=MEDIUM  # 密码的强度验证等级，默认MEDIUM，

  set global validate_password_special_char_count=1  # 密码中包含特殊字符的个数，1个



2. 未设置登录失败策略

  安装插件

  INSTALL PLUGIN CONNECTION_CONTROL SONAME 'connection_control.so';

  INSTALL PLUGIN CONNECTION_CONTROL_FAILED_LOGIN_ATTEMPTS SONAME 'connection_control.so';

  检查登录失败变量，

  SELECT * FROM information_schema.PLUGINS WHERE PLUGIN_NAME like 'connection%';

  show variables like "connection_control%";



3. 安全审计问题

  SHOW variables LIKE'general_log%';  # 检查数据库日志模块的状态，建议值 general_log=ON

  install plugin audit soname 'libaudit_plugin.so';  # 安装插件，检查是否安装并开启了

  SELECT * FROM INFORMATION_SCHEMA.PLUGINS WHERE PLUGIN_NAME='audit_log';

  show variables like '%audit%' \G;

  set global server_audit_logging=on;

  set global server_audit_file_rotate_now=on;