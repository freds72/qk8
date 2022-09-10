import sys
from antlr4 import *
from udmfLexer import udmfLexer
from udmfParser import udmfParser
from udmfVisitor import udmfVisitor
from udmfListener import udmfListener
from collections import namedtuple
from dotdict import dotdict

class VertexWalker(udmfListener):
    def __init__(self):
      self.result=[]   
    def exitBlock(self, ctx):  
        block = ctx.keyword().getText()  
        if block=='vertex':
          x = 0
          y = 0
          for pair in ctx.pair():
            attribute = pair.keyword().getText()
            value = pair.value().getText()
            if attribute == 'x':
              x = float(value)
            elif attribute == 'y':
              y = float(value)
          # scale world down
          self.result.append((x,y))
class LinedefWalker(udmfListener):     
    def __init__(self):
      self.result=[]   
    def exitBlock(self, ctx):  
        block = ctx.keyword().getText()  
        if block=='linedef':
          linedef = dotdict({
            # default value
            'twosided' : False,
            'sideback': -1
          })
          for pair in ctx.pair():
            attribute = pair.keyword().getText()
            value = pair.value().getText()
            if attribute == 'v1' or attribute == 'v2':
              value = int(value)
            elif attribute in ['twosided','dontpegtop','playercross','playeruse','repeatspecial','blocking']:
              value = value=='true'
            elif attribute in ['sidefront','sideback','special','arg0','arg1','arg2','arg3','arg4']:
              value = int(value)
            linedef[attribute] = value
          self.result.append(linedef)

class SideWalker(udmfListener):     
    def __init__(self):
      self.result=[]   
    def exitBlock(self, ctx):  
        block = ctx.keyword().getText()  
        if block=='sidedef':
          side = dotdict()
          for pair in ctx.pair():
            attribute = pair.keyword().getText()
            value = pair.value().getText().strip('"')
            if attribute == 'sector':
              value = int(value)
            side[attribute] = value
          self.result.append(side)
  
class SectorWalker(udmfListener):    
    def __init__(self):
      self.result=[]    
    def exitBlock(self, ctx):  
        block = ctx.keyword().getText()  
        if block=='sector':
          # defaults
          sector = dotdict({
            'heightfloor' : 0,
            'heightceiling' : 128,
            'special' : 0})
          for pair in ctx.pair():
            attribute = pair.keyword().getText()
            value = pair.value().getText().strip('"')
            if attribute in ['heightfloor','heightceiling','id','special','lightlevel','lightcolor']:
              value = int(value)
            sector[attribute] = value
          self.result.append(sector)

class ThingWalker(udmfListener):    
    def __init__(self):
      self.result=[]    
    def exitBlock(self, ctx):  
        block = ctx.keyword().getText()  
        if block=='thing':
          # default
          thing = dotdict()
          for pair in ctx.pair():
            attribute = pair.keyword().getText().lower()
            value = pair.value().getText()
            if attribute in ['x','y']:
              value = float(value)
            elif attribute in ['skill1','skill2','skill3','skill4','skill5','dm','single','coop']:
              value = value == 'true'
            elif attribute in ['type','angle','special','arg0','arg1','arg2','arg3','arg4']:
              value = int(value)
            thing[attribute] = value
          self.result.append(thing)

class UDMF():
  def __init__(self, data):
    lexer = udmfLexer(InputStream(data))
    stream = CommonTokenStream(lexer)
    parser = udmfParser(stream)
    tree = parser.udmf()
    walker = ParseTreeWalker()

    walkers = dotdict({
      'vertices':VertexWalker(),
      'lines':LinedefWalker(),
      'sides':SideWalker(),
      'sectors':SectorWalker(),
      'things':ThingWalker()
    })
    for k,w in walkers.items(): 
      walker.walk(w, tree)
    self.vertices = walkers.vertices.result
    self.lines = walkers.lines.result
    self.sides = walkers.sides.result
    self.sectors = walkers.sectors.result
    self.things = walkers.things.result