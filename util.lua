local string    = string
local io        = io
local table     = table
local ipairs    = ipairs

module("gnarly.util")

function log(str)
  if str then
    io.stderr:write(str)
    io.stderr:write("\n")
  end
  io.flush()
end

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

-- thanks to @mikelovesrobots' excellent lua-enumerable:
--  https://github.com/mikelovesrobots/lua-enumerable
--
table.select = function(list, func)
    local results = {}
    for i,x in ipairs(list) do
      if (func(x, i)) then
        table.insert(results, x)
      end
    end
    return(results)
end

table.collect = function(source, func) 
    local result = {}
    for i,v in ipairs(source) do table.insert(result, func(v)) end
    return result
end

table.keys = function(table)
    _k = {}
    for k, v in ipairs(table) do
      table.insert(_k, k)
    end
    return _k
end
