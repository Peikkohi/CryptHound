-- Game made by Cobaltum
-- Last edit 12.7.19 by Cobaltum
function love.load()
  love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

  local ww, wh = love.window.getDesktopDimensions()
  love.window.updateMode(ww, wh)

  setScene = require('script/set_scene')
  setScene('menu')
end
