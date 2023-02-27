-- variables
local bars = {}

function bars:new(data)
  local bar = {
    data = data,
    visible = false,
  }

  if data.hpp >= 0 then
    bar.visible = true
  end

  function bar:update(data)
    self.data = data

    if self.data.hpp <= 0 then
      self.visible = false
    end
  end

  function bar:isVisible()
    return self.visible == true
  end

  function bar:destroy()
    --
  end

  return bar
end

return bars
