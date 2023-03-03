local images = require('images')
local settings = require('settings')

local debuffElements = {}

function debuffElements.new(effectID, x, y)
  local imageSize = settings.get('bars.effects.size')
  local debuffElement = {
    _effectID = effectID,
    _image = images.new(),
  }

  debuffElement._image:path(debuffElements.getImagePath(effectID))
  debuffElement._image:draggable(false)
  debuffElement._image:size(imageSize, imageSize)
  debuffElement._image:pos(x, y)
  debuffElement._image:fit(false)
  debuffElement._image:show()

  function debuffElement.destroy()
    debuffElement._image:destroy()
    debuffElement._image = nil
  end

  function debuffElement.pos(x, y)
    debuffElement._image:pos(x, y)
  end

  return debuffElement
end

function debuffElements.getImagePath(effectID)
  if effectID < 10 then
    effectID = '00' .. effectID
  elseif effectID < 100 then
    effectID = '0' .. effectID
  end

  return windower.addon_path .. 'images/icons/' .. effectID .. '.png'
end

return debuffElements
