local module = {}

-- str_format or "string format" means the way the position are saved
-- for example 'x,y' => '0,0' or '10,0'
function module.newGrid(box_size, str_format, str_pattern)
  local grid = {pos = {}}

  function grid:newPosition(x, y, value)
    assert(x and y, 'x and y values were not provided for grid element')

    self.pos[string.format(str_format, x, y)] = value
  end

  function grid:deletePosition(x, y)
    self:newPosition(x, y, nil)
  end

  function grid:getValue(x, y)
    assert(x and y, 'x and y values were not provided for grid element')

    return self.pos[string.format(str_format, x, y)]
  end

  function grid:containValue(x, y)
    return self:getValue(x, y) and 1 or 0
  end

  function grid:valueIter()
    return coroutine.wrap(function()
      for key, tile in pairs(grid) do
        local x, y = key:match(str_pattern, key)
        x, y = tonumber(x), tonumber(y)

        coroutine.yield(x, y)
      end
    end)
  end

end

function module.newBorderAutotile(grid)
  assert(grid, 'border autotile needs grid element')
  local border_autotile = grid

  function border_autotile:checkTiling(x, y, grid, box_size)
    if grid:containValue(x, y) == 0 then
      local up_lf = grid:containValue(x - box_size, y - box_size)
      local up_cn = grid:containValue(x, y - box_size)
      local up_rg = grid:containValue(x + box_size, y - box_size)

      local md_lf = grid:containValue(x - box_size, y)
      local md_rg = grid:containValue(x + box_size, y)

      local dw_lf = grid:containValue(x - box_size, y + box_size)
      local dw_cn = grid:containValue(x, y + box_size)
      local dw_rg = grid:containValue(x + box_size, y + box_size)
    end
  end

  return border_autotile
end

return module
