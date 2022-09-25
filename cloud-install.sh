#!/bin/bash

#导入环境变量
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/bin:/sbin
export PATH

#检查并安装Docker
function check_docker(){
	echo '-------------------------------------------'
	docker_path=$(which docker)
	if [ -e "${docker_path}" ]
	then
		echo 'Docker已安装，继续执行'
	else
		read -p "Docker未安装，是否安装Docker?(y/n):" is_docker
		if [ $is_docker == 'y' ]
			then
				curl -fsSL https://get.docker.com -o get-docker.sh
				sh get-docker.sh
			else
				echo '放弃安装！'
				echo '-------------------------------------------'
				exit
		fi
	fi
	#启动docker
	systemctl start docker
	echo '-------------------------------------------'
}

#安装前的准备
function ready(){
	#创建用户和用户组
	groupadd www
	useradd -M -g www www -s /sbin/nologin
	#CentOS
	if [ -e "/usr/bin/yum" ]
	then
		yum -y update
		yum -y install unzip wget
	else
		#更新软件，否则可能make命令无法安装
		apt-get update
		apt-get install -y unzip wget
	fi
}
#默认安装端口
nport=1080
#安装Zdir
function install_zdir(){
	echo '-------------------------------------------'
	read -p "请输入网盘安装目录（如果留空，则默认为/data/wwwroot/default）:" zdir_path
	#如果路径为空
	if [ -z "${zdir_path}" ]
	then
		zdir_path='/data/wwwroot/default'
	fi
	echo '-------------------------------------------'
	read -p "请输入网盘服务端口（如果留空，则默认端口为$nport）:" port
	    if [[ ! -n "$port" ]]; then
        port=$nport
    fi
	#创建目录
	mkdir -p $zdir_path
	#下载源码
	wget -O ${zdir_path}/cloud.zip https://raw.githubusercontent.com/jellyfina/onekey/main/cloud.zip
	#进入目录
	cd $zdir_path
	unzip -o cloud.zip
	mv zdir-master zdir
	rm -rf zdir-master
	rm -rf cloud.zip
	#重命名配置文件
	cp ${zdir_path}/zdir/config.simple.php ${zdir_path}/zdir/config.php
	#设置读取的路径
	sed -i "s%\"thedir.*%\"thedir\"=>'/data/wwwroot/default',%g" ${zdir_path}/zdir/config.php
	echo '-------------------------------------------'
	#设置文件管理器密码
	read -p "请设置文件管理器密码:" zdir_pass
	#如果密码为空，循环让用户输入
	while [ -z "${zdir_pass}" ]
	do
		read -p "请设置文件管理器密码:" zdir_pass
	done
	#设置密码
	sed -i "s/\"jellyfin\"/\"${zdir_pass}\"/g" ${zdir_path}/zdir/config.php
	#设置用户组权限
	chown -R www:www $zdir_path
}
#自动放行端口
function chk_firewall(){
	if [ -e "/etc/sysconfig/iptables" ]
	then
		iptables -I INPUT -p tcp --dport $port -j ACCEPT
		service iptables save
		service iptables restart
	elif [ -e "/etc/firewalld/zones/public.xml" ]
	then
		firewall-cmd --zone=public --add-port=$port/tcp --permanent
		firewall-cmd --reload
	elif [ -e "/etc/ufw/before.rules" ]
	then
		sudo ufw allow $port/tcp
	fi
}

#运行容器
function zdir_run(){
	docker run --name="zdir"  \
    -d -p $port:80 --restart=always \
    -v ${zdir_path}:/data/wwwroot/default \
    jellyfina/zdir \
    /usr/sbin/run.sh

	#内网ip地址获取
ip=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)

#外网IP地址获取
address=$(curl https://ipip.ooo)

    echo '-------------------------------------------'
    echo '外网请访问 http://'${address}:$port
    echo '内网请访问 http://'${ip}:$port
    echo '安装路径为:'${zdir_path}
    echo '用户名为:admin,密码为:'${zdir_pass}
    echo '-------------------------------------------'
}

check_docker
ready
install_zdir
chk_firewall
zdir_run
