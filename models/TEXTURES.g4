// set CLASSPATH=antlr-4.8-complete.jar
// java org.antlr.v4.Tool -Dlanguage=Python3 -visitor -listener TEXTURES.g4
grammar TEXTURES;

// parser
textures:
  block* EOF
  ;

block:
  'Texture' name ',' height ',' width '{' xscale? yscale? patch '}' |
  'Flat' name ',' height ',' width '{' xscale? yscale? patch '}'
  ;

xscale:
  'XScale' NUMBER
  ;

yscale:
	'YScale' NUMBER
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
