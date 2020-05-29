import sys
from antlr4 import *
from TEXTURESLexer import TEXTURESLexer
from TEXTURESParser import TEXTURESParser
from TEXTURESVisitor import TEXTURESVisitor
from TEXTURESListener import TEXTURESListener
from collections import namedtuple
from dotdict import dotdict

class TextureWalker(TEXTURESListener):     
    def __init__(self):
      self.result = {}   
    def exitBlock(self, ctx):  
      name = ctx.name().getText()
      # skip texture atlas
      if name != 'TILES':
        patch = ctx.patch()
        # convert to 8x8 map unit
        texture = dotdict({
          'width':int(ctx.width().getText())>>3,
          'height':int(ctx.height().getText())>>3,
          'mx':-int(patch.xoffset().getText())>>3,
          'my':-int(patch.yoffset().getText())>>3
        })
        print(texture)
        self.result[name] = texture

class TEXTURES():
  def __init__(self, data):
    lexer = TEXTURESLexer(InputStream(data))
    stream = CommonTokenStream(lexer)
    parser = TEXTURESParser(stream)
    tree = parser.textures()
    walker = ParseTreeWalker()

    walkers = dotdict({
      'textures':TextureWalker(),
    })
    for k,w in walkers.items(): 
      walker.walk(w, tree)
    self.textures = walkers.textures.result
