# SSHAutoLogin
一个SSH登录服务器的shell脚本，通常我们使用ssh登录服务器都要自己输入密码，而且容易输入错误，
每当遇到这种情况甚是苦恼，下定决心自己写一个不用输入密码自动登录ssh的shell脚本。
## 添加配置
在ssh_login文件中，修改以下配置
```shell
CONFIGS=(
    "服务器别名 服务器名称 端口号 IP地址 登录用户名 登录密码/秘钥文件Key 秘钥文件地址"
    "服务器别名 服务器名称 端口号 IP地址 登录用户名 登录密码"
)
```
比如可以修改成：
```shell
CONFIGS=(
    "服务器别名 服务器名称 22 220.181.57.217 root passphrase key ~/private_key.pem"
    "服务器别名 新浪服务器 22 66.102.251.33 root sina.com"
)
```
或者在脚本同目录下新建一个文件server_config,按照以上格式写入文件，每个配置单独一行如下：
```
服务器别名 服务器名称 22 220.181.57.217 root passphrase key ~/private_key.pem
服务器别名 新浪服务器 22 66.102.251.33 root sina.com
```
## 使用
1).给ssh_login文件执行的权限,并执行ssh_login
```shell
  chmod u+x ssh_login
  ./ssh_login
```
2).可以将ssh_login 软连接到 /usr/local ,之后便可以在终端中全局使用ssh_login
```shell
  chmod u+x ssh_login
  ln -s $PWD/ssh_login /usr/local/
  ssh_login
```
    注意: ln -s 之后的路径都要是完整的路径地址

3).命令使用

`ssh_login list` - 查看所有服务器配置

`ssh_login 1` - 登录第一个配置的服务器


## 提示
使用本脚本前，请确认已安装expect

1) Linux 下 安装expect
```shell
 yum install expect
```
2) Mac 下 安装expect
```shell
 brew install homebrew/dupes/expect
```

## 特殊说明
如果密码中含有以下特殊字符，请按照一下规则转义：
- \ 需转义为 \\\\\
- } 需转义为 \\}
- [ 需转义为 \\[
- $ 需转义为 \\\\\\$
- \` 需转义为 \\`
- " 需转义为 \\\\\\"
- . 需转义为 \\.

```
如密码为'-OU[]98' 在CONFIG配置中写成'-OU\[]98'
否则，提示要手动输入密码
```
