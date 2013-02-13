gnarly
=====

A collection of **vicious library widgets** for the **awesome window manager**.

Widget types
========

**gnarly.widgets.cmus**

- For the [cmus](http://cmus.sourceforge.net/) audio player!
- Queries `cmus-remote` at a configurable interval and returns a
  dict of parsed output

always available fields

    - status        - textual status ("playing", "paused", "stopped")
    - duration      - integer duration
    - position      - integer position
    - file          - track path
    - elapsed_pct   - track elapsed percentage
    - remains_pct   - track remaining percentage
    - continue      - bool
    - repeat        - bool
    - shuffle       - bool
    - CRS           - string showing a subset of "CRS"

usually available fields (depending on track metadata)

    - artist        - track artist
    - album         - track album
    - title         - track title
    - song          - track "artist - album - title"
    - date          - track year
    - track         - track number

**gnarly.widgets.mdir**

- Returns a table of `{maildir basename = count of new messages}`


Usage
=====

    % git clone git://github.com/noah/gnarly.git $XDG_CONFIG_HOME/awesome

Edit `rc.lua`:

```Lua
vicious.register(musicbox, gnarly.cmus, 
  function(widget, T)
    if T["{error}"] then return "error: " .. T["{status}"] end
    if T["{status}"] == "stopped" or T["{status}"] == "not running" then 
      return string.format("♫ %s", T["{status_symbol}"]) 
    end

    return string.format("♫  %s %s %s %s", 
                            T["{status_symbol}"],
                            T["{song}"],
                            T["{remains_pct}"],
                            T["{CRS}"]
                        )
  end, 2)

vicious.register(mdirbox, gnarly.mdir, 
    function(widget, mailboxes)

      if #mailboxes > 0 then
          _t = {}
          for k, v in pairs(mailboxes) do
            table.insert(_t, "{" .. k .. " => " .. v .. "}")
          end
          return join(_t, " ")
      else
          return "No new mail."
      end

    end, 1, "/home/noah*/mail/noah*@*.com")
```

That will produce a cmus status line like the following:

    ♫ > Neil Young & Crazy Horse .. Ragged Glory .. F*!#In' Up 92% CR

And will print out some maildir labels with associated unread message
counts:

    {@todo => 3} {work => 5} {amazon => 2}
