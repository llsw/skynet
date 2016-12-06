## 下载

git clone https://github.com/interfacekun/skynet.git




## 编译
cd skynet
make 'PLATFORM'  # PLATFORM 可以是 linux, macosx, freebsd now

#或者

export PLAT=linux
make

##对于FreeBSD , 使用 gmake 代替 make



## 安装redis,用redis-cli sprj/redis/redis1.conf 开启redis
## 安装mysql数据库, 并启动mysql数据库
## redis、mysql连接的配置都在sprj/config/sgateconfig中



## 测试
## 在不同的控制运行下面的命令

./skynet sprj/sgateconfig	
./3rd/lua/lua sprj/client/client.lua 	

