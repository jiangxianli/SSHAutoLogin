# SSHAutoLogin
一个SSH登录服务器的shell脚本，通常我们使用ssh登录服务器都要自己输入密码，而且容易输入错误，
每当遇到这种情况甚是苦恼，下定决心自己写一个不用输入密码自动登录ssh的shell脚本。
##添加配置
在ssh_login文件中，修改以下配置
```shell
    CONFIGS=(
    "服务器名称 端口号 IP地址 登录用户名 登录密码"
    "服务器名称 端口号 IP地址 登录用户名 登录密码"
)
```
比如可以修改成：
```shell
    CONFIGS=(
    "服务器名称 22 220.181.57.217 root baidu.com"
    "新浪服务器 22 66.102.251.33 root sina.com"
)
```

##使用
1).给ssh_login文件执行的权限,并执行ssh_login
```shell
  chmod u+x ssh_login
  ./ssh_login
```
2).可以将ssh_login 拷贝至 /usr/local ,之后便可以在终端中全局使用ssh_login
```shell
  chmod u+x ssh_login
  cp ssh_login /usr/local/
  ssh_login
```
##提示
使用本脚本前，请确认已安装expect

1) Linux 下 安装expect
```shell
 yum install expect
```
2) Mac 下 安装expect
```shell
 brew install homebrew/dupes/expect
```
