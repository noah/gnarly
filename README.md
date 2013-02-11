gnarly
=====

A collection of **vicious library widgets** for the **awesome window manager**.

Currently includes widget types for:

# [cmus](http://cmus.sourceforge.net/) audio player

To use, create something like this in your `rc.lua:`

    vicious.register(musicbox, gnarly.cmus, 
      function(widget, T)
        if T["{error}"] then
            return "error: " .. T["{status}"]
        end
        if T["{status}"] == "stopped" then
          return string.format("♫ %s", T["{status_symbol}"])
        end
    
        return string.format("♫  %s %s %s %s", 
                                T["{status_symbol}"],
                                T["{song}"],
                                T["{remains_pct}"],
                                T["{CRS}"]
                            )
      end, 2)

That will produce a status line like the following:

    ♫ > Neil Young & Crazy Horse .. Ragged Glory .. F*!#In' Up 92% CR

## always available fields:
 
    
    status        - textual status ("playing", "paused", "stopped")
    duration      - integer duration
    position      - integer position
    file          - track path
    elapsed_pct   - track elapsed percentage
    remains_pct   - track remaining percentage
    continue      - bool
    repeat        - bool
    shuffle       - bool
    CRS           - string showing a subset of "CRS"

## usually available fields (depends on track metadata):

    artist        - track artist
    album         - track album
    title         - track title
    song          - track "artist - album - title"
    date          - track year
    track         - track number
