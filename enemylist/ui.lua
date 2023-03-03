local events = require('events')
local settings = require('settings')
local barElements = require('bar-elements')
local texts = require('texts')
require('tables')

local ui = {
  _frameCount = 0,
  _dragMeText = texts.new('    Drag Me    '),
  _bars = T{},
}

function ui.initialize()
  ui._dragMeText:pos(settings.get('position.x'), settings.get('position.y'))

  windower.register_event('prerender', ui.handlePrerender)
  events.subscribe('mob.track', ui.addMobBar)
  events.subscribe('mob.untrack', ui.removeMobBar)
  events.subscribe('mobs.cleared', ui.clearBars)
  events.subscribe('settings.updated', ui.handleSettingsUpdate)
end

function ui.handlePrerender()
  if ui._frameCount % 2 == 0 then
    ui.update()
    ui._frameCount = 0
  end

  ui._frameCount = ui._frameCount + 1
end

function ui.update()
  local x, y = ui._dragMeText:pos()
  local width, height = ui._dragMeText:extents()

  if (x ~= settings.get('position.x')) or (y ~= settings.get('position.y')) then
    settings.setPosition(x, y)
  end

  y = y + height + settings.get('bars.spacing')

  local count = 0
  for mobID, bar in pairs(ui._bars) do
    if bar then
      local barSpacing = settings.get('bars.spacing') + settings.get('bars.height') + (settings.get('bars.padding') * 2)

      bar.pos(x, y + (barSpacing * count))
      bar.update()
      count = count + 1
    end
  end
end

function ui.addMobBar(id, name, hpp)
  local x = settings.get('position.x')
  local y = settings.get('position.y')
  local barSpacing = settings.get('bars.spacing') + settings.get('bars.height') + (settings.get('bars.padding') * 2)

  if not ui._bars[id] then
    ui._bars[id] = barElements.new(id, x, y + (barSpacing * ui._bars:length()), hpp, name)
  else
    ui._bars[id].setPercent(hpp)
  end
end

function ui.removeMobBar(id)
  if not ui._bars[id] then
    return
  end

  local x = settings.get('position.x')
  local y = settings.get('position.y')
  local barSpacing = settings.get('bars.spacing') + settings.get('bars.height') + (settings.get('bars.padding') * 2)
  local copy = T{}

  for mobID, bar in pairs(ui._bars) do
    if id ~= mobID then
      copy[mobID] = bar
      bar.pos(x, y + (barSpacing * (copy:length() - 1)))
    else
      bar.destroy()
    end
  end

  ui._bars = copy
end

function ui.clearBars()
  for id, bar in pairs(ui._bars) do
    bar.destroy()
  end

  ui._bars = T{}
end

function ui.handleSettingsUpdate(key, value)
  if key == 'locked' then
    if value == true then
      ui._dragMeText:show()
    else
      ui._dragMeText:hide()
    end
  end
end

return ui
