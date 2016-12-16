
![coder farmer](https://raw.githubusercontent.com/interfacekun/skynet/master/img/manong.jpg "0. 0")


## 下载
<br>
```Bash
git clone https://github.com/interfacekun/skynet.git
```
<br>
## 编译
对于FreeBSD , 使用 gmake 代替 make
```Bash
cd skynet
make 'PLATFORM'  # PLATFORM 可以是 linux, macosx, freebsd now
```
<br>
##或者
<br>
```Bash
export PLAT=linux
make
```
<br>
## 配置环境
* 安装redis
```Bash
sudo apt-get install redis
```
* 启动redis
```Bash
cd skynet
redis-server sprj/redis/redis1.conf
```
* 安装mysql
```Bash
sudo apt-get install mysql-server
```
创建好数据库
执行sprj/cluster_database/config/目录下的sql文件，导入表和数据到数据库中

<br>
## 说明
数据库连接配置在sprj/cluster_database/config/config文件里
<br>
密码加密
```Bash
lua sprj/tools/encodepwd.lua 
#先输入who(对应confg文件里的who) 
#然后输入未加密的明文密码
```

<br>
## 运行
在不同的控制运行下面的命令
 	