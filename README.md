<div align="">
<br/>
<h1>apisix-plugins</h1>
</div>

<div align="">
  <img src="https://img.shields.io/github/license/yahahaff/rapide?style=flat-square" alt="GitHub License">
  <a href="https://codecov.io/gh/yahahaff/rapide"><img src="https://codecov.io/gh/yahahaff/rapide/branch/main/graph/badge.svg?v=4" alt="codecov"></a>

</div>


 一些自定义的Apisix插件,用于入门学习记录  

 `以下docs 只针对client-ip.lua`

## 如何使用
```shell
cd /usr/local/apisix/apisix/plugins
rz ${custom_plugins}.lua
```

## 确认插件有优先级
```shell
vim /usr/local/apisix/conf/config-default.yaml

...
...

plugins:                          # plugin list (sorted by priority)
  - real-ip                        # priority: 23000
  - ai                             # priority: 22900
  - client-control                 # priority: 22000
  - proxy-control                  # priority: 21990
  - request-id                     # priority: 12015
...  
...
  #找一个没有被占用的优先级数值
```

## 更改插件脚本优先级
```lua
local _M = {
    version = 0.1,
    priority = 415,   -- 优先级， 数值越小优先级越低
    name = plugin_name,
    schema = schema,
    metadata_schema = metadata_schema
}
```

## 使插件生效
```shell
systemctl reload apisix
#查看插件列表
curl "http://127.0.0.1:9180/apisix/admin/plugins/list" -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1'
```

## 创建路由
```shell
curl -X PUT 'http://127.0.0.1:9180/apisix/admin/routes/482183271426993588' \
    -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' \
    -H 'Content-Type: application/json' \
    -d '{
    "uri": "/client-ip",
    "name": "client-ip", 
    "host": "xxxxx.com",
    "desc": "自定义插件，暴露公共API，获取客户端IP并返回",
    "plugins": {
        "public-api": {
            "uri": "/apisix/plugin/client-ip"
        }
    }
}'
```
## 验证
```shell
curl xxxxx.com/client-ip
{"client_ip":"192.168.8.120"}
```
## 日志
如果apisix的日志级别为`debug`或`info`,可查看apisix日志来确认插件是否正确执行
`conf/config.yaml`
```shell
tail -f  logs/error.log

2022/10/04 15:59:34 [info] 32345#32345: *1310355 [lua] client-ip.lua:64: phase_func(): Custom plugin client-ip in request has been processed! while logging request, client: 192.168.8.120, server: _, request: "GET /clientIp HTTP/1.1", host: "xxxxx.com"

```