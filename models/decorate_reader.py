import sys
from antlr4 import *
from DECORATELexer import DECORATELexer
from DECORATEParser import DECORATEParser
from DECORATEVisitor import DECORATEVisitor
from DECORATEListener import DECORATEListener
from collections import namedtuple
from dotdict import dotdict
from enum import IntFlag

class ACTOR_KIND(IntFlag):
  KEY = 0
  AMMO = 1
  WEAPON = 2
  HEALTH = 3
  ARMOR = 4

builtin_actors = {
  'key':{
    'kind': ACTOR_KIND.KEY,
    'amount': 1,
    'maxamount':1,
    'radius': 20
  },
  'ammo':{
    'kind': ACTOR_KIND.AMMO,
    'radius': 20
  },
  'weapon':{
    'kind': ACTOR_KIND.WEAPON,
    'radius': 20
  },
  'health':{
    'kind': ACTOR_KIND.HEALTH,
    'radius': 20,
    'maxamount': 200
  },
  'armor':{
    'kind': ACTOR_KIND.ARMOR,
    'radius': 20,
    'maxamount': 200
  }}
  
class DecorateWalker(DECORATEListener):     
    def __init__(self):
      self.result = {}
    def exitBlock(self, ctx):  
      name = ctx.name().KEYWORD().getText().lower()
      if name in builtin_actors:
        raise Exception("Cannot redefine base actor: {}".format(name))
      id = -1
      if ctx.uid():
        id = int(ctx.uid().getText())
      properties = dotdict({
        'id': id
      })
      if ctx.parent():
        parent = ctx.parent().KEYWORD().getText().lower()
        if parent not in self.result and parent not in builtin_actors:
          raise Exception("Actor {} references unknown parent: {}".format(name, parent))
        # built-in parent or user defined?
        if parent in builtin_actors:
          parent = builtin_actors[parent]
        else:
          parent = self.result[parent]
        # copy parent properties in self
        for k,v in parent.items():
          if k=='id':
            properties['parent']=id 
          else:
            properties[k]=v

      for pair in ctx.pair():
        attribute = pair.keyword().getText().lower()
        value = pair.value().getText()
        if attribute in []:
          value = value=='true'
        elif attribute in ['height','radius','slotnumber','amount','maxamount']:
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
