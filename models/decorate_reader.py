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
      name = ctx.name().getText()
      parent = ctx.parent() and ctx.parent().STRING().getText()
      print("{}:{} ({})".format(name,parent,ctx.uid().getText()))

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
