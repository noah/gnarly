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
        ["shuffle"]     = "set shuffle",
        -- requires cmus 2.6.0+
        ["stream"]      = "stream"
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

-- wrap table keys in brackets
-- this is the vicious library convention
local function viciousify(table)
    vT = {}
    for k, v in pairs(table) do 
      vT["{" .. k .. "}"] = v 
    end
    return vT
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
    local status = { 
        ["error"]           = false,
        ["status"]          = "not running",
        ["status_symbol"]   = status_symbols["stopped"]
    }

    local cmus_status_cmd   = "/usr/bin/cmus-remote -Q 2>&1"
    local f                 = popen(cmus_status_cmd)
    local rs
    if f ~= nil then
            rs = f:read("*all")
            f:close()
    end

    -- not found/executable
    if rs == nil or rs:find("No such file or directory") then
        status["error"], status["status"] = true, "cmus not found"
        return viciousify(status)
    end

    if rs:find("cmus is not running") then return viciousify(status) end

    -- cmus is running, so get the status
    local status = parse_cmus_status(rs)
    status["status_symbol"] = status_symbols[status["status"]]

    streaming = not (status["stream"] == nil)

    if not (status["status"] == "stopped") then
        -- note:  lua coerces strings to numbers automatically, and has *no
        -- integers* ==> no integer division
        --if tonumber(status["duration"]) < 0 then
            -- most likely, we're playing a stream
        if streaming then
            status["elapsed_pct"]   = "∞"
            status["remains_pct"]   = "∞"
            status["song"] = status["title"] .. " / " .. status["stream"]
        else
            elapsed_pct             = 100 * status["position"] / status["duration"]
            remains_pct             = 100-elapsed_pct
            status["elapsed_pct"]   = string.format("%d%%", elapsed_pct)
            status["remains_pct"]   = string.format("%d%%", remains_pct)
            status["song"] = join(collect( select({"artist", "album", "title"}, 
                                    function(key) 
                                        return status[key] ~= nil 
                                    end), 
                                        function(key)
                                            return status[key]
                                        end), SONGDELIM)
        end
    end


    status["CRS"]  = join(collect( select({"continue", "repeat", "shuffle"}, 
                                    function(key) 
                                        return status[key] == "true" 
                                    end), 
                                        function(item) 
                                            return item:sub(1, 1):upper()
                                        end), "")

    return viciousify(status)
end

-- }}}

-- a little cargo-cult never hurt anybody ...
return setmetatable(cmus, { __call = function(_, ...) return worker(...) end })
