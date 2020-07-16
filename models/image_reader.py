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

def rgba_to_string(rgba):
  return "{:02x}{:02x}{:02x}{:02x}".format(rgba[0],rgba[1],rgba[2],rgba[3])
class WADImageReader():  
  def __init__(self):
    # cache already processed tiles
    # image name -> tiles
    self.frames = {}
    # read game palette  
    local_dir = os.path.dirname(os.path.realpath(__file__))
    img = Image.open("{}\\{}".format(local_dir,'palette_line.png'))
    self.rgba_to_pico = {}
    for x in range(17):
      rgba = img.getpixel((x,0))
      self.rgba_to_pico[rgba_to_string(rgba)] = x==0 and 3 or x-1
    # alternate transparency color
    self.rgba_to_pico["00000000"] = 3

  # convert a wad image into a pair of tiles address and tiles data (binary)
  def read(self, file, lumps, name):
    # read from WAD
    entry = lumps.get(name,None)
    if not entry:
      raise Exception("Missing WAD image: {}".format(name))

    file.seek(entry.lump_ofs)
    image_data = file.read(entry.lump_size)
    # get offsets (if any)

    src = Image.open(io.BytesIO(image_data))
    src_width, src_height = src.size

    # resize to multiple of 16x16
    # + force known image format
    width = 16*(math.ceil(src_width/16))
    height = 16*(math.ceil(src_height/16))
    if width>64 or height>64:
      raise Exception("Image: {} too large: {}x{} - must be 64x64 max.".format(name,width,height))

    img = Image.new('RGBA', (width, height), (0,0,0,0))
    img.paste(src, (0,0,src_width,src_height))

    tw = math.floor(width/16)
    th = math.floor(height/16)
    print("Processing: {} - {}x{} pix -> {}x{}".format(name,src_width,src_height,width,height))

    data = bytes([])
    frame_tiles = {}
    tiles = 0
    for j in range(th):
      for i in range(tw):
        # read 16x16 blocks
        image_data = bytes([])
        for y in range(16):
          for x in range(0,16,8):
            pixels = []
            for n in range(0,8,2):
              # image is using the pico palette (+transparency)
              # print(indexed_to_rgba[img.getpixel((i*16 + x + n, j*16 + y))])
              low = img.getpixel((i*16 + x + n, j*16 + y))
              low = self.rgba_to_pico[rgba_to_string(low)]
              high = img.getpixel((i*16 + x + n + 1, j*16 + y))
              high = self.rgba_to_pico[rgba_to_string(high)]
              pixels.append(low|high<<4)
            image_data += bytes(pixels[::-1])
        # skip fully transparent tile
        if not all(b==0xff for b in image_data):
          data += image_data
          # reference to corresponding tiles
          frame_tiles[j*tw+i] = tiles
          tiles += 1

    return dotdict({
      'name': name,
      'tiles': frame_tiles,
      'width':  tw,
      'height': th,
      'xoffset': width-src_width,
      'yoffset': height-src_height,
      'data': data})
