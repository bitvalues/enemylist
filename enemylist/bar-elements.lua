local events = require('events')
local settings = require('settings')
local effectElements = require('effect-elements')
local images = require('images')
local texts = require('texts')
require('tables')

local barElements = {}

function barElements.new(mobID, x, y, percent, mobName)
  local barElement = {
    _images = T{},
    _texts = T{},
    _effects = T{},
    _percent = percent,
  }

  -- cache some variables for easier use later
  local fontSize = settings.get('bars.fontSize')
  local barWidth = settings.get('bars.width')
  local barHeight = settings.get('bars.height')
  local padding = settings.get('bars.padding')
  local boxBackgroundColors = {
    red = settings.get('bars.boxBackground.color.red'),
    green = settings.get('bars.boxBackground.color.green'),
    blue = settings.get('bars.boxBackground.color.blue'),
  }
  local barBackgroundColors = {
    red = settings.get('bars.barBackground.color.red'),
    green = settings.get('bars.barBackground.color.green'),
    blue = settings.get('bars.barBackground.color.blue'),
  }
  local barBackgroundAffectedColors = {
    red = settings.get('bars.barBackground.affected.color.red'),
    green = settings.get('bars.barBackground.affected.color.green'),
    blue = settings.get('bars.barBackground.affected.color.blue'),
  }
  local barForegroundColors = {
    red = settings.get('bars.barForeground.color.red'),
    green = settings.get('bars.barForeground.color.green'),
    blue = settings.get('bars.barForeground.color.blue'),
  }
  local barForegroundAffectedColors = {
    red = settings.get('bars.barForeground.affected.color.red'),
    green = settings.get('bars.barForeground.affected.color.green'),
    blue = settings.get('bars.barForeground.affected.color.blue'),
  }
  local mobTextStrokeWidth = settings.get('bars.mobText.stroke.width')
  local mobTextStrokeColor = {
    red = settings.get('bars.mobText.stroke.color.red'),
    green = settings.get('bars.mobText.stroke.color.green'),
    blue = settings.get('bars.mobText.stroke.color.blue'),
  }

  -- initialize all of the elements needed to draw a bar
  barElement._images.boxBackground = images.new(mobID .. 'boxBackground')
  barElement._images.boxBackground:color(boxBackgroundColors.red, boxBackgroundColors.green, boxBackgroundColors.blue)
  barElement._images.boxBackground:pos(x, y)
  barElement._images.boxBackground:draggable(false)
  barElement._images.boxBackground:size(barWidth + (padding * 2), barHeight + (padding * 2))
  barElement._images.boxBackground:show()

  barElement._images.barBackground = images.new(mobID .. 'barBackground')
  barElement._images.barBackground:color(barBackgroundColors.red, barBackgroundColors.green, barBackgroundColors.blue)
  barElement._images.barBackground:pos(x + padding, y + padding)
  barElement._images.barBackground:size((barElement._percent / 100) * barWidth, barHeight)
  barElement._images.barBackground:draggable(false)
  barElement._images.barBackground:show()

  barElement._images.barForeground = images.new(mobID .. 'barForeground')
  barElement._images.barForeground:color(barForegroundColors.red, barForegroundColors.green, barForegroundColors.blue)
  barElement._images.barForeground:pos(x + padding, y + padding)
  barElement._images.barForeground:size((barElement._percent / 100) * barWidth, barHeight)
  barElement._images.barForeground:draggable(false)
  barElement._images.barForeground:show()

  barElement._texts.mobName = texts.new(mobName)
  barElement._texts.mobName:size(fontSize)
  barElement._texts.mobName:bg_visible(false)
  barElement._texts.mobName:stroke_color(mobTextStrokeColor.red, mobTextStrokeColor.green, mobTextStrokeColor.blue)
  barElement._texts.mobName:stroke_width(mobTextStrokeWidth)
  barElement._texts.mobName:pos(x - padding, y + ((barHeight + (padding * 2)) / 2) - fontSize + mobTextStrokeWidth)
  barElement._texts.mobName:right_justified(true)
  barElement._texts.mobName:italic(true)
  barElement._texts.mobName:show()

  barElement._texts.mobHealth = texts.new('${percent}%')
  barElement._texts.mobHealth:bg_visible(false)
  barElement._texts.mobHealth:stroke_color(mobTextStrokeColor.red, mobTextStrokeColor.green, mobTextStrokeColor.blue)
  barElement._texts.mobHealth:stroke_width(mobTextStrokeWidth)
  barElement._texts.mobHealth:pos(x + barWidth + padding, y + ((barHeight + (padding * 2)) / 2) - fontSize + mobTextStrokeWidth)
  barElement._texts.mobHealth:right_justified(true)
  barElement._texts.mobHealth:italic(true)
  barElement._texts.mobHealth.percent = percent
  barElement._texts.mobHealth:show()

  function barElement.addEffectToMob(targetID, effectID, spellName)
    if targetID ~= mobID then
      return
    end

    barElement.addEffect(effectID)
  end

  function barElement.removeEffectFromMob(targetID, effectID, spellName)
    if targetID ~= mobID then
      return
    end

    barElement.removeEffect(effectID)
  end

  -- subscribe to events for debuffs
  events.subscribe('debuffs.register', barElement.addEffectToMob)
  events.subscribe('debuffs.unregister', barElement.removeEffectFromMob)

  function barElement.pos(x, y)
    barElement._images.boxBackground:pos(x, y)
    barElement._images.barBackground:pos(x + padding, y + padding)
    barElement._images.barForeground:pos(x + padding, y + padding)

    barElement._texts.mobName:right_justified(false)
    barElement._texts.mobName:pos(x - padding, y + ((barHeight + (padding * 2)) / 2) - fontSize + mobTextStrokeWidth)
    barElement._texts.mobName:right_justified(true)

    barElement._texts.mobHealth:right_justified(false)
    barElement._texts.mobHealth:pos(x + barWidth + padding, y + ((barHeight + (padding * 2)) / 2) - fontSize + mobTextStrokeWidth)
    barElement._texts.mobHealth:right_justified(true)

    barElement.updateEffectsPositioning()
  end

  function barElement.size(width, height)
    barElement._images.boxBackground:size(width + (padding * 2), height + (padding * 2))
    barElement._images.barBackground:size((barElement._percent / 100) * width, height)
    barElement._images.barForeground:size((barElement._percent / 100) * width, height)
  end

  function barElement.getPercent()
    return barElement._percent
  end

  function barElement.setPercent(percent)
    barElement._percent = percent
    barElement._texts.mobHealth.percent = percent
    barElement._texts.mobHealth:update()
  end

  function barElement.update()
    local maxWidth, maxHeight = barElement._images.boxBackground:size()
    maxWidth = maxWidth - (padding * 2)
    maxHeight = maxHeight - (padding * 2)

    local targetWidth = (barElement._percent / 100) * maxWidth
    local backgroundWidth, backgroundHeight = barElement._images.barBackground:size()
    local foregroundWidth = barElements.easeInSine(0.8, backgroundWidth, targetWidth - backgroundWidth, 2)

    barElement._images.barForeground:size(targetWidth, maxHeight)
    barElement._images.barBackground:size(foregroundWidth, maxHeight)
  end

  function barElement.show()
    -- show all the images
    for _, element in pairs(barElement._images) do
      element:show()
    end

    -- show all the texts
    for _, element in pairs(barElement._texts) do
      element:show()
    end
  end

  function barElement.hide()
    -- hide all the images
    for _, element in pairs(barElement._images) do
      element:hide()
    end

    -- hide all the texts
    for _, element in pairs(barElement._texts) do
      element:hide()
    end
  end

  function barElement.destroy()
    -- destroy all the images
    for _, element in pairs(barElement._images) do
      element:destroy()
    end

    -- destroy all the texts
    for _, element in pairs(barElement._texts) do
      element:destroy()
    end

    -- destroy all debuff elements
    barElement.clearEffects()

    -- remove callbacks
    events.unsubscribe('debuffs.register', barElement.addEffectToMob)
    events.unsubscribe('debuffs.unregister', barElement.removeEffectFromMob)
  end

  function barElement.addEffect(id)
    if not barElement._effects[id] then
      local x, y = barElement._images.boxBackground:pos()
      local imageSize = settings.get('bars.effects.size')
      local spacing = settings.get('bars.effects.spacing')

      x = x + (barWidth + (padding * 3)) + ((imageSize + spacing) * barElement._effects:length())
      y = y + ((barHeight + (padding * 2)) / 2) - (imageSize / 2)

      barElement._effects[id] = effectElements.new(id, x, y)

      if barElement._effects:length() > 0 then
        barElement._images.barBackground:color(barBackgroundAffectedColors.red, barBackgroundAffectedColors.green, barBackgroundAffectedColors.blue)
        barElement._images.barForeground:color(barForegroundAffectedColors.red, barForegroundAffectedColors.green, barForegroundAffectedColors.blue)
      end
    end
  end

  function barElement.removeEffect(id)
    if not barElement._effects[id] then
      return
    end

    local copy = T{}

    for effectID, effectElement in pairs(barElement._effects) do
      if id ~= effectID then
        copy[effectID] = effectElement
      else
        effectElement.destroy()
      end
    end

    barElement._effects = copy
    barElement.updateEffectsPositioning()

    if barElement._effects:length() == 0 then
      barElement._images.barBackground:color(barBackgroundColors.red, barBackgroundColors.green, barBackgroundColors.blue)
      barElement._images.barForeground:color(barForegroundColors.red, barForegroundColors.green, barForegroundColors.blue)
    end
  end

  function barElement.updateEffectsPositioning()
    local x, y = barElement._images.boxBackground:pos()
    local imageSize = settings.get('bars.effects.size')
    local spacing = settings.get('bars.effects.spacing')
    local count = 0

    for effectID, effectElement in pairs(barElement._effects) do
      effectElement.pos(
        x + (barWidth + (padding * 3)) + ((imageSize + spacing) * count),
        y + ((barHeight + (padding * 2)) / 2) - (imageSize / 2)
      )
      count = count + 1
    end
  end

  function barElement.clearEffects()
    for id, effectElement in pairs(barElement._effects) do
      if effectElement then
        effectElement.destroy()
      end
    end

    barElements._effects = T{}
  end

  return barElement
end

function barElements.easeInSine(time, begin, change, duration)
  return -change * math.cos(time / duration * (math.pi / 2)) + change + begin
end

return barElements
