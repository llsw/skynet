
![coder farmer](https://raw.githubusercontent.com/interfacekun/skynet/master/img/manong.jpg "0. 0")

## Skynet

* Skynet is a lightweight online game framework, and it can be used in many other fields.https://github.com/cloudwu/skynet.git

## 下载
```Bash
git clone https://github.com/interfacekun/skynet.git
```
## 编译
```Bash

cd skynet
make 'PLATFORM'  # PLATFORM 可以是 linux, macosx, freebsd now
				 #对于FreeBSD , 使用 gmake 代替 make
```
##或者
```Bash
export PLAT=linux
make
```
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
* 创建好数据库
* 执行sprj/cluster_database/config/目录下的sql文件，导入表和数据到数据库中

## 说明
* 所有文件都在sprj目录中
* 数据库连接配置在sprj/cluster_database/config/config文件里
* 密码加密
```Bash
lua sprj/tools/encodepwd.lua
#先输入who(对应confg文件里的who) 
#然后输入未加密的明文密码 
```
## 运行
* 在`不同`的控制运行下面的命令
```Bash
./skynet sprj/cluster_database/config 	#启动数据库节点
./skynet sprj/cluster_center/config 	#启动中心节点
./skynet sprj/cluster_room/config 		#启动房间节点
./3rd/lua/lua sprj/client/client.lua 	#启动客户端1
./3rd/lua/lua sprj/client/client.lua 	#启动客户端2
./3rd/lua/lua sprj/client/client.lua 	#启动客户端3
``` 	