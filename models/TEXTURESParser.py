# Generated from TEXTURES.g4 by ANTLR 4.8
# encoding: utf-8
from antlr4 import *
from io import StringIO
import sys
if sys.version_info[1] > 5:
	from typing import TextIO
else:
	from typing.io import TextIO


def serializedATN():
    with StringIO() as buf:
        buf.write("\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\3\16")
        buf.write("B\4\2\t\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b")
        buf.write("\t\b\4\t\t\t\3\2\7\2\24\n\2\f\2\16\2\27\13\2\3\2\3\2\3")
        buf.write("\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3")
        buf.write("\3\3\3\3\3\3\3\3\3\3\3\3\5\3/\n\3\3\4\3\4\3\4\3\4\3\4")
        buf.write("\3\4\3\4\3\5\3\5\3\6\3\6\3\7\3\7\3\b\3\b\3\t\3\t\3\t\2")
        buf.write("\2\n\2\4\6\b\n\f\16\20\2\2\2;\2\25\3\2\2\2\4.\3\2\2\2")
        buf.write("\6\60\3\2\2\2\b\67\3\2\2\2\n9\3\2\2\2\f;\3\2\2\2\16=\3")
        buf.write("\2\2\2\20?\3\2\2\2\22\24\5\4\3\2\23\22\3\2\2\2\24\27\3")
        buf.write("\2\2\2\25\23\3\2\2\2\25\26\3\2\2\2\26\30\3\2\2\2\27\25")
        buf.write("\3\2\2\2\30\31\7\2\2\3\31\3\3\2\2\2\32\33\7\3\2\2\33\34")
        buf.write("\5\b\5\2\34\35\7\4\2\2\35\36\5\f\7\2\36\37\7\4\2\2\37")
        buf.write(" \5\n\6\2 !\7\5\2\2!\"\5\6\4\2\"#\7\6\2\2#/\3\2\2\2$%")
        buf.write("\7\7\2\2%&\5\b\5\2&\'\7\4\2\2\'(\5\f\7\2()\7\4\2\2)*\5")
        buf.write("\n\6\2*+\7\5\2\2+,\5\6\4\2,-\7\6\2\2-/\3\2\2\2.\32\3\2")
        buf.write("\2\2.$\3\2\2\2/\5\3\2\2\2\60\61\7\b\2\2\61\62\5\b\5\2")
        buf.write("\62\63\7\4\2\2\63\64\5\16\b\2\64\65\7\4\2\2\65\66\5\20")
        buf.write("\t\2\66\7\3\2\2\2\678\7\13\2\28\t\3\2\2\29:\7\t\2\2:\13")
        buf.write("\3\2\2\2;<\7\t\2\2<\r\3\2\2\2=>\7\t\2\2>\17\3\2\2\2?@")
        buf.write("\7\t\2\2@\21\3\2\2\2\4\25.")
        return buf.getvalue()


