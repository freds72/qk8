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
        buf.write("\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\3\17")
        buf.write("T\4\2\t\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b")
        buf.write("\t\b\4\t\t\t\4\n\t\n\4\13\t\13\4\f\t\f\4\r\t\r\3\2\7\2")
        buf.write("\34\n\2\f\2\16\2\37\13\2\3\2\3\2\3\3\3\3\3\3\3\3\3\3\3")
        buf.write("\3\3\3\3\3\5\3+\n\3\3\3\5\3.\n\3\3\3\5\3\61\n\3\3\3\3")
        buf.write("\3\3\3\3\4\3\4\3\5\3\5\3\5\3\6\3\6\3\6\3\7\3\7\3\7\3\7")
        buf.write("\3\7\3\b\3\b\3\b\3\b\3\b\3\b\3\b\3\t\3\t\3\n\3\n\3\13")
        buf.write("\3\13\3\f\3\f\3\r\3\r\3\r\2\2\16\2\4\6\b\n\f\16\20\22")
        buf.write("\24\26\30\2\2\2K\2\35\3\2\2\2\4\"\3\2\2\2\6\65\3\2\2\2")
        buf.write("\b\67\3\2\2\2\n:\3\2\2\2\f=\3\2\2\2\16B\3\2\2\2\20I\3")
        buf.write("\2\2\2\22K\3\2\2\2\24M\3\2\2\2\26O\3\2\2\2\30Q\3\2\2\2")
        buf.write("\32\34\5\4\3\2\33\32\3\2\2\2\34\37\3\2\2\2\35\33\3\2\2")
        buf.write("\2\35\36\3\2\2\2\36 \3\2\2\2\37\35\3\2\2\2 !\7\2\2\3!")
        buf.write("\3\3\2\2\2\"#\5\6\4\2#$\5\20\t\2$%\7\3\2\2%&\5\22\n\2")
        buf.write("&\'\7\3\2\2\'(\5\24\13\2(*\7\4\2\2)+\5\b\5\2*)\3\2\2\2")
        buf.write("*+\3\2\2\2+-\3\2\2\2,.\5\n\6\2-,\3\2\2\2-.\3\2\2\2.\60")
        buf.write("\3\2\2\2/\61\5\f\7\2\60/\3\2\2\2\60\61\3\2\2\2\61\62\3")
        buf.write("\2\2\2\62\63\5\16\b\2\63\64\7\5\2\2\64\5\3\2\2\2\65\66")
        buf.write("\7\13\2\2\66\7\3\2\2\2\678\7\6\2\289\7\n\2\29\t\3\2\2")
        buf.write("\2:;\7\7\2\2;<\7\n\2\2<\13\3\2\2\2=>\7\b\2\2>?\5\26\f")
        buf.write("\2?@\7\3\2\2@A\5\30\r\2A\r\3\2\2\2BC\7\t\2\2CD\5\20\t")
        buf.write("\2DE\7\3\2\2EF\5\26\f\2FG\7\3\2\2GH\5\30\r\2H\17\3\2\2")
        buf.write("\2IJ\7\f\2\2J\21\3\2\2\2KL\7\n\2\2L\23\3\2\2\2MN\7\n\2")
        buf.write("\2N\25\3\2\2\2OP\7\n\2\2P\27\3\2\2\2QR\7\n\2\2R\31\3\2")
        buf.write("\2\2\6\35*-\60")
        return buf.getvalue()


