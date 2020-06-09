# Generated from DECORATE.g4 by ANTLR 4.8
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
        buf.write("\3\u608b\ua72a\u8133\ub9ed\u417c\u3be7\u7786\u5964\3\23")
        buf.write("r\4\2\t\2\4\3\t\3\4\4\t\4\4\5\t\5\4\6\t\6\4\7\t\7\4\b")
        buf.write("\t\b\4\t\t\t\4\n\t\n\4\13\t\13\4\f\t\f\4\r\t\r\4\16\t")
        buf.write("\16\4\17\t\17\4\20\t\20\3\2\7\2\"\n\2\f\2\16\2%\13\2\3")
        buf.write("\2\3\2\3\3\3\3\3\3\3\3\5\3-\n\3\3\3\5\3\60\n\3\3\3\3\3")
        buf.write("\7\3\64\n\3\f\3\16\3\67\13\3\3\3\5\3:\n\3\3\3\3\3\3\4")
        buf.write("\3\4\3\4\5\4A\n\4\3\4\3\4\3\4\3\5\3\5\3\6\3\6\3\6\7\6")
        buf.write("K\n\6\f\6\16\6N\13\6\3\6\3\6\3\7\3\7\3\b\3\b\3\b\3\b\3")
        buf.write("\b\3\b\5\bZ\n\b\6\b\\\n\b\r\b\16\b]\3\b\3\b\3\t\3\t\3")
        buf.write("\n\3\n\3\13\3\13\3\f\3\f\3\r\3\r\3\16\3\16\3\17\3\17\3")
        buf.write("\20\3\20\3\20\2\2\21\2\4\6\b\n\f\16\20\22\24\26\30\32")
        buf.write("\34\36\2\5\3\2\3\4\3\2\n\13\4\2\f\r\17\17\2k\2#\3\2\2")
        buf.write("\2\4(\3\2\2\2\6@\3\2\2\2\bE\3\2\2\2\nG\3\2\2\2\fQ\3\2")
        buf.write("\2\2\16S\3\2\2\2\20a\3\2\2\2\22c\3\2\2\2\24e\3\2\2\2\26")
        buf.write("g\3\2\2\2\30i\3\2\2\2\32k\3\2\2\2\34m\3\2\2\2\36o\3\2")
        buf.write("\2\2 \"\5\4\3\2! \3\2\2\2\"%\3\2\2\2#!\3\2\2\2#$\3\2\2")
        buf.write("\2$&\3\2\2\2%#\3\2\2\2&\'\7\2\2\3\'\3\3\2\2\2()\t\2\2")
        buf.write("\2),\5\26\f\2*+\7\5\2\2+-\5\34\17\2,*\3\2\2\2,-\3\2\2")
        buf.write("\2-/\3\2\2\2.\60\5\32\16\2/.\3\2\2\2/\60\3\2\2\2\60\61")
        buf.write("\3\2\2\2\61\65\7\6\2\2\62\64\5\6\4\2\63\62\3\2\2\2\64")
        buf.write("\67\3\2\2\2\65\63\3\2\2\2\65\66\3\2\2\2\669\3\2\2\2\67")
        buf.write("\65\3\2\2\28:\5\n\6\298\3\2\2\29:\3\2\2\2:;\3\2\2\2;<")
        buf.write("\7\7\2\2<\5\3\2\2\2=>\5\34\17\2>?\7\b\2\2?A\3\2\2\2@=")
        buf.write("\3\2\2\2@A\3\2\2\2AB\3\2\2\2BC\5\b\5\2CD\5\36\20\2D\7")
        buf.write("\3\2\2\2EF\7\20\2\2F\t\3\2\2\2GH\7\t\2\2HL\7\6\2\2IK\5")
        buf.write("\16\b\2JI\3\2\2\2KN\3\2\2\2LJ\3\2\2\2LM\3\2\2\2MO\3\2")
        buf.write("\2\2NL\3\2\2\2OP\7\7\2\2P\13\3\2\2\2QR\t\3\2\2R\r\3\2")
        buf.write("\2\2ST\5\26\f\2T[\7\5\2\2UV\5\20\t\2VW\5\22\n\2WY\5\24")
        buf.write("\13\2XZ\5\30\r\2YX\3\2\2\2YZ\3\2\2\2Z\\\3\2\2\2[U\3\2")
        buf.write("\2\2\\]\3\2\2\2][\3\2\2\2]^\3\2\2\2^_\3\2\2\2_`\5\f\7")
        buf.write("\2`\17\3\2\2\2ab\7\20\2\2b\21\3\2\2\2cd\7\16\2\2d\23\3")
        buf.write("\2\2\2ef\7\f\2\2f\25\3\2\2\2gh\7\20\2\2h\27\3\2\2\2ij")
        buf.write("\7\17\2\2j\31\3\2\2\2kl\7\f\2\2l\33\3\2\2\2mn\7\20\2\2")
        buf.write("n\35\3\2\2\2op\t\4\2\2p\37\3\2\2\2\13#,/\659@LY]")
        return buf.getvalue()


