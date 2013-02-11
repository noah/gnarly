-- © 2013 Noah K. Tilton <noah@tilton.co>
-- 
--      gnarly/cmus.lua -- vicious widget for cmus
--      inspired by vicious.widgets.*

-- need to declare this shit in local scope, otherwise it gets gobbled up
-- by module()
local helpers       = require("vicious.helpers")
local setmetatable  = setmetatable
local pairs         = pairs
local pcall         = pcall
local tonumber      = tonumber
local join          = table.concat
local popen         = io.popen
local string = {
    sub     = string.sub,
    find    = string.find,
    match   = string.match,
    upper   = string.upper,
    format  = string.format }

-- my stuff
local util          = require("gnarly.util")
local split         = util.split
local select        = table.select
local collect       = table.collect
local log           = util.log

module("gnarly.cmus")

local cmus = {}

local function parse_cmus_status(status_str)
    local status = {}
    -- cmus-remote -Q returns a newline-delimited string that has
    -- varying length depending on what metadata is available in the
    -- audio file.
    local key_map = {
        ["status"]      = "status",
        ["duration"]    = "duration",
        ["position"]    = "position",
        ["file"]        = "file",
        ["artist"]      = "tag artist",
        ["album"]       = "tag album",
        ["title"]       = "tag title",
        ["date"]        = "tag date",
        ["track"]       = "tag tracknumber",
        ["continue"]    = "set continue",
        ["repeat"]      = "set repeat",
        ["shuffle"]     = "set shuffle"
    }
    for my_key, cmus_prefix in pairs(key_map) do
      -- the format of the cmus-remote -Q output is:
      --    "$key $value"
      --
      -- this builds a regex dynamically to populate my_key with
      -- whatever text comes after cmus_prefix
      local assign = pcall(function () 
        local _, _, match = status_str:find(cmus_prefix .. " ([^\n]+)") 
        status[my_key] = helpers.escape(match)
      end)
    end

    return status
end

-- {{{ Memory widget type
local function worker(format)

    local SONGDELIM = " .. "
    local status_symbols = {
        ["playing"]   = ">",
        ["stopped"]   = ".",
        ["paused"]    = "="
    }

    -- defaults
    local cmus = { 
        ["{error}"]  = false,
        ["{status}"] = "not running"
    }

    local cmus_status_cmd   = "/usr/bin/cmus-remote -Q 2>&1"
    local f                 = popen(cmus_status_cmd)
    local rs                = f:read("*all")
    f:close()

    -- not found/executable
    if rs == nil or rs:find("No such file or directory") then
        cmus["{error}"], cmus["{status}"] = true, "cmus not found"
        return cmus
    end

    if rs:find("cmus is not running") then return cmus end

    -- cmus is running, so get the status
    local status = parse_cmus_status(rs)

    -- note:  lua coerces strings to numbers automatically, and has *no
    -- integers* ==> no integer division
    elapsed_pct             = 100 * status["position"] / status["duration"]
    remains_pct             = 100-elapsed_pct
    cmus["{elapsed_pct}"]   = string.format("%d%%", elapsed_pct)
    cmus["{remains_pct}"]   = string.format("%d%%", remains_pct)
    cmus["{status_symbol}"] = status_symbols[status["status"]]
    cmus["{song}"]          = join({status["artist"], status["album"], status["title"]}, SONGDELIM)
    cmus["{CRS}"]           = join(collect( select({"continue", "repeat", "shuffle"}, 
                                    function(key) 
                                        return status[key] == "true" 
                                    end), 
                                        function(item) 
                                            return item:sub(1, 1):upper()
                                        end), "")

    for k, v in pairs(status) do cmus["{" .. k .. "}"] = v end

    return cmus
end

-- }}}

-- a little cargo-cult never hurt anybody ...
return setmetatable(cmus, { __call = function(_, ...) return worker(...) end })
