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
import logging

class TEXTURES(TEXTURESListener):
  # filter contains the set of textures to include
  def __init__(self, filter):
    self.flats = {}
    self.patches = set()
    self.filter = filter    
    # reverse x/y to texture index
    self.textureByTile = {}

  def exitBlock(self, ctx):  
    name = ctx.name().getText().strip('"')
    if name in self.filter:
      namespace = ctx.namespace().getText().lower()
      logging.debug("Found texture: {}.{}".format(namespace, name))
      if namespace == "sprite":
        raise Exception("Texture sprite not supportted - {}: must be defined as a lump entry.".format(name))
      # get texture data
      patch = ctx.patch()

      self.patches.add(patch.name().getText().lower().strip('"'))

      # texture size
      width = int(ctx.width().getText())>>3
      height = int(ctx.height().getText())>>3

      # offset in texture image
      xoffset = -int(patch.xoffset().getText())>>3
      yoffset = -int(patch.yoffset().getText())>>3

      # convert to 8x8 map unit
      texture = dotdict({
        'width':width,
        'height':height,
        'mx':xoffset,
        'my':yoffset,
        'transparent': patch.translucent() is not None
      })
      self.flats[name] = texture
      for j in range(height):          
        for i in range(width):
          self.textureByTile[(i+xoffset)+(j+yoffset)*128] = texture
  
# Converts a TEXTURE file definition into a set of unique tiles + map index
class TextureReader(TEXTURESListener):
  def __init__(self, stream, palette):
    self.rgba_to_pico = {}
    for i,rgba in enumerate(palette):
      self.rgba_to_pico[rgba] = i
    # forced transparency colors
    self.rgba_to_pico[(00,00,00,00)] = -1
    self.rgba_to_pico[(255,255,255,00)] = -1
    self.stream = stream
    
  def read(self, texture_filter):    
    # get data
    data = self.stream.read("TEXTURES").decode('ascii')

    lexer = TEXTURESLexer(InputStream(data))
    stream = CommonTokenStream(lexer)
    parser = TEXTURESParser(stream)
    tree = parser.textures()
    walker = ParseTreeWalker()

    listener = TEXTURES(texture_filter)
    walker.walk(listener, tree)

    # convert texture image to map/gfx
    if len(listener.patches)>1:
      raise Exception("Multiple tilesets not supported: {}".format(listener.patches))
    
    texture_name = listener.patches.pop()
    texture_by_tile = listener.textureByTile

    image_data = self.stream.read(texture_name)

    # read image bytes
    src = Image.open(io.BytesIO(image_data))
    width, height = src.size
    if width>1024 or height>256:
      raise Exception("Texture: {} invalid size: {}x{} - Texture file size must be less than 1024x256px".format(width,height))
    img = Image.new('RGBA', (width, height), (0,0,0,0))
    img.paste(src, (0,0,width,height))

    logging.info("Found tileset: {} - {}x{}px".format(texture_name,width, height))

    # extract tiles
    pico_gfx = []
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
            if low not in self.rgba_to_pico:
              raise Exception("Tileset: {} - invalid color: {} at {},{}".format(texture_name,low,i*8 + x, j*8 + y))
            low = self.rgba_to_pico[low]
            if low==-1: low = 0
            high = img.getpixel((i*8 + x + 1, j*8 + y))
            if high not in self.rgba_to_pico:
              raise Exception("Tileset: {} - invalid color: {} at {},{}".format(texture_name,high,i*8 + x + 1, j*8 + y))
            high = self.rgba_to_pico[high]
            if high==-1: high = 0
            data += bytes([high|low<<4])

        # remove empty tiles (only if texture patch is transparent)        
        texture = texture_by_tile.get(i+j*128,None)
        # not referenced zone
        if texture is None or (texture.transparent and all(b==0 for b in data)):
          pico_map.append(0)
        else:          
          tile = 0
          # known tile?
          if data in pico_gfx:
            tile = pico_gfx.index(data)
          else:
            tile = len(pico_gfx)
            pico_gfx.append(data) 
          # tiles are in spritesheet 2+3
          pico_map.append(tile+128)

    # map width
    width=width>>3

    max_tiles = 16*4*2
    if len(pico_gfx)>max_tiles:
      raise Exception("Too many unique tiles: {} in tileset: {} (max: {})".format(len(pico_gfx), texture_name, max_tiles))

    logging.info("Tileset: Found {}/{} unique tiles".format(len(pico_gfx),max_tiles))

    return dotdict({'flats':listener.flats,'width':width,'map':pico_map,'gfx':pico_gfx})
