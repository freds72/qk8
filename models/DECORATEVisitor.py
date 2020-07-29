# Generated from DECORATE.g4 by ANTLR 4.8
from antlr4 import *
if __name__ is not None and "." in __name__:
    from .DECORATEParser import DECORATEParser
else:
    from DECORATEParser import DECORATEParser

# This class defines a complete generic visitor for a parse tree produced by DECORATEParser.

class DECORATEVisitor(ParseTreeVisitor):

    # Visit a parse tree produced by DECORATEParser#actors.
    def visitActors(self, ctx:DECORATEParser.ActorsContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#block.
    def visitBlock(self, ctx:DECORATEParser.BlockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#pair.
    def visitPair(self, ctx:DECORATEParser.PairContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#keyword.
    def visitKeyword(self, ctx:DECORATEParser.KeywordContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#flags.
    def visitFlags(self, ctx:DECORATEParser.FlagsContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#states.
    def visitStates(self, ctx:DECORATEParser.StatesContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#state_block.
    def visitState_block(self, ctx:DECORATEParser.State_blockContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#state_stop.
    def visitState_stop(self, ctx:DECORATEParser.State_stopContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#state_loop.
    def visitState_loop(self, ctx:DECORATEParser.State_loopContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#state_goto.
    def visitState_goto(self, ctx:DECORATEParser.State_gotoContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#label.
    def visitLabel(self, ctx:DECORATEParser.LabelContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#state_command.
    def visitState_command(self, ctx:DECORATEParser.State_commandContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#image_modifier.
    def visitImage_modifier(self, ctx:DECORATEParser.Image_modifierContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#image.
    def visitImage(self, ctx:DECORATEParser.ImageContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#variant.
    def visitVariant(self, ctx:DECORATEParser.VariantContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#ticks.
    def visitTicks(self, ctx:DECORATEParser.TicksContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#name.
    def visitName(self, ctx:DECORATEParser.NameContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#function.
    def visitFunction(self, ctx:DECORATEParser.FunctionContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#uid.
    def visitUid(self, ctx:DECORATEParser.UidContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#parent.
    def visitParent(self, ctx:DECORATEParser.ParentContext):
        return self.visitChildren(ctx)


    # Visit a parse tree produced by DECORATEParser#value.
    def visitValue(self, ctx:DECORATEParser.ValueContext):
        return self.visitChildren(ctx)



del DECORATEParser