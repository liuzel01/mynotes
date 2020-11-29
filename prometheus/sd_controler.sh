#!/bin/bash
#version: 1.0
#Description: add | del | show instance from|to prometheus file_sd_files.
# rl | vl | dk | rw | vw | tcp | http | icmp : short for job name, each one means a sd_file. 
# tcp | http | icmp ( because with ports for service ) add with label (server_name by default) to easy read in alert emails.
# each time can only add|del for one instance. 
#说明：用来添加、删除、查看prometheus基于文件的服务发现中的条目。比如IP:PORT 组合。
# rl | vl | dk | rw | vw | tcp | http | icmp ：这写prometheus job名称的简称，每一项代表一个job，操作一个sd_file 即job文件服务发现使用的文件。
# tcp | http | icmp，由于常常无法根据服务端口第一时间确认挂掉的是什么服务，所以，在tcp http icmp（顺带）添加的时候要求带上server_name的标签label，
#让监控人员收到告警邮件第十时间知道挂掉的是什么服务。
# 每一次只能添加、删除一条记录，如果需要批量添加，可以直接使用vim 文本操作，或者写for 语句批量执行。
### vars
SD_DIR=./prometheus/sd_files
DOCKER_SD=$SD_DIR/docker_host.yml
RL_HOST_SD=$SD_DIR/real_lan.yml
VL_HOST_SD=$SD_DIR/virtual_lan.yml
RW_HOST_SD=$SD_DIR/real_wan.yml
VW_HOST_SD=$SD_DIR/virtual_wan.yml

TCP_SD=$SD_DIR/tcp.yml
HTTP_SD=$SD_DIR/http.yml
ICMP_SD=$SD_DIR/icmp.yml

SDFILE=

### funcs
usage(){
echo -e "Usage: $0 < rl | vl | dk | rw | vw | tcp | http | icmp >  < add | del | show >  [ IP:PORT | FQDN ] [ server-name ]"
echo -e " example: \n\t node add:\t $0 rl add | del 10.10.10.10:9100\n\t tcp,http,icmp add:\t $0 tcp add 10.10.10.10:3306 web-mysql\n\t del:\t $0 http del www.baidu.com\n\t show:\t $0 rl | vl | dk | rw | vw | tcp | http | icmp show."
exit
}

add(){
# $1: SDFILE, $2: IP:PORT
grep -q $2 $1 ||  echo -e "- targets: ['$2']" >> $1
}


del(){
# $1: SDFILE, $2: IP:PORT
sed -i '/'$2'/d' $1
}

add_with_label(){
# $1: SDFILE, $2: [IP:[PROT]|FQDN] $3:SERVER-NAME
LABEL_01="server_name"
if ! grep -q '$2' $1;then
 echo -e "- targets: ['$2']" >> $1
 echo -e "  labels:" >> $1
 echo -e " ${LABEL_01}: $3" >> $1
fi
}

del_with_label(){
# $1: SDFILE, $2: [IP:[PROT]|FQDN]
NUM=`cat -n $SDFILE |grep "'$2'"|awk '{print $1}'`
let ENDNUM=NUM+2
 
sed -i $NUM,${ENDNUM}d $1
}

action(){
if [ "$1" == "add" ];then
 add $SDFILE $2
elif [ "$1" == "del" ];then
 del $SDFILE $2
elif [ "$1" == "show" ];then
 cat $SDFILE
fi
}

action_with_label(){
if [ "$1" == "add" ];then
 add_with_label $SDFILE $2 $3
elif [ "$1" == "del" ];then
 del_with_label $SDFILE $2 $3
elif [ "$1" == "show" ];then
 cat $SDFILE
fi
}

### main code
[ "$2" == "" ] || [[ ! "$2" =~ ^(add|del|show)$ ]] && usage

curl --version &>/dev/null || { echo -e "no curl found. " && exit 15; }

if [[ $1 =~ ^(rl|vl|rw|vw|dk)$ ]] && [ "$2" == "add" ];then
[ "$3" == "" ] && usage
 
if [ "$4" != "-f" ];then
 COOD=`curl -IL -o /dev/null --retry 3 --connect-timeout 3 -s -w "%{http_code}" http://$3/metrics`
 [ "$COOD" != "200" ] &&  echo -e "http://$3/metrics is not arriable. check it again. or you can use -f to ignor it." && exit 11
fi
fi

if [[ $1 =~ ^(tcp|http|icmp)$ ]] && [ "$2" == "add" ];then
[ "$4" == "" ] && echo -e "监听 tcp  http  icmp 服务时必须指明 server-name." && usage
fi

case $1 in
rl)
SDFILE=$RL_HOST_SD
action $2 $3 && echo $2 OK
;;
vl)
SDFILE=$VL_HOST_SD
action $2 $3 && echo $2 OK
;;
dk)
SDFILE=$DOCKER_SD
action $2 $3 && echo $2 OK
;;
rw)
SDFILE=$RW_HOST_SD
action $2 $3 && echo $2 OK
;;
vw)
SDFILE=$VW_HOST_SD
action $2 $3 && echo $2 OK
;;
tcp)
SDFILE=$TCP_SD
action_with_label $2 $3 $4 && echo $2 OK
;;
http)
SDFILE=$HTTP_SD
action_with_label $2 $3 $4 && echo $2 OK
;; 
icmp)
SDFILE=$ICMP_SD
action_with_label $2 $3 $4 && echo $2 OK
;; 
*)
usage
;;
esac