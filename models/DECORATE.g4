// set CLASSPATH=antlr-4.8-complete.jar
// java org.antlr.v4.Tool -Dlanguage=Python3 -visitor -listener DECORATE.g4
grammar DECORATE;

// parser
actors:
  block* EOF
  ;

block:
  ('ACTOR'|'actor') name (':' parent)? uid? '{' pair* flags* states? '}'
  ;

pair:
  (parent '.')? keyword value args ';'?
  ;
  
keyword:
  KEYWORD
  ;

flags:
  ENABLED keyword ';'?
  ;

states:
  'States' '{' state_block* '}'
  ;

state_block:
  (label|state_command|state_stop|state_loop|state_goto) ';'?
  ;

state_stop:
  'Stop'
  ;
state_loop:
  'Loop'
  ;
state_goto:
  'Goto' KEYWORD
  ;

label:
  KEYWORD ':'
  ;

state_command:
 image variant ticks image_modifier? function?
 ;

image_modifier:
  'BRIGHT'|
  'Bright'|
  'bright'
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

args:
  (',' value)*
  ;

value:
  NUMBER |
  BOOLEAN_VALUE |
  QUOTED_STRING
  ;

// lexer
ENABLED:
  ('-'|'+')
  ;

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
