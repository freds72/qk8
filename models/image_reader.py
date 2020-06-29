import struct
import os
import re
import io
import math
from collections import namedtuple
from dotdict import dotdict
from python2pico import pack_int
from python2pico import pack_variant
from python2pico import pack_fixed
from python2pico import to_multicart
from python2pico import pack_int32
from PIL import Image, ImageFilter

# https://github.com/coells/100days
def lzw_encode(data):
    code, code_bits = {bytes([i]): i for i in range(256)}, 8
    buffer, buffer_bits = 0, 0
    index, aux = 0, []

    while index < len(data):
        # find word
        for j in range(index + 1, len(data) + 1):
            word = data[index:j]

            # store word
            if word not in code:
                code[word] = len(code)
                word = word[:-1]
                break

        # write buffer
        buffer <<= code_bits
        buffer |= code[word]
        buffer_bits += code_bits

        # code length
        if len(code) > 2 ** code_bits:
            code_bits += 1

        # shift
        index += len(word)

        # buffer alignment
        if index >= len(data) and buffer_bits % 8:
            r = 8 - (buffer_bits % 8)
            buffer <<= r
            buffer_bits += r

        # emit output
        if not buffer_bits % 8:
            aux += int.to_bytes(buffer, buffer_bits >> 3, 'big')
            buffer, buffer_bits = 0, 0

    return bytes(aux)

local_dir = os.path.dirname(os.path.realpath(__file__))

data = bytes([])
files = ['CYBRA1.png','CYBRA2.png','CYBRA3.png','CYBRA4.png','CYBRA5.png','CYBRA6.png','CYBRA7.png','CYBRA8.png']

img = Image.open("{}\\{}".format(local_dir,'palette_line.png'))
rgba_to_pico = {}
for x in range(17):
  rgba = img.getpixel((x,0))
  rgba_to_pico["{:02x}{:02x}{:02x}{:02x}".format(rgba[0],rgba[1],rgba[2],rgba[3])] = x==0 and 15 or x-1

metadata = pack_variant(len(files))
tiles = 0
for f in files:
  img = Image.open("{}\\resized\\{}".format(local_dir,f))
  transparency = img.info['transparency']

  palette = img.palette.palette
  indexed_to_rgba = []
  # rgb triplets
  for i in range(0,math.floor(len(palette)),3):
    indexed_to_rgba.append("{:02x}{:02x}{:02x}{:02x}".format(palette[i],palette[i+1],palette[i+2],0xff))

  width, height = img.size
  tw = math.floor(width/16)
  th = math.floor(height/16)
  print("Processing: {} - {}x{} pix".format(f,width,height))
  metadata += "{:02x}{:02x}".format(tw,th)

  frame_tiles = []
  for j in range(th):
    for i in range(tw):
      # read 16x16 blocks
      for y in range(16):
        for x in range(0,16,8):
          pixels = []
          for n in range(0,8,2):
            # image is using the pico palette (+transparency)
            # print(indexed_to_rgba[img.getpixel((i*16 + x + n, j*16 + y))])
            low = img.getpixel((i*16 + x + n, j*16 + y))
            low = low==transparency and 15 or rgba_to_pico[indexed_to_rgba[low]]
            high = img.getpixel((i*16 + x + n + 1, j*16 + y))
            high = high==transparency and 15 or rgba_to_pico[indexed_to_rgba[high]]
            pixels.append(low|high<<4)
          data += bytes(pixels[::-1])
      # reference to corresponding tiles
      frame_tiles.append(tiles)
      tiles += 1
  metadata += pack_variant(len(frame_tiles))
  for i in frame_tiles:
    # keep zero-based index
    metadata += pack_variant(i)

# compressed = lzw_encode(data)
# print("uncompressed:{} / compressed: {}".format(len(data),len(compressed)))

# total number of tiles
metadata += pack_variant(tiles)
# data
for b in data:
    metadata += "{:02x}".format(b)
# export as cart
to_multicart(metadata, "vsspr")


