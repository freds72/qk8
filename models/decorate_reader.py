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
  # inventory items
  KEY = 0
  AMMO = 1
  WEAPON = 2
  HEALTH = 3
  ARMOR = 4
  # generic class
  DEFAULT = 5
  MONSTER = 6
  PROJECTILE = 7
  PLAYER = 8

builtin_actors = {
  'key':{
    'kind': ACTOR_KIND.KEY,
    'amount': 1,
    'maxamount':1,
    'radius': 20,
    'solid': True
  },
  'ammo':{
    'kind': ACTOR_KIND.AMMO,
    'radius': 20,
    'solid': True
  },
  'weapon':{
    'kind': ACTOR_KIND.WEAPON,
    'radius': 20,
    'amount': 0,
    'maxamount': 1,
    'solid': True
  },
  'health':{
    'kind': ACTOR_KIND.HEALTH,
    'radius': 20,
    'maxamount': 200,
    'solid': True
  },
  'armor':{
    'kind': ACTOR_KIND.ARMOR,
    'radius': 20,
    'maxamount': 200,
    'solid': True
  },
  'player':{
    'kind': ACTOR_KIND.PLAYER,
    'radius': 32,
    'armor': 100,
    'health': 100,
    'speed': 3,
    'shootable': True,
    'solid': True
  },
  'monster':{
    'kind': ACTOR_KIND.MONSTER,
    'radius': 32,
    'armor': 0,
    'health': 50,
    'shootable': True,
    'solid': True
  },
  'projectile':{
    'kind': ACTOR_KIND.PROJECTILE,
    'damage': 1,
    'speed': 5
  }
}

class DecorateWalker(DECORATEListener):     
    def __init__(self):
      self.result = {}
      self.frames = []

    def enterBlock(self, ctx):
      # clear frames
      self.frames = []

    def exitBlock(self, ctx):  
      name = ctx.name().KEYWORD().getText().lower()
      print("end of actor: {}".format(name))

      if name in builtin_actors:
        raise Exception("Cannot redefine base actor: {}".format(name))
      # -1 = not exported
      id = -1
      if ctx.uid():
        id = int(ctx.uid().getText())
      properties = dotdict({
        'id': id,
        'kind': ACTOR_KIND.DEFAULT
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
        value = pair.value().getText().lower().strip('"')
        if attribute in []:
          value = value=='true'
        elif attribute in ['health','armor','height','radius','slotnumber','amount','maxamount','damage','speed','ammogive','ammouse','icon']:
          value = int(value)
        elif attribute in ['ammotype','projectile']:
          if value not in self.result:
            raise Exception("Actor: {} references unknown: {}".format(name, value))
          otheractor = self.result[value]
          value = otheractor.id
        elif attribute in ['startitem']:
          if value not in self.result:
            raise Exception("Actor: {} references unknown start item: {}".format(name, value))
          otheractor = self.result[value]
          startitems = properties.get('startitems',[])
          # default amount
          amount = 1
          # so far, only ammo can have startitem params
          values = pair.args().value
          if otheractor.kind == ACTOR_KIND.AMMO and len(values())>0:
            amount = int(values(0).getText())
          startitems.append((otheractor.id, amount))
          value = startitems
          attribute = 'startitems'
        
        # else string
        properties[attribute] = value
      
      # flags
      for flag in ctx.flags():
        activated = flag.ENABLED().getText()
        attribute = flag.keyword().getText().lower()
        properties[attribute] = activated=='+'
      
      # add sprite frames
      frames = []
      for frame in self.frames:
        frames.append(frame)
      properties['frames'] = frames
      self.result[name] = properties

    def exitState_block(self, ctx):
      state = ctx.name().KEYWORD().getText().lower()
      if state=='spawn':
        for i in range(len(ctx.image())):
          self.frames.append(dotdict({
            'image': ctx.image(i).getText(),
            'variant': ctx.variant(i).getText(),
            'ticks': int(ctx.ticks(i).getText())
          }))

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
