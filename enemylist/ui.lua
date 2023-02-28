-- dependencies
local texts = require('texts')
local tracker = require('tracker')
local bars = require('ui/bars')
local settings = require('settings')

-- variables
local backgroundImagePath = windower.addon_path .. 'images/background.png'
local foregroundImagePath = windower.addon_path .. 'images/foreground.png'
local ui = {
  frameCount = 0,
  containers = {},
  placeholder = nil,
}

function ui:initialize()
  tracker:initialize()
  ui.placeholder = texts.new('                Drag Me                ')
  ui.placeholder:pos(settings:get().position.x, settings:get().position.y)

  windower.register_event('prerender', function()
    ui:handlePrerender()
  end)

  -- handle zoning
  windower.register_event('incoming chunk', function(id, data, modified, isInjected, isBlocked)
    if isInjected then
      return
    end

    -- handle zoning somewhere else
    if id == 0xB then
      ui.containers = {}
    end
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
  local options = settings:get()

  -- create any new containers that need to be added
  for id, data in pairs(mobs) do
    if ui.containers[id] == nil then
      -- setup the name
      local name = texts.new(data.name)
      name:bg_visible(false)
      name:stroke_color(options.text.stroke.red, options.text.stroke.green, options.text.stroke.blue)
      name:stroke_width(options.text.stroke.width)

      -- setup the hpp
      local hpp = texts.new('${value}%')
      hpp:bg_visible(false)
      hpp:stroke_color(options.text.stroke.red, options.text.stroke.green, options.text.stroke.blue)
      hpp:stroke_width(options.text.stroke.width)

      -- setup the bars
      ui.containers[id] = {
        background = bars:create(backgroundImagePath),
        foreground = bars:create(foregroundImagePath),
        name = name,
        hpp = hpp,
      }
    end
  end

  -- sort the bars
  table.sort(ui.containers)

  -- cache some variables outside of for loop
  local containerHeight = options.container.height
  local containerSpacing = options.container.spacing
  local barWidth = options.bar.width
  local barPadding = options.bar.padding
  local x = options.position.x + 24
  local y = options.position.y + 24
  local containers = {}

  -- display the placeholder if we're supposed to
  if options.locked == false then
    ui.placeholder:show()
  else
    ui.placeholder:hide()
  end

  -- save the coordinates of the placeholder
  local placeholderX, placeholderY = ui.placeholder:pos()
  settings:updatePosition(placeholderX, placeholderY)

  -- next, update all of the container positions
  for id, container in pairs(ui.containers) do
    if container ~= nil then
      if mobs[id] == nil then
        -- mob is no longer tracked, remove the container
        container.background:destroy()
        container.foreground:destroy()
        container.name:destroy()
        container.hpp:destroy()
        ui.containers[id] = nil
      else
        -- mob is still being tracked
        local mobHPP = mobs[id].hpp

        container.background:update(x, y, containerHeight, barWidth)
        container.foreground:update(x + barPadding, y + barPadding, containerHeight - (barPadding * 2), ((mobHPP / 100) * (barWidth - barPadding * 2)))
        container.name:pos(x - barPadding - container.name:extents(), y + (barPadding / 2))
        container.name:show()
        container.hpp:pos(x + barWidth + barPadding, y + (barPadding / 2))
        container.hpp:show()
        container.hpp.value = mobHPP

        y = y + containerHeight + containerSpacing
      end
    end
  end
end

return ui
