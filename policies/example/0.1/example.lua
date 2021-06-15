local setmetatable = setmetatable

local _M = require('apicast.policy').new('Example', '0.1')
local mt = { __index = _M }

function _M.new()
  ngx.log(ngx.WARN, "new()")
  return setmetatable({}, mt)
end

function _M:init()
  ngx.log(ngx.WARN, "init()")
  -- do work when nginx master process starts
end

function _M:init_worker()
  -- do work when nginx worker process is forked from master
end

function _M:rewrite()
  -- change the request before it reaches upstream
end

function _M:access()
  -- ability to deny the request before it is sent upstream
end

function _M:content()
  -- can create content instead of connecting to upstream
end

function _M:post_action()
  -- do something after the response was sent to the client
end

function _M:header_filter()
  -- can change response headers
end

function _M:body_filter()
  -- can read and change response body
  -- https://github.com/openresty/lua-nginx-module/blob/master/README.markdown#body_filter_by_lua
  ngx.log(ngx.WARN, "body_filter()")
  ngx.ctx.buffered = (ngx.ctx.buffered or "") .. ngx.arg[1]
  if ngx.arg[2] then -- EOF
    local dict = {}

    -- Gather information of the request
    local request = {}
    if ngx.var.request_body then
      if (base64_flag == 'true') then
        request["body"] = ngx.encode_base64(ngx.var.request_body)
      else
        request["body"] = ngx.var.request_body
      end
    end
    request["headers"] = ngx.req.get_headers()
    request["start_time"] = ngx.req.start_time()
    request["http_version"] = ngx.req.http_version()
    if (base64_flag == 'true') then
      request["raw"] = ngx.encode_base64(ngx.req.raw_header())
    else
      request["raw"] = ngx.req.raw_header()
    end

    request["method"] = ngx.req.get_method()
    request["uri_args"] = ngx.req.get_uri_args()
    request["request_id"] = ngx.var.request_id
    dict["request"] = request

    -- Gather information of the response
    local response = {}
    if ngx.ctx.buffered then
      if (base64_flag == 'true') then
        response["body"] = ngx.encode_base64(ngx.ctx.buffered)
      else
        response["body"] = ngx.ctx.buffered
      end
    end
    response["headers"] = ngx.resp.get_headers()
    response["status"] = ngx.status
    dict["response"] = response

    -- timing stats
    local upstream = {}
    upstream["addr"] = ngx.var.upstream_addr
    upstream["bytes_received"] = ngx.var.upstream_bytes_received
    upstream["cache_status"] = ngx.var.upstream_cache_status
    upstream["connect_time"] = ngx.var.upstream_connect_time
    upstream["header_time"] = ngx.var.upstream_header_time
    upstream["response_length"] = ngx.var.upstream_response_length    
    upstream["response_time"] = ngx.var.upstream_response_time
    upstream["status"] = ngx.var.upstream_status
    dict["upstream"] = upstream

    -- do_log(cjson.encode(dict))
    ngx.log(ngx.WARN, "do to log message : " .. cjson.encode(dict) .. " end....")
  end
  return apicast:body_filter()
end

function _M:log()
  -- can do extra logging
end

function _M:balancer()
  -- use for example require('resty.balancer.round_robin').call to do load balancing
end

return _M
