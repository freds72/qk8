import sys
from antlr4 import *
from DECORATELexer import DECORATELexer
from DECORATEParser import DECORATEParser
from DECORATEVisitor import DECORATEVisitor
from DECORATEListener import DECORATEListener
from collections import namedtuple
from dotdict import dotdict

class DecorateWalker(DECORATEListener):     
    def __init__(self):
      self.result = {}
    def exitBlock(self, ctx):  
      name = ctx.name().KEYWORD().getText()
      parent = ctx.parent() and ctx.parent().KEYWORD().getText()
      properties = dotdict()

      for pair in ctx.pair():
        parent = ctx.parent() and ctx.parent().getText()
        # todo: check if parent is valid
        attribute = pair.keyword().getText()
        value = pair.value().getText()
        if attribute in []:
          value = value=='true'
        elif attribute.lower() in ['height','radius','slotnumber','amount','maxamount']:
          value = int(value)
        # else string
        properties[attribute] = value
      self.result[name] = properties

class ACTORS():
  def __init__(self, data):
    lexer = DECORATELexer(InputStream(data))
    stream = CommonTokenStream(lexer)
    parser = DECORATEParser(stream)
    tree = parser.actors()
    walker = ParseTreeWalker()

    decorate_walker = DecorateWalker()
    walker.walk(decorate_walker, tree)
    self.actors = decorate_walker.result
