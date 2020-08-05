import os
from subprocess import Popen, PIPE
import re
import tempfile
import random
import math
import socket

# file helpers
local_dir = os.path.dirname(os.path.realpath(__file__))
pico_dir = ""
if socket.gethostname()=="FRWS3706":
    pico_dir = os.path.join("C:",os.path.sep,"pico-8-0.2.0")
else:
    pico_dir = os.path.join("D:",os.path.sep,"pico-8_0.1.12c")

def call(args):
    proc = Popen(args, stdout=PIPE, stderr=PIPE)
    out, err = proc.communicate()
    exitcode = proc.returncode
    #
    return exitcode, out, err

# pack helpers
def tohex(val, nbits):
    return (hex((int(round(val,0)) + (1<<nbits)) % (1<<nbits))[2:]).zfill(nbits>>2)

# variable length packing (1 or 2 bytes)
def pack_variant(x):
    x=int(x)
    if x>0x7fff:
      raise Exception('Unable to convert: {} into a 1 or 2 bytes'.format(x))
    # 2 bytes
    if x>127:
        h = "{:04x}".format(x + 0x8000)
        if len(h)!=4:
            raise Exception('Unable to convert: {} into a word: {}'.format(x,h))
        return h
    # 1 byte
    h = "{:02x}".format(x)
    if len(h)!=2:
        raise Exception('Unable to convert: {} into a byte: {}'.format(x,h))
    return h

# single byte (unsigned short)
def pack_byte(x):
    h = tohex(x,8)
    if len(h)!=2:
        raise Exception('Unable to convert: {} into a byte: {}'.format(x,h))
    return h
    
# short must be between -32000/32000
def pack_int(x):
    h = tohex(x,16)
    if len(h)!=4:
        raise Exception('Unable to convert: {} into a word: {}'.format(x,h))
    return h

def pack_int32(x):
    h = tohex(x,32)
    if len(h)!=8:
        raise Exception('Unable to convert: {} into a dword: {}'.format(x,h))
    return h

# 16:16 fixed point value
def pack_fixed(x):
    h = tohex(int(x*(1<<16)),32)
    if len(h)!=8:
        raise Exception('Unable to convert: {} into a dword: {}'.format(x,h))
    return h

# short must be between -127/127
def pack_short(x):
    h = "{:02x}".format(int(round(x+128,0)))
    if len(h)!=2:
        raise Exception('Unable to convert: {} into a byte: {}'.format(x,h))
    return h

# float must be between -4/+3.968 resolution: 0.03125
def pack_float(x):
    h = "{:02x}".format(int(round(32*x+128,0)))
    if len(h)!=2:
        raise Exception('Unable to convert: {} into a byte: {}'.format(x,h))
    return h
# double must be between -128/+127 resolution: 0.0078
def pack_double(x):
    h = "{}".format(tohex(128*x+16384,16))
    if len(h)!=4:
        raise Exception('Unable to convert: {} into a word: {}'.format(x,h))
    return h

def to_cart(s,cart_name,cart_id):
    cart="""\
pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- data cart
-- @freds72
local data="{}"
local mem=0x3100
for i=1,#data,2 do
    poke(mem,tonum("0x"..sub(data,i,i+1)))
    mem+=1
end
cstore()
"""
    tmp=s[:2*0x2000]
    # swap bytes
    gfx_data = ""
    for i in range(0,len(tmp),2):
        gfx_data = gfx_data + tmp[i+1:i+2] + tmp[i:i+1]
    cart += "__gfx__\n"
    cart += re.sub("(.{128})", "\\1\n", gfx_data, 0, re.DOTALL)

    map_data=s[2*0x2000:2*0x3000]
    if len(map_data)>0:
        cart += "__map__\n"
        cart += re.sub("(.{256})", "\\1\n", map_data, 0, re.DOTALL)

    gfx_props=s[2*0x3000:2*0x3100]
    if len(gfx_props)>0:
        cart += "__gff__\n"
        cart += re.sub("(.{256})", "\\1\n", gfx_props, 0, re.DOTALL)

    # save cart + export cryptic music+sfx part
    sfx_data=s[2*0x3100:2*0x4300]
    cart_path = os.path.join(local_dir, "..", "carts", "{}_{}.p8".format(cart_name,cart_id))
    f = open(cart_path, "w")
    f.write(cart.format(sfx_data))
    f.close()

    # run cart
    exitcode, out, err = call([os.path.join(pico_dir,"pico8.exe"),"-x",cart_path])
    if err:
        raise Exception('Unable to process pico-8 cart: {}. Exception: {}'.format(cart_path,err))

def to_multicart(s,cart_name):
  cart_id = 0
  cart_data = ""
  for b in s:
      cart_data += b
      # full cart?
      if len(cart_data)==2*0x4300:
          to_cart(cart_data,cart_name,cart_id)
          cart_id += 1
          cart_data = ""
  # remaining data?
  if len(cart_data)!=0:
      to_cart(cart_data,cart_name,cart_id)


def pack_sprite(arr):
    return ["".join(map("{:02x}".format,arr[i*4:i*4+4])) for i in range(8)]

def map_tiles_to_cart(name,width,map_data,gfx_data):
    cart="""\
pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- poom
-- @freds72
#include main.lua
"""
    # transpose gfx
    gfx_data=[pack_sprite(data) for data in gfx_data]
    print("Packing {} texture tiles".format(len(gfx_data)))

    s = ""
    rows = [""]*8
    for i,img in enumerate(gfx_data):
        # full row?
        if i%16==0:
            # collect
            s += "".join(rows)
            rows = [""]*8           
        for j in range(8):
            rows[j] += img[j]

    # remaining tiles
    s += "".join([row + "0" * (128-len(row)) for row in rows])
    s += "0"*(128*64-len(s))
    s += "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111122000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000333442200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004444220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055566722000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000666672200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007777220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088899ab7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999aab70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaabb700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbb7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccdd70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddd7700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eee55670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffe567000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"

    # convert to string
    cart += "__gfx__\n"
    cart += re.sub("(.{128})", "\\1\n", s, 0, re.DOTALL)
    cart += "\n"

    # pad map
    map_data = ["".join(map("{:02x}".format,map_data[i:i+width] + [0]*(128-width))) for i in range(0,len(map_data),width)]
    map_data = "".join(map_data)
    cart += "__map__\n"
    cart += re.sub("(.{256})", "\\1\n", map_data, 0, re.DOTALL)

    cart_path = os.path.join(local_dir, "..", "carts", "{}.p8".format(name))
    f = open(cart_path, "w")
    f.write(cart)
    f.close()

