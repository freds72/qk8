# Generated from MAPINFO.g4 by ANTLR 4.8
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
        buf.write("\63\4\2\t\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4")
        buf.write("\b\t\b\3\2\7\2\22\n\2\f\2\16\2\25\13\2\3\2\3\2\3\3\3\3")
        buf.write("\3\3\3\3\3\3\7\3\36\n\3\f\3\16\3!\13\3\3\3\3\3\3\4\3\4")
        buf.write("\3\4\3\4\5\4)\n\4\3\5\3\5\3\6\3\6\3\7\3\7\3\b\3\b\3\b")
        buf.write("\2\2\t\2\4\6\b\n\f\16\2\3\3\2\b\n\2.\2\23\3\2\2\2\4\30")
        buf.write("\3\2\2\2\6$\3\2\2\2\b*\3\2\2\2\n,\3\2\2\2\f.\3\2\2\2\16")
        buf.write("\60\3\2\2\2\20\22\5\4\3\2\21\20\3\2\2\2\22\25\3\2\2\2")
        buf.write("\23\21\3\2\2\2\23\24\3\2\2\2\24\26\3\2\2\2\25\23\3\2\2")
        buf.write("\2\26\27\7\2\2\3\27\3\3\2\2\2\30\31\7\3\2\2\31\32\5\b")
        buf.write("\5\2\32\33\5\f\7\2\33\37\7\4\2\2\34\36\5\6\4\2\35\34\3")
        buf.write("\2\2\2\36!\3\2\2\2\37\35\3\2\2\2\37 \3\2\2\2 \"\3\2\2")
        buf.write("\2!\37\3\2\2\2\"#\7\5\2\2#\5\3\2\2\2$%\5\n\6\2%&\7\6\2")
        buf.write("\2&(\5\16\b\2\')\7\7\2\2(\'\3\2\2\2()\3\2\2\2)\7\3\2\2")
        buf.write("\2*+\7\13\2\2+\t\3\2\2\2,-\7\13\2\2-\13\3\2\2\2./\7\n")
        buf.write("\2\2/\r\3\2\2\2\60\61\t\2\2\2\61\17\3\2\2\2\5\23\37(")
        return buf.getvalue()


