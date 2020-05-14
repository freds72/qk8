# Generated from udmf.g4 by ANTLR 4.8
from antlr4 import *
if __name__ is not None and "." in __name__:
    from .udmfParser import udmfParser
else:
    from udmfParser import udmfParser

# This class defines a complete generic visitor for a parse tree produced by udmfParser.

class udmfVisitor(ParseTreeVisitor):

    # Visit a parse tree produced by udmfParser#udmf.
    def visitUdmf(self, ctx:udmfParser.UdmfContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by udmfParser#block.
    def visitBlock(self, ctx:udmfParser.BlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by udmfParser#pair.
    def visitPair(self, ctx:udmfParser.PairContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by udmfParser#keyword.
    def visitKeyword(self, ctx:udmfParser.KeywordContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by udmfParser#value.
    def visitValue(self, ctx:udmfParser.ValueContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by udmfParser#number.
    def visitNumber(self, ctx:udmfParser.NumberContext):
        return self.visitChildren(ctx)



del udmfParser