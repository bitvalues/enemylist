-- dependencies
local settings = require('settings')

-- variables
local commands = {}

function commands:initialize()
  windower.register_event('addon command', function(...)
    commands:process(...)
  end)
end

function commands:process(...)
  local cmds = {...}
  local firstCommand = cmds[1]

  if firstCommand ~= nil then
    firstCommand = firstCommand:lower()
  end

  if firstCommand == 'toggle' then
    if settings:get().locked then
      print('enemylist is now: unlocked')
      settings:unlock()
    else
      print('enemylist is now: locked')
      settings:lock()
    end
  else
    commands:showHelp()
  end
end

function commands:showHelp()
  print('enemylist help:')
  print('    //elist toggle - toggles the ability to drag the enemylist')
end

return commands
