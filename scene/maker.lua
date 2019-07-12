local BOX_SIZE = 16

local resource = {}
local grid = {}
local camera = {x = 0, y = 0, speed = 100}
local ms1, ms2 = 0, 0
local button_height

local border_tile_grid = {}
local to_border_tile = {}
function to_border_tile.add(x, y, key)
  if not border_tile_grid[x..','..y] then border_tile_grid[x..','..y] = {} end

  border_tile_grid[x..','..y][key] = true
end
function to_border_tile.del(x, y, key)
  if border_tile_grid[x..','..y] then border_tile_grid[x..','..y][key] = nil end

  if border_tile_grid[x..','..y] and not next(border_tile_grid[x..','..y]) then
    border_tile_grid[x..','..y] = nil
  end
end

function love.load()
  resource.click_sound = love.audio.newSource('assets/click.mp3', 'static')
  resource.tile_image = love.graphics.newImage('assets/tile.png')
  resource.font = love.graphics.newFont('assets/DeterminationWeb.ttf', 15)

  resource.border_tile = love.graphics.newImage('assets/autotile.png')
  resource.quads = {}

  for y = 0, 3 do
    for x = 0, 3 do
      table.insert(resource.quads, love.graphics.newQuad(
        8 * x, 8 * y, 8, 8, 32, 32
      ))
    end
  end

  button_height = resource.font:getHeight() + 10

  local function newButton(text, func)
    return {text = text, func = func}
  end

  resource.buttons = {
    [1] = newButton('Tiling', function()end),
    [2] = newButton('Back', function()
      setScene('menu')
    end)
  }
end

function love.update(dt)

  if ms1 + ms2 == 1 then
    local mx, my = love.mouse.getPosition()

    local rx = mx - (mx + camera.x) % BOX_SIZE + camera.x
    local ry = my - (my + camera.y) % BOX_SIZE + camera.y

    grid[rx..','..ry] = ms1 == 1 or nil

    --[[
    [ul][uc][ur]
    [ml][mc][mr]
    [dl][dc][dr]
    ]]

    to_border_tile[ms1 == 1 and 'add' or 'del'](rx + BOX_SIZE, ry + BOX_SIZE, 'ul')
    to_border_tile[ms1 == 1 and 'add' or 'del'](rx, ry + BOX_SIZE, 'uc')
    to_border_tile[ms1 == 1 and 'add' or 'del'](rx - BOX_SIZE, ry + BOX_SIZE, 'ur')
    to_border_tile[ms1 == 1 and 'add' or 'del'](rx + BOX_SIZE, ry, 'ml')
    to_border_tile[ms1 == 1 and 'add' or 'del'](rx - BOX_SIZE, ry, 'mr')
    to_border_tile[ms1 == 1 and 'add' or 'del'](rx + BOX_SIZE, ry - BOX_SIZE, 'dl')
    to_border_tile[ms1 == 1 and 'add' or 'del'](rx, ry - BOX_SIZE, 'dc')
    to_border_tile[ms1 == 1 and 'add' or 'del'](rx - BOX_SIZE, ry - BOX_SIZE, 'dr')
  end

  local up = love.keyboard.isDown('w') and 1 or 0
  local dn = love.keyboard.isDown('s') and 1 or 0
  local lf = love.keyboard.isDown('a') and 1 or 0
  local rg = love.keyboard.isDown('d') and 1 or 0

  camera.x = camera.x + (rg - lf) * camera.speed * dt
  camera.y = camera.y + (dn - up) * camera.speed * dt

end

function love.draw()
  local ww, wh = love.graphics.getDimensions()
  local cx = math.floor(camera.x)
  local cy = math.floor(camera.y)

  for x = -cx % BOX_SIZE - BOX_SIZE, ww, BOX_SIZE do
    for y = -cy % BOX_SIZE - BOX_SIZE, wh, BOX_SIZE do
      if grid[x + cx ..','.. y + cy] then
        love.graphics.draw(resource.tile_image, x, y)
      elseif border_tile_grid[x + cx ..','.. y + cy] then
        local spot = border_tile_grid[x + cx ..','.. y + cy]

        local ul = (spot.uc and 1 or 0) + (spot.ml and 2 or 0)
        local ur = (spot.uc and 1 or 0) + (spot.mr and 2 or 0)
        local dl = (spot.dc and 1 or 0) + (spot.ml and 2 or 0)
        local dr = (spot.dc and 1 or 0) + (spot.mr and 2 or 0)

        if ul > 0 then
          love.graphics.draw(resource.border_tile, resource.quads[ul], x, y)
        elseif spot.ul then
          love.graphics.draw(resource.border_tile, resource.quads[4], x, y)
        end

        if ur > 0 then
          love.graphics.draw(resource.border_tile, resource.quads[ur + 4], x + 8, y)
        elseif spot.ur then
          love.graphics.draw(resource.border_tile, resource.quads[8], x + 8, y)
        end

        if dl > 0 then
          love.graphics.draw(resource.border_tile, resource.quads[dl + 8], x, y + 8)
        elseif spot.dl then
          love.graphics.draw(resource.border_tile, resource.quads[12], x, y + 8)
        end

        if dr > 0 then
          love.graphics.draw(resource.border_tile, resource.quads[dr + 12], x + 8, y + 8)
        elseif spot.dr then
          love.graphics.draw(resource.border_tile, resource.quads[16], x + 8, y + 8)
        end
      end
    end
  end

  local mx, my = love.mouse.getPosition()

  if ww - 120 > mx then
    local rx = mx - (mx + camera.x) % BOX_SIZE
    local ry = my - (my + camera.y) % BOX_SIZE

    love.graphics.rectangle('line', rx, ry, BOX_SIZE, BOX_SIZE)
  end

  for i, button in ipairs(resource.buttons) do
    local y = 10 + (button_height + 10) * (i - 1)

    if ww - 110 <= mx and mx <= ww - 10
    and y <= my and my <= y + button_height then
      love.graphics.setColor(0.8, 0.8, 0.8)
    else
      love.graphics.setColor(0.5, 0.5, 0.5)
    end

    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', ww - 110, y, 100, button_height)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(button.text, resource.font, ww - 110, y + 5, 100,
    'center')
  end

 love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function love.mousepressed(mx, my, button, isTouch)

  local ww, wh = love.graphics.getDimensions()
  for i, button in ipairs(resource.buttons) do
    local y = 10 + (button_height + 10) * (i - 1)

    if ww - 110 <= mx and mx <= ww - 10
    and y <= my and my <= y + button_height then
      resource.click_sound:play()
      button.func()
      return nil
    end
  end

  ms1 = button == 1 and 1 or ms1
  ms2 = button == 2 and 1 or ms2
end

function love.mousereleased(x, y, button, isTouch)
  ms1 = button == 1 and 0 or ms1
  ms2 = button == 2 and 0 or ms2
end
