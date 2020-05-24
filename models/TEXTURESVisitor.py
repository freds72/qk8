# Generated from TEXTURES.g4 by ANTLR 4.8
from antlr4 import *
if __name__ is not None and "." in __name__:
    from .TEXTURESParser import TEXTURESParser
else:
    from TEXTURESParser import TEXTURESParser

# This class defines a complete generic visitor for a parse tree produced by TEXTURESParser.

class TEXTURESVisitor(ParseTreeVisitor):

    # Visit a parse tree produced by TEXTURESParser#textures.
    def visitTextures(self, ctx:TEXTURESParser.TexturesContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by TEXTURESParser#block.
    def visitBlock(self, ctx:TEXTURESParser.BlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by TEXTURESParser#patch.
    def visitPatch(self, ctx:TEXTURESParser.PatchContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by TEXTURESParser#name.
    def visitName(self, ctx:TEXTURESParser.NameContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by TEXTURESParser#width.
    def visitWidth(self, ctx:TEXTURESParser.WidthContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by TEXTURESParser#height.
    def visitHeight(self, ctx:TEXTURESParser.HeightContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by TEXTURESParser#xoffset.
    def visitXoffset(self, ctx:TEXTURESParser.XoffsetContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by TEXTURESParser#yoffset.
    def visitYoffset(self, ctx:TEXTURESParser.YoffsetContext):
        return self.visitChildren(ctx)



del TEXTURESParser