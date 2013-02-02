--Copyright 2012 37signals / Taylor Weibley
local sleep_time = tonumber(ngx.var.intermission_interval);
local max_time = tonumber(ngx.var.intermission_max_time);
local pausedreqs = ngx.shared.pausedreqs;

if pausedreqs:get('enabled') then
  ngx.log(ngx.ERR, "Entering pause mode: " .. x_pause_id)
  
  --Auto inc counter for each paused request
  if pausedreqs:get('id') == nil then
    pausedreqs:set('id', 0)
  end
  
  --Increment the id
  local id = pausedreqs:incr('id', 1)
  ngx.log(ngx.ERR, 'Pause id:' .. id)

  --Add to our queue of paused requests
  local succ, err = pausedreqs:add('paused:' .. id, 1)

  if succ then
    ngx.log(ngx.ERR, 'Pause id added ' .. tostring(succ))

    local wait_time = 0;

    repeat
      --First check the global state then check if the request ahead of us is still here
      if pausedreqs:get('enabled') == nil and pausedreqs:get('paused:' .. id - 1) == nil then
        ngx.log(ngx.ERR, "Unpause id: " .. id .. " after " .. wait_time .. " seconds")
        pausedreqs:delete('paused:' .. id)
        return
      else
        ngx.sleep(sleep_time)
        wait_time = wait_time + sleep_time
        --Warning will be *very* noisy with a small sleep_time
        ngx.log(ngx.DEBUG, 'Pause id:' .. id .. ' waiting for ' .. wait_time .. ' seconds total')
      end
    until wait_time > max_time
  else
    ngx.log(ngx.ERR, 'Failed to add pause id.')
  end

else
  --Self explanatory
  ngx.log(ngx.ERR, 'Pause not enabled')
  return
end