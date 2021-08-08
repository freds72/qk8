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
  (parent '.')? keyword value (',' value)* | ENABLED keyword ';'?
  ;
  
keyword:
  KEYWORD
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
 image variant ticks image_modifier? alpha_modifier? function?
 ;

image_modifier:
  'BRIGHT'|
  'Bright'|
  'bright'
  ;

alpha_modifier:
  ('ALPHA' | 'Alpha' | 'alpha') HEXA
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
  KEYWORD ('(' value (',' value)* ')')?
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
  AZ
  ;

QUOTED_STRING:
  '"' (~('"' | '\\' | '\r' | '\n') )+ '"'
  ;

KEYWORD:
  CHAR (CHAR|DIGIT)*
  ;

HEXA:
  '0x' HEX HEX HEX HEX
  ;

fragment AZ:
  'A'..'Z'
  ;

fragment CHAR:
  ('a'..'z'|'A'..'Z'|'_')
  ;

fragment DIGIT
  : ('0'..'9')
  ;

fragment BOOLEAN
  : ('true' | 'false')
  ;

fragment HEX:
  '0'..'9'|'a'..'f'
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