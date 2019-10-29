#!/bin/bash

#基础目录
BaseDir="/etc/ssh_login"

#配置文件下载地址
#iniUrl="https://raw.githubusercontent.com/jiangxianli/SSHAutoLogin/master/host.ini"
iniUrl="https://www.jiangxianli.com/SSHAutoLogin/host.ini"

#可执行文件下载地址
#exeUrl="https://raw.githubusercontent.com/jiangxianli/SSHAutoLogin/master/ssh_login.sh"
exeUrl="https://www.jiangxianli.com/SSHAutoLogin/ssh_login.sh"

##
# 检查基础目录是否存在
##
CheckDir()
{
    if [ ! -d "$BaseDir" ]; then
        mkdir -p $BaseDir
    fi
}

# 根据类型 安装软件
SYSTEM_NAME=$1
case $SYSTEM_NAME in
    'centos' | 'linux' )
        yum install -y curl expect
        ;;
    'ubuntu' )
        apt-get install -y curl expect
        ;;
    'mac' )
        brew install -y curl expect
        ;;
esac

CheckDir
cd $BaseDir

#写入配置文件
curl -ko  $BaseDir/host.ini --connect-timeout 300 --retry 5 --retry-delay 3 $iniUrl
echo -e "写入配置文件host.ini到$BaseDir/host.ini ......\n"

#写入可执行文件
curl -ko  $BaseDir/ssh_login --connect-timeout 300 --retry 5 --retry-delay 3 $exeUrl
chmod u+x $BaseDir/ssh_login
echo -e "写入可执行文件ssh_login到$BaseDir/ssh_login ......\n"

#创建软连
ln -s  $BaseDir/ssh_login /usr/local/bin/
ssh_login

