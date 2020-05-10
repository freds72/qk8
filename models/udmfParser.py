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
        buf.write("\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\3\16")
        buf.write("*\4\2\t\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\3\2\7\2\16\n")
        buf.write("\2\f\2\16\2\21\13\2\3\2\3\2\3\3\3\3\3\3\7\3\30\n\3\f\3")
        buf.write("\16\3\33\13\3\3\3\3\3\3\4\3\4\3\4\3\4\3\4\3\5\3\5\5\5")
        buf.write("&\n\5\3\6\3\6\3\6\2\2\7\2\4\6\b\n\2\3\3\2\b\t\2\'\2\17")
        buf.write("\3\2\2\2\4\24\3\2\2\2\6\36\3\2\2\2\b%\3\2\2\2\n\'\3\2")
        buf.write("\2\2\f\16\5\4\3\2\r\f\3\2\2\2\16\21\3\2\2\2\17\r\3\2\2")
        buf.write("\2\17\20\3\2\2\2\20\22\3\2\2\2\21\17\3\2\2\2\22\23\7\2")
        buf.write("\2\3\23\3\3\2\2\2\24\25\7\7\2\2\25\31\7\3\2\2\26\30\5")
        buf.write("\6\4\2\27\26\3\2\2\2\30\33\3\2\2\2\31\27\3\2\2\2\31\32")
        buf.write("\3\2\2\2\32\34\3\2\2\2\33\31\3\2\2\2\34\35\7\4\2\2\35")
        buf.write("\5\3\2\2\2\36\37\7\13\2\2\37 \7\5\2\2 !\5\b\5\2!\"\7\6")
        buf.write("\2\2\"\7\3\2\2\2#&\5\n\6\2$&\7\n\2\2%#\3\2\2\2%$\3\2\2")
        buf.write("\2&\t\3\2\2\2\'(\t\2\2\2(\13\3\2\2\2\5\17\31%")
        return buf.getvalue()


class udmfParser ( Parser ):

    grammarFileName = "udmf.g4"

    atn = ATNDeserializer().deserialize(serializedATN())

    decisionsToDFA = [ DFA(ds, i) for i, ds in enumerate(atn.decisionToState) ]

    sharedContextCache = PredictionContextCache()

    literalNames = [ "<INVALID>", "'{'", "'}'", "'='", "';'" ]

    symbolicNames = [ "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "KEYWORD", "HEX_NUMBER", "INTEGER_NUMBER", 
                      "QUOTED_STRING", "ATTRIBUTE", "BLOCKCOMMENT", "LINECOMMENT", 
                      "WS" ]

    RULE_udmf = 0
    RULE_block = 1
    RULE_pair = 2
    RULE_value = 3
    RULE_number = 4

    ruleNames =  [ "udmf", "block", "pair", "value", "number" ]

    EOF = Token.EOF
    T__0=1
    T__1=2
    T__2=3
    T__3=4
    KEYWORD=5
    HEX_NUMBER=6
    INTEGER_NUMBER=7
    QUOTED_STRING=8
    ATTRIBUTE=9
    BLOCKCOMMENT=10
    LINECOMMENT=11
    WS=12

    def __init__(self, input:TokenStream, output:TextIO = sys.stdout):
        super().__init__(input, output)
        self.checkVersion("4.8")
        self._interp = ParserATNSimulator(self, self.atn, self.decisionsToDFA, self.sharedContextCache)
        self._predicates = None




    class UdmfContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

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
            self.state = 13
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==udmfParser.KEYWORD:
                self.state = 10
                self.block()
                self.state = 15
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 16
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

        def KEYWORD(self):
            return self.getToken(udmfParser.KEYWORD, 0)

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
            self.state = 18
            self.match(udmfParser.KEYWORD)
            self.state = 19
            self.match(udmfParser.T__0)
            self.state = 23
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==udmfParser.ATTRIBUTE:
                self.state = 20
                self.pair()
                self.state = 25
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 26
            self.match(udmfParser.T__1)
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

        def ATTRIBUTE(self):
            return self.getToken(udmfParser.ATTRIBUTE, 0)

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
            self.state = 28
            self.match(udmfParser.ATTRIBUTE)
            self.state = 29
            self.match(udmfParser.T__2)
            self.state = 30
            self.value()
            self.state = 31
            self.match(udmfParser.T__3)
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
        self.enterRule(localctx, 6, self.RULE_value)
        try:
            self.state = 35
            self._errHandler.sync(self)
            token = self._input.LA(1)
            if token in [udmfParser.HEX_NUMBER, udmfParser.INTEGER_NUMBER]:
                self.enterOuterAlt(localctx, 1)
                self.state = 33
                self.number()
                pass
            elif token in [udmfParser.QUOTED_STRING]:
                self.enterOuterAlt(localctx, 2)
                self.state = 34
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
        self.enterRule(localctx, 8, self.RULE_number)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 37
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





