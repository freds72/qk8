import sys
from antlr4 import *
from udmfLexer import udmfLexer
from udmfParser import udmfParser
from udmfVisitor import udmfVisitor
from udmfListener import udmfListener
 
vertices=[]
lines=[]
class VertexWalker(udmfListener):     
    def exitBlock(self, ctx):  
        block = ctx.KEYWORD().getText()  
        if block=='vertex':
          x = 0
          y = 0
          for pair in ctx.pair():
            attribute = pair.ATTRIBUTE().getText()
            value = pair.value().getText()
            if attribute == 'x':
              x = float(value)
            elif attribute == 'y':
              y = float(value)
            else:
              print("unhandled block: {}".format(block))
              print("attribute: {} = {}".format(attribute, value))
          vertices.append((x,y))

class LinedefWalker(udmfListener):     
    def exitBlock(self, ctx):  
        block = ctx.KEYWORD().getText()  
        if block=='linedef':
          v1 = -1
          v2 = -1
          for pair in ctx.pair():
            attribute = pair.ATTRIBUTE().getText()
            value = pair.value().getText()
            if attribute == 'v1':
              v1 = int(value)
            elif attribute == 'v2':
              v2 = int(value)
            else:
              print("unhandled block: {}".format(block))
              print("attribute: {} = {}".format(attribute, value))
          lines.append((vertices[v1],vertices[v2]))

def main(argv):
    input_stream = FileStream("e1m1.udmf")
    lexer = udmfLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = udmfParser(stream)
    tree = parser.udmf()
    walker = ParseTreeWalker()
    walker.walk(VertexWalker(), tree)
    walker.walk(LinedefWalker(), tree)

    s = ""
    for line in lines:
      s += "Polygon(({},{}), ({},{})),\n".format(
        line[0][0]/16.0,
        line[0][1]/16.0,
        line[1][0]/16.0,
        line[1][1]/16.0)
    print(s)
if __name__ == '__main__':
    main(sys.argv)