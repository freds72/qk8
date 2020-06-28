pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- data cart
-- @freds72
local data=""
local mem=0x3100
for i=1,#data,2 do
    poke(mem,tonum("0x"..sub(data,i,i+1)))
    mem+=1
end
cstore()
__gfx__
10101010101010101000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101000010101010101010101010101010010101010101010101010101000001010101010101010101010100000
10101010101010101010101010000001010101010101010101010101001010101010101010101010101010100001010101010101010101010101010110101010
10101010101010000000010101010101010101000000101010101010101000000000101010101010101000000000101010101010101000000000101010101010
10000000000001010101010000000000101010100001010000000010101010000101000000001010101010000000000000010101010101000000000001010101
01010100000000101010101010000000000010101010101010000000000001010101010101010000000001010101010101010100000010101010101010101010
00000010101010101010101010000000101010101010101000000000101010101010100000000000010101010101000000000001010101010000000000101010
10100000000000000101010100000000000001010100000000000010100000000000000010000000000000000000000000000000000000000000000010000000
00000000101000000000000000101010000000000000101010100000000000000101010101000000000010101010101000000000001010101010100000000000
10101010101000000000001010101010100000000000101010101010000000000010101010101000000000001010101010101000000000000101010101010000
00000010101010101000000000001010101010101000000000000101010101010100000000000101010101010000000000010101010101010000000001010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010100000000000001010101000000000001010101000000000000010101000000000000100000100000000000000010100000
00000000001010000000000000101010100000000000101010101010000000000000010101010100000000000010101000000000000000101000000000000000
10100000000000000010100000000000000001010100000000000010101000000000000000010101000000000000101010000000000000000101010000000000
00010101010000000000000101010100000000000001010101000000000000010101010000000000001010100000000000000001010100000000000000010100
00000000000010000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000001010000000000001010100000000000001010101010000000000000010101010100000000001010101010100000000000010101010101
01010000000001010101010101010000000001010101010101010000000001010101010101010000000010101010101010000000000001010101010101010000
00000101010101010101010000001010101010101010100000000001010101010101010101000000010101010101010101010100001010101010101010101010
10000010101010101010101010101000001010101010101010101010101000000101010101010101010101010000010101010101010101010101000001010101
01010101010101010100101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
10101010101010101010101010101010101010101010101010101010101010101010101010101010101000010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010110101010101010101010101010101000010101010101
01010101010101010101010101010101010101010101010101101010101010101010101010101010000101010101010101010101010101010001010101010101
01010101010101000101010101010101010101010101000101010101010101010101010101000101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101101010101010101010101010101010000101010101010101010101010101011010101010101010101010101010100010101010101010101010101010
10000001010101010101010101010101000001010101010101010101010100001010101010101010101010000000010101010101010101010100000001010101
01010101010100000001010101010101010101000000010101010101010101010000000101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010110000000