class TEXTURESParser ( Parser ):

    grammarFileName = "TEXTURES.g4"

    atn = ATNDeserializer().deserialize(serializedATN())

    decisionsToDFA = [ DFA(ds, i) for i, ds in enumerate(atn.decisionToState) ]

    sharedContextCache = PredictionContextCache()

    literalNames = [ "<INVALID>", "','", "'{'", "'}'", "'XScale'", "'YScale'", 
                     "'Offset'", "'Patch'" ]

    symbolicNames = [ "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "NUMBER", "STRING", "QUOTED_STRING", "BLOCKCOMMENT", 
                      "LINECOMMENT", "WS" ]

    RULE_textures = 0
    RULE_block = 1
    RULE_namespace = 2
    RULE_xscale = 3
    RULE_yscale = 4
    RULE_offsets = 5
    RULE_patch = 6
    RULE_name = 7
    RULE_width = 8
    RULE_height = 9
    RULE_xoffset = 10
    RULE_yoffset = 11

    ruleNames =  [ "textures", "block", "namespace", "xscale", "yscale", 
                   "offsets", "patch", "name", "width", "height", "xoffset", 
                   "yoffset" ]

    EOF = Token.EOF
    T__0=1
    T__1=2
    T__2=3
    T__3=4
    T__4=5
    T__5=6
    T__6=7
    NUMBER=8
    STRING=9
    QUOTED_STRING=10
    BLOCKCOMMENT=11
    LINECOMMENT=12
    WS=13

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
            self.state = 27
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==TEXTURESParser.STRING:
                self.state = 24
                self.block()
                self.state = 29
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 30
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

        def namespace(self):
            return self.getTypedRuleContext(TEXTURESParser.NamespaceContext,0)


        def name(self):
            return self.getTypedRuleContext(TEXTURESParser.NameContext,0)


        def width(self):
            return self.getTypedRuleContext(TEXTURESParser.WidthContext,0)


        def height(self):
            return self.getTypedRuleContext(TEXTURESParser.HeightContext,0)


        def patch(self):
            return self.getTypedRuleContext(TEXTURESParser.PatchContext,0)


        def xscale(self):
            return self.getTypedRuleContext(TEXTURESParser.XscaleContext,0)


        def yscale(self):
            return self.getTypedRuleContext(TEXTURESParser.YscaleContext,0)


        def offsets(self):
            return self.getTypedRuleContext(TEXTURESParser.OffsetsContext,0)


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
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 32
            self.namespace()
            self.state = 33
            self.name()
            self.state = 34
            self.match(TEXTURESParser.T__0)
            self.state = 35
            self.width()
            self.state = 36
            self.match(TEXTURESParser.T__0)
            self.state = 37
            self.height()
            self.state = 38
            self.match(TEXTURESParser.T__1)
            self.state = 40
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==TEXTURESParser.T__3:
                self.state = 39
                self.xscale()


            self.state = 43
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==TEXTURESParser.T__4:
                self.state = 42
                self.yscale()


            self.state = 46
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==TEXTURESParser.T__5:
                self.state = 45
                self.offsets()


            self.state = 48
            self.patch()
            self.state = 49
            self.match(TEXTURESParser.T__2)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class NamespaceContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def STRING(self):
            return self.getToken(TEXTURESParser.STRING, 0)

        def getRuleIndex(self):
            return TEXTURESParser.RULE_namespace

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterNamespace" ):
                listener.enterNamespace(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitNamespace" ):
                listener.exitNamespace(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitNamespace" ):
                return visitor.visitNamespace(self)
            else:
                return visitor.visitChildren(self)




    def namespace(self):

        localctx = TEXTURESParser.NamespaceContext(self, self._ctx, self.state)
        self.enterRule(localctx, 4, self.RULE_namespace)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 51
            self.match(TEXTURESParser.STRING)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class XscaleContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def NUMBER(self):
            return self.getToken(TEXTURESParser.NUMBER, 0)

        def getRuleIndex(self):
            return TEXTURESParser.RULE_xscale

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterXscale" ):
                listener.enterXscale(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitXscale" ):
                listener.exitXscale(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitXscale" ):
                return visitor.visitXscale(self)
            else:
                return visitor.visitChildren(self)




    def xscale(self):

        localctx = TEXTURESParser.XscaleContext(self, self._ctx, self.state)
        self.enterRule(localctx, 6, self.RULE_xscale)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 53
            self.match(TEXTURESParser.T__3)
            self.state = 54
            self.match(TEXTURESParser.NUMBER)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class YscaleContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def NUMBER(self):
            return self.getToken(TEXTURESParser.NUMBER, 0)

        def getRuleIndex(self):
            return TEXTURESParser.RULE_yscale

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterYscale" ):
                listener.enterYscale(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitYscale" ):
                listener.exitYscale(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitYscale" ):
                return visitor.visitYscale(self)
            else:
                return visitor.visitChildren(self)




    def yscale(self):

        localctx = TEXTURESParser.YscaleContext(self, self._ctx, self.state)
        self.enterRule(localctx, 8, self.RULE_yscale)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 56
            self.match(TEXTURESParser.T__4)
            self.state = 57
            self.match(TEXTURESParser.NUMBER)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class OffsetsContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def xoffset(self):
            return self.getTypedRuleContext(TEXTURESParser.XoffsetContext,0)


        def yoffset(self):
            return self.getTypedRuleContext(TEXTURESParser.YoffsetContext,0)


        def getRuleIndex(self):
            return TEXTURESParser.RULE_offsets

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterOffsets" ):
                listener.enterOffsets(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitOffsets" ):
                listener.exitOffsets(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitOffsets" ):
                return visitor.visitOffsets(self)
            else:
                return visitor.visitChildren(self)




    def offsets(self):

        localctx = TEXTURESParser.OffsetsContext(self, self._ctx, self.state)
        self.enterRule(localctx, 10, self.RULE_offsets)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 59
            self.match(TEXTURESParser.T__5)
            self.state = 60
            self.xoffset()
            self.state = 61
            self.match(TEXTURESParser.T__0)
            self.state = 62
            self.yoffset()
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
        self.enterRule(localctx, 12, self.RULE_patch)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 64
            self.match(TEXTURESParser.T__6)
            self.state = 65
            self.name()
            self.state = 66
            self.match(TEXTURESParser.T__0)
            self.state = 67
            self.xoffset()
            self.state = 68
            self.match(TEXTURESParser.T__0)
            self.state = 69
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
        self.enterRule(localctx, 14, self.RULE_name)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 71
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

        def NUMBER(self):
            return self.getToken(TEXTURESParser.NUMBER, 0)

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
        self.enterRule(localctx, 16, self.RULE_width)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 73
            self.match(TEXTURESParser.NUMBER)
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

        def NUMBER(self):
            return self.getToken(TEXTURESParser.NUMBER, 0)

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
        self.enterRule(localctx, 18, self.RULE_height)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 75
            self.match(TEXTURESParser.NUMBER)
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

        def NUMBER(self):
            return self.getToken(TEXTURESParser.NUMBER, 0)

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
        self.enterRule(localctx, 20, self.RULE_xoffset)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 77
            self.match(TEXTURESParser.NUMBER)
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

        def NUMBER(self):
            return self.getToken(TEXTURESParser.NUMBER, 0)

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
        self.enterRule(localctx, 22, self.RULE_yoffset)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 79
            self.match(TEXTURESParser.NUMBER)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx





