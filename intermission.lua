--Copyright 2012-2014 37signals / Taylor Weibley
local sleep_time = tonumber(ngx.var.intermission_interval)
local max_time = tonumber(ngx.var.intermission_max_time)
local pausedreqs = ngx.shared.pausedreqs
local health_check_path = ngx.var.intermission_health_check_path
local privileged_user_agent = ngx.var.intermission_privileged_user_agent
local app_name
local enabled_key
local id_key
local paused_key

--Check for app_name and 'scope' keys with it.
if ngx.var.app_name == nil then
  enabled_key = "enabled"
  id_key = "id"
  paused_key = "paused"
else
  app_name = tostring(ngx.var.app_name)
  enabled_key = "enabled_" .. app_name
  id_key = "id" .. app_name
  paused_key = "paused_" .. app_name
end

if pausedreqs:get(enabled_key) then
  --Pass healthchecks no matter what.
  if ngx.var.uri == health_check_path or ngx.var.uri == '/up' then
    ngx.log(ngx.DEBUG, 'Passing through health check request.')
    return
  end

  --Pass special user agent no matter what. (Pingdom perhaps?)
  if ngx.var.http_user_agent and ngx.var.http_user_agent ~= '' then
    if string.match(ngx.var.http_user_agent, privileged_user_agent) then
      ngx.log(ngx.DEBUG, 'Passing through privileged user agent request.')
      return
    end
  end

  --Auto inc counter for each paused request
  if pausedreqs:get(id_key) == nil then
    pausedreqs:set(id_key, 0)
  end

  --Increment the id
  local id = pausedreqs:incr(id_key, 1)
  ngx.log(ngx.DEBUG, 'Pause id:' .. id)

  --Add to our queue of paused requests
  local succ, err = pausedreqs:add(paused_key .. id, 1)

  if succ then
    ngx.log(ngx.DEBUG, 'Pause id added ' .. tostring(succ))

    local wait_time = 0;

    repeat
      --First check the global state then check if the request ahead of us is still here
      if pausedreqs:get(enabled_key) == nil and pausedreqs:get(paused_key .. id - 1) == nil then
        ngx.log(ngx.DEBUG, "Unpause id: " .. id .. " after " .. wait_time .. " seconds")
        pausedreqs:delete(paused_key .. id)
        return
      else
        ngx.sleep(sleep_time)
        wait_time = wait_time + sleep_time
        --Warning will be *very* noisy with a small sleep_time
        ngx.log(ngx.DEBUG, 'Pause id:' .. id .. ' waiting for ' .. wait_time .. ' seconds total')
      end
    until wait_time > max_time
  else
    ngx.log(ngx.err, 'Failed to add pause id.')
  end

else
  --Self explanatory
  return
end
