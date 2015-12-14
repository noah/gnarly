
-- © 2014 Noah K. Tilton <noah@tilton.co>
-- 
--      gnarly/battery.lua -- vicious widget for battery status inspired by
--      vicious.widgets.*

-- need to declare this shit in local scope, otherwise it gets gobbled up
-- by module()
local helpers       = require("vicious.helpers")

local setmetatable  = setmetatable
local pairs         = pairs
-- local pcall         = pcall
-- local tonumber      = tonumber
-- local join          = table.concat
local popen         = io.popen
-- local string = {
--     sub     = string.sub,
--     find    = string.find,
--     match   = string.match,
--     upper   = string.upper,
--     format  = string.format }

-- my stuff
local util          = require("gnarly.util")
-- local split         = util.split
-- local select        = table.select
-- local collect       = table.collect
local log           = util.log

module("gnarly.battery")

local battery = {}

-- wrap table keys in brackets
-- this is the vicious library convention
local function viciousify(table)
    vT = {}
    for k, v in pairs(table) do 
      vT["{" .. k .. "}"] = v 
    end
    return vT
end

-- TODO put this in UTIL
local function syscall(cmd)
    local f      = popen(cmd)
    local rs
    if f ~= nil then
            rs = f:read("*all")
            f:close()
    end
    return rs
end

-- {{{ Memory widget type
local function worker(format)
 
    local status        = {};
    local SYSBASE       = "/sys/class/power_supply/BAT0/"
    local st = syscall('cat ' .. SYSBASE .. 'status' .. '| tr -d "\n"')
    local ch = syscall('d='..SYSBASE..'; echo "scale=2; `cat "$d/charge_now"`/`cat "$d/charge_full"`*100" | bc')
    status['status']    = st
    status['charge']    = ch
    if status['status'] == "" then status['status'] = 'N/A' end
    if status['charge'] == "" then status['charge'] = 0 end
    return viciousify(status)
end

-- }}}

-- a little cargo-cult never hurt anybody ...
return setmetatable(battery, { __call = function(_, ...) return worker(...) end })
