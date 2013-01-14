--Copyright 2012 37signals / Taylor Weibley
local pausedreqs = ngx.shared.pausedreqs;
local enabled = pausedreqs:get('enabled')

if enabled then
  local id = pausedreqs:get('id')
  pausedreqs:set('paused:' .. id + 1, 0)
  pausedreqs:delete('enabled')
  ngx.log(ngx.ERR, 'Pause disabled.')

  ngx.say("Pause disabled.")
  ngx.exit(200)
else
  pausedreqs:flush_all()
  pausedreqs:set('enabled', true)
  ngx.log(ngx.ERR, 'Pause enabled')
  ngx.say("Pause enabled.")
  ngx.exit(200)
end  