class MAPINFOParser ( Parser ):

    grammarFileName = "MAPINFO.g4"

    atn = ATNDeserializer().deserialize(serializedATN())

    decisionsToDFA = [ DFA(ds, i) for i, ds in enumerate(atn.decisionToState) ]

    sharedContextCache = PredictionContextCache()

    literalNames = [ "<INVALID>", "'map'", "'{'", "'}'", "'='", "';'" ]

    symbolicNames = [ "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "NUMBER", "BOOLEAN_VALUE", 
                      "QUOTED_STRING", "KEYWORD", "BLOCKCOMMENT", "LINECOMMENT", 
                      "WS" ]

    RULE_maps = 0
    RULE_block = 1
    RULE_pair = 2
    RULE_maplump = 3
    RULE_keyword = 4
    RULE_label = 5
    RULE_value = 6

    ruleNames =  [ "maps", "block", "pair", "maplump", "keyword", "label", 
                   "value" ]

    EOF = Token.EOF
    T__0=1
    T__1=2
    T__2=3
    T__3=4
    T__4=5
    NUMBER=6
    BOOLEAN_VALUE=7
    QUOTED_STRING=8
    KEYWORD=9
    BLOCKCOMMENT=10
    LINECOMMENT=11
    WS=12

    def __init__(self, input:TokenStream, output:TextIO = sys.stdout):
        super().__init__(input, output)
        self.checkVersion("4.8")
        self._interp = ParserATNSimulator(self, self.atn, self.decisionsToDFA, self.sharedContextCache)
        self._predicates = None




    class MapsContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def EOF(self):
            return self.getToken(MAPINFOParser.EOF, 0)

        def block(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(MAPINFOParser.BlockContext)
            else:
                return self.getTypedRuleContext(MAPINFOParser.BlockContext,i)


        def getRuleIndex(self):
            return MAPINFOParser.RULE_maps

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterMaps" ):
                listener.enterMaps(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitMaps" ):
                listener.exitMaps(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitMaps" ):
                return visitor.visitMaps(self)
            else:
                return visitor.visitChildren(self)




    def maps(self):

        localctx = MAPINFOParser.MapsContext(self, self._ctx, self.state)
        self.enterRule(localctx, 0, self.RULE_maps)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 17
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==MAPINFOParser.T__0:
                self.state = 14
                self.block()
                self.state = 19
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 20
            self.match(MAPINFOParser.EOF)
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

        def maplump(self):
            return self.getTypedRuleContext(MAPINFOParser.MaplumpContext,0)


        def label(self):
            return self.getTypedRuleContext(MAPINFOParser.LabelContext,0)


        def pair(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(MAPINFOParser.PairContext)
            else:
                return self.getTypedRuleContext(MAPINFOParser.PairContext,i)


        def getRuleIndex(self):
            return MAPINFOParser.RULE_block

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

        localctx = MAPINFOParser.BlockContext(self, self._ctx, self.state)
        self.enterRule(localctx, 2, self.RULE_block)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 22
            self.match(MAPINFOParser.T__0)
            self.state = 23
            self.maplump()
            self.state = 24
            self.label()
            self.state = 25
            self.match(MAPINFOParser.T__1)
            self.state = 29
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==MAPINFOParser.KEYWORD:
                self.state = 26
                self.pair()
                self.state = 31
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 32
            self.match(MAPINFOParser.T__2)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class PairContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def keyword(self):
            return self.getTypedRuleContext(MAPINFOParser.KeywordContext,0)


        def value(self):
            return self.getTypedRuleContext(MAPINFOParser.ValueContext,0)


        def getRuleIndex(self):
            return MAPINFOParser.RULE_pair

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterPair" ):
                listener.enterPair(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitPair" ):
                listener.exitPair(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitPair" ):
                return visitor.visitPair(self)
            else:
                return visitor.visitChildren(self)




    def pair(self):

        localctx = MAPINFOParser.PairContext(self, self._ctx, self.state)
        self.enterRule(localctx, 4, self.RULE_pair)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 34
            self.keyword()
            self.state = 35
            self.match(MAPINFOParser.T__3)
            self.state = 36
            self.value()
            self.state = 38
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==MAPINFOParser.T__4:
                self.state = 37
                self.match(MAPINFOParser.T__4)


        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class MaplumpContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def KEYWORD(self):
            return self.getToken(MAPINFOParser.KEYWORD, 0)

        def getRuleIndex(self):
            return MAPINFOParser.RULE_maplump

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterMaplump" ):
                listener.enterMaplump(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitMaplump" ):
                listener.exitMaplump(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitMaplump" ):
                return visitor.visitMaplump(self)
            else:
                return visitor.visitChildren(self)




    def maplump(self):

        localctx = MAPINFOParser.MaplumpContext(self, self._ctx, self.state)
        self.enterRule(localctx, 6, self.RULE_maplump)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 40
            self.match(MAPINFOParser.KEYWORD)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class KeywordContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def KEYWORD(self):
            return self.getToken(MAPINFOParser.KEYWORD, 0)

        def getRuleIndex(self):
            return MAPINFOParser.RULE_keyword

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterKeyword" ):
                listener.enterKeyword(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitKeyword" ):
                listener.exitKeyword(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitKeyword" ):
                return visitor.visitKeyword(self)
            else:
                return visitor.visitChildren(self)




    def keyword(self):

        localctx = MAPINFOParser.KeywordContext(self, self._ctx, self.state)
        self.enterRule(localctx, 8, self.RULE_keyword)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 42
            self.match(MAPINFOParser.KEYWORD)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class LabelContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def QUOTED_STRING(self):
            return self.getToken(MAPINFOParser.QUOTED_STRING, 0)

        def getRuleIndex(self):
            return MAPINFOParser.RULE_label

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterLabel" ):
                listener.enterLabel(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitLabel" ):
                listener.exitLabel(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitLabel" ):
                return visitor.visitLabel(self)
            else:
                return visitor.visitChildren(self)




    def label(self):

        localctx = MAPINFOParser.LabelContext(self, self._ctx, self.state)
        self.enterRule(localctx, 10, self.RULE_label)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 44
            self.match(MAPINFOParser.QUOTED_STRING)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class ValueContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def NUMBER(self):
            return self.getToken(MAPINFOParser.NUMBER, 0)

        def BOOLEAN_VALUE(self):
            return self.getToken(MAPINFOParser.BOOLEAN_VALUE, 0)

        def QUOTED_STRING(self):
            return self.getToken(MAPINFOParser.QUOTED_STRING, 0)

        def getRuleIndex(self):
            return MAPINFOParser.RULE_value

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterValue" ):
                listener.enterValue(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitValue" ):
                listener.exitValue(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitValue" ):
                return visitor.visitValue(self)
            else:
                return visitor.visitChildren(self)




    def value(self):

        localctx = MAPINFOParser.ValueContext(self, self._ctx, self.state)
        self.enterRule(localctx, 12, self.RULE_value)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 46
            _la = self._input.LA(1)
            if not((((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << MAPINFOParser.NUMBER) | (1 << MAPINFOParser.BOOLEAN_VALUE) | (1 << MAPINFOParser.QUOTED_STRING))) != 0)):
                self._errHandler.recoverInline(self)
            else:
                self._errHandler.reportMatch(self)
                self.consume()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx





