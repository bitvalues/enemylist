-- dependencies
local tracker = require('tracker')
local bars = require('ui/bars')

-- variables
local ui = {
  frameCount = 0,
  settings = {
    x = 400,
    y = 400,
  },
  bars = {},
}

function ui:initialize()
  -- tracker:initialize()

  windower.register_event('prerender', function()
    ui:handlePrerender()
  end)
end

function ui:handlePrerender()
  if ui.frameCount % 30 == 0 then
    ui:update()
    ui.frameCount = 0
  end

  ui.frameCount = ui.frameCount + 1
end

function ui:update()
  -- -- first, create new bar elements
  -- for id, data in pairs(tracker:getTrackedMobs()) do
  --   if ui.bars[id] == nil then
  --     -- ui.bars[id] = bars.new(data)
  --   end
  -- end

  -- -- update bars
  -- for id, bar in pairs(self.bars) do
  --   --

  --   if bar:isVisible() ~= true then
  --     bar:destroy()
  --   end
  -- end
end

function ui:removeLeftoverBars()
  --
end

return ui
