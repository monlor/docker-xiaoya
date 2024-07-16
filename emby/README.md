## Emby 小雅版本

* 添加依赖服务检查，等待Alist和元数据处理完成
* 解析小雅Alist的ip，自动更新

## 环境变量

`ALIST_ADDR`: 小雅alist的地址，默认http://alist:5678，容器内部使用地址，一般不用改

## 其他镜像

> 此镜像仅支持 x86,arm64 架构

```
ghcr.io/monlor/xiaoya-embyserver-amilys
```