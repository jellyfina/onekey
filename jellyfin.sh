#!/bin/bash
# emby变量
EMBY_DOCKER_IMG_NAME="xinjiawei1/emby_unlockd"
EMBY_TAG="latest"
EMBY_PATH=""
EMBY_CONFIG_FOLDER=$(pwd)/emby
EMBY_MOVIES_FOLDER=$(pwd)/movies
EMBY_TVSHOWS_FOLDER=$(pwd)/tvshows
EMBY_CONTAINER_NAME=""
EMBY_PORT="8096"
EMBY_PORT1="8920"
# jellyfin变量
JELLYFIN_DOCKER_IMG_NAME="jellyfin/jellyfin"
JELLYFIN_PATH=""
JELLYFIN_CONFIG_FOLDER=$(pwd)/jellyfin
JELLYFIN_MOVIES_FOLDER=$(pwd)/movies
JELLYFIN_TVSHOWS_FOLDER=$(pwd)/tvshows
JELLYFIN_CONTAINER_NAME=""
JELLYFIN_PORT="8096"
JELLYFIN_PORT1="8920"
#内网ip地址获取
ip=$(ip addr | grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -E -v "^127\.|^255\.|^0\." | head -n 1)

#外网IP地址获取
address=$(curl ipip.ooo)


log() {
    echo -e "\n$1"
}
inp() {
    echo -e "\n$1"
}

opt() {
    echo -n -e "输入您的选择->"
}
cancelrun() {
    if [ $# -gt 0 ]; then
        echo -e " $1 "
    fi
    exit 1
}


TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31;1m";;
	g) export Color="\e[32;1m";;
	b) export Color="\e[34;1m";;
	y) export Color="\e[33;1m";;
	z) export Color="\e[35;1m";;
	l) export Color="\e[36;1m";;
	w) export Color="\e[29;1m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}
