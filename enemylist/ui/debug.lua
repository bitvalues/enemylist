local texts = require('texts')
local tracker = require('tracker')

local boxSettings = {
  pos = {
    x = 400,
    y = 400,
  },
  bg = {
      alpha = 255,
      red = 0,
      green = 0,
      blue = 0,
      visible = true
  },
  flags = {
      right = false,
      bottom = false,
      bold = true,
      italic = false
  },
  padding = 5,
  text = {
      size = 11,
      font = 'Segoe UI',
  }
}
local settings = {}

local debug = {
  frameCount = 0,
  box = nil,
}

function debug:initialize()
  tracker:initialize()

  debug.box = texts.new('${currentString}', boxSettings, settings)
  debug.box.currentString = 'Current Targets:'

  windower.register_event('prerender', function()
    debug:handlePrerender()
  end)
end

function debug:handlePrerender()
  if debug.frameCount % 30 == 0 then
    debug:update()
  end

  debug.frameCount = debug.frameCount + 1
end

function debug:update()
  local str = 'Current Targets:\n'

  for id, data in pairs(tracker:getTrackedMobs()) do
    str = str .. '[' .. id .. '] ' .. data.name .. ' (' .. data.hpp .. '%)\n'
  end

  debug.box.currentString = str
  debug.box:show()
end

return debug
