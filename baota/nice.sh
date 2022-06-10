#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

if [ $(whoami) != "root" ];then
	echo -e "\033[31m请使用root权限执行命令！\033[0m"
	exit 1;
fi
if [ ! -d /www/server/panel ] || [ ! -f /etc/init.d/bt ];then
	echo -e "\033[31m未安装宝塔面板\033[0m"
	exit 1
fi 




wget -O nice.tar.gz https://raw.githubusercontent.com/jellyfina/onekey/main/baota/nice.tar.gz -T 10

tar -zxvf nice.tar.gz

mv login.css /www/server/panel/BTPanel/static/css/login.css
mv login.html /www/server/panel/BTPanel/templates/default/login.html
mv bg.jpg /www/server/panel/BTPanel/static/img/bg.jpg
mv phonebg.jpg /www/server/panel/BTPanel/static/img/phonebg.jpg
echo -e "\033[33m已完成登录界面美化\033[0m"

rm -rf nice.tar.gz


/etc/init.d/bt restart

echo -e "=================================================================="
echo -e "\033[32m宝塔面板美化脚本执行完毕\033[0m"
echo -e "=================================================================="
echo  "适用宝塔面板版本：7.7"
echo -e "如需还原，请在面板首页右上角点击\033[31m 修复 \033[0m即可"
echo -e "=================================================================="
