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

local ui = {
  frameCount = 0,
  box = nil,
}

function ui:initialize()
  tracker:initialize()

  ui.box = texts.new('${currentString}', boxSettings, settings)
  ui.box.currentString = 'Current Targets:'

  windower.register_event('prerender', function()
    ui:handlePrerender()
  end)
end

function ui:handlePrerender()
  if ui.frameCount % 30 == 0 then
    ui:update()
  end

  ui.frameCount = ui.frameCount + 1
end

function ui:update()
  local str = 'Current Targets:\n'

  for id, data in pairs(tracker:getTrackedMobs()) do
    str = str .. '[' .. id .. '] ' .. data.name .. ' (' .. data.hpp .. '%)\n'
  end

  ui.box.currentString = str
  ui.box:show()
end

return ui
