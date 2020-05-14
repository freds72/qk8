# Generated from udmf.g4 by ANTLR 4.8
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
        buf.write("\63\4\2\t\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\3")
        buf.write("\2\3\2\3\2\3\2\3\2\7\2\24\n\2\f\2\16\2\27\13\2\3\2\3\2")
        buf.write("\3\3\3\3\3\3\7\3\36\n\3\f\3\16\3!\13\3\3\3\3\3\3\4\3\4")
        buf.write("\3\4\3\4\3\4\3\5\3\5\3\6\3\6\3\6\5\6/\n\6\3\7\3\7\3\7")
        buf.write("\2\2\b\2\4\6\b\n\f\2\3\3\2\b\t\2\60\2\16\3\2\2\2\4\32")
        buf.write("\3\2\2\2\6$\3\2\2\2\b)\3\2\2\2\n.\3\2\2\2\f\60\3\2\2\2")
        buf.write("\16\17\7\3\2\2\17\20\7\4\2\2\20\21\7\f\2\2\21\25\7\5\2")
        buf.write("\2\22\24\5\4\3\2\23\22\3\2\2\2\24\27\3\2\2\2\25\23\3\2")
        buf.write("\2\2\25\26\3\2\2\2\26\30\3\2\2\2\27\25\3\2\2\2\30\31\7")
        buf.write("\2\2\3\31\3\3\2\2\2\32\33\5\b\5\2\33\37\7\6\2\2\34\36")
        buf.write("\5\6\4\2\35\34\3\2\2\2\36!\3\2\2\2\37\35\3\2\2\2\37 \3")
        buf.write("\2\2\2 \"\3\2\2\2!\37\3\2\2\2\"#\7\7\2\2#\5\3\2\2\2$%")
        buf.write("\5\b\5\2%&\7\4\2\2&\'\5\n\6\2\'(\7\5\2\2(\7\3\2\2\2)*")
        buf.write("\7\13\2\2*\t\3\2\2\2+/\5\f\7\2,/\7\n\2\2-/\7\f\2\2.+\3")
        buf.write("\2\2\2.,\3\2\2\2.-\3\2\2\2/\13\3\2\2\2\60\61\t\2\2\2\61")
        buf.write("\r\3\2\2\2\5\25\37.")
        return buf.getvalue()


