pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--#include poom_images.lua


function escape_binary_str(s)
 local out=""
 for i=1,#s do
  local c  = sub(s,i,i)
  local nc = ord(s,i+1)
  local pr = (nc and nc>=48 and nc<=57) and "00" or ""
  local v=c
  if(c=="\"") v="\\\""
  if(c=="\\") v="\\\\"
  if(ord(c)==0) v="\\"..pr.."0"
  if(ord(c)==10) v="\\n"
  if(ord(c)==13) v="\\r"
  out..= v
 end
 return out
end

function _init()
	--local src=title_gfx.bytes
	--printh(escape_binary_str(src),"@clip")
	binstr=""
	for i=0,255 do
	 binstr..=chr(i) -- any data you like
	end
	printh(escape_binary_str(binstr), "@clip")
end

--[[
function _init()
 local out=""
 for c=0,255 do
	local c  = chr(c)
  local nc = ord(c)
  local pr = (nc and nc>=48 and nc<=57) and "00" or ""
  local v=c
  if(c=="\"") v="\\\""
  if(c=="\\") v="\\\\"
  if(ord(c)==0) v="\\"..pr.."0"
  if(ord(c)==10) v="\\n"
  if(ord(c)==13) v="\\r"
  out..="\""..v.."\","
 end
 printh(out,"@clip")
end
]]
