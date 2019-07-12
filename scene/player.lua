local enet = require('enet')
local host = enet.host_create()

if room then server = host:connect('localhost:' .. options.port, 2)
else server = host:connect(options.ip .. ':' .. options.port, 2) end

local world = love.physics.newWorld(0, 200)
local box = {}
local tiles = {}
local player = {fixture}
local players = {}

local SCALE = 2

local event = host:service(2000)
if not event then sm:setScene(1) return end

function love.update(dt)

    event = host:service()
    while event do
        if event.type == 'receive' then
            local cmd, parms = event.data:match('^(%S*) (.*)')

            if cmd == 'tile' then
                local tile, x, y = parms:match(
                    '^(%S*) (%-?[%d.e]*) (%-?[%d.e]*)$')

                assert(tile and x and y)
                x, y = tonumber(x), tonumber(y)

                if tile == 'collision' then
                    table.insert(box, love.physics.newFixture(
                        love.physics.newBody(world, x, y, 'static'),
                        love.physics.newRectangleShape(BOX_SIZE, BOX_SIZE)
                    ))
                else
                    table.insert(tiles, {x = x, y = y})
                end
            elseif cmd == 'start' then
                local x, y = parms:match('^(%-?[%d.e]*) (%-?[%d.e]*)$')

                assert(x and y)
                x, y = tonumber(x), tonumber(y)
                player.fixture = love.physics.newFixture(
                    love.physics.newBody(world, x, y, 'dynamic'),
                    love.physics.newRectangleShape(BOX_SIZE, BOX_SIZE)
                )
            elseif cmd == 'pos' then
                local id, x, y = parms:match(
                    '^(%-?[%d.e]*) (%-?[%d.e]*) (%-?[%d.e]*)$')

                assert(x and y and id)
                id, x, y = tonumber(id), tonumber(x), tonumber(y)
                players[id] = {x = x, y = y}
            elseif cmd == 'left' then
                local id = parms:match('^(%-?[%d.e]*)$')

                assert(id)
                id = tonumber(id)
                players[id] = nil
            end
        end
        event = host:service()
    end

    if player.fixture and love.keyboard.isDown('d') then
        player.fixture:getBody():applyForce(100, 0)
    elseif player.fixture and love.keyboard.isDown('a') then
        player.fixture:getBody():applyForce(-100, 0)
    end

    if player.fixture then player.fixture:getBody():setAngle(0) end
    if player.fixture then player.fixture:getBody():setAngularVelocity(0) end

    world:update(dt)
    if player.fixture then
        server:send(string.format('%s %f %f', 'pos',
            player.fixture:getBody():getX(), player.fixture:getBody():getY())
        )
    end
end

function love.draw()
    ww, wh = love.graphics.getDimensions()

    love.graphics.scale(SCALE)
    if player.fixture then
        love.graphics.translate(
            -player.fixture:getBody():getX() + (ww / (SCALE * 2)),
            -player.fixture:getBody():getY() + (wh / (SCALE * 2))
        )
    end

    love.graphics.setColor(1, 1, 1, 1)
    for i, tile in ipairs(tiles) do
        love.graphics.rectangle('fill', tile.x, tile.y, BOX_SIZE, BOX_SIZE)
    end

    for id, player in pairs(players) do
        love.graphics.setColor(1, 0.5, 0.5, 0.5)
        love.graphics.rectangle('fill',
            player.x, player.y,
            BOX_SIZE, BOX_SIZE
        )
    end

    if player.fixture then
        love.graphics.setColor(1, 0.3, 0.3, 1)
        love.graphics.rectangle('fill',
            player.fixture:getBody():getX(),
            player.fixture:getBody():getY(),
            BOX_SIZE, BOX_SIZE
        )
    end

end

function love.keypressed(key)

    if player.fixture and key == 'space' then
        local contacts = player.fixture:getBody():getContacts()

        if next(contacts) ~= nil then
            player.fixture:getBody():applyForce(0, -1800)
        end
    end
end
