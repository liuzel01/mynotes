- 将启动项目脚本设置为开机自启，

1. cd /etc/init.d/		startup.sh		将启动项目的脚本文件，copy到此路径内
2. chmod +x startup.sh                      给脚本添加上可执行权限
3. chkconfig --add startup.sh            将可执行文件，添加进
4. chkconfig startup.sh on                 将可执行文件，设置为开机自启，2,3,4,5 要都为on
5. chkconfig --list                                  检查开机自启的脚本，都有哪些，是否添加上了

- 设置项目备份任务，

1. 项目文件的备份脚本，bak.sh 

```shell
#!/bin/bash
# the directory for story your backup file.you shall change this dir
a=$(ls -l /mnt/data/portal/ |awk '/^d/ {print $NF}')
for i in $a
do
        tar -zcf $i.tar.gz /mnt/data/portal/$i
done
[ $? -eq 0 ] && scp ./*.tar.gz root@116.62.156.142:/mnt/mysql/databak/		# 异地备份
```

2. 项目文件（windows）的备份脚本，backup.bat

```bat
@echo off
set folder_source=D:\03_soft\lzhrsip-hr\data

set folder_to=D:\04_back_file\bakup
echo %folder_name%
"C:\Program Files\7-Zip\7z" a -tzip "%folder_to%\repositories_%Date:/=-%.zip" "%folder_source%"
Pause 		# 最后这行，可去掉
```

- 设置会议系统（windows），启动项目脚本，

```
title meeting

REM 是否静默运行 如需静默运行删除一下四行前面的REM，下面四行是已经去掉REM的效果。静默运行即没有cmd终端。同理，这四行放在其他运行脚本，比如kkfile中也能达到静默运行。
 @echo off
 if "%1" == "h" goto begin
 mshta vbscript:createobject("wscript.shell").run("%~nx0 h",0)(window.close)&&exit
 :begin

java "-Dthin.root=." "-Dthin.offline=true" -jar meeting-standard.jar
⁣
⁣pause
```

