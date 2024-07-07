## 小雅Alist

alist访问端口：5678

emby访问端口：2345

jellyfin访问端口：2346

tvbox访问地址：http://ip:5678/tvbox/my_ext.json

## 启动命令

```
docker run -d -p 5678:80 -p 2345:2345 -p 2346:2346 --restart=unless-stopped --name=xiaoya monlor/xiaoya-alist:latest
```

## 环境变量

`ALIYUN_TOKEN`: 阿里云token https://alist.nn.ci/zh/guide/drivers/aliyundrive.html 

`ALIYUN_OPEN_TOKEN`: 阿里云 open-token https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html

`ALIYUN_FOLDER_ID`: 进入阿里云盘网页版，资源盘里面创建一个文件夹，点击文件夹，复制浏览器阿里云盘地址末尾的文件夹ID（最后一个斜杠/后面的一串字符串）

`QUARK_COOKIE`: 夸克的cookie，登陆夸克网盘，F12找一个请求，查看请求中的Cookie信息

`PAN115_COOKIE`:  115网盘的cookie，登陆115网盘，F12找一个请求，查看请求中的Cookie信息

`PIKPAK_USER`: pikpak 账号，用来观看小雅中pikpak分享给你的资源，格式：`qqq@qq.com:aaadds`

`PIKPAK_LIST`: 挂载你自己 pikpak 账号，格式：`挂载名:qqq@qq.com:aaadds,aaa:+8613111111111:dasf`，密码中不支持符号,:

`PIKPAK_SHARE_LIST`: 挂载自定义的pikpak分享内容，会覆盖小雅的分享，格式：`挂载名1:分享ID1:分享目录ID1,挂载名2:分享ID2:分享目录ID2`

`ALI_SHARE_LIST`: 挂载额外的阿里云盘分享内容，格式：`挂载名1:分享ID1:文件夹ID1,挂载名2:分享ID2:文件夹ID2`

`QUARK_SHARE_LIST`: 挂载额外的夸克网盘分享内容，格式：`挂载名1:分享ID1:文件夹ID1(不存在填root):提取码1(没有留空),挂载名2:分享ID2:文件夹ID2(不存在填root):提取码2`

`PAN115_SHARE_LIST`: 挂载额外的115网盘分享内容，格式：`挂载名1:分享ID1:文件夹ID1(不存在填root):提取码1(没有留空),挂载名2:分享ID2:文件夹ID2(不存在填root):提取码2`

`TVBOX_SECURITY`: 开启tvbox随机订阅地址，true/false，默认：false

`PROXY`: 使用代理，支持http、https、socks5协议，格式：http://ip:7890 或 socks5://ip:7890

`WEBDAV_PASSWORD`: webdav用户名为dav，设置密码。默认用户密码：guest/guest_Api789

`EMBY_ADDR`: emby部署地址，默认http://emby:6908，容器内部使用地址，一般不用改

`JELLYFIN_ADDR`: jellyfin部署地址，默认http://jellyfin:8096，容器内部使用地址，一般不用改

`EMBY_APIKEY`: 填入一个emby的api key，用于在infuse中播放emby

`AUTO_UPDATE_ENABLED`: 每天自动更新小雅的文件，true/false，默认false

`AUTO_CLEAR_ENABLED`: 自动清理阿里云云盘的文件，true/false，默认false

`AUTO_CLEAR_INTERVAL`: 自动清理间隔，单位分钟，范围0-60分钟，默认10分钟

`AUTO_CLEAR_THRESHOLD`: 阿里云盘自动清理文件存在时间阈值，单位分钟，范围0-60分钟，默认10分钟