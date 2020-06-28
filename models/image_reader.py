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

local_dir = os.path.dirname(os.path.realpath(__file__))

data = ""
files = ['CYBRA1.png','CYBRA2.png','CYBRA3.png','CYBRA4.png','CYBRA5.png','CYBRA6.png','CYBRA7.png','CYBRA8.png']
metadata = pack_variant(len(files))
tiles = 0
for f in files:
  img = Image.open("{}\\resized\\{}".format(local_dir,f))

  pal = img.palette.palette
  for i in range(math.floor(len(pal)/3)):
    print("{:02x}{:02x}{:02x}".format(pal[i],pal[9+i],pal[18+i]))

  width, height = img.size
  tw = math.floor(width/16)
  th = math.floor(height/16)
  print("Processing: {} - {}x{} pix".format(f,width,height))
  metadata += "{:02x}{:02x}".format(tw,th)

  frame_tiles = []
  for j in range(th):
    for i in range(tw):
      # reference to corresponding tiles
      frame_tiles.append(tiles)
      # read 16x16 blocks
      for y in range(16):
        pixels = []
        for x in range(16):
          # image is using the pico palette (+transparency)
          # print("{}/{} - {},{}".format(i,j,i*16 + x, j*16 + y))
          pixels.append(img.getpixel((i*16 + x, j*16 + y)))
        for x in range(16):
          data += "{:01x}".format(pixels[math.floor(x/8)*8+7-(x%8)])
      tiles += 1
  metadata += pack_variant(len(frame_tiles))
  for i in frame_tiles:
    # keep zero-based index
    metadata += pack_variant(i)

# total number of tiles
metadata += pack_variant(tiles)
# export as cart
to_multicart(metadata + data, "vsspr")


