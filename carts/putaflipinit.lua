
-->8
-- put a flip in it
-- https://gist.github.com/kometbomb/9a644e9814330ee067b72e051c7d1965
function cflip(len) if(slowflip) for i=0,len or 0 do flip() end flip()
end
odraw_flats=draw_flats
function draw_flats(...)
  odraw_flats(...)
  cflip(5)
end
otline=tline
function tline(...)
  otline(...)
  cflip()
end
opolyfill=polyfill
function polyfill(...)
  opolyfill(...)
  cflip()
end
ospr=spr
function spr(...)
ospr(...)
cflip()
end
osspr=sspr
function sspr(...)
osspr(...)
cflip(4)
end
omap=map
function map(...)
omap(...)
cflip()
end
orect=rect
function rect(...)
orect(...)
cflip()
end
odraw=_draw
function _draw()
if(slowflip)extcmd("rec")
odraw()
if(slowflip)for i=0,99 do flip() end extcmd("video")cls()stop("gif saved")
end
menuitem(1,"put a flip in it!",function() slowflip=not slowflip end)