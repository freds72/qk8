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
        buf.write("\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\3\17")
        buf.write("@\4\2\t\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b")
        buf.write("\t\b\4\t\t\t\3\2\3\2\7\2\25\n\2\f\2\16\2\30\13\2\3\2\3")
        buf.write("\2\3\3\3\3\3\3\3\3\3\3\7\3!\n\3\f\3\16\3$\13\3\3\3\3\3")
        buf.write("\3\4\3\4\3\4\7\4+\n\4\f\4\16\4.\13\4\3\4\3\4\3\5\3\5\3")
        buf.write("\5\3\5\5\5\66\n\5\3\6\3\6\3\7\3\7\3\b\3\b\3\t\3\t\3\t")
        buf.write("\2\2\n\2\4\6\b\n\f\16\20\2\3\3\2\t\13\2<\2\26\3\2\2\2")
        buf.write("\4\33\3\2\2\2\6\'\3\2\2\2\b\61\3\2\2\2\n\67\3\2\2\2\f")
        buf.write("9\3\2\2\2\16;\3\2\2\2\20=\3\2\2\2\22\25\5\4\3\2\23\25")
        buf.write("\5\6\4\2\24\22\3\2\2\2\24\23\3\2\2\2\25\30\3\2\2\2\26")
        buf.write("\24\3\2\2\2\26\27\3\2\2\2\27\31\3\2\2\2\30\26\3\2\2\2")
        buf.write("\31\32\7\2\2\3\32\3\3\2\2\2\33\34\7\3\2\2\34\35\5\n\6")
        buf.write("\2\35\36\5\16\b\2\36\"\7\4\2\2\37!\5\b\5\2 \37\3\2\2\2")
        buf.write("!$\3\2\2\2\" \3\2\2\2\"#\3\2\2\2#%\3\2\2\2$\"\3\2\2\2")
        buf.write("%&\7\5\2\2&\5\3\2\2\2\'(\7\6\2\2(,\7\4\2\2)+\5\b\5\2*")
        buf.write(")\3\2\2\2+.\3\2\2\2,*\3\2\2\2,-\3\2\2\2-/\3\2\2\2.,\3")
        buf.write("\2\2\2/\60\7\5\2\2\60\7\3\2\2\2\61\62\5\f\7\2\62\63\7")
        buf.write("\7\2\2\63\65\5\20\t\2\64\66\7\b\2\2\65\64\3\2\2\2\65\66")
        buf.write("\3\2\2\2\66\t\3\2\2\2\678\7\f\2\28\13\3\2\2\29:\7\f\2")
        buf.write("\2:\r\3\2\2\2;<\7\13\2\2<\17\3\2\2\2=>\t\2\2\2>\21\3\2")
        buf.write("\2\2\7\24\26\",\65")
        return buf.getvalue()


class MAPINFOParser ( Parser ):

    grammarFileName = "MAPINFO.g4"

    atn = ATNDeserializer().deserialize(serializedATN())

    decisionsToDFA = [ DFA(ds, i) for i, ds in enumerate(atn.decisionToState) ]

    sharedContextCache = PredictionContextCache()

    literalNames = [ "<INVALID>", "'map'", "'{'", "'}'", "'gameinfo'", "'='", 
                     "';'" ]

    symbolicNames = [ "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "NUMBER", "BOOLEAN_VALUE", 
                      "QUOTED_STRING", "KEYWORD", "BLOCKCOMMENT", "LINECOMMENT", 
                      "WS" ]

    RULE_maps = 0
    RULE_mapblock = 1
    RULE_infoblock = 2
    RULE_pair = 3
    RULE_maplump = 4
    RULE_keyword = 5
    RULE_label = 6
    RULE_value = 7

    ruleNames =  [ "maps", "mapblock", "infoblock", "pair", "maplump", "keyword", 
                   "label", "value" ]

    EOF = Token.EOF
    T__0=1
    T__1=2
    T__2=3
    T__3=4
    T__4=5
    T__5=6
    NUMBER=7
    BOOLEAN_VALUE=8
    QUOTED_STRING=9
    KEYWORD=10
    BLOCKCOMMENT=11
    LINECOMMENT=12
    WS=13

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

        def mapblock(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(MAPINFOParser.MapblockContext)
            else:
                return self.getTypedRuleContext(MAPINFOParser.MapblockContext,i)


        def infoblock(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(MAPINFOParser.InfoblockContext)
            else:
                return self.getTypedRuleContext(MAPINFOParser.InfoblockContext,i)


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
            self.state = 20
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==MAPINFOParser.T__0 or _la==MAPINFOParser.T__3:
                self.state = 18
                self._errHandler.sync(self)
                token = self._input.LA(1)
                if token in [MAPINFOParser.T__0]:
                    self.state = 16
                    self.mapblock()
                    pass
                elif token in [MAPINFOParser.T__3]:
                    self.state = 17
                    self.infoblock()
                    pass
                else:
                    raise NoViableAltException(self)

                self.state = 22
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 23
            self.match(MAPINFOParser.EOF)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class MapblockContext(ParserRuleContext):

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
            return MAPINFOParser.RULE_mapblock

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterMapblock" ):
                listener.enterMapblock(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitMapblock" ):
                listener.exitMapblock(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitMapblock" ):
                return visitor.visitMapblock(self)
            else:
                return visitor.visitChildren(self)




    def mapblock(self):

        localctx = MAPINFOParser.MapblockContext(self, self._ctx, self.state)
        self.enterRule(localctx, 2, self.RULE_mapblock)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 25
            self.match(MAPINFOParser.T__0)
            self.state = 26
            self.maplump()
            self.state = 27
            self.label()
            self.state = 28
            self.match(MAPINFOParser.T__1)
            self.state = 32
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==MAPINFOParser.KEYWORD:
                self.state = 29
                self.pair()
                self.state = 34
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 35
            self.match(MAPINFOParser.T__2)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class InfoblockContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def pair(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(MAPINFOParser.PairContext)
            else:
                return self.getTypedRuleContext(MAPINFOParser.PairContext,i)


        def getRuleIndex(self):
            return MAPINFOParser.RULE_infoblock

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterInfoblock" ):
                listener.enterInfoblock(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitInfoblock" ):
                listener.exitInfoblock(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitInfoblock" ):
                return visitor.visitInfoblock(self)
            else:
                return visitor.visitChildren(self)




    def infoblock(self):

        localctx = MAPINFOParser.InfoblockContext(self, self._ctx, self.state)
        self.enterRule(localctx, 4, self.RULE_infoblock)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 37
            self.match(MAPINFOParser.T__3)
            self.state = 38
            self.match(MAPINFOParser.T__1)
            self.state = 42
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==MAPINFOParser.KEYWORD:
                self.state = 39
                self.pair()
                self.state = 44
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 45
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
        self.enterRule(localctx, 6, self.RULE_pair)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 47
            self.keyword()
            self.state = 48
            self.match(MAPINFOParser.T__4)
            self.state = 49
            self.value()
            self.state = 51
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==MAPINFOParser.T__5:
                self.state = 50
                self.match(MAPINFOParser.T__5)


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
        self.enterRule(localctx, 8, self.RULE_maplump)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 53
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
        self.enterRule(localctx, 10, self.RULE_keyword)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 55
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
        self.enterRule(localctx, 12, self.RULE_label)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 57
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
        self.enterRule(localctx, 14, self.RULE_value)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 59
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





