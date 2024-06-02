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

`ALIYUN_FOLDER_ID`: 进入阿里云盘网页版，创建一个文件夹，点击文件夹，复制浏览器阿里云盘地址末尾的文件夹ID（最后一个斜杠/后面的一串字符串）

`PIKPAK_LIST`: pikpak 账号列表，格式：`qqq@qq.com:aaadds,+8613111111111:dasf`，密码中不支持符号,:

`FORCE_LOGIN`: 开启登陆功能，true/false

`WEBDAV_PASSWORD`: webdav用户名为dav，设置密码。默认用户密码：guest/guest_Api789

`EMBY_ADDR`: emby部署地址，默认http://emby:6908

`JELLYFIN_ADDR`: jellyfin部署地址，默认http://jellyfin:8096

`EMBY_APIKEY`: 填入一个emby的api key，用于在infuse中播放emby

`AUTO_UPDATE_ENABLED`: 自动更新小雅的文件，true/false，默认false

`AUTO_CLEAR_ENABLED`: 自动清理阿里云云盘的文件，true/false，默认false

`AUTO_CLEAR_INTERVAL`: 自动清理间隔，单位小时，默认24小时