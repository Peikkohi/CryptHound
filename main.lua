-- Game made by Cobaltum
-- Last edit 22.4.19 by Cobaltum
function love.load()
  love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

  local ww, wh = love.window.getDesktopDimensions()
  love.window.updateMode(ww, wh)

  setScene = require('script/set_scene')
  setScene('menu')
end
