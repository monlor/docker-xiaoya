## 小雅影视库

简化部署逻辑，来源：https://xiaoyaliu.notion.site/xiaoya-docker-69404af849504fa5bcf9f2dd5ecaa75f

## 启动命令

```
docker run -d -p 5678:80 -p 2345:2345 -p 2346:2346 --restart=unless-stopped --name=xiaoya monlor/xiaoya-alist:latest
```

## 环境变量

`ALIYUN_TOKEN`: 阿里云token https://alist.nn.ci/zh/guide/drivers/aliyundrive.html 

`ALIYUN_OPEN_TOKEN`: 阿里云 open-token https://alist.nn.ci/zh/guide/drivers/aliyundrive_open.html

`ALIYUN_FOLDER_ID`: 阿里云小雅文件夹id，转存以下文件到你的云盘，获取文件夹id，共享链接：https://www.aliyundrive.com/s/rP9gP3h9asE

`PIKPAK_LIST`: pikpak 账号列表，格式：`qqq@qq.com:aaadds,+8613111111111:dasf`，密码中不支持符号,:

`FORCE_LOGIN`: 开启登陆功能，true/false

`WEBDAV_PASSWORD`: webdav用户名为dav，设置密码，默认密码：guest_Api789

`AUTO_UPDATE_ENABLED`: 自动更新小雅的文件，true/false

`AUTO_CLEAR_ENABLED`: 自动清理阿里云云盘的文件，true/false

`AUTO_CLEAR_INTERVAL`: 自动清理间隔，单位小时，默认24小时