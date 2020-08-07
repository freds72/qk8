import sys
import os
import io
import math
from antlr4 import *
from TEXTURESLexer import TEXTURESLexer
from TEXTURESParser import TEXTURESParser
from TEXTURESVisitor import TEXTURESVisitor
from TEXTURESListener import TEXTURESListener
from collections import namedtuple
from dotdict import dotdict
from PIL import Image, ImageFilter

class TEXTURES(TEXTURESListener):
  def __init__(self):
    self.flats = {}
    self.patches = set()

  def exitBlock(self, ctx):  
    name = ctx.name().getText().strip('"')
    namespace = ctx.namespace().getText().lower()
    print("Texture: {}.{}".format(namespace, name))
    if namespace == "sprite":
      raise Exception("Texture sprite not supportted - {}: must be defined as lump entry.".format(name))
    # get texture data
    patch = ctx.patch()

    self.patches.add(patch.name().getText().strip('"'))

    # texture size
    width = int(ctx.width().getText())
    height = int(ctx.height().getText())

    # offset in texture image
    xoffset = -int(patch.xoffset().getText())
    yoffset = -int(patch.yoffset().getText())

    # convert to 8x8 map unit
    texture = dotdict({
      'width':width>>3,
      'height':height>>3,
      'mx':xoffset>>3,
      'my':yoffset>>3
    })
    self.flats[name] = texture
  
class WADTextureReader(TEXTURESListener):
  def __init__(self, palette):
    self.rgba_to_pico = {}
    for i,rgba in enumerate(palette):
      self.rgba_to_pico[rgba] = i
    # forced transparency color
    self.rgba_to_pico[(00,00,00,00)] = -1
    
  def read(self, data, file, lumps):    
    lexer = TEXTURESLexer(InputStream(data))
    stream = CommonTokenStream(lexer)
    parser = TEXTURESParser(stream)
    tree = parser.textures()
    walker = ParseTreeWalker()

    listener = TEXTURES()
    walker.walk(listener, tree)

    # convert texture image to map/gfx
    if len(listener.patches)>1:
      raise Exception("Multiple texture images not supported: {}".format(listener.patches))

    texture_name = listener.patches.pop()
    # read from WAD
    entry = lumps.get(texture_name,None)
    if not entry:
      raise Exception("Missing WAD image: {}".format(texture_name))

    file.seek(entry.lump_ofs)
    image_data = file.read(entry.lump_size)

    # read image bytes
    src = Image.open(io.BytesIO(image_data))
    width, height = src.size
    if width>1024 or height>256:
      raise Exception("Texture: {} invalid size: {}x{} - Texture file size must be less than 1024x256px".format(width,height))
    img = Image.new('RGBA', (width, height), (0,0,0,0))
    img.paste(src, (0,0,width,height))

    # extract tiles
    # tile 0 (all black)
    pico_gfx = [bytes(32)]
    pico_map = []
    for j in range(0,math.floor(height/8)):
      for i in range(0,math.floor(width/8)):
        data = bytes([])
        for y in range(8):
          # read nimbles
          for x in range(0,8,2):
            # print("{}/{}".format(i+x,j+y))
            # image is using the pico palette (+transparency)
            low = img.getpixel((i*8 + x, j*8 + y))
            low = self.rgba_to_pico[low]
            if low==-1: low = 0
            high = img.getpixel((i*8 + x + 1, j*8 + y))
            high = self.rgba_to_pico[high]
            if high==-1: high = 0
            data += bytes([high|low<<4])
        tile = 0
        # remove empty tiles
        if not all(b==0 for b in data):
          # known tile?
          if data in pico_gfx:
            tile = pico_gfx.index(data)
          else:
            tile = len(pico_gfx)
            pico_gfx.append(data)
        pico_map.append(tile)
    # map width
    width=width>>3
    
    return dotdict({'flats':listener.flats,'width':width,'map':pico_map,'gfx':pico_gfx})
