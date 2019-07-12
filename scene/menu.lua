local utf8 = require('utf8')
local module = require('script/stuff')

local resource = {}
local focus = true
local button_height
local text = ''
local current = 'main'

local SCALE = 2

function love.load()
    love.keyboard.setKeyRepeat(true)

    resource.ww, resource.wh = love.graphics.getDimensions()
    resource.ww, resource.wh = resource.ww/SCALE, resource.wh/SCALE

    resource.background_music = love.audio.newSource('assets/title.mp3',
    'stream')

    resource.click_sound = love.audio.newSource('assets/click.mp3', 'static')

    resource.title_font = love.graphics.newFont('assets/Bullpen3D.ttf', 30)
    resource.title_font:setFilter('nearest')

    resource.button_font = love.graphics.newFont('assets/DeterminationWeb.ttf',15)
    resource.button_font:setFilter('nearest')

    button_height = resource.button_font:getHeight() + 10

    local function newButton(text, func)
      return {text = text, func = func}
    end

    resource.main = {
      [1] = newButton('Create Room', function()
        love.keyboard.setKeyRepeat(false)
        resource.background_music:stop()
        setScene('maker')
      end),
      [2] = newButton('Join Room', function()
        current = 'join'
      end),
      [3] = newButton('Exit', function()
        love.event.quit()
      end)
    }

    resource.mainStep = module.step(resource.wh/2, button_height + 10, 3)

    resource.join = {
      [1] = newButton('Join', function()
        setScene('player')
      end),
      [2] = newButton('Back', function()
        current = 'main'
      end)
    }

    resource.joinStep = module.step(resource.wh/2 + button_height + 10,
    button_height + 10, 2)
end

function love.draw()
  if focus and not resource.background_music:isPlaying() then
    resource.background_music:play()
  end

  local mx, my = love.mouse.getPosition()

  if SCALE then
    love.graphics.scale(SCALE)
    mx, my = mx/SCALE, my/SCALE
  end

  love.graphics.printf('Crypt Hound', resource.title_font, 0, resource.wh/8,
  resource.ww, 'center')

  local function drawButton(y, i)
    if module.hover(resource.ww/2 - 50, y, 100, button_height, mx, my) then
      love.graphics.setColor(0.8, 0.8, 0.8, 1)
    else
      love.graphics.setColor(0.5, 0.5, 0.5, 1)
    end

    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', resource.ww/2 - 50, y, 100, button_height)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(resource[current][i].text, resource.button_font,
    resource.ww/2 - 50, y + 5, 100, 'center')
  end

  if current == 'main' then
    resource.mainStep(drawButton)
  elseif current == 'join' then
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', resource.ww/2 - 50, resource.wh/2, 100,
    button_height)

    local _text = text:sub(-12, -1)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(_text, resource.button_font, resource.ww/2 - 45,
    resource.wh/2 + 5)

    local text_lenght = resource.button_font:getWidth(_text) + 17

    love.graphics.setLineStyle('rough')
    love.graphics.setLineWidth(1)
    love.graphics.line(text_lenght + resource.ww/2 - 60, resource.wh/2 + 5,
    text_lenght + resource.ww/2 - 60, resource.wh/2 + button_height - 5)

    resource.joinStep(drawButton)
  end
end

function love.mousepressed(mx, my, bt)
  if SCALE then
    mx, my = mx/SCALE, my/SCALE
  end

  local function clicked(y, i)
    if module.hover(resource.ww/2 - 50, y, 100, button_height, mx, my) then
      resource.click_sound:play()
      resource[current][i].func()
    end
  end

  if current == 'main' then
    resource.mainStep(clicked)
  elseif current == 'join' then
    resource.joinStep(clicked)
  end
end

function love.textinput(_text)
  if current == 'join' then
    text = text .. _text
  end
end

function love.keypressed(key)
  if current == 'join' and key == 'backspace' then
    local byteoffset = utf8.offset(text, -1)

    if byteoffset then
      text = text:sub(1, byteoffset - 1)
    end
  end
end

function love.focus(_focus)
  focus = _focus
  if not _focus then resource.background_music:stop() end
end
