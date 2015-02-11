---------------------------------------------------
-- Licensed under the GNU General Public License v2
--  * (c) 2013, Noah K. Tilton <noahktilton@gmail.com>
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
-- }}}

module("gnarly.yaourt")

-- Pkg: provides number of pending updates on UNIX systems
local yaourt = {}


-- {{{ Packages widget type
local function worker()
    local pacf = io.popen("pacman -Qu")
    local aurf = io.popen("yaourt --aur -Qu|grep ^aur")
    pacman = 0
    aur = 0
    for _ in pacf:lines() do
      pacman = pacman + 1
    end
    if aurf ~= nil then
            for _ in aurf:lines() do
              aur = aur + 1
            end
            pacf:close()
            aurf:close()
    end
    return {
      ["pacman"] = pacman,
      ["aur"] = aur,
    }
end
-- }}}

return setmetatable(yaourt, { __call = function(_, ...) return worker(...) end })
