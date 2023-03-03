require('lists')

local events = {
  _internal = {},
}

function events.publish(name, ...)
  local callbacks = events._internal[name]

  if not callbacks then
    return
  end

  for callback in callbacks:it() do
    callback(...)
  end
end

function events.subscribe(name, callback)
  events._internal[name] = events._internal[name] or L{}
  events._internal[name]:append(callback)
end

function events.unsubscribe(name, callback)
  local callbacks = events._internal[name]

  if not callbacks then
    return
  end

  local index = callbacks:find(functions.equals(callback))

  if index then
    callbacks:remove(index)
  end
end

return events
