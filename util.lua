local string    = string
local io        = io
local table     = table
local ipairs    = ipairs
local type      = type


local naughty = require("naughty")

module("gnarly.util")

function log(d)
  if d then
    local nt = ""
    local td = type(d)
    if td == 'string' then
        nt = d
    else
        nt = 'object of type: ' .. td
    end
    naughty.notify({ 
      preset = naughty.config.presets.normal, 
      title = "Log", text = nt .. "\n",
      timeout = 0})
    io.stderr:write(nt)
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

-- Lua implementation of PHP scandir function
-- ~ http://stackoverflow.com/questions/5303174/get-list-of-directory-in-a-lua
function scandir(d)
  local i, t = 0, {}
  for path in io.popen('ls "' .. d .. '"'):lines() do
    i = i + 1
    t[i] = path
  end
  return t
end
