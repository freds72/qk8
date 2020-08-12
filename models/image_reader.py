import struct
import os
import re
import io
import math
from collections import namedtuple
from dotdict import dotdict
from PIL import Image, ImageFilter

# helper methods for image manipulation
class ImageReader():  
  def __init__(self, stream, palette):
    # cache already processed tiles
    # image name -> tiles
    self.frames = {}
    self.rgba_to_pico = {}
    for i,rgba in enumerate(palette):
      self.rgba_to_pico[rgba] = i
    # forced transparency color
    self.rgba_to_pico[(00,00,00,00)] = -1
    self.rgba_to_pico[(255,255,255,0)] = -1
    if stream is None:
      raise Exception("Missing resource stream parameter")
    self.stream = stream

  # convert a wad image into a pair of tiles address and tiles data (binary)
  def read(self, name):
    image_data = self.stream.read(name)

    # read image bytes
    src_io = io.BytesIO(image_data)
    src_bytes = bytes(src_io.getbuffer())

    src = Image.open(src_io)
    src_width, src_height = src.size

    # resize to multiple of 16x16
    # + force known image format
    width = 16*(math.ceil(src_width/16))
    height = 16*(math.ceil(src_height/16))
    if width>64 or height>64:
      raise Exception("Image: {} too large: {}x{} - must be 64x64 max.".format(name,width,height))

    # get offsets (if any)
    xoffset = src_width/2
    yoffset = src_height
    pattern_index = src_bytes.find(b"grAb")
    if pattern_index!=-1:
      xoffset,yoffset = struct.unpack_from(">ii",src_bytes,pattern_index+4)
      print("Custom offset: {}/{}".format(xoffset,yoffset))

    img = Image.new('RGBA', (width, height), (0,0,0,0))
    img.paste(src, (0,0,src_width,src_height))

    # find a transparency color
    all_colors = set([rgba for rgba,i in self.rgba_to_pico.items()])

    for j in range(src_height):
      for i in range(src_width):
        rgba = img.getpixel((i,j))
        if rgba in all_colors: all_colors.remove(rgba)
    pico8_transparency = 0
    # pick a random color to act as transparent color
    if len(rgba)>0: pico8_transparency = self.rgba_to_pico[all_colors.pop()]

    tw = math.floor(width/16)
    th = math.floor(height/16)
    # print("Processing: {} - {}x{} pix -> {}x{}".format(name,src_width,src_height,width,height))

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
              if low not in self.rgba_to_pico:
                raise Exception("Image: {} - invalid color: {} at {},{}".format(name, low, i*16 + x + n, j*16 + y))
              low = self.rgba_to_pico[low]
              high = img.getpixel((i*16 + x + n + 1, j*16 + y))
              if high not in self.rgba_to_pico:
                raise Exception("Image: {} - invalid color: {} at {},{}".format(name, high, i*16 + x + n + 1, j*16 + y))
              high = self.rgba_to_pico[high]
              if low==-1: low = pico8_transparency
              if high==-1: high = pico8_transparency
              pixels.append(low|high<<4)
            image_data += bytes(pixels[::-1])
        # skip fully transparent tile
        if not all(b==pico8_transparency|pico8_transparency<<4 for b in image_data):
          data += image_data
          # reference to corresponding tiles
          frame_tiles[j*tw+i] = tiles
          tiles += 1

    if abs(xoffset)>127 or abs(yoffset)>127:
      raise Exception("Unsupported image offset: {}/{} - must be in [-127,127]".format(xoffset,yoffset))
    
    return dotdict({
      'name': name,
      'tiles': frame_tiles,
      'width':  tw,
      'height': th,
      'xoffset': int(xoffset),
      'yoffset': int(yoffset),
      'background': pico8_transparency,
      'data': data})

  # returns reference to image frame(s) (multiple sides if any)
  def read_frames(self,image,variant):
    pattern = "{}{}".format(image,variant)
    frames = []
    lumps = self.stream.directory()
    if pattern+"1" in lumps:
      # multi-sided image
      angles = [
        re.compile("({}{}1)".format(image,variant)),
        re.compile("({}{}2)".format(image,variant)),
        re.compile("({}{}3)".format(image,variant)),
        re.compile("({}{}4)".format(image,variant)),
        re.compile("({}{}5)".format(image,variant)),
        re.compile("({}{}6)|({}{}4{}6)".format(image,variant,image,variant,variant)),
        re.compile("({}{}7)|({}{}3{}7)".format(image,variant,image,variant,variant)),
        re.compile("({}{}8)|({}{}2{}8)".format(image,variant,image,variant,variant))]
      for angle in angles:
        match = [m for m in map(angle.match, lumps) if m is not None][0]
        if match:
          if match.group(1):
            frames.append((match.string, False))
          elif match.group(2):
            frames.append((match.string, True))
        else:
          raise Exception("Missing angle: {} for image: {} {}".format(angle,image,variant))
    elif pattern+"0" in lumps:
      # single image
      frames.append((pattern+"0",False))
    else:
      raise Exception("Missing image: {} {}".format(image,variant))
    return frames