class udmfParser ( Parser ):

    grammarFileName = "udmf.g4"

    atn = ATNDeserializer().deserialize(serializedATN())

    decisionsToDFA = [ DFA(ds, i) for i, ds in enumerate(atn.decisionToState) ]

    sharedContextCache = PredictionContextCache()

    literalNames = [ "<INVALID>", "'namespace'", "'='", "';'", "'{'", "'}'" ]

    symbolicNames = [ "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "HEX_NUMBER", "INTEGER_NUMBER", 
                      "BOOLEAN_VALUE", "STRING", "QUOTED_STRING", "BLOCKCOMMENT", 
                      "LINECOMMENT", "WS" ]

    RULE_udmf = 0
    RULE_block = 1
    RULE_pair = 2
    RULE_keyword = 3
    RULE_value = 4
    RULE_number = 5

    ruleNames =  [ "udmf", "block", "pair", "keyword", "value", "number" ]

    EOF = Token.EOF
    T__0=1
    T__1=2
    T__2=3
    T__3=4
    T__4=5
    HEX_NUMBER=6
    INTEGER_NUMBER=7
    BOOLEAN_VALUE=8
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




    class UdmfContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def QUOTED_STRING(self):
            return self.getToken(udmfParser.QUOTED_STRING, 0)

        def EOF(self):
            return self.getToken(udmfParser.EOF, 0)

        def block(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(udmfParser.BlockContext)
            else:
                return self.getTypedRuleContext(udmfParser.BlockContext,i)


        def getRuleIndex(self):
            return udmfParser.RULE_udmf

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterUdmf" ):
                listener.enterUdmf(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitUdmf" ):
                listener.exitUdmf(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitUdmf" ):
                return visitor.visitUdmf(self)
            else:
                return visitor.visitChildren(self)




    def udmf(self):

        localctx = udmfParser.UdmfContext(self, self._ctx, self.state)
        self.enterRule(localctx, 0, self.RULE_udmf)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 12
            self.match(udmfParser.T__0)
            self.state = 13
            self.match(udmfParser.T__1)
            self.state = 14
            self.match(udmfParser.QUOTED_STRING)
            self.state = 15
            self.match(udmfParser.T__2)
            self.state = 19
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==udmfParser.STRING:
                self.state = 16
                self.block()
                self.state = 21
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 22
            self.match(udmfParser.EOF)
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

        def keyword(self):
            return self.getTypedRuleContext(udmfParser.KeywordContext,0)


        def pair(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(udmfParser.PairContext)
            else:
                return self.getTypedRuleContext(udmfParser.PairContext,i)


        def getRuleIndex(self):
            return udmfParser.RULE_block

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

        localctx = udmfParser.BlockContext(self, self._ctx, self.state)
        self.enterRule(localctx, 2, self.RULE_block)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 24
            self.keyword()
            self.state = 25
            self.match(udmfParser.T__3)
            self.state = 29
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==udmfParser.STRING:
                self.state = 26
                self.pair()
                self.state = 31
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 32
            self.match(udmfParser.T__4)
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
            return self.getTypedRuleContext(udmfParser.KeywordContext,0)


        def value(self):
            return self.getTypedRuleContext(udmfParser.ValueContext,0)


        def getRuleIndex(self):
            return udmfParser.RULE_pair

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

        localctx = udmfParser.PairContext(self, self._ctx, self.state)
        self.enterRule(localctx, 4, self.RULE_pair)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 34
            self.keyword()
            self.state = 35
            self.match(udmfParser.T__1)
            self.state = 36
            self.value()
            self.state = 37
            self.match(udmfParser.T__2)
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

        def STRING(self):
            return self.getToken(udmfParser.STRING, 0)

        def getRuleIndex(self):
            return udmfParser.RULE_keyword

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

        localctx = udmfParser.KeywordContext(self, self._ctx, self.state)
        self.enterRule(localctx, 6, self.RULE_keyword)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 39
            self.match(udmfParser.STRING)
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

        def number(self):
            return self.getTypedRuleContext(udmfParser.NumberContext,0)


        def BOOLEAN_VALUE(self):
            return self.getToken(udmfParser.BOOLEAN_VALUE, 0)

        def QUOTED_STRING(self):
            return self.getToken(udmfParser.QUOTED_STRING, 0)

        def getRuleIndex(self):
            return udmfParser.RULE_value

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

        localctx = udmfParser.ValueContext(self, self._ctx, self.state)
        self.enterRule(localctx, 8, self.RULE_value)
        try:
            self.state = 44
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [udmfParser.HEX_NUMBER, udmfParser.INTEGER_NUMBER]:
                self.enterOuterAlt(localctx, 1)
                self.state = 41
                self.number()
                pass
            elif token in [udmfParser.BOOLEAN_VALUE]:
                self.enterOuterAlt(localctx, 2)
                self.state = 42
                self.match(udmfParser.BOOLEAN_VALUE)
                pass
            elif token in [udmfParser.QUOTED_STRING]:
                self.enterOuterAlt(localctx, 3)
                self.state = 43
                self.match(udmfParser.QUOTED_STRING)
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


    class NumberContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def HEX_NUMBER(self):
            return self.getToken(udmfParser.HEX_NUMBER, 0)

        def INTEGER_NUMBER(self):
            return self.getToken(udmfParser.INTEGER_NUMBER, 0)

        def getRuleIndex(self):
            return udmfParser.RULE_number

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterNumber" ):
                listener.enterNumber(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitNumber" ):
                listener.exitNumber(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitNumber" ):
                return visitor.visitNumber(self)
            else:
                return visitor.visitChildren(self)




    def number(self):

        localctx = udmfParser.NumberContext(self, self._ctx, self.state)
        self.enterRule(localctx, 10, self.RULE_number)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 46
            _la = self._input.LA(1)
            if not(_la==udmfParser.HEX_NUMBER or _la==udmfParser.INTEGER_NUMBER):
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





