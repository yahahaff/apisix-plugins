--
-- Licensed to the Apache Software Foundation (ASF) under one or more
-- contributor license agreements.  See the NOTICE file distributed with
-- this work for additional information regarding copyright ownership.
-- The ASF licenses this file to You under the Apache License, Version 2.0
-- (the "License"); you may not use this file except in compliance with
-- the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--

local core         =   require("apisix.core")


-- 声明插件名称
local plugin_name = "get-keys"

-- 定义插件 schema 格式
local schema = {
    type = "object",
    properties = {}
}

-- 插件元数据 schema
local metadata_schema = {
    type = "object",
    properties = {}
}


local _M = {
    version = 0.1,
    priority = 416,
    name = plugin_name,
    schema = schema,
    metadata_schema = metadata_schema
}

-- 检查插件配置是否正确
function _M.check_schema(conf, schema_type)
    if schema_type == core.schema.TYPE_METADATA then
        return core.schema.check(metadata_schema, conf)
    end
    return core.schema.check(schema, conf)
end

-- 执行逻辑
local function get_key()
    local key = "/ssls/451025546319534994"  -- core.etcd已经定义了/apisix prefix，只需从三级目录开始即可
    core.log.info("Processing access request for client IP validation")
    local res, err = core.etcd.get(key)
    if res then
        core.log.debug("Keys in etcd:")
        core.log.debug("res: ", core.json.encode(res.body.node))
    else
        core.log.error("Error while fetching etcd key: " .. (err or "Unknown error"))
    end
    return 200,  core.json.encode(res.body.node)
end


-- 公共接口
function _M.api()
    return {
        {
            methods = {"GET"},
            uri = "/apisix/plugin/" .. plugin_name,
            handler = get_key,
        }
    }
end

function _M.log(conf, ctx)
    core.log.info("Custom plugin " .. plugin_name .. " in request has been processed!")
end



return _M