class DECORATEParser ( Parser ):

    grammarFileName = "DECORATE.g4"

    atn = ATNDeserializer().deserialize(serializedATN())

    decisionsToDFA = [ DFA(ds, i) for i, ds in enumerate(atn.decisionToState) ]

    sharedContextCache = PredictionContextCache()

    literalNames = [ "<INVALID>", "'ACTOR'", "'actor'", "':'", "'{'", "'}'", 
                     "'.'", "'States'", "'Stop'", "'Loop'" ]

    symbolicNames = [ "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "<INVALID>", "<INVALID>", 
                      "<INVALID>", "<INVALID>", "NUMBER", "BOOLEAN_VALUE", 
                      "SINGLE_CHAR", "QUOTED_STRING", "KEYWORD", "BLOCKCOMMENT", 
                      "LINECOMMENT", "WS" ]

    RULE_actors = 0
    RULE_block = 1
    RULE_pair = 2
    RULE_keyword = 3
    RULE_states = 4
    RULE_state_control = 5
    RULE_state_block = 6
    RULE_image = 7
    RULE_variant = 8
    RULE_ticks = 9
    RULE_name = 10
    RULE_function = 11
    RULE_uid = 12
    RULE_parent = 13
    RULE_value = 14

    ruleNames =  [ "actors", "block", "pair", "keyword", "states", "state_control", 
                   "state_block", "image", "variant", "ticks", "name", "function", 
                   "uid", "parent", "value" ]

    EOF = Token.EOF
    T__0=1
    T__1=2
    T__2=3
    T__3=4
    T__4=5
    T__5=6
    T__6=7
    T__7=8
    T__8=9
    NUMBER=10
    BOOLEAN_VALUE=11
    SINGLE_CHAR=12
    QUOTED_STRING=13
    KEYWORD=14
    BLOCKCOMMENT=15
    LINECOMMENT=16
    WS=17

    def __init__(self, input:TokenStream, output:TextIO = sys.stdout):
        super().__init__(input, output)
        self.checkVersion("4.8")
        self._interp = ParserATNSimulator(self, self.atn, self.decisionsToDFA, self.sharedContextCache)
        self._predicates = None




    class ActorsContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def EOF(self):
            return self.getToken(DECORATEParser.EOF, 0)

        def block(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(DECORATEParser.BlockContext)
            else:
                return self.getTypedRuleContext(DECORATEParser.BlockContext,i)


        def getRuleIndex(self):
            return DECORATEParser.RULE_actors

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterActors" ):
                listener.enterActors(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitActors" ):
                listener.exitActors(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitActors" ):
                return visitor.visitActors(self)
            else:
                return visitor.visitChildren(self)




    def actors(self):

        localctx = DECORATEParser.ActorsContext(self, self._ctx, self.state)
        self.enterRule(localctx, 0, self.RULE_actors)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 33
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==DECORATEParser.T__0 or _la==DECORATEParser.T__1:
                self.state = 30
                self.block()
                self.state = 35
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 36
            self.match(DECORATEParser.EOF)
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
            return self.getTypedRuleContext(DECORATEParser.NameContext,0)


        def parent(self):
            return self.getTypedRuleContext(DECORATEParser.ParentContext,0)


        def uid(self):
            return self.getTypedRuleContext(DECORATEParser.UidContext,0)


        def pair(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(DECORATEParser.PairContext)
            else:
                return self.getTypedRuleContext(DECORATEParser.PairContext,i)


        def states(self):
            return self.getTypedRuleContext(DECORATEParser.StatesContext,0)


        def getRuleIndex(self):
            return DECORATEParser.RULE_block

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

        localctx = DECORATEParser.BlockContext(self, self._ctx, self.state)
        self.enterRule(localctx, 2, self.RULE_block)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 38
            _la = self._input.LA(1)
            if not(_la==DECORATEParser.T__0 or _la==DECORATEParser.T__1):
                self._errHandler.recoverInline(self)
            else:
                self._errHandler.reportMatch(self)
                self.consume()
            self.state = 39
            self.name()
            self.state = 42
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==DECORATEParser.T__2:
                self.state = 40
                self.match(DECORATEParser.T__2)
                self.state = 41
                self.parent()


            self.state = 45
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==DECORATEParser.NUMBER:
                self.state = 44
                self.uid()


            self.state = 47
            self.match(DECORATEParser.T__3)
            self.state = 51
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==DECORATEParser.KEYWORD:
                self.state = 48
                self.pair()
                self.state = 53
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 55
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            if _la==DECORATEParser.T__6:
                self.state = 54
                self.states()


            self.state = 57
            self.match(DECORATEParser.T__4)
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
            return self.getTypedRuleContext(DECORATEParser.KeywordContext,0)


        def value(self):
            return self.getTypedRuleContext(DECORATEParser.ValueContext,0)


        def parent(self):
            return self.getTypedRuleContext(DECORATEParser.ParentContext,0)


        def getRuleIndex(self):
            return DECORATEParser.RULE_pair

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

        localctx = DECORATEParser.PairContext(self, self._ctx, self.state)
        self.enterRule(localctx, 4, self.RULE_pair)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 62
            self._errHandler.sync(self)
            la_ = self._interp.adaptivePredict(self._input,5,self._ctx)
            if la_ == 1:
                self.state = 59
                self.parent()
                self.state = 60
                self.match(DECORATEParser.T__5)


            self.state = 64
            self.keyword()
            self.state = 65
            self.value()
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
            return self.getToken(DECORATEParser.KEYWORD, 0)

        def getRuleIndex(self):
            return DECORATEParser.RULE_keyword

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

        localctx = DECORATEParser.KeywordContext(self, self._ctx, self.state)
        self.enterRule(localctx, 6, self.RULE_keyword)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 67
            self.match(DECORATEParser.KEYWORD)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class StatesContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def state_block(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(DECORATEParser.State_blockContext)
            else:
                return self.getTypedRuleContext(DECORATEParser.State_blockContext,i)


        def getRuleIndex(self):
            return DECORATEParser.RULE_states

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterStates" ):
                listener.enterStates(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitStates" ):
                listener.exitStates(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitStates" ):
                return visitor.visitStates(self)
            else:
                return visitor.visitChildren(self)




    def states(self):

        localctx = DECORATEParser.StatesContext(self, self._ctx, self.state)
        self.enterRule(localctx, 8, self.RULE_states)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 69
            self.match(DECORATEParser.T__6)
            self.state = 70
            self.match(DECORATEParser.T__3)
            self.state = 74
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while _la==DECORATEParser.KEYWORD:
                self.state = 71
                self.state_block()
                self.state = 76
                self._errHandler.sync(self)
                _la = self._input.LA(1)

            self.state = 77
            self.match(DECORATEParser.T__4)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class State_controlContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser


        def getRuleIndex(self):
            return DECORATEParser.RULE_state_control

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterState_control" ):
                listener.enterState_control(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitState_control" ):
                listener.exitState_control(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitState_control" ):
                return visitor.visitState_control(self)
            else:
                return visitor.visitChildren(self)




    def state_control(self):

        localctx = DECORATEParser.State_controlContext(self, self._ctx, self.state)
        self.enterRule(localctx, 10, self.RULE_state_control)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 79
            _la = self._input.LA(1)
            if not(_la==DECORATEParser.T__7 or _la==DECORATEParser.T__8):
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


    class State_blockContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def name(self):
            return self.getTypedRuleContext(DECORATEParser.NameContext,0)


        def state_control(self):
            return self.getTypedRuleContext(DECORATEParser.State_controlContext,0)


        def image(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(DECORATEParser.ImageContext)
            else:
                return self.getTypedRuleContext(DECORATEParser.ImageContext,i)


        def variant(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(DECORATEParser.VariantContext)
            else:
                return self.getTypedRuleContext(DECORATEParser.VariantContext,i)


        def ticks(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(DECORATEParser.TicksContext)
            else:
                return self.getTypedRuleContext(DECORATEParser.TicksContext,i)


        def function(self, i:int=None):
            if i is None:
                return self.getTypedRuleContexts(DECORATEParser.FunctionContext)
            else:
                return self.getTypedRuleContext(DECORATEParser.FunctionContext,i)


        def getRuleIndex(self):
            return DECORATEParser.RULE_state_block

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterState_block" ):
                listener.enterState_block(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitState_block" ):
                listener.exitState_block(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitState_block" ):
                return visitor.visitState_block(self)
            else:
                return visitor.visitChildren(self)




    def state_block(self):

        localctx = DECORATEParser.State_blockContext(self, self._ctx, self.state)
        self.enterRule(localctx, 12, self.RULE_state_block)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 81
            self.name()
            self.state = 82
            self.match(DECORATEParser.T__2)
            self.state = 89 
            self._errHandler.sync(self)
            _la = self._input.LA(1)
            while True:
                self.state = 83
                self.image()
                self.state = 84
                self.variant()
                self.state = 85
                self.ticks()
                self.state = 87
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if _la==DECORATEParser.QUOTED_STRING:
                    self.state = 86
                    self.function()


                self.state = 91 
                self._errHandler.sync(self)
                _la = self._input.LA(1)
                if not (_la==DECORATEParser.KEYWORD):
                    break

            self.state = 93
            self.state_control()
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class ImageContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def KEYWORD(self):
            return self.getToken(DECORATEParser.KEYWORD, 0)

        def getRuleIndex(self):
            return DECORATEParser.RULE_image

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterImage" ):
                listener.enterImage(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitImage" ):
                listener.exitImage(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitImage" ):
                return visitor.visitImage(self)
            else:
                return visitor.visitChildren(self)




    def image(self):

        localctx = DECORATEParser.ImageContext(self, self._ctx, self.state)
        self.enterRule(localctx, 14, self.RULE_image)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 95
            self.match(DECORATEParser.KEYWORD)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class VariantContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def SINGLE_CHAR(self):
            return self.getToken(DECORATEParser.SINGLE_CHAR, 0)

        def getRuleIndex(self):
            return DECORATEParser.RULE_variant

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterVariant" ):
                listener.enterVariant(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitVariant" ):
                listener.exitVariant(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitVariant" ):
                return visitor.visitVariant(self)
            else:
                return visitor.visitChildren(self)




    def variant(self):

        localctx = DECORATEParser.VariantContext(self, self._ctx, self.state)
        self.enterRule(localctx, 16, self.RULE_variant)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 97
            self.match(DECORATEParser.SINGLE_CHAR)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class TicksContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def NUMBER(self):
            return self.getToken(DECORATEParser.NUMBER, 0)

        def getRuleIndex(self):
            return DECORATEParser.RULE_ticks

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterTicks" ):
                listener.enterTicks(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitTicks" ):
                listener.exitTicks(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitTicks" ):
                return visitor.visitTicks(self)
            else:
                return visitor.visitChildren(self)




    def ticks(self):

        localctx = DECORATEParser.TicksContext(self, self._ctx, self.state)
        self.enterRule(localctx, 18, self.RULE_ticks)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 99
            self.match(DECORATEParser.NUMBER)
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

        def KEYWORD(self):
            return self.getToken(DECORATEParser.KEYWORD, 0)

        def getRuleIndex(self):
            return DECORATEParser.RULE_name

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

        localctx = DECORATEParser.NameContext(self, self._ctx, self.state)
        self.enterRule(localctx, 20, self.RULE_name)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 101
            self.match(DECORATEParser.KEYWORD)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class FunctionContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def QUOTED_STRING(self):
            return self.getToken(DECORATEParser.QUOTED_STRING, 0)

        def getRuleIndex(self):
            return DECORATEParser.RULE_function

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterFunction" ):
                listener.enterFunction(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitFunction" ):
                listener.exitFunction(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitFunction" ):
                return visitor.visitFunction(self)
            else:
                return visitor.visitChildren(self)




    def function(self):

        localctx = DECORATEParser.FunctionContext(self, self._ctx, self.state)
        self.enterRule(localctx, 22, self.RULE_function)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 103
            self.match(DECORATEParser.QUOTED_STRING)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class UidContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def NUMBER(self):
            return self.getToken(DECORATEParser.NUMBER, 0)

        def getRuleIndex(self):
            return DECORATEParser.RULE_uid

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterUid" ):
                listener.enterUid(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitUid" ):
                listener.exitUid(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitUid" ):
                return visitor.visitUid(self)
            else:
                return visitor.visitChildren(self)




    def uid(self):

        localctx = DECORATEParser.UidContext(self, self._ctx, self.state)
        self.enterRule(localctx, 24, self.RULE_uid)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 105
            self.match(DECORATEParser.NUMBER)
        except RecognitionException as re:
            localctx.exception = re
            self._errHandler.reportError(self, re)
            self._errHandler.recover(self, re)
        finally:
            self.exitRule()
        return localctx


    class ParentContext(ParserRuleContext):

        def __init__(self, parser, parent:ParserRuleContext=None, invokingState:int=-1):
            super().__init__(parent, invokingState)
            self.parser = parser

        def KEYWORD(self):
            return self.getToken(DECORATEParser.KEYWORD, 0)

        def getRuleIndex(self):
            return DECORATEParser.RULE_parent

        def enterRule(self, listener:ParseTreeListener):
            if hasattr( listener, "enterParent" ):
                listener.enterParent(self)

        def exitRule(self, listener:ParseTreeListener):
            if hasattr( listener, "exitParent" ):
                listener.exitParent(self)

        def accept(self, visitor:ParseTreeVisitor):
            if hasattr( visitor, "visitParent" ):
                return visitor.visitParent(self)
            else:
                return visitor.visitChildren(self)




    def parent(self):

        localctx = DECORATEParser.ParentContext(self, self._ctx, self.state)
        self.enterRule(localctx, 26, self.RULE_parent)
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 107
            self.match(DECORATEParser.KEYWORD)
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
            return self.getToken(DECORATEParser.NUMBER, 0)

        def BOOLEAN_VALUE(self):
            return self.getToken(DECORATEParser.BOOLEAN_VALUE, 0)

        def QUOTED_STRING(self):
            return self.getToken(DECORATEParser.QUOTED_STRING, 0)

        def getRuleIndex(self):
            return DECORATEParser.RULE_value

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

        localctx = DECORATEParser.ValueContext(self, self._ctx, self.state)
        self.enterRule(localctx, 28, self.RULE_value)
        self._la = 0 # Token type
        try:
            self.enterOuterAlt(localctx, 1)
            self.state = 109
            _la = self._input.LA(1)
            if not((((_la) & ~0x3f) == 0 and ((1 << _la) & ((1 << DECORATEParser.NUMBER) | (1 << DECORATEParser.BOOLEAN_VALUE) | (1 << DECORATEParser.QUOTED_STRING))) != 0)):
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





