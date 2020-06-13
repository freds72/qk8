import sys
from antlr4 import *
from TEXTURESLexer import TEXTURESLexer
from TEXTURESParser import TEXTURESParser
from TEXTURESVisitor import TEXTURESVisitor
from TEXTURESListener import TEXTURESListener
from collections import namedtuple
from dotdict import dotdict

class TEXTURES(TEXTURESListener):
  def __init__(self):
    self.flats = {}
    self.sprites = {}
  def read(self, data):
    lexer = TEXTURESLexer(InputStream(data))
    stream = CommonTokenStream(lexer)
    parser = TEXTURESParser(stream)
    tree = parser.textures()
    walker = ParseTreeWalker()

    walker.walk(self, tree)

  def exitBlock(self, ctx):  
    name = ctx.name().getText().strip('"')
    namespace = ctx.namespace().getText().lower()
    print("Texture: {}.{}".format(namespace, name))
    if namespace == "sprite":
      # multi-frame/multi-pose images
      patch = ctx.patch()
      texture = dotdict({
        'width':int(ctx.width().getText()),
        'height':int(ctx.height().getText()),
        'mx':-int(patch.xoffset().getText()),
        'my':-int(patch.yoffset().getText())
      })
      # todo: split frames
      self.sprites[name] = texture        
    else:
      # wall textures
      patch = ctx.patch()
      # convert to 8x8 map unit
      texture = dotdict({
        'width':int(ctx.width().getText())>>3,
        'height':int(ctx.height().getText())>>3,
        'mx':-int(patch.xoffset().getText())>>3,
        'my':-int(patch.yoffset().getText())>>3
      })
      self.flats[name] = texture