class TEXTURESParser ( Parser ):

    grammarFileName = "TEXTURES.g4"

    atn = ATNDeserializer().deserialize(serializedATN())

    decisionsToDFA = [ DFA(ds, i) for i, ds in enumerate(atn.decisionToState) ]

    sharedContextCache = PredictionContextCache()

    literalNames = [ "<INVALID>", "'Texture'", "','", "'{'", "'}'", "'Flat'", 
                     "'Patch'" ]

    symbolicNames = [ "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "INTEGER_NUMBER", 
                      "STRING", "QUOTED_STRING", "BLOCKCOMMENT", "LINECOMMENT", 
                      "WS" ]

    RULE_textures = 0
    RULE_block = 1
    RULE_patch = 2
    RULE_name = 3
    RULE_width = 4
    RULE_height = 5
    RULE_xoffset = 6
    RULE_yoffset = 7

    ruleNames =  [ "textures", "block", "patch", "name", "width", "height", 
                   "xoffset", "yoffset" ]

    EOF = Token.EOF
    T__0=1
    T__1=2
    T__2=3
    T__3=4
    T__4=5
    T__5=6
    INTEGER_NUMBER=7
    STRING=8
    QUOTED_STRING=9
    BLOCKCOMMENT=10
    LINECOMMENT=11
    WS=12

    def __init__(self, input:TokenStream, output:TextIO = sys.stdout):
        super().__init__(input, output)
        self.checkVersion("4.8")
        self._interp = ParserATNSimulator(self, self.atn, self.decisionsToDFA, self.sharedContextCache)
        self._predicates = None




    class TexturesContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def EOF(self):
            return self.getToken(TEXTURESParser.EOF, 0)

        def block(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(TEXTURESParser.BlockContext)
            else:
                return self.getTypedRuleContext(TEXTURESParser.BlockContext,i)


        def getRuleIndex(self):
            return TEXTURESParser.RULE_textures

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterTextures" ):
                listener.enterTextures(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitTextures" ):
                listener.exitTextures(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitTextures" ):
                return visitor.visitTextures(self)
            else:
                return visitor.visitChildren(self)




    def textures(self):

        localctx = TEXTURESParser.TexturesContext(self, self._ctx, self.state)
        self.enterRule(localctx, 0, self.RULE_textures)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 19
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==TEXTURESParser.T__0 or _la==TEXTURESParser.T__4:
                self.state = 16
                self.block()
                self.state = 21
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 22
            self.match(TEXTURESParser.EOF)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class BlockContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def name(self):
            return self.getTypedRuleContext(TEXTURESParser.NameContext,0)


        def height(self):
            return self.getTypedRuleContext(TEXTURESParser.HeightContext,0)


        def width(self):
            return self.getTypedRuleContext(TEXTURESParser.WidthContext,0)


        def patch(self):
            return self.getTypedRuleContext(TEXTURESParser.PatchContext,0)


        def getRuleIndex(self):
            return TEXTURESParser.RULE_block

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterBlock" ):
                listener.enterBlock(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitBlock" ):
                listener.exitBlock(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitBlock" ):
                return visitor.visitBlock(self)
            else:
                return visitor.visitChildren(self)




    def block(self):

        localctx = TEXTURESParser.BlockContext(self, self._ctx, self.state)
        self.enterRule(localctx, 2, self.RULE_block)
        try:
            self.state = 44
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [TEXTURESParser.T__0]:
                self.enterOuterAlt(localctx, 1)
                self.state = 24
                self.match(TEXTURESParser.T__0)
                self.state = 25
                self.name()
                self.state = 26
                self.match(TEXTURESParser.T__1)
                self.state = 27
                self.height()
                self.state = 28
                self.match(TEXTURESParser.T__1)
                self.state = 29
                self.width()
                self.state = 30
                self.match(TEXTURESParser.T__2)
                self.state = 31
                self.patch()
                self.state = 32
                self.match(TEXTURESParser.T__3)
                pass
            elif token in [TEXTURESParser.T__4]:
                self.enterOuterAlt(localctx, 2)
                self.state = 34
                self.match(TEXTURESParser.T__4)
                self.state = 35
                self.name()
                self.state = 36
                self.match(TEXTURESParser.T__1)
                self.state = 37
                self.height()
                self.state = 38
                self.match(TEXTURESParser.T__1)
                self.state = 39
                self.width()
                self.state = 40
                self.match(TEXTURESParser.T__2)
                self.state = 41
                self.patch()
                self.state = 42
                self.match(TEXTURESParser.T__3)
                pass
            else:
                raise NoViableAltException(self)

        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class PatchContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def name(self):
            return self.getTypedRuleContext(TEXTURESParser.NameContext,0)


        def xoffset(self):
            return self.getTypedRuleContext(TEXTURESParser.XoffsetContext,0)


        def yoffset(self):
            return self.getTypedRuleContext(TEXTURESParser.YoffsetContext,0)


        def getRuleIndex(self):
            return TEXTURESParser.RULE_patch

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterPatch" ):
                listener.enterPatch(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitPatch" ):
                listener.exitPatch(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitPatch" ):
                return visitor.visitPatch(self)
            else:
                return visitor.visitChildren(self)




    def patch(self):

        localctx = TEXTURESParser.PatchContext(self, self._ctx, self.state)
        self.enterRule(localctx, 4, self.RULE_patch)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 46
            self.match(TEXTURESParser.T__5)
            self.state = 47
            self.name()
            self.state = 48
            self.match(TEXTURESParser.T__1)
            self.state = 49
            self.xoffset()
            self.state = 50
            self.match(TEXTURESParser.T__1)
            self.state = 51
            self.yoffset()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class NameContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def QUOTED_STRING(self):
            return self.getToken(TEXTURESParser.QUOTED_STRING, 0)

        def getRuleIndex(self):
            return TEXTURESParser.RULE_name

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterName" ):
                listener.enterName(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitName" ):
                listener.exitName(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitName" ):
                return visitor.visitName(self)
            else:
                return visitor.visitChildren(self)




    def name(self):

        localctx = TEXTURESParser.NameContext(self, self._ctx, self.state)
        self.enterRule(localctx, 6, self.RULE_name)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 53
            self.match(TEXTURESParser.QUOTED_STRING)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class WidthContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def INTEGER_NUMBER(self):
            return self.getToken(TEXTURESParser.INTEGER_NUMBER, 0)

        def getRuleIndex(self):
            return TEXTURESParser.RULE_width

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterWidth" ):
                listener.enterWidth(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitWidth" ):
                listener.exitWidth(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitWidth" ):
                return visitor.visitWidth(self)
            else:
                return visitor.visitChildren(self)




    def width(self):

        localctx = TEXTURESParser.WidthContext(self, self._ctx, self.state)
        self.enterRule(localctx, 8, self.RULE_width)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 55
            self.match(TEXTURESParser.INTEGER_NUMBER)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class HeightContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def INTEGER_NUMBER(self):
            return self.getToken(TEXTURESParser.INTEGER_NUMBER, 0)

        def getRuleIndex(self):
            return TEXTURESParser.RULE_height

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterHeight" ):
                listener.enterHeight(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitHeight" ):
                listener.exitHeight(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitHeight" ):
                return visitor.visitHeight(self)
            else:
                return visitor.visitChildren(self)




    def height(self):

        localctx = TEXTURESParser.HeightContext(self, self._ctx, self.state)
        self.enterRule(localctx, 10, self.RULE_height)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 57
            self.match(TEXTURESParser.INTEGER_NUMBER)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class XoffsetContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def INTEGER_NUMBER(self):
            return self.getToken(TEXTURESParser.INTEGER_NUMBER, 0)

        def getRuleIndex(self):
            return TEXTURESParser.RULE_xoffset

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterXoffset" ):
                listener.enterXoffset(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitXoffset" ):
                listener.exitXoffset(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitXoffset" ):
                return visitor.visitXoffset(self)
            else:
                return visitor.visitChildren(self)




    def xoffset(self):

        localctx = TEXTURESParser.XoffsetContext(self, self._ctx, self.state)
        self.enterRule(localctx, 12, self.RULE_xoffset)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 59
            self.match(TEXTURESParser.INTEGER_NUMBER)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class YoffsetContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def INTEGER_NUMBER(self):
            return self.getToken(TEXTURESParser.INTEGER_NUMBER, 0)

        def getRuleIndex(self):
            return TEXTURESParser.RULE_yoffset

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterYoffset" ):
                listener.enterYoffset(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitYoffset" ):
                listener.exitYoffset(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitYoffset" ):
                return visitor.visitYoffset(self)
            else:
                return visitor.visitChildren(self)




    def yoffset(self):

        localctx = TEXTURESParser.YoffsetContext(self, self._ctx, self.state)
        self.enterRule(localctx, 14, self.RULE_yoffset)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 61
            self.match(TEXTURESParser.INTEGER_NUMBER)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx





