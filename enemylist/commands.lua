local settings = require('settings')

local commands = {}

function commands.initialize()
  windower.register_event('addon command', commands.process)
end

function commands.process(...)
  local cmds = {...}
  local firstCommand = cmds[1]

  if firstCommand then
    firstCommand = firstCommand:lower()
  end

  if firstCommand == 'toggle' then
    if settings.get('locked') == true then
      settings.setLocked(false)
    else
      settings.setLocked(true)
    end
  else
    commands.showHelp()
  end
end

function commands.showHelp()
  print('enemylist help:')
  print('    //elist toggle - toggles the ability to drag the enemylist')
end

return commands
