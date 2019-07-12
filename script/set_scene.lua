return function(scene_name)
  local main = love.filesystem.load('scene/' .. scene_name .. '.lua')

  if main then
    local callbacks = {'update', 'draw', 'mousepressed', 'keypressed',
    'load', 'textinput', 'wheelmoved'}

    for i, callback in ipairs(callbacks) do
      love[callback] = nil
    end

    collectgarbage()

    main()
    if love.load then love.load() end
  end
end
