--Copyright 2012 37signals / Taylor Weibley

local redis = require "resty.redis"
local redis_key_prefix = ngx.var.redis_key_prefix;
local red = redis:new()
red:set_timeout(ngx.var.x_redis_timeout)


-- Try to connect to redis and log an error if that fails and pass the request through.
local ok, err = red:connect(ngx.var.redis_ip, ngx.var.redis_port)
if not ok then
  ngx.log(ngx.ERR, "Failed to connect to redis: " .. err)
  ngx.say("Unable to connect to redis!")
  ngx.exit(500)
end

-- Ask redis for the pause key, if it's not there pass the request through.
local res, err = red:get(redis_key_prefix .. 'pause')
if not res then
  ngx.log(ngx.ERR, "Failed to get pause key: " .. err)
  ngx.say("Unable to get pause key!")
  ngx.exit(500)
end
if res == ngx.null then -- not in pause mode
  local res, err = red:set(redis_key_prefix .. 'pause', 1)
  if not res then
    ngx.log(ngx.ERR, "Failed to set pause key: " .. err)
    ngx.say("Unable to set pause key!")
    ngx.exit(500)
  else
    ngx.say("Request paused!")
    ngx.exit(200)
  end
else
  local res, err = red:del(redis_key_prefix .. 'pause')
  if not res then
    ngx.log(ngx.ERR, "Failed to remove pause key: " .. err)
    ngx.say("Unable to delete pause key!")
    ngx.exit(500)
  else
    ngx.say("Request no longer paused!")
    ngx.exit(200)
  end
end  