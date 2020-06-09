// set CLASSPATH=antlr-4.8-complete.jar
// java org.antlr.v4.Tool -Dlanguage=Python3 -visitor -listener DECORATE.g4
grammar DECORATE;

// parser
actors:
  block* EOF
  ;

block:
  ('ACTOR'|'actor') name (':' parent)? uid? '{' pair* states? '}'
  ;

pair:
  (parent '.')? keyword value
  ;
  
keyword:
  KEYWORD
  ;

states:
  'States' '{' state_block* '}'
  ;

state_control:
  'Stop' | 
  'Loop'
  ;

state_block:
  name ':' (image variant ticks function?)+ state_control
  ;

image:
  KEYWORD
  ;

variant:
  SINGLE_CHAR
  ;

ticks:
  NUMBER
  ;

name:
  KEYWORD
  ;

function:
  QUOTED_STRING
  ;

uid:
  NUMBER
  ;

parent:
  KEYWORD
  ;

value:
  NUMBER |
  BOOLEAN_VALUE |
  QUOTED_STRING
  ;

// lexer
NUMBER
  : '-'? DIGIT+ ('.' DIGIT+)?
  ;

BOOLEAN_VALUE:
  BOOLEAN
  ;

SINGLE_CHAR:
  CHAR
  ;

QUOTED_STRING:
  '"' (~('"' | '\\' | '\r' | '\n') )+ '"'
  ;

KEYWORD:
  CHAR (CHAR|DIGIT)+
  ;

fragment CHAR:
  ('a'..'z'|'A'..'Z')
  ;

fragment DIGIT
  : ('0'..'9')
  ;

fragment BOOLEAN
  : ('true' | 'false')
  ;

BLOCKCOMMENT
   : '/*' .*? '*/' -> skip
   ;

LINECOMMENT
   : '//' ~ [\r\n]* -> skip
   ;

WS
   : [ \t\n\r] + -> skip
   ;
