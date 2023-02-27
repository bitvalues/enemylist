-- dependencies
local config = require('config')

-- variables
local settings = {
  data = nil,
}

function settings:initialize()
  settings.data = config.load('data\\settings.xml', settings:defaults())

  config.register(settings.data, function()
    settings:onInitialize()
  end)
end

function settings:defaults()
  return {
    locked = true,
    position = {
      x = 400,
      y = 400,
    },
    container = {
      height = 24,
      spacing = 4,
    },
    bar = {
      padding = 4,
      width = 150,
    },
    text = {
      stroke = {
        width = 2,
        red = 0,
        green = 0,
        blue = 0,
      },
    },
  }
end

function settings:get()
  return settings.data
end

function settings:save(data)
  settings.data = data
  config.save(settings.data)
end

function settings:onInitialize()
  -- no-op for now
end

function settings:lock()
  settings.data.locked = true
  config.save(settings.data)
end

function settings:unlock()
  settings.data.locked = false
  config.save(settings.data)
end

function settings:updatePosition(x, y)
  if (x ~= settings.data.position.x) or (y ~= settings.data.position.y) then
    settings.data.position.x = x
    settings.data.position.y = y
    config.save(settings.data)
  end
end

return settings
