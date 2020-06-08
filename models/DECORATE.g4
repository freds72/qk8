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
   (parent '.')?keyword value
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
  STRING
  ;

variant:
  SINGLE_CHAR
  ;

ticks:
  SIGNED_INTEGER
  ;

name:
  STRING
  ;

function:
  QUOTED_STRING
  ;

parent:
  STRING
  ;

uid:
  INTEGER
  ;

keyword:
  STRING
  ;

value:
  NUMBER
  | BOOLEAN_VALUE
  | QUOTED_STRING
  ;

// lexer
INTEGER
  : DIGIT+
  ;

SIGNED_INTEGER
  : '-'? DIGIT+
  ;

NUMBER
  : '-'? DIGIT+ ('.' DIGIT+)?
  ;

BOOLEAN_VALUE
  : BOOLEAN
  ;

SINGLE_CHAR:
  CHAR
  ;

STRING:
  ('a'..'z'|'A'..'Z'|'0'..'9'|'_')+
  ;

QUOTED_STRING:
  '"' (~('"' | '\\' | '\r' | '\n') )+ '"'
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
