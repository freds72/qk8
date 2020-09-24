pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
#include lzs.lua

local _sprite_cache
local _frames,_tiles
function _init()
	-- multicart peek global function
	_frames,_tiles=decompress("vsspr",0,0,unpack_sprites)
	_sprite_cache=make_sprite_cache(_tiles,32)
end

function vspr(frame,sx,sy,scale,flipx)
  -- faster equivalent to: palt(0,false)
  poke(0x5f00,0)
  local w,xoffset,yoffset,tc,tiles=unpack(frame)
  palt(tc,true)
  local sw,xscale=xoffset*scale,flipx and -scale or scale
  sx-=sw
  -- todo: bug?
  if(flipx) sx+=sw  
	sy-=yoffset*scale
	for i,tile in pairs(tiles) do
    local dx,dy,ssx,ssy=sx+(i%w)*xscale,sy+(i\w)*scale,_sprite_cache:use(tile)
    -- scale sub-pixel fix 
    sspr(ssx,ssy,16,16,dx,dy,scale+dx%1,scale+dy%1,flipx)
    -- print(tile,(i%w)*16,(i\w)*16,7)
  end
  palt()
end

local angle,scale=0,16
function _update()
	if(btnp(0)) angle-=0.01
	if(btnp(1)) angle+=0.01
	if(btnp(2)) scale-=0.25
	if(btnp(3)) scale+=0.25
	angle=(angle%1+1)%1
end

function _draw()
	cls(1)
	--vsspr(1,64,64,1)
	--spr(0,0,64,16,8)
	palt(0,false)
	--for i=16,96,32 do
		local frame=_frames[flr(angle*#_frames)+1]
		vspr(frame,32,96,scale,btn(4))

		--vspr2(96,96,angle,scale,btn(4))

		--end
	palt()

	-- spr(0,0,64,16,8)

	--_sprite_cache:print(2,16,7)
	--_sprite_cache:draw(64)
	print(stat(1).."\n"..stat(0).."\n"..scale,90,2,8)

	pal({140,1,139,3,4,132,133,7,6,134,5,8,2,9,10},1)
end
-->8
-- https://github.com/luapower/linkedlist/blob/master/linkedlist.lua
function make_sprite_cache(tiles,maxlen)
	local len,index,first,last=0,{}

  -- note: keep multiline assignments, they are *faster*
	local function remove(t)
		if t._next then
			if t._prev then
				t._next._prev = t._prev
				t._prev._next = t._next
			else
				t._next._prev = nil
				first = t._next
			end
		elseif t._prev then
			t._prev._next = nil
			last = t._prev
		else
			first = nil
			last = nil
		end
		-- gc
		t._next = nil
		t._prev = nil
		len-=1
		return t
	end
	
	return {
    use=function(self,id)
			local entry=index[id]
			if entry then
				-- existing item?
				-- force refresh
				remove(entry)
			else
				-- allocate a new 16x16 entry
				-- todo: optimize
				local sx,sy=(len<<4)&127,64+(((len<<4)\128)<<4)
				-- list too large?
				if len+1>maxlen then
					local old=remove(first)
					-- reuse cache entry
					sx,sy,index[old.id]=old[1],old[2]
				end
				-- new (or relocate)
				-- copy data to sprite sheet
				local mem=sx\2|sy<<6
				for j=0,31 do
					poke4(mem|(j&1)<<2|(j\2)<<6,tiles[id+j])
				end		
				--
				entry={sx,sy,id=id}
				-- reverse lookup
				index[id]=entry
			end
			-- insert 'fresh'
			local anchor=last
			if anchor then
				if anchor._next then
					anchor._next._prev=entry
					entry._next=anchor._next
				else
					last=entry
				end
				entry._prev=anchor
				anchor._next=entry
			else
			 -- empty list use case
				first,last=entry,entry
			end
			len+=1
			-- return sprite sheet coords
			return entry[1],entry[2]
		end
	}
end

-->8
-- w: number of bytes (1 or 2)
function unpack_int(w)
  w=w or 1
	local i=w==1 and mpeek() or mpeek()<<8|mpeek()
  return i
end
-- unpack 1 or 2 bytes
function unpack_variant()
	local h=mpeek()
	-- above 127?
  if h&0x80>0 then
    local hl=mpeek()
    h=(h&0x7f)<<8|hl
  end
	return h
end
-- unpack a fixed 16:16 value
function unpack_fixed()
	return mpeek()<<8|mpeek()|mpeek()>>8|mpeek()>>16
end

-- unpack an array of bytes
function unpack_array(fn)
	local n=unpack_variant()
	printh("array:"..n)
	for i=1,n do
		fn(i)
	end
end

function unpack_sprites()
	local frames,tiles={},{}
  unpack_array(function()
    -- packed:
    -- width/transparent color
    -- xoffset/yoffset in tiles unit (16x16)
    local wtc=mpeek()
		local frame=add(frames,{wtc&0xf,(mpeek()-128)/16,(mpeek()-128)/16,flr(wtc>>4),{}})
		unpack_array(function()
			-- tiles index
			frame[5][mpeek()]=unpack_variant()
    end)
  end)
  -- sprite tiles
	unpack_array(function()
		-- 16 rows of 2*8 pixels
		for k=0,31 do
			add(tiles,unpack_fixed())
		end
  end)
	printh("frames#:"..#frames)
	printh("tiles#:"..#tiles)

	-- restore spritesheet
	reload()
	return frames,tiles
end


__gfx__
88888888222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88788788222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88877888222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88877888222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88788788222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888222222220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
