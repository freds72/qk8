import os
from subprocess import Popen, PIPE
import re
import tempfile
import random
import math
import socket
import shutil

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

def to_cart(s,pico_path,carts_path,cart_name,cart_id,cart_code=None):
    cart="""\
pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- {} data cart
-- @freds72
local data="{}"
local mem=0x3100
for i=1,#data,2 do
    poke(mem,tonum("0x"..sub(data,i,i+1)))
    mem+=1
end
cstore(0, 0, 0x4300, "{}")
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
    cart_filename = "{}_{}.p8".format(cart_name,cart_id)
    cart_path = os.path.join(carts_path,"{}_tmp.p8".format(cart_name))
    with open(cart_path, "w") as f:
        f.write(cart.format(cart_name, sfx_data, cart_filename))
    # run cart
    exitcode, out, err = call([os.path.join(pico_path,"pico8.exe"),"-x",os.path.abspath(cart_path)])
    if err:
        raise Exception('Unable to process pico-8 cart: {}. Exception: {}'.format(cart_path,err))
    if cart_code:
        cart = cart_code
        with open(os.path.join(carts_path,cart_filename),"r") as f:
            copy = False
            for line in f:
                line = line.rstrip("\n\r")
                if line in ["__lua__"]:
                    # skip code section
                    copy = False
                elif re.match("__([a-z]+)__",line):
                    # any other section
                    copy = True
                if copy:
                    cart += line
                    cart += "\n"
        with open(os.path.join(carts_path,cart_filename),"w") as f:                   
            f.write(cart)
    os.unlink(cart_path)

def to_multicart(s,pico_path,carts_path,cart_name,boot_code=None):
  cart_id = 0
  cart_data = ""
  for b in s:
      cart_data += b
      # full cart?
      if len(cart_data)==2*0x4300:
          to_cart(cart_data, pico_path, carts_path, cart_name, cart_id, cart_id==0 and boot_code)
          cart_id += 1
          cart_data = ""
  # remaining data?
  if len(cart_data)!=0:
      to_cart(cart_data, pico_path, carts_path, cart_name, cart_id, cart_id==0 and boot_code)
  return cart_id

