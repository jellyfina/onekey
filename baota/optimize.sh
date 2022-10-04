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


if [ ! -f /www/server/panel/data/userInfo.json ]; then
	echo "{\"uid\":1000,\"username\":\"admin\",\"serverid\":1}" > /www/server/panel/data/userInfo.json
fi
echo -e "\033[33m已去除宝塔面板强制绑定账号\033[0m"

Layout_file="/www/server/panel/BTPanel/templates/default/layout.html";
JS_file="/www/server/panel/BTPanel/static/bt.js";
if [ `grep -c "<script src=\"/static/bt.js\"></script>" $Layout_file` -eq '0' ];then
	sed -i '/{% block scripts %} {% endblock %}/a <script src="/static/bt.js"></script>' $Layout_file;
fi;
wget -q https://raw.githubusercontent.com/jellyfina/onekey/main/baota/bt.js -O $JS_file;
echo -e "\033[33m已去除各种计算题与延时等待\033[0m"

sed -i "/htaccess = self.sitePath+'\/.htaccess'/, /public.ExecShell('chown -R www:www ' + htaccess)/d" /www/server/panel/class/panelSite.py
sed -i "/index = self.sitePath+'\/index.html'/, /public.ExecShell('chown -R www:www ' + index)/d" /www/server/panel/class/panelSite.py
sed -i "/doc404 = self.sitePath+'\/404.html'/, /public.ExecShell('chown -R www:www ' + doc404)/d" /www/server/panel/class/panelSite.py
echo -e "\033[33m已去除创建网站自动创建的垃圾文件\033[0m"

sed -i "s/root \/www\/server\/nginx\/html/return 400/" /www/server/panel/class/panelSite.py
if [ -f /www/server/panel/vhost/nginx/0.default.conf ]; then
	sed -i "s/root \/www\/server\/nginx\/html/return 400/" /www/server/panel/vhost/nginx/0.default.conf
fi
echo -e "\033[33m已关闭未绑定域名提示页面\033[0m"

sed -i "s/return render_template('autherr.html')/return abort(404)/" /www/server/panel/BTPanel/__init__.py
echo -e "\033[33m已关闭安全入口登录提示页面\033[0m"

sed -i "/p = threading.Thread(target=check_files_panel)/, /p.start()/d" /www/server/panel/task.py
sed -i "/p = threading.Thread(target=check_panel_msg)/, /p.start()/d" /www/server/panel/task.py
echo -e "\033[33m已去除消息推送与文件校验\033[0m"

sed -i "/^logs_analysis()/d" /www/server/panel/script/site_task.py
sed -i "s/run_thread(cloud_check_domain,(domain,))/return/" /www/server/panel/class/public.py
echo -e "\033[33m已去除面板日志与绑定域名上报\033[0m"

if [ ! -f /www/server/panel/data/not_recommend.pl ]; then
	echo "True" > /www/server/panel/data/not_recommend.pl
fi
if [ ! -f /www/server/panel/data/not_workorder.pl ]; then
	echo "True" > /www/server/panel/data/not_workorder.pl
fi

echo -e "\033[33m已关闭活动推荐与在线客服\033[0m"

rm -rf bt.js

/etc/init.d/bt restart

echo -e "=================================================================="
echo -e "\033[32m宝塔面板优化脚本执行完毕\033[0m"
echo -e "=================================================================="
echo  "适用宝塔面板版本：7.7"
echo -e "如需还原，请在面板首页右上角点击\033[31m 修复 \033[0m即可"
echo -e "=================================================================="
