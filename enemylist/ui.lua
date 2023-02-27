-- dependencies
local texts = require('texts')
local tracker = require('tracker')
local bars = require('ui/bars')

-- variables
local backgroundImagePath = windower.addon_path .. 'images/background.png'
local foregroundImagePath = windower.addon_path .. 'images/foreground.png'
local containerHeight = 24
local containerSpacing = 4
local barPadding = 4
local barWidth = 150
local ui = {
  frameCount = 0,
  settings = {
    x = 1300,
    y = 600,
  },
  containers = {},
}

function ui:initialize()
  tracker:initialize()

  windower.register_event('prerender', function()
    ui:handlePrerender()
  end)
end

function ui:handlePrerender()
  if ui.frameCount % 10 == 0 then
    ui:update()
    ui.frameCount = 0
  end

  ui.frameCount = ui.frameCount + 1
end

function ui:update()
  local mobs = tracker:getTrackedMobs()

  -- create any new containers that need to be added
  for id, data in pairs(mobs) do
    if ui.containers[id] == nil then
      -- setup the name
      local name = texts.new(data.name)
      name:bg_visible(false)
      name:stroke_color(0, 0, 0)
      name:stroke_width(2)

      -- setup the hpp
      local hpp = texts.new('${value}%')
      hpp:bg_visible(false)
      hpp:stroke_color(0, 0, 0)
      hpp:stroke_width(2)

      -- setup the bars
      ui.containers[id] = {
        background = bars:create(backgroundImagePath),
        foreground = bars:create(foregroundImagePath),
        name = name,
        hpp = hpp,
      }
    end
  end

  -- next, update all of the container positions
  local x = ui.settings.x
  local y = ui.settings.y
  local containers = {}

  for id, container in pairs(ui.containers) do
    if mobs[id] == nil then
      -- mob is no longer tracked, remove the container
      container.background:destroy()
      container.foreground:destroy()
      container.name:destroy()
      container.hpp:destroy()
    else
      -- mob is still being tracked
      containers[id] = container
      container.background:update(x, y, containerHeight, barWidth)
      container.foreground:update(x + barPadding, y + barPadding, containerHeight - (barPadding * 2), ((mobs[id].hpp / 100) * (barWidth - barPadding * 2)))
      container.name:pos(x - barPadding - container.name:extents(), y + (barPadding / 2))
      container.name:show()
      container.hpp:pos(x + barWidth + barPadding, y + (barPadding / 2))
      container.hpp:show()
      container.hpp.value = mobs[id].hpp

      y = y + containerHeight + containerSpacing
    end
  end

  ui.containers = containers
end

return ui
