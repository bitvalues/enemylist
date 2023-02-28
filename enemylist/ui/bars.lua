-- dependencies
local images = require('images')

-- variables
local bars = {}

function bars:create(path)
  local bar = {
    image = nil,
    options = {},
  }

  bar.image = images.new(bar.options)
  bar.image:path(path)
  bar.image:repeat_xy(1, 1)
  bar.image:draggable(false)
  bar.image:fit(false)

  function bar:update(x, y, height, width)
    bar.image:pos(x, y)
    bar.image:size(width, height)
    bar.image:show()
  end

  function bar:destroy()
    bar.image:destroy()
    bar = {}
  end

  return bar
end

return bars
