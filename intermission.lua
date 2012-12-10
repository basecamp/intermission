--Copyright 2012 37signals / Taylor Weibley
local x_pause_id = ngx.var.x_request_id;
local sleep_time = ngx.var.intermission_interval;
ngx.log(ngx.ERR, "Redis IP: " .. ngx.var.redis_ip .. " and Port: " .. ngx.var.redis_port)

local redis = require "resty.redis"
local redis_key_prefix = ngx.var.redis_key_prefix;
local red = redis:new()
red:set_timeout(ngx.var.x_redis_timeout)

-- Try to connect to redis and log an error if that fails and pass the request through.
local ok, err = red:connect(ngx.var.redis_ip, ngx.var.redis_port)
if not ok then
  ngx.log(ngx.ERR, "Failed to connect to redis: " .. err)
  return
end

-- Ask redis for the pause key, if it's not there pass the request through.
local res, err = red:get(redis_key_prefix .. 'pause')
if not res then
  ngx.log(ngx.ERR, "Failed to get pause key: " .. err)
  return
end

-- We've got a result and we need to either pass the request (not paused) or hold on to it (paused).
if res == ngx.null then -- not in pause mode
  -- Put it into the connection pool of size 5, with 0 idle timeout.
  local ok, err = red:set_keepalive(0, 5)
  if not ok then
    ngx.log(ngx.ERR, "Failed to set keepalive: " .. err)
  end
  return

else
  -- We are pausing...
  ngx.log(ngx.ERR, "Entering pause mode: " .. x_pause_id)

  local count = 0; 
  while true do
    -- On the first loop add our req_id to the list.
    if count == 0 then
      local ok, err = red:lpush(redis_key_prefix .. 'paused', x_pause_id)
      if not ok then
        ngx.log(ngx.ERR, "failed to lpush: " .. err)
      end
    end

    -- It is possible we are already unpaused, so lets check.
    local res, err = red:get(redis_key_prefix .. 'pause')
    if res == ngx.null then
      local val, err = red:lindex(redis_key_prefix .. 'paused', -1)
      if val == x_pause_id then
        ngx.log(ngx.ERR, "Ready to exit pause because req_id " .. x_pause_id .. " is last on list: " .. val)
        local ok, err = red:rpop(redis_key_prefix .. 'paused') -- remove ourself from the list
        -- If the operation fails, we need to bail out
        if not ok then
              ngx.log(ngx.ERR, "failed to rpop: " .. err)
              return
        end
        ngx.log(ngx.ERR, "Exiting pause mode after " .. count .. " seconds" .. " for req_id " .. val)
        local ok, err = red:set_keepalive(0, 5)
        if not ok then
          ngx.log(ngx.ERR, "Failed to set keepalive: " .. err)
          return
        end
        break
      end
    end
    -- Pause for however long and update the count of seconds.
    ngx.sleep(sleep_time)
    count = count + sleep_time;
  end
end