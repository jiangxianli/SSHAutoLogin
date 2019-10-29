#!/bin/bash

# Function : 使用except无需输入密码自动登录ssh
# Author   : Jiangxianli
# Date     : 2016/01/14
# Github   : https://github.com/jiangxianli/SSHAutoLogin
# Update   : Xiongwilee 2018/06/18 https://github.com/xiongwilee/SSHAutoLogin

#默认服务器配置项
#   "别名            服务器名称                   端口号   IP地址             登录用户名     登录密码/秘钥文件Key 秘钥文件地址"
CONFIGS=()

#基础目录
BaseDir="/etc/ssh_login"
#配置文件目录
CONFIG_PATH="$BaseDir/host.ini"

# 读取配置文件
if [ -f ${CONFIG_PATH} ]; then
    CONFIGS=()
    while read line
    do
        # 注释行或空行 跳过
        if [[ ${LINE:0:1} == "#" || $LINE =~ ^$ ]]; then
            continue
        else
            CONFIGS+=("$line")
        fi
    done < ${CONFIG_PATH}
fi

#服务器配置数
CONFIG_LENGTH=${#CONFIGS[*]}  #配置站点个数

##
# 检查基础目录是否存在
##
CheckDir()
{
    if [ ! -d "$BaseDir" ]; then
        mkdir -p $BaseDir
    fi
}

##
# 检查是否有配置信息
##
CheckConfig()
{
    if [[ $CONFIG_LENGTH -le 0 ]] ;
    then
        echo "未检测到服务器配置项!请使用 ssh_login -c 命令配置!"
        exit ;
    fi
}

##
# 绿色输出
##
function GreenEcho() {
    echo -e "\033[32m ${1} \033[0m";
}

##
# 服务器配置菜单
##
function ConfigList(){
    CheckConfig
    echo -e "- 序号\t\tIP\t\t别名"
    for ((i=0;i<${CONFIG_LENGTH};i++));
    do
        CONFIG=(${CONFIGS[$i]}) #将一维sites字符串赋值到数组
        serverNum=$(($i+1))
        echo -e "- [${serverNum}]\t\t${CONFIG[3]}\t\t${CONFIG[0]}"
    done
}

##
# 登录菜单
##
function LoginMenu(){
    CheckConfig
    if [  ! -n $1 ]; then
        AutoLogin $1
    else
        echo "-------请输入登录的服务器序号或别名---------"
        ConfigList
        echo "请输入您选择登录的服务器序号或别名: "
    fi
}

##
# 选择登录的服务器
##
function ChooseServer(){
    read serverNum;

    # 是否重新选择
    needChooseServer=1;

    if [  -z $serverNum ]; then
        echo "请输入序号或者别名"
        reChooseServer $needChooseServer;
    fi

    AutoLogin $serverNum $needChooseServer;
}

##
# 是退出还是重新选择Server
# @param $1 是否重新选择server 1: 重新选择server
##
function reChooseServer(){
    if [ "$1"x = "1"x ]; then
        ChooseServer;
    else
        exit;
    fi    
}

## 
# 自动登录
# @param $1 序号或者别名
# @param $2 是否重新选择server 1: 重新选择server
##
function AutoLogin(){
    CheckConfig
    num=$(GetServer $1)
    
    if [  -z $num ]; then
        echo "您输入的别名【$1】不存在，请重试"
        reChooseServer $2;
    fi

    CONFIG=(${CONFIGS[$num]})

    if [  -z $CONFIG ]; then
        echo "您输入的序号【$1】不存在，请重试"
        reChooseServer $2;
    else
        echo "正在登录【${CONFIG[1]}】"
    fi

	export PASSWORD=${CONFIG[5]};

    command="
        expect {
                \"*assword\" {set timeout 6000; send \$env(PASSWORD)\r; exp_continue ; sleep 3; }
                \"*passphrase\" {set timeout 6000; send \$env(PASSWORD)\n\r; exp_continue ; sleep 3; }
                \"yes/no\" {send \"yes\n\"; exp_continue;}
                \"Last*\" {  send_user \"\n成功登录【${CONFIG[1]}】\n\";}
        }
       interact
    ";
    pem=${CONFIG[6]}
    if [ -n "$pem" ] ;then
    expect -c "
        spawn ssh -p ${CONFIG[2]} -i ${CONFIG[6]} ${CONFIG[4]}@${CONFIG[3]}
        ${command}
    "
    else
    expect -c "
        spawn ssh -p ${CONFIG[2]} ${CONFIG[4]}@${CONFIG[3]}
        ${command}
    "
    fi
    GreenEcho "您已退出【${CONFIG[1]}】"
    exit;

}

## 
# 通过输入定位选择那个服务器配置
##
function GetServer(){
    # 判断输入是否为数字
    if [ "$1" -gt 0 ] 2>/dev/null ;then
      echo $(($1-1))
    else
        for key in ${!CONFIGS[*]} ; do
            item=(${CONFIGS[$key]})
            if [ ${item[0]} == $1 ]; then
                echo $key
                break;
            fi
        done
    fi
}

##
# 帮助菜单
##
ShowHelp()
{
	echo 'Usage: ssh_login [OPTIONS]'
	echo
	echo 'OPTIONS:'
	echo "-h | --help : show help of tool"
	echo "-c | --config : edit the configure of ssh host"
	echo "-l | --list : list all of host info"
	echo "[a-zA-z0-9]* |  auto Login by alias name or numbers"
	echo
}

##
# 帮助菜单
##
EditConfig()
{
    CheckDir
    if [ ! -f "$CONFIG_PATH" ]; then
      curl -ko $CONFIG_PATH --connect-timeout 300 --retry 5 --retry-delay 3 "https://raw.githubusercontent.com/jiangxianli/SSHAutoLogin/master/host.ini"
    fi
    vi $CONFIG_PATH
}


##
# 程序入口
##
case $1 in
    '-h' | '--help' )
        ShowHelp
        exit
        ;;
    '--config' | '-c' )
        EditConfig
        exit
        ;;
    '-l' | '--list' )
        ConfigList
        exit
        ;;
   [a-zA-z0-9]* )
        AutoLogin $1
        exit
        ;;
    * )
    LoginMenu
    ChooseServer $1
    exit
    ;;
esac