clear
while [ "$flag" -eq 0 ]
do
#cat << EOF
TIME w "----------------------------------------"
TIME w "|****Please Enter Your Choice:[0-2]****|"
TIME w "|*********** EMBY & JELLYFIN **********|"
TIME w "----------------------------------------"
TIME w "(1) 安装emby (开心版暂无arm64)"
TIME w "(2) 安装jellyfin"
TIME b "(0) 退出"
#EOF
TIME r "<注>请使用root账户部署容器"
 read -p "Please enter your Choice[0-2]: " input5
 case $input5 in 
 1)
    TIME y " >>>>>>>>>>>开始安装emby"
  # 创建映射文件夹
  input_container_emby_config() {
  echo -n -e "请输入emby配置文件保存的绝对路径（示例：/home/emby)，回车默认为当前目录: "
  read emby_path
  if [ -z "$emby_path" ]; then
      EMBY_PATH=$EMBY_CONFIG_FOLDER
  elif [ -d "$emby_path" ]; then
      EMBY_PATH=$emby_path
  else
      #mkdir -p $emby_path
      EMBY_PATH=$emby_path
  fi
  CONFIG_PATH=$EMBY_PATH/config
  echo -n -e "请输入电影文件保存的绝对路径（示例：/home/movies)，回车默认为当前目录: "
  read movies_path
  if [ -z "$movies_path" ]; then
      MOVIES_PATH=$EMBY_MOVIES_FOLDER
  elif [ -d "$movies_path" ]; then
      MOVIES_PATH=$movies_path
  else
      #mkdir -p $movies_path
      MOVIES_PATH=$movies_path
  fi
  echo -n -e "请输入电视剧文件保存的绝对路径（示例：/home/tvshows)，回车默认为当前目录: "
  read tvshows_path
  if [ -z "$tvshows_path" ]; then
      TVSHOWS_PATH=$EMBY_TVSHOWS_FOLDER
  elif [ -d "$tvshows_path" ]; then
      TVSHOWS_PATH=$tvshows_path
  else
      #mkdir -p $tvshows_path
      TVSHOWS_PATH=$tvshows_path
  fi
  }
  input_container_emby_config
  
  # 输入容器名
  input_container_emby_name() {
    echo -n -e "请输入将要创建的容器名[默认为：emby]-> "
    read container_name
    if [ -z "$container_name" ]; then
        EMBY_CONTAINER_NAME="emby"
    else
        EMBY_CONTAINER_NAME=$container_name
    fi
  }
  input_container_emby_name

  # 面板端口
  input_container_emby_webui_config() {
  inp "是否修改emby面板端口[默认 8096]：\n1) 修改\n2) 不修改[默认]"
  opt
  read change_emby_port
  if [ "$change_emby_port" = "1" ]; then
      echo -n -e "输入想修改的端口->"
      read EMBY_PORT
  fi
  }
  input_container_emby_webui_config
  
  # https端口
  input_container_emby_https_config() {
  inp "是否修改emby的https端口[默认 8920]：\n1) 修改\n2) 不修改[默认]"
  opt
  read change_emby_port1
  if [ "$change_emby_port1" = "1" ]; then
      echo -n -e "输入想修改的端口->"
      read EMBY_PORT1
  fi
  }
  input_container_emby_https_config

  # 确认
  while true
  do
  	TIME y "emby 配置文件路径：$CONFIG_PATH"
  	TIME y "emby 电影文件路径：$MOVIES_PATH"
  	TIME y "emby 电视剧文件路径：$TVSHOWS_PATH"
  	TIME y "emby 容器名：$EMBY_CONTAINER_NAME"
  	TIME y "emby 面板端口：$EMBY_PORT"
  	TIME y "emby https端口：$EMBY_PORT1"
  	read -r -p "以上信息是否正确？[Y/n] " input51
  	case $input51 in
  		[yY][eE][sS]|[yY])
  			break
  			;;
  		[nN][oO]|[nN])
  			TIME w "即将返回上一步"
  			sleep 1
  			EMBY_PORT="8096"
  			EMBY_PORT1="8920"
  			input_container_emby_config
  			input_container_emby_name
  			input_container_emby_webui_config
  			input_container_emby_https_config
  			;;
  		*)
  			TIME r "输入错误，请输入[Y/n]"
  			;;
  	esac
  done

  TIME y " >>>>>>>>>>>配置完成，开始安装emby"
  log "1.开始创建配置文件目录"
  PATH_LIST=($CONFIG_PATH $MOVIES_PATH $TVSHOWS_PATH)
  for i in ${PATH_LIST[@]}; do
      mkdir -p $i
  done

  log "2.开始创建容器并执行"
      if [ -d "/dev/dri" ]; then
          docker run -dit \
              --name $EMBY_CONTAINER_NAME \
              --hostname $EMBY_CONTAINER_NAME \
              --restart always \
              -v $CONFIG_PATH:/config \
              -v $MOVIES_PATH:/mnt/movies \
              -v $TVSHOWS_PATH:/mnt/tvshows \
              -p $EMBY_PORT:8096 -p $EMBY_PORT1:8920 \
              -e TZ=Asia/Shanghai \
              --device /dev/dri:/dev/dri \
              -e UMASK_SET=022 \
              -e UID=0 \
              -e GID=0 \
              -e GIDLIST=0 \
              $EMBY_DOCKER_IMG_NAME:$EMBY_TAG
      else
          docker run -dit \
              --name $EMBY_CONTAINER_NAME \
              --hostname $EMBY_CONTAINER_NAME \
              --restart always \
              -v $CONFIG_PATH:/config \
              -v $MOVIES_PATH:/mnt/movies \
              -v $TVSHOWS_PATH:/mnt/tvshows \
              -p $EMBY_PORT:8096 -p $EMBY_PORT1:8920 \
              -e TZ=Asia/Shanghai \
              -e UMASK_SET=022 \
              -e UID=0 \
              -e GID=0 \
              -e GIDLIST=0 \
              $EMBY_DOCKER_IMG_NAME:$EMBY_TAG
      fi
      if [ $? -ne 0 ] ; then
          cancelrun "** 错误：容器创建失败，请翻译以上英文报错，Google/百度尝试解决问题！"
      fi

      log "列出所有宿主机上的容器"
      docker ps -a
    TIME g "-----------------------------------------------------------------"
    TIME g "|              emby启动需要一点点时间，请耐心等待！             |"
    sleep 10
    TIME g "|                    安装完成，自动退出脚本                     |"
    TIME g "|         emby默认端口为8096，如有修改请访问修改的端口          |"
    TIME g "|         访问方式为宿主机ip:端口(例192.168.2.1:8096)           |"
    TIME g "|         访问http://$ip:8096            |"
    TIME g "|   openwrt需要先执行命令 chmod 777 /dev/dri/* 才能读取到显卡   |"
    TIME g "-----------------------------------------------------------------"
  exit 0
  ;;
 2)
    TIME y " >>>>>>>>>>>开始安装jellyfin"
  # 创建映射文件夹
  input_container_jellyfin_config() {
  echo -n -e "请输入jellyfin配置文件保存的绝对路径（示例：/home/jellyfin)，回车默认为当前目录: "
  read jellyfin_path
  if [ -z "$jellyfin_path" ]; then
      JELLYFIN_PATH=$JELLYFIN_CONFIG_FOLDER
  elif [ -d "$jellyfin_path" ]; then
      JELLYFIN_PATH=$jellyfin_path
  else
      #mkdir -p $jellyfin_path
      JELLYFIN_PATH=$jellyfin_path
  fi
  CONFIG_PATH=$JELLYFIN_PATH/config
  echo -n -e "请输入电影文件保存的绝对路径（示例：/home/movies)，回车默认为当前目录: "
  read movies_path
  if [ -z "$movies_path" ]; then
      MOVIES_PATH=$JELLYFIN_MOVIES_FOLDER
  elif [ -d "$movies_path" ]; then
      MOVIES_PATH=$movies_path
  else
      #mkdir -p $movies_path
      MOVIES_PATH=$movies_path
  fi
  echo -n -e "请输入电视剧文件保存的绝对路径（示例：/home/tvshows)，回车默认为当前目录: "
  read tvshows_path
  if [ -z "$tvshows_path" ]; then
      TVSHOWS_PATH=$JELLYFIN_TVSHOWS_FOLDER
  elif [ -d "$tvshows_path" ]; then
      TVSHOWS_PATH=$tvshows_path
  else
      #mkdir -p $tvshows_path
      TVSHOWS_PATH=$tvshows_path
  fi
  }
  input_container_jellyfin_config
  
  # 输入容器名
  input_container_jellyfin_name() {
    echo -n -e "请输入将要创建的容器名[默认为：jellyfin]-> "
    read container_name
    if [ -z "$container_name" ]; then
        JELLYFIN_CONTAINER_NAME="jellyfin"
    else
        JELLYFIN_CONTAINER_NAME=$container_name
    fi
  }
  input_container_jellyfin_name

  # 面板端口
  input_container_jellyfin_webui_config() {
  inp "是否修改jellyfin面板端口[默认 8096]：\n1) 修改\n2) 不修改[默认]"
  opt
  read change_jellyfin_port
  if [ "$change_jellyfin_port" = "1" ]; then
      echo -n -e "输入想修改的端口->"
      read JELLYFIN_PORT
  fi
  }
  input_container_jellyfin_webui_config
  
  # https端口
  input_container_jellyfin_https_config() {
  inp "是否修改jellyfin的https端口[默认 8920]：\n1) 修改\n2) 不修改[默认]"
  opt
  read change_jellyfin_port1
  if [ "$change_jellyfin_port1" = "1" ]; then
      echo -n -e "输入想修改的端口->"
      read JELLYFIN_PORT1
  fi
  }
  input_container_jellyfin_https_config

  # 确认
  while true
  do
  	TIME y "jellyfin 配置文件路径：$CONFIG_PATH"
  	TIME y "jellyfin 电影文件路径：$MOVIES_PATH"
  	TIME y "jellyfin 电视剧文件路径：$TVSHOWS_PATH"
  	TIME y "jellyfin 容器名：$JELLYFIN_CONTAINER_NAME"
  	TIME y "jellyfin 面板端口：$JELLYFIN_PORT"
  	TIME y "jellyfin https端口：$JELLYFIN_PORT1"
  	read -r -p "以上信息是否正确？[Y/n] " input52
  	case $input52 in
  		[yY][eE][sS]|[yY])
  			break
  			;;
  		[nN][oO]|[nN])
  			TIME w "即将返回上一步"
  			sleep 1
  			JELLYFIN_PORT="8096"
  			JELLYFIN_PORT1="8920"
  			input_container_jellyfin_config
  			input_container_jellyfin_name
  			input_container_jellyfin_webui_config
  			input_container_jellyfin_https_config
  			;;
  		*)
  			TIME r "输入错误，请输入[Y/n]"
  			;;
  	esac
  done

  TIME y " >>>>>>>>>>>配置完成，开始安装jellyfin"
  log "1.开始创建配置文件目录"
  PATH_LIST=($CONFIG_PATH $MOVIES_PATH $TVSHOWS_PATH)
  for i in ${PATH_LIST[@]}; do
      mkdir -p $i
  done

  log "2.开始创建容器并执行"
      if [ -d "/dev/dri" ]; then
          docker run -dit \
              --name $JELLYFIN_CONTAINER_NAME \
              --hostname $JELLYFIN_CONTAINER_NAME \
              --restart always \
              -v $CONFIG_PATH:/config \
              -v $MOVIES_PATH:/mnt/movies \
              -v $TVSHOWS_PATH:/mnt/tvshows \
              -p $JELLYFIN_PORT:8096 -p $JELLYFIN_PORT1:8920 \
              -e TZ=Asia/Shanghai \
              --device /dev/dri:/dev/dri \
              -e UMASK_SET=022 \
              -e UID=0 \
              -e GID=0 \
              -e GIDLIST=0 \
              $JELLYFIN_DOCKER_IMG_NAME:$TAG
      else
          docker run -dit \
              --name $JELLYFIN_CONTAINER_NAME \
              --hostname $JELLYFIN_CONTAINER_NAME \
              --restart always \
              -v $CONFIG_PATH:/config \
              -v $MOVIES_PATH:/mnt/movies \
              -v $TVSHOWS_PATH:/mnt/tvshows \
              -p $JELLYFIN_PORT:8096 -p $JELLYFIN_PORT1:8920 \
              -e TZ=Asia/Shanghai \
              -e UMASK_SET=022 \
              -e UID=0 \
              -e GID=0 \
              -e GIDLIST=0 \
              $JELLYFIN_DOCKER_IMG_NAME:$TAG
      fi
      if [ $? -ne 0 ] ; then
          cancelrun "** 错误：容器创建失败，请翻译以上英文报错，Google/百度尝试解决问题！"
      fi

      log "列出所有宿主机上的容器"
      docker ps -a
    TIME g "-----------------------------------------------------------------"
    TIME g "|              emby启动需要一点点时间，请耐心等待！             |"
    sleep 10
    TIME g "|                    安装完成，自动退出脚本                     |"
    TIME g "|       jellyfin默认端口为8096，如有修改请访问修改的端口        |"
    TIME g "|         访问方式为宿主机ip:端口(例192.168.2.1:8096)           |"
    TIME g "|   openwrt需要先执行命令 chmod 777 /dev/dri/* 才能读取到显卡   |"
    TIME g "-----------------------------------------------------------------"
  exit 0
  ;;
 0) 
 clear 
 exit
 ;;
 *) TIME r "----------------------------------"
    TIME r "|          Warning!!!            |"
    TIME r "|       请输入正确的选项!        |"
    TIME r "----------------------------------"
 for i in $(seq -w 1 -1 1)
   do
     #TIME r "\b\b$i";
     sleep 1;
   done
 clear
 ;;
 esac
 done
;;
