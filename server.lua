local socket = require('socket')

local players = {}
local tilemap = ...

local host = socket.udp()
host:settimeout(0)
host:setsockname('*', tostring(27^3))

local data, msg_or_ip, port_or_nil
local entity, command, parms

print('done')
while true do
  data, msg_or_ip, port_or_nil = host:receivefrom()
  if data then
    entity, command, parms = string.match(data, '^(%S+) (%S+) (.*)')

  elseif msg_or_ip ~= 'timeout'
    error('Unknown network error: ' .. tostring(msg_or_ip))
  end
  socket.sleep(0.01)
end
