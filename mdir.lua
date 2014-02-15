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


gnarly.util     = require("gnarly.util")
local log=gnarly.util.log

-- {{{ Maildir widget type
local function worker(format, warg)
    if not warg then return end

    local mailboxes = {}
    local f         = io.popen("ls " .. warg .. "/*/new/* 2>/dev/null |grep -v Junk\\/new")

    if f then
      for line in f:lines() do
          name = line:match(".*/(.*)/new.*")

          -- don't report any mail in INBOX newer than 5 minutes
          -- (this mail probably hasn't been picked up by the filter yet)
          skip = false
          if name == "INBOX" then
              local mtime   = io.popen("stat -c %Z " .. line):read("*l")
              local now     = io.popen("date +%s"):read("*l")
              -- log(line .. " " .. now-mtime)
              if not (mtime == nil) and (now-mtime < 90) then
                skip = true
              end
          end
          if not skip then
            if mailboxes[name] == nil then mailboxes[name] = 0 end
            mailboxes[name] = mailboxes[name] + 1 
          end
      end
      f:close()
    end

    return mailboxes
end
-- }}}

return setmetatable(mdir, { __call = function(_, ...) return worker(...) end })
