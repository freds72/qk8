import sys
from antlr4 import *
from udmfLexer import udmfLexer
from udmfParser import udmfParser
from udmfVisitor import udmfVisitor
from udmfListener import udmfListener
 
class BlockPrinter(udmfListener):     
    def exitBlock(self, ctx):         
        print("block: {}".format(ctx.KEYWORD()))
        for pair in ctx.pair():
          print("attribute: {} = {}".format(pair.ATTRIBUTE().getText(), pair.value().getText()))
    
def main(argv):
    input_stream = FileStream("e1m1.udmf")
    lexer = udmfLexer(input_stream)
    stream = CommonTokenStream(lexer)
    parser = udmfParser(stream)
    tree = parser.udmf()
    printer = BlockPrinter()
    walker = ParseTreeWalker()
    walker.walk(printer, tree)

if __name__ == '__main__':
    main(sys.argv)