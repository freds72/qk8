# Generated from udmf.g4 by ANTLR 4.8
from antlr4 import *
if __name__ is not None and "." in __name__:
    from .udmfParser import udmfParser
else:
    from udmfParser import udmfParser

# This class defines a complete listener for a parse tree produced by udmfParser.
class udmfListener(ParseTreeListener):

    # Enter a parse tree produced by udmfParser#udmf.
    def enterUdmf(self, ctx:udmfParser.UdmfContext):
        pass

    # Exit a parse tree produced by udmfParser#udmf.
    def exitUdmf(self, ctx:udmfParser.UdmfContext):
        pass


    # Enter a parse tree produced by udmfParser#block.
    def enterBlock(self, ctx:udmfParser.BlockContext):
        pass

    # Exit a parse tree produced by udmfParser#block.
    def exitBlock(self, ctx:udmfParser.BlockContext):
        pass


    # Enter a parse tree produced by udmfParser#pair.
    def enterPair(self, ctx:udmfParser.PairContext):
        pass

    # Exit a parse tree produced by udmfParser#pair.
    def exitPair(self, ctx:udmfParser.PairContext):
        pass


    # Enter a parse tree produced by udmfParser#keyword.
    def enterKeyword(self, ctx:udmfParser.KeywordContext):
        pass

    # Exit a parse tree produced by udmfParser#keyword.
    def exitKeyword(self, ctx:udmfParser.KeywordContext):
        pass


    # Enter a parse tree produced by udmfParser#value.
    def enterValue(self, ctx:udmfParser.ValueContext):
        pass

    # Exit a parse tree produced by udmfParser#value.
    def exitValue(self, ctx:udmfParser.ValueContext):
        pass


    # Enter a parse tree produced by udmfParser#number.
    def enterNumber(self, ctx:udmfParser.NumberContext):
        pass

    # Exit a parse tree produced by udmfParser#number.
    def exitNumber(self, ctx:udmfParser.NumberContext):
        pass



del udmfParser