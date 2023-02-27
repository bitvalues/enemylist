-- dependencies
local images = require('images')

-- variables
local bars = {}

function bars:create(path)
  local bar = {
    image = nil,
    options = {},
    settings = {
      height = 24,
      width = 150,
      x = 500,
      y = 500,
    },
  }

  bar.image = images.new(bar.options)
  bar.image:path(path)
  bar.image:repeat_xy(1, 1)
  bar.image:draggable(false)
  bar.image:fit(false)
  bar.image:pos(bar.settings.x, bar.settings.y)
  bar.image:size(bar.settings.width, bar.settings.height)

  function bar:update(x, y, height, width)
    bar.settings.x = x
    bar.settings.y = y
    bar.settings.height = height
    bar.settings.width = width

    bar.image:pos(bar.settings.x, bar.settings.y)
    bar.image:size(bar.settings.width, bar.settings.height)
    bar.image:show()
  end

  function bar:destroy()
    bar.image:destroy()
    bar = {}
  end

  return bar
end

return bars
