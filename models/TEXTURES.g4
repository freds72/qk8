// set CLASSPATH=antlr-4.8-complete.jar
// java org.antlr.v4.Tool -Dlanguage=Python3 -visitor -listener TEXTURES.g4
grammar TEXTURES;

// parser
textures:
  block* EOF
  ;

block:
  namespace name ',' width ',' height '{' xscale? yscale? offsets? patch '}'
  ;

namespace:
  STRING
  ;

xscale:
  'XScale' NUMBER
  ;

yscale:
	'YScale' NUMBER
  ;

offsets:
  'Offset' xoffset ',' yoffset
  ;

patch:
  'Patch' name ',' xoffset ',' yoffset
  ;

name:
  QUOTED_STRING
  ;

width:
  NUMBER
  ;
height:
  NUMBER
  ;
xoffset:
  NUMBER
  ;
yoffset:
  NUMBER
  ;

// lexer
NUMBER
  : '-'? DIGIT+ ('.' DIGIT+)?
  ;

STRING:
  ('a'..'z'|'A'..'Z'|'0'..'9'|'_')+
  ;

QUOTED_STRING:
  '"' (~('"' | '\\' | '\r' | '\n') )+ '"'
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
