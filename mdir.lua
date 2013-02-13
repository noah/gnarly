---------------------------------------------------
-- This file is licensed under the GNU General Public License v2
--  * (c) 2013, Noah K. Tilton <noahktilton@gmail.com>
--  * (c) 2010, Adrian C. <anrxc@sysphere.org>
--  * (c) Maildir Biff Widget, Fredrik Ax
---------------------------------------------------

-- {{{ Grab environment
local io = { popen = io.popen }
local setmetatable = setmetatable
-- }}}


-- Mdir: provides the number of new and unread messages in Maildir structures/dirs
-- gnarly.widgets.mdir
local mdir = {}


-- {{{ Maildir widget type
local function worker(format, warg)
    if not warg then return end

    local mailboxes = {}

    local f = io.popen("ls " .. warg .. "/*/new/*|grep -v Junk\\/new")
    for line in f:lines() do
        name = line:match(".*/(.*)/new.*")
        if mailboxes[name] == nil then mailboxes[name] = 0 end
        mailboxes[name] = mailboxes[name] + 1 
    end
    f:close()

    return mailboxes
end
-- }}}

return setmetatable(mdir, { __call = function(_, ...) return worker(...) end })
