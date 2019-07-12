local module = {}

function module.hover(x, y, w, h, mx, my)
  return x <= mx and mx <= x + w and y <= my and my <= y + h
end

function module.step(pos, gap, step)
  return function(func)
    for i = 1, step do
      local _pos = pos + gap * (i - 1)
      func(_pos, i)
    end
  end
end

return module
