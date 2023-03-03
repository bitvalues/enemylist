local events = require('events')
local config = require('config')
require('strings')

local settings = {
  _storage = nil,
}

function settings.initialize()
  settings._storage = config.load('data\\settings.xml', settings.getDefaultSettings())
  config.register(settings._storage, settings.onInitialize)
end

function settings.getDefaultSettings()
  return {
    locked = false,
    position = {
      x = 400,
      y = 400,
    },
    bars = {
      fontSize = 12,
      width = 150,
      height = 20,
      padding = 4,
      spacing = 4,
      boxBackground = {
        color = {
          red = 0,
          green = 0,
          blue = 0,
        },
      },
      barBackground = {
        color = {
          red = 127,
          green = 0,
          blue = 0,
        },
        affected = {
          color = {
            red = 64,
            green = 64,
            blue = 0,
          },
        }
      },
      barForeground = {
        color = {
          red = 255,
          green = 0,
          blue = 0,
        },
        affected = {
          color = {
            red = 127,
            green = 127,
            blue = 0,
          },
        }
      },
      mobText = {
        stroke = {
          width = 2,
          color = {
            red = 0,
            green = 0,
            blue = 0,
          },
        },
      },
      effects = {
        size = 24,
        spacing = 4,
      },
    },
  }
end

function settings.onInitialize()
  -- no operation
end

function settings.get(key)
  local parts = key:split('.')
  local value = settings._storage

  if value == nil then
    return nil
  end

  for part in parts:it() do
    if not value[part] then
      return nil
    else
      value = value[part]
    end
  end

  return value
end

function settings.setPosition(x, y)
  settings._storage.position.x = x
  settings._storage.position.y = y

  config.save(settings._storage, 'all')
end

function settings.setLocked(value)
  if value == true then
    settings._storage.locked = true
  else
    value = false
    settings._storage.locked = value
  end

  config.save(settings._storage, 'all')
  events.publish('settings.updated', 'locked', value)
end

return settings
