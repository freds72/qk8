import sys
from antlr4 import *
from udmfLexer import udmfLexer
from udmfParser import udmfParser
from udmfVisitor import udmfVisitor
from udmfListener import udmfListener
from bsp_compiler import BSP_Compiler 

# helper dict
class dotdict(dict):
    def __getattr__(self, name):
        return self[name]

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
          self.result.append((x/16,y/16))
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
            elif attribute == 'twosided':
              value = value=='true'
            elif attribute == 'sidefront' or attribute == 'sideback':
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
            value = pair.value().getText()
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
          # default
          sector = dotdict({
            'heightfloor' : 0,
            'heightceiling' : 128})
          for pair in ctx.pair():
            attribute = pair.keyword().getText()
            value = pair.value().getText()
            if attribute == 'heightfloor' or attribute == 'heightceiling':
              value = float(value)
            sector[attribute] = value
          self.result.append(sector)

def main(argv):
    input_stream = FileStream("e1m1.udmf")
    lexer = udmfLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = udmfParser(stream)
    tree = parser.udmf()
    walker = ParseTreeWalker()

    walkers = dotdict({
      'vertices':VertexWalker(),
      'lines':LinedefWalker(),
      'sides':SideWalker(),
      'sectors':SectorWalker()
    })
    for k,w in walkers.items(): 
      walker.walk(w, tree)

    BSP_Compiler(
      walkers.vertices.result, 
      walkers.lines.result, 
      walkers.sides.result, 
      walkers.sectors.result)

if __name__ == '__main__':
    main(sys.argv)