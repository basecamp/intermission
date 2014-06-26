--Copyright 2012-2014 37signals / Taylor Weibley
local pausedreqs = ngx.shared.pausedreqs
local enabled
local app_name
local enabled_key
local id_key
local paused_key

--Check for app_name and 'scope' keys with it.
--app_name should be set in the server block of the
--nginx app config.
if ngx.var.app_name == nil then
  enabled_key = "enabled"
  id_key = "id"
  paused_key = "paused"
  enabled = pausedreqs:get(enabled_key)
else
  app_name = tostring(ngx.var.app_name)
  enabled_key = "enabled_" .. app_name
  id_key = "id" .. app_name
  paused_key = "paused_" .. app_name
  enabled = pausedreqs:get(enabled_key)
end

if ngx.var.uri == '/_intermission/status' then
  if enabled then
    ngx.say("Pause enabled.")
  else
    ngx.say("Pause disabled.")
  end

  ngx.exit(200)

elseif ngx.var.uri == '/_intermission/enable' then
  if enabled then
    ngx.status = 304
    ngx.say("Pause already enabled.")
    ngx.exit(304)
  end

  pausedreqs:flush_all()
  pausedreqs:set(enabled_key, true)
  ngx.log(ngx.ERR, 'Pause enabled')
  ngx.say("Pause enabled.")
  ngx.exit(200)

elseif ngx.var.uri == '/_intermission/disable' then
  if not enabled then
    ngx.status = 304
    ngx.say("Pause already disabled.")
    ngx.exit(304)
  end

  -- Unpause requests
  pausedreqs:delete(enabled_key)

  -- Say how many connections we paused after we let them all go.
  local paused_count = tonumber(pausedreqs:get(id_key)) or 0

  ngx.log(ngx.ERR, 'Pause disabled. ' .. paused_count .. ' requests were held in-flight.')

  ngx.say("Pause disabled.")
  ngx.exit(200)

else
  ngx.exit(404)
end