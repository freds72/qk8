pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
local _sprite_cache
local _frames,_tiles
function _init()
	_frames,_tiles=unpack_sprites()
	_sprite_cache=make_sprite_cache(32)
end

function vspr(sx,sy,angle,scale)
	palt(15,true)
	local frame=_frames[flr(angle*#_frames)+1]
	local w,h,tiles=unpack(frame)
  --local scale=16--((abs(cos(time()/4))+2)<<4)\1+1
	for i,tile in pairs(tiles) do
		local ssx,ssy=_sprite_cache:use(tile,_tiles)
		sspr(ssx,ssy,16,16,sx+(i%w-w/2)*scale,sy+(i\w-h)*scale,scale,scale)
		-- print(tile,(i%w)*16,(i\w)*16,7)
	end
end

local angle=0
function _update()
	if(btnp(0)) angle-=0.05
	if(btnp(1)) angle+=0.05
	angle=(angle%1+1)%1
end

function _draw()
	cls(1)
	--vsspr(1,64,64,1)
	--spr(0,0,64,16,8)
	palt(0,false)
	for i=16,96,32 do
		vspr(i,64,angle,16)
	end
	palt()

	-- spr(0,0,64,16,8)

	--_sprite_cache:print(2,16,7)
	--_sprite_cache:draw(64)
	print(stat(1).."\n"..stat(0),90,2,8)

	pal({140,1,3,131,4,132,133,7,6,134,5,8,2,9,10},1)
end
-->8
-- https://github.com/luapower/linkedlist/blob/master/linkedlist.lua
function make_sprite_cache(maxlen)
	local len,index,first,last=0,{}

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
		index={},
		use=function(self,id,tiles)
			local entry=index[id]
			if entry then
				-- existing item?
				-- force refresh
				remove(entry)
			else
				-- allocate a new 16x16 entry
				-- todo: optimize
				local sx,sy=(len<<4)&127,((len<<4)\128)<<4
				-- list too large?
				if len+1>maxlen then
					local old=remove(first)
					-- reuse cache entry
					sx,sy=old[1],old[2]
					index[old.id]=nil
				end
				-- new (or relocate)
				-- copy data to sprite sheet
				local mem=(sx\2)|sy<<6
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
		end,
		print=function(self,x,y,c)
		 color(c)
			local head=first
			while head do
			 print(head.id.." "..head.t,x,y)
			 y+=6
				head=head._next
			end
		end,
		draw=function(self,sy)
			local t,head=time(),first
			while head do
			 local slot=head.slot
				pset(slot%128,sy+slot\128,15*head.t/t)
				head=head._next
			end			
		end
	}
end

-->8
-- unpack data
local cart_id,mem
local cart_progress=0
function mpeek()
	if mem==0x4300 then
		cart_progress=0
    cart_id+=1
		reload(0,0,0x4300,"vsspr_"..cart_id..".p8")
		mem=0
	end
	local v=peek(mem)
	if mem%779==0 then
		cart_progress+=1
		rectfill(0,120,shl(cart_progress,4),127,cart_id%2==0 and 1 or 7)
		flip()
  end
	mem+=1
	return v
end

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
	for i=1,unpack_variant() do
		fn(i)
	end
end

function unpack_sprites()
  -- jump to data cart
  cart_id,mem=0,0
  reload(0,0,0x4300,"vsspr_"..cart_id..".p8")

	local frames,tiles={},{}
	unpack_array(function()
		-- width/height
		local w,h=mpeek(),mpeek()
		local frame=add(frames,{w,h,{}})
		unpack_array(function()
			-- tile index
			frame[3][mpeek()]=unpack_variant()
		end)
	end)
	unpack_array(function()
		-- 16 rows of 2*8 pixels
		for k=0,31 do
			add(tiles,unpack_fixed())
		end
	end)
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
