# Generated from MAPINFO.g4 by ANTLR 4.8
from antlr4 import *
if __name__ is not None and "." in __name__:
    from .MAPINFOParser import MAPINFOParser
else:
    from MAPINFOParser import MAPINFOParser

# This class defines a complete generic visitor for a parse tree produced by MAPINFOParser.

class MAPINFOVisitor(ParseTreeVisitor):

    # Visit a parse tree produced by MAPINFOParser#maps.
    def visitMaps(self, ctx:MAPINFOParser.MapsContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by MAPINFOParser#block.
    def visitBlock(self, ctx:MAPINFOParser.BlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by MAPINFOParser#pair.
    def visitPair(self, ctx:MAPINFOParser.PairContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by MAPINFOParser#maplump.
    def visitMaplump(self, ctx:MAPINFOParser.MaplumpContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by MAPINFOParser#keyword.
    def visitKeyword(self, ctx:MAPINFOParser.KeywordContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by MAPINFOParser#label.
    def visitLabel(self, ctx:MAPINFOParser.LabelContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by MAPINFOParser#value.
    def visitValue(self, ctx:MAPINFOParser.ValueContext):
        return self.visitChildren(ctx)



del MAPINFOParser