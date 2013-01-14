--Copyright 2012 37signals / Taylor Weibley
local sleep_time = ngx.var.intermission_interval;
local max_time = ngx.var.intermission_max_time;

  if pausedreqs:get('enabled') then
    ngx.log(ngx.ERR, "Entering pause mode: " .. x_pause_id)
  
    --If this fails it already exists, no big deal.
    pausedreqs:set('id', 0)

    --Increment the id
    local id = pausedreqs:incr('id', 1)
    ngx.log(ngx.ERR, 'Pause id:' .. id)

    local succ, err = pausedreqs:add('paused:' .. id, 1)
    ngx.log(ngx.ERR, 'Pause id added ' .. tostring(succ))

    local count = 0;

    if succ then
      ngx.log(ngx.ERR, 'Pause id successfully added.')

      repeat
        if pausedreqs:get('paused:' .. id + 1) == 0 or (pausedreqs:get('paused:' .. id + 1) == nil and id ~= 1) then
            pausedreqs:set('paused:' .. id, 0)
            pausedreqs:delete('paused:' .. id + 1)
            return
        else
          ngx.sleep(sleep_time)
          count = count + 0.05
          ngx.log(ngx.ERR, "Count is: " .. count)
        end
      until count > max_time
    else
      ngx.log(ngx.ERR, 'Failed to add pause id.')
    end

  else
    ngx.log(ngx.ERR, 'Pause not enabled')
  
    